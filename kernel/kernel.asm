
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	80010113          	addi	sp,sp,-2048 # 8000a800 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <junk>:
    8000001a:	a001                	j	8000001a <junk>

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

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	0000a617          	auipc	a2,0xa
    8000004e:	fb660613          	addi	a2,a2,-74 # 8000a000 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	ee478793          	addi	a5,a5,-284 # 80005f40 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffce7a3>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	f9e78793          	addi	a5,a5,-98 # 80001044 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  timerinit();
    800000c4:	00000097          	auipc	ra,0x0
    800000c8:	f58080e7          	jalr	-168(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000cc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000d0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000d2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000d4:	30200073          	mret
}
    800000d8:	60a2                	ld	ra,8(sp)
    800000da:	6402                	ld	s0,0(sp)
    800000dc:	0141                	addi	sp,sp,16
    800000de:	8082                	ret

00000000800000e0 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(struct file *f, int user_dst, uint64 dst, int n)
{
    800000e0:	7159                	addi	sp,sp,-112
    800000e2:	f486                	sd	ra,104(sp)
    800000e4:	f0a2                	sd	s0,96(sp)
    800000e6:	eca6                	sd	s1,88(sp)
    800000e8:	e8ca                	sd	s2,80(sp)
    800000ea:	e4ce                	sd	s3,72(sp)
    800000ec:	e0d2                	sd	s4,64(sp)
    800000ee:	fc56                	sd	s5,56(sp)
    800000f0:	f85a                	sd	s6,48(sp)
    800000f2:	f45e                	sd	s7,40(sp)
    800000f4:	f062                	sd	s8,32(sp)
    800000f6:	ec66                	sd	s9,24(sp)
    800000f8:	e86a                	sd	s10,16(sp)
    800000fa:	1880                	addi	s0,sp,112
    800000fc:	8aae                	mv	s5,a1
    800000fe:	8a32                	mv	s4,a2
    80000100:	89b6                	mv	s3,a3
  uint target;
  int c;
  char cbuf;

  target = n;
    80000102:	00068b1b          	sext.w	s6,a3
  acquire(&cons.lock);
    80000106:	00012517          	auipc	a0,0x12
    8000010a:	6fa50513          	addi	a0,a0,1786 # 80012800 <cons>
    8000010e:	00001097          	auipc	ra,0x1
    80000112:	b1a080e7          	jalr	-1254(ra) # 80000c28 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000116:	00012497          	auipc	s1,0x12
    8000011a:	6ea48493          	addi	s1,s1,1770 # 80012800 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000011e:	00012917          	auipc	s2,0x12
    80000122:	78290913          	addi	s2,s2,1922 # 800128a0 <cons+0xa0>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    80000126:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000128:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000012a:	4ca9                	li	s9,10
  while(n > 0){
    8000012c:	07305863          	blez	s3,8000019c <consoleread+0xbc>
    while(cons.r == cons.w){
    80000130:	0a04a783          	lw	a5,160(s1)
    80000134:	0a44a703          	lw	a4,164(s1)
    80000138:	02f71463          	bne	a4,a5,80000160 <consoleread+0x80>
      if(myproc()->killed){
    8000013c:	00002097          	auipc	ra,0x2
    80000140:	a44080e7          	jalr	-1468(ra) # 80001b80 <myproc>
    80000144:	5d1c                	lw	a5,56(a0)
    80000146:	e7b5                	bnez	a5,800001b2 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    80000148:	85a6                	mv	a1,s1
    8000014a:	854a                	mv	a0,s2
    8000014c:	00002097          	auipc	ra,0x2
    80000150:	20a080e7          	jalr	522(ra) # 80002356 <sleep>
    while(cons.r == cons.w){
    80000154:	0a04a783          	lw	a5,160(s1)
    80000158:	0a44a703          	lw	a4,164(s1)
    8000015c:	fef700e3          	beq	a4,a5,8000013c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80000160:	0017871b          	addiw	a4,a5,1
    80000164:	0ae4a023          	sw	a4,160(s1)
    80000168:	07f7f713          	andi	a4,a5,127
    8000016c:	9726                	add	a4,a4,s1
    8000016e:	02074703          	lbu	a4,32(a4)
    80000172:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000176:	077d0563          	beq	s10,s7,800001e0 <consoleread+0x100>
    cbuf = c;
    8000017a:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000017e:	4685                	li	a3,1
    80000180:	f9f40613          	addi	a2,s0,-97
    80000184:	85d2                	mv	a1,s4
    80000186:	8556                	mv	a0,s5
    80000188:	00002097          	auipc	ra,0x2
    8000018c:	428080e7          	jalr	1064(ra) # 800025b0 <either_copyout>
    80000190:	01850663          	beq	a0,s8,8000019c <consoleread+0xbc>
    dst++;
    80000194:	0a05                	addi	s4,s4,1
    --n;
    80000196:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000198:	f99d1ae3          	bne	s10,s9,8000012c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000019c:	00012517          	auipc	a0,0x12
    800001a0:	66450513          	addi	a0,a0,1636 # 80012800 <cons>
    800001a4:	00001097          	auipc	ra,0x1
    800001a8:	af4080e7          	jalr	-1292(ra) # 80000c98 <release>

  return target - n;
    800001ac:	413b053b          	subw	a0,s6,s3
    800001b0:	a811                	j	800001c4 <consoleread+0xe4>
        release(&cons.lock);
    800001b2:	00012517          	auipc	a0,0x12
    800001b6:	64e50513          	addi	a0,a0,1614 # 80012800 <cons>
    800001ba:	00001097          	auipc	ra,0x1
    800001be:	ade080e7          	jalr	-1314(ra) # 80000c98 <release>
        return -1;
    800001c2:	557d                	li	a0,-1
}
    800001c4:	70a6                	ld	ra,104(sp)
    800001c6:	7406                	ld	s0,96(sp)
    800001c8:	64e6                	ld	s1,88(sp)
    800001ca:	6946                	ld	s2,80(sp)
    800001cc:	69a6                	ld	s3,72(sp)
    800001ce:	6a06                	ld	s4,64(sp)
    800001d0:	7ae2                	ld	s5,56(sp)
    800001d2:	7b42                	ld	s6,48(sp)
    800001d4:	7ba2                	ld	s7,40(sp)
    800001d6:	7c02                	ld	s8,32(sp)
    800001d8:	6ce2                	ld	s9,24(sp)
    800001da:	6d42                	ld	s10,16(sp)
    800001dc:	6165                	addi	sp,sp,112
    800001de:	8082                	ret
      if(n < target){
    800001e0:	0009871b          	sext.w	a4,s3
    800001e4:	fb677ce3          	bgeu	a4,s6,8000019c <consoleread+0xbc>
        cons.r--;
    800001e8:	00012717          	auipc	a4,0x12
    800001ec:	6af72c23          	sw	a5,1720(a4) # 800128a0 <cons+0xa0>
    800001f0:	b775                	j	8000019c <consoleread+0xbc>

00000000800001f2 <consputc>:
  if(panicked){
    800001f2:	00030797          	auipc	a5,0x30
    800001f6:	e2e7a783          	lw	a5,-466(a5) # 80030020 <panicked>
    800001fa:	c391                	beqz	a5,800001fe <consputc+0xc>
    for(;;)
    800001fc:	a001                	j	800001fc <consputc+0xa>
{
    800001fe:	1141                	addi	sp,sp,-16
    80000200:	e406                	sd	ra,8(sp)
    80000202:	e022                	sd	s0,0(sp)
    80000204:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000206:	10000793          	li	a5,256
    8000020a:	00f50a63          	beq	a0,a5,8000021e <consputc+0x2c>
    uartputc(c);
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	5dc080e7          	jalr	1500(ra) # 800007ea <uartputc>
}
    80000216:	60a2                	ld	ra,8(sp)
    80000218:	6402                	ld	s0,0(sp)
    8000021a:	0141                	addi	sp,sp,16
    8000021c:	8082                	ret
    uartputc('\b'); uartputc(' '); uartputc('\b');
    8000021e:	4521                	li	a0,8
    80000220:	00000097          	auipc	ra,0x0
    80000224:	5ca080e7          	jalr	1482(ra) # 800007ea <uartputc>
    80000228:	02000513          	li	a0,32
    8000022c:	00000097          	auipc	ra,0x0
    80000230:	5be080e7          	jalr	1470(ra) # 800007ea <uartputc>
    80000234:	4521                	li	a0,8
    80000236:	00000097          	auipc	ra,0x0
    8000023a:	5b4080e7          	jalr	1460(ra) # 800007ea <uartputc>
    8000023e:	bfe1                	j	80000216 <consputc+0x24>

0000000080000240 <consolewrite>:
{
    80000240:	715d                	addi	sp,sp,-80
    80000242:	e486                	sd	ra,72(sp)
    80000244:	e0a2                	sd	s0,64(sp)
    80000246:	fc26                	sd	s1,56(sp)
    80000248:	f84a                	sd	s2,48(sp)
    8000024a:	f44e                	sd	s3,40(sp)
    8000024c:	f052                	sd	s4,32(sp)
    8000024e:	ec56                	sd	s5,24(sp)
    80000250:	0880                	addi	s0,sp,80
    80000252:	89ae                	mv	s3,a1
    80000254:	84b2                	mv	s1,a2
    80000256:	8ab6                	mv	s5,a3
  acquire(&cons.lock);
    80000258:	00012517          	auipc	a0,0x12
    8000025c:	5a850513          	addi	a0,a0,1448 # 80012800 <cons>
    80000260:	00001097          	auipc	ra,0x1
    80000264:	9c8080e7          	jalr	-1592(ra) # 80000c28 <acquire>
  for(i = 0; i < n; i++){
    80000268:	03505e63          	blez	s5,800002a4 <consolewrite+0x64>
    8000026c:	00148913          	addi	s2,s1,1
    80000270:	fffa879b          	addiw	a5,s5,-1
    80000274:	1782                	slli	a5,a5,0x20
    80000276:	9381                	srli	a5,a5,0x20
    80000278:	993e                	add	s2,s2,a5
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000027a:	5a7d                	li	s4,-1
    8000027c:	4685                	li	a3,1
    8000027e:	8626                	mv	a2,s1
    80000280:	85ce                	mv	a1,s3
    80000282:	fbf40513          	addi	a0,s0,-65
    80000286:	00002097          	auipc	ra,0x2
    8000028a:	380080e7          	jalr	896(ra) # 80002606 <either_copyin>
    8000028e:	01450b63          	beq	a0,s4,800002a4 <consolewrite+0x64>
    consputc(c);
    80000292:	fbf44503          	lbu	a0,-65(s0)
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	f5c080e7          	jalr	-164(ra) # 800001f2 <consputc>
  for(i = 0; i < n; i++){
    8000029e:	0485                	addi	s1,s1,1
    800002a0:	fd249ee3          	bne	s1,s2,8000027c <consolewrite+0x3c>
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	55c50513          	addi	a0,a0,1372 # 80012800 <cons>
    800002ac:	00001097          	auipc	ra,0x1
    800002b0:	9ec080e7          	jalr	-1556(ra) # 80000c98 <release>
}
    800002b4:	8556                	mv	a0,s5
    800002b6:	60a6                	ld	ra,72(sp)
    800002b8:	6406                	ld	s0,64(sp)
    800002ba:	74e2                	ld	s1,56(sp)
    800002bc:	7942                	ld	s2,48(sp)
    800002be:	79a2                	ld	s3,40(sp)
    800002c0:	7a02                	ld	s4,32(sp)
    800002c2:	6ae2                	ld	s5,24(sp)
    800002c4:	6161                	addi	sp,sp,80
    800002c6:	8082                	ret

00000000800002c8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	e04a                	sd	s2,0(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00012517          	auipc	a0,0x12
    800002da:	52a50513          	addi	a0,a0,1322 # 80012800 <cons>
    800002de:	00001097          	auipc	ra,0x1
    800002e2:	94a080e7          	jalr	-1718(ra) # 80000c28 <acquire>

  switch(c){
    800002e6:	47d5                	li	a5,21
    800002e8:	0af48663          	beq	s1,a5,80000394 <consoleintr+0xcc>
    800002ec:	0297ca63          	blt	a5,s1,80000320 <consoleintr+0x58>
    800002f0:	47a1                	li	a5,8
    800002f2:	0ef48763          	beq	s1,a5,800003e0 <consoleintr+0x118>
    800002f6:	47c1                	li	a5,16
    800002f8:	10f49a63          	bne	s1,a5,8000040c <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002fc:	00002097          	auipc	ra,0x2
    80000300:	360080e7          	jalr	864(ra) # 8000265c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000304:	00012517          	auipc	a0,0x12
    80000308:	4fc50513          	addi	a0,a0,1276 # 80012800 <cons>
    8000030c:	00001097          	auipc	ra,0x1
    80000310:	98c080e7          	jalr	-1652(ra) # 80000c98 <release>
}
    80000314:	60e2                	ld	ra,24(sp)
    80000316:	6442                	ld	s0,16(sp)
    80000318:	64a2                	ld	s1,8(sp)
    8000031a:	6902                	ld	s2,0(sp)
    8000031c:	6105                	addi	sp,sp,32
    8000031e:	8082                	ret
  switch(c){
    80000320:	07f00793          	li	a5,127
    80000324:	0af48e63          	beq	s1,a5,800003e0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000328:	00012717          	auipc	a4,0x12
    8000032c:	4d870713          	addi	a4,a4,1240 # 80012800 <cons>
    80000330:	0a872783          	lw	a5,168(a4)
    80000334:	0a072703          	lw	a4,160(a4)
    80000338:	9f99                	subw	a5,a5,a4
    8000033a:	07f00713          	li	a4,127
    8000033e:	fcf763e3          	bltu	a4,a5,80000304 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000342:	47b5                	li	a5,13
    80000344:	0cf48763          	beq	s1,a5,80000412 <consoleintr+0x14a>
      consputc(c);
    80000348:	8526                	mv	a0,s1
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	ea8080e7          	jalr	-344(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000352:	00012797          	auipc	a5,0x12
    80000356:	4ae78793          	addi	a5,a5,1198 # 80012800 <cons>
    8000035a:	0a87a703          	lw	a4,168(a5)
    8000035e:	0017069b          	addiw	a3,a4,1
    80000362:	0006861b          	sext.w	a2,a3
    80000366:	0ad7a423          	sw	a3,168(a5)
    8000036a:	07f77713          	andi	a4,a4,127
    8000036e:	97ba                	add	a5,a5,a4
    80000370:	02978023          	sb	s1,32(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000374:	47a9                	li	a5,10
    80000376:	0cf48563          	beq	s1,a5,80000440 <consoleintr+0x178>
    8000037a:	4791                	li	a5,4
    8000037c:	0cf48263          	beq	s1,a5,80000440 <consoleintr+0x178>
    80000380:	00012797          	auipc	a5,0x12
    80000384:	5207a783          	lw	a5,1312(a5) # 800128a0 <cons+0xa0>
    80000388:	0807879b          	addiw	a5,a5,128
    8000038c:	f6f61ce3          	bne	a2,a5,80000304 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000390:	863e                	mv	a2,a5
    80000392:	a07d                	j	80000440 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000394:	00012717          	auipc	a4,0x12
    80000398:	46c70713          	addi	a4,a4,1132 # 80012800 <cons>
    8000039c:	0a872783          	lw	a5,168(a4)
    800003a0:	0a472703          	lw	a4,164(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a4:	00012497          	auipc	s1,0x12
    800003a8:	45c48493          	addi	s1,s1,1116 # 80012800 <cons>
    while(cons.e != cons.w &&
    800003ac:	4929                	li	s2,10
    800003ae:	f4f70be3          	beq	a4,a5,80000304 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b2:	37fd                	addiw	a5,a5,-1
    800003b4:	07f7f713          	andi	a4,a5,127
    800003b8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ba:	02074703          	lbu	a4,32(a4)
    800003be:	f52703e3          	beq	a4,s2,80000304 <consoleintr+0x3c>
      cons.e--;
    800003c2:	0af4a423          	sw	a5,168(s1)
      consputc(BACKSPACE);
    800003c6:	10000513          	li	a0,256
    800003ca:	00000097          	auipc	ra,0x0
    800003ce:	e28080e7          	jalr	-472(ra) # 800001f2 <consputc>
    while(cons.e != cons.w &&
    800003d2:	0a84a783          	lw	a5,168(s1)
    800003d6:	0a44a703          	lw	a4,164(s1)
    800003da:	fcf71ce3          	bne	a4,a5,800003b2 <consoleintr+0xea>
    800003de:	b71d                	j	80000304 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003e0:	00012717          	auipc	a4,0x12
    800003e4:	42070713          	addi	a4,a4,1056 # 80012800 <cons>
    800003e8:	0a872783          	lw	a5,168(a4)
    800003ec:	0a472703          	lw	a4,164(a4)
    800003f0:	f0f70ae3          	beq	a4,a5,80000304 <consoleintr+0x3c>
      cons.e--;
    800003f4:	37fd                	addiw	a5,a5,-1
    800003f6:	00012717          	auipc	a4,0x12
    800003fa:	4af72923          	sw	a5,1202(a4) # 800128a8 <cons+0xa8>
      consputc(BACKSPACE);
    800003fe:	10000513          	li	a0,256
    80000402:	00000097          	auipc	ra,0x0
    80000406:	df0080e7          	jalr	-528(ra) # 800001f2 <consputc>
    8000040a:	bded                	j	80000304 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000040c:	ee048ce3          	beqz	s1,80000304 <consoleintr+0x3c>
    80000410:	bf21                	j	80000328 <consoleintr+0x60>
      consputc(c);
    80000412:	4529                	li	a0,10
    80000414:	00000097          	auipc	ra,0x0
    80000418:	dde080e7          	jalr	-546(ra) # 800001f2 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000041c:	00012797          	auipc	a5,0x12
    80000420:	3e478793          	addi	a5,a5,996 # 80012800 <cons>
    80000424:	0a87a703          	lw	a4,168(a5)
    80000428:	0017069b          	addiw	a3,a4,1
    8000042c:	0006861b          	sext.w	a2,a3
    80000430:	0ad7a423          	sw	a3,168(a5)
    80000434:	07f77713          	andi	a4,a4,127
    80000438:	97ba                	add	a5,a5,a4
    8000043a:	4729                	li	a4,10
    8000043c:	02e78023          	sb	a4,32(a5)
        cons.w = cons.e;
    80000440:	00012797          	auipc	a5,0x12
    80000444:	46c7a223          	sw	a2,1124(a5) # 800128a4 <cons+0xa4>
        wakeup(&cons.r);
    80000448:	00012517          	auipc	a0,0x12
    8000044c:	45850513          	addi	a0,a0,1112 # 800128a0 <cons+0xa0>
    80000450:	00002097          	auipc	ra,0x2
    80000454:	086080e7          	jalr	134(ra) # 800024d6 <wakeup>
    80000458:	b575                	j	80000304 <consoleintr+0x3c>

000000008000045a <consoleinit>:

void
consoleinit(void)
{
    8000045a:	1141                	addi	sp,sp,-16
    8000045c:	e406                	sd	ra,8(sp)
    8000045e:	e022                	sd	s0,0(sp)
    80000460:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000462:	00008597          	auipc	a1,0x8
    80000466:	cb658593          	addi	a1,a1,-842 # 80008118 <userret+0x88>
    8000046a:	00012517          	auipc	a0,0x12
    8000046e:	39650513          	addi	a0,a0,918 # 80012800 <cons>
    80000472:	00000097          	auipc	ra,0x0
    80000476:	668080e7          	jalr	1640(ra) # 80000ada <initlock>

  uartinit();
    8000047a:	00000097          	auipc	ra,0x0
    8000047e:	33a080e7          	jalr	826(ra) # 800007b4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000482:	00028797          	auipc	a5,0x28
    80000486:	0b678793          	addi	a5,a5,182 # 80028538 <devsw>
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c5670713          	addi	a4,a4,-938 # 800000e0 <consoleread>
    80000492:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000494:	00000717          	auipc	a4,0x0
    80000498:	dac70713          	addi	a4,a4,-596 # 80000240 <consolewrite>
    8000049c:	ef98                	sd	a4,24(a5)
}
    8000049e:	60a2                	ld	ra,8(sp)
    800004a0:	6402                	ld	s0,0(sp)
    800004a2:	0141                	addi	sp,sp,16
    800004a4:	8082                	ret

00000000800004a6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a6:	7179                	addi	sp,sp,-48
    800004a8:	f406                	sd	ra,40(sp)
    800004aa:	f022                	sd	s0,32(sp)
    800004ac:	ec26                	sd	s1,24(sp)
    800004ae:	e84a                	sd	s2,16(sp)
    800004b0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004b2:	c219                	beqz	a2,800004b8 <printint+0x12>
    800004b4:	08054663          	bltz	a0,80000540 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b8:	2501                	sext.w	a0,a0
    800004ba:	4881                	li	a7,0
    800004bc:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004c0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004c2:	2581                	sext.w	a1,a1
    800004c4:	00008617          	auipc	a2,0x8
    800004c8:	5fc60613          	addi	a2,a2,1532 # 80008ac0 <digits>
    800004cc:	883a                	mv	a6,a4
    800004ce:	2705                	addiw	a4,a4,1
    800004d0:	02b577bb          	remuw	a5,a0,a1
    800004d4:	1782                	slli	a5,a5,0x20
    800004d6:	9381                	srli	a5,a5,0x20
    800004d8:	97b2                	add	a5,a5,a2
    800004da:	0007c783          	lbu	a5,0(a5)
    800004de:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004e2:	0005079b          	sext.w	a5,a0
    800004e6:	02b5553b          	divuw	a0,a0,a1
    800004ea:	0685                	addi	a3,a3,1
    800004ec:	feb7f0e3          	bgeu	a5,a1,800004cc <printint+0x26>

  if(sign)
    800004f0:	00088b63          	beqz	a7,80000506 <printint+0x60>
    buf[i++] = '-';
    800004f4:	fe040793          	addi	a5,s0,-32
    800004f8:	973e                	add	a4,a4,a5
    800004fa:	02d00793          	li	a5,45
    800004fe:	fef70823          	sb	a5,-16(a4)
    80000502:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000506:	02e05763          	blez	a4,80000534 <printint+0x8e>
    8000050a:	fd040793          	addi	a5,s0,-48
    8000050e:	00e784b3          	add	s1,a5,a4
    80000512:	fff78913          	addi	s2,a5,-1
    80000516:	993a                	add	s2,s2,a4
    80000518:	377d                	addiw	a4,a4,-1
    8000051a:	1702                	slli	a4,a4,0x20
    8000051c:	9301                	srli	a4,a4,0x20
    8000051e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000522:	fff4c503          	lbu	a0,-1(s1)
    80000526:	00000097          	auipc	ra,0x0
    8000052a:	ccc080e7          	jalr	-820(ra) # 800001f2 <consputc>
  while(--i >= 0)
    8000052e:	14fd                	addi	s1,s1,-1
    80000530:	ff2499e3          	bne	s1,s2,80000522 <printint+0x7c>
}
    80000534:	70a2                	ld	ra,40(sp)
    80000536:	7402                	ld	s0,32(sp)
    80000538:	64e2                	ld	s1,24(sp)
    8000053a:	6942                	ld	s2,16(sp)
    8000053c:	6145                	addi	sp,sp,48
    8000053e:	8082                	ret
    x = -xx;
    80000540:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000544:	4885                	li	a7,1
    x = -xx;
    80000546:	bf9d                	j	800004bc <printint+0x16>

0000000080000548 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000548:	1101                	addi	sp,sp,-32
    8000054a:	ec06                	sd	ra,24(sp)
    8000054c:	e822                	sd	s0,16(sp)
    8000054e:	e426                	sd	s1,8(sp)
    80000550:	1000                	addi	s0,sp,32
    80000552:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000554:	00012797          	auipc	a5,0x12
    80000558:	3607ae23          	sw	zero,892(a5) # 800128d0 <pr+0x20>
  printf("PANIC: ");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	bc450513          	addi	a0,a0,-1084 # 80008120 <userret+0x90>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	03e080e7          	jalr	62(ra) # 800005a2 <printf>
  printf(s);
    8000056c:	8526                	mv	a0,s1
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	034080e7          	jalr	52(ra) # 800005a2 <printf>
  printf("\n");
    80000576:	00008517          	auipc	a0,0x8
    8000057a:	d1a50513          	addi	a0,a0,-742 # 80008290 <userret+0x200>
    8000057e:	00000097          	auipc	ra,0x0
    80000582:	024080e7          	jalr	36(ra) # 800005a2 <printf>
  printf("HINT: restart xv6 using 'make qemu-gdb', type 'b panic' (to set breakpoint in panic) in the gdb window, followed by 'c' (continue), and when the kernel hits the breakpoint, type 'bt' to get a backtrace\n");
    80000586:	00008517          	auipc	a0,0x8
    8000058a:	ba250513          	addi	a0,a0,-1118 # 80008128 <userret+0x98>
    8000058e:	00000097          	auipc	ra,0x0
    80000592:	014080e7          	jalr	20(ra) # 800005a2 <printf>
  panicked = 1; // freeze other CPUs
    80000596:	4785                	li	a5,1
    80000598:	00030717          	auipc	a4,0x30
    8000059c:	a8f72423          	sw	a5,-1400(a4) # 80030020 <panicked>
  for(;;)
    800005a0:	a001                	j	800005a0 <panic+0x58>

00000000800005a2 <printf>:
{
    800005a2:	7131                	addi	sp,sp,-192
    800005a4:	fc86                	sd	ra,120(sp)
    800005a6:	f8a2                	sd	s0,112(sp)
    800005a8:	f4a6                	sd	s1,104(sp)
    800005aa:	f0ca                	sd	s2,96(sp)
    800005ac:	ecce                	sd	s3,88(sp)
    800005ae:	e8d2                	sd	s4,80(sp)
    800005b0:	e4d6                	sd	s5,72(sp)
    800005b2:	e0da                	sd	s6,64(sp)
    800005b4:	fc5e                	sd	s7,56(sp)
    800005b6:	f862                	sd	s8,48(sp)
    800005b8:	f466                	sd	s9,40(sp)
    800005ba:	f06a                	sd	s10,32(sp)
    800005bc:	ec6e                	sd	s11,24(sp)
    800005be:	0100                	addi	s0,sp,128
    800005c0:	8a2a                	mv	s4,a0
    800005c2:	e40c                	sd	a1,8(s0)
    800005c4:	e810                	sd	a2,16(s0)
    800005c6:	ec14                	sd	a3,24(s0)
    800005c8:	f018                	sd	a4,32(s0)
    800005ca:	f41c                	sd	a5,40(s0)
    800005cc:	03043823          	sd	a6,48(s0)
    800005d0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005d4:	00012d97          	auipc	s11,0x12
    800005d8:	2fcdad83          	lw	s11,764(s11) # 800128d0 <pr+0x20>
  if(locking)
    800005dc:	020d9b63          	bnez	s11,80000612 <printf+0x70>
  if (fmt == 0)
    800005e0:	040a0263          	beqz	s4,80000624 <printf+0x82>
  va_start(ap, fmt);
    800005e4:	00840793          	addi	a5,s0,8
    800005e8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005ec:	000a4503          	lbu	a0,0(s4)
    800005f0:	14050f63          	beqz	a0,8000074e <printf+0x1ac>
    800005f4:	4981                	li	s3,0
    if(c != '%'){
    800005f6:	02500a93          	li	s5,37
    switch(c){
    800005fa:	07000b93          	li	s7,112
  consputc('x');
    800005fe:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000600:	00008b17          	auipc	s6,0x8
    80000604:	4c0b0b13          	addi	s6,s6,1216 # 80008ac0 <digits>
    switch(c){
    80000608:	07300c93          	li	s9,115
    8000060c:	06400c13          	li	s8,100
    80000610:	a82d                	j	8000064a <printf+0xa8>
    acquire(&pr.lock);
    80000612:	00012517          	auipc	a0,0x12
    80000616:	29e50513          	addi	a0,a0,670 # 800128b0 <pr>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	60e080e7          	jalr	1550(ra) # 80000c28 <acquire>
    80000622:	bf7d                	j	800005e0 <printf+0x3e>
    panic("null fmt");
    80000624:	00008517          	auipc	a0,0x8
    80000628:	bdc50513          	addi	a0,a0,-1060 # 80008200 <userret+0x170>
    8000062c:	00000097          	auipc	ra,0x0
    80000630:	f1c080e7          	jalr	-228(ra) # 80000548 <panic>
      consputc(c);
    80000634:	00000097          	auipc	ra,0x0
    80000638:	bbe080e7          	jalr	-1090(ra) # 800001f2 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000063c:	2985                	addiw	s3,s3,1
    8000063e:	013a07b3          	add	a5,s4,s3
    80000642:	0007c503          	lbu	a0,0(a5)
    80000646:	10050463          	beqz	a0,8000074e <printf+0x1ac>
    if(c != '%'){
    8000064a:	ff5515e3          	bne	a0,s5,80000634 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000064e:	2985                	addiw	s3,s3,1
    80000650:	013a07b3          	add	a5,s4,s3
    80000654:	0007c783          	lbu	a5,0(a5)
    80000658:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000065c:	cbed                	beqz	a5,8000074e <printf+0x1ac>
    switch(c){
    8000065e:	05778a63          	beq	a5,s7,800006b2 <printf+0x110>
    80000662:	02fbf663          	bgeu	s7,a5,8000068e <printf+0xec>
    80000666:	09978863          	beq	a5,s9,800006f6 <printf+0x154>
    8000066a:	07800713          	li	a4,120
    8000066e:	0ce79563          	bne	a5,a4,80000738 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000672:	f8843783          	ld	a5,-120(s0)
    80000676:	00878713          	addi	a4,a5,8
    8000067a:	f8e43423          	sd	a4,-120(s0)
    8000067e:	4605                	li	a2,1
    80000680:	85ea                	mv	a1,s10
    80000682:	4388                	lw	a0,0(a5)
    80000684:	00000097          	auipc	ra,0x0
    80000688:	e22080e7          	jalr	-478(ra) # 800004a6 <printint>
      break;
    8000068c:	bf45                	j	8000063c <printf+0x9a>
    switch(c){
    8000068e:	09578f63          	beq	a5,s5,8000072c <printf+0x18a>
    80000692:	0b879363          	bne	a5,s8,80000738 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4605                	li	a2,1
    800006a4:	45a9                	li	a1,10
    800006a6:	4388                	lw	a0,0(a5)
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	dfe080e7          	jalr	-514(ra) # 800004a6 <printint>
      break;
    800006b0:	b771                	j	8000063c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006c2:	03000513          	li	a0,48
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	b2c080e7          	jalr	-1236(ra) # 800001f2 <consputc>
  consputc('x');
    800006ce:	07800513          	li	a0,120
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	b20080e7          	jalr	-1248(ra) # 800001f2 <consputc>
    800006da:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006dc:	03c95793          	srli	a5,s2,0x3c
    800006e0:	97da                	add	a5,a5,s6
    800006e2:	0007c503          	lbu	a0,0(a5)
    800006e6:	00000097          	auipc	ra,0x0
    800006ea:	b0c080e7          	jalr	-1268(ra) # 800001f2 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ee:	0912                	slli	s2,s2,0x4
    800006f0:	34fd                	addiw	s1,s1,-1
    800006f2:	f4ed                	bnez	s1,800006dc <printf+0x13a>
    800006f4:	b7a1                	j	8000063c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006f6:	f8843783          	ld	a5,-120(s0)
    800006fa:	00878713          	addi	a4,a5,8
    800006fe:	f8e43423          	sd	a4,-120(s0)
    80000702:	6384                	ld	s1,0(a5)
    80000704:	cc89                	beqz	s1,8000071e <printf+0x17c>
      for(; *s; s++)
    80000706:	0004c503          	lbu	a0,0(s1)
    8000070a:	d90d                	beqz	a0,8000063c <printf+0x9a>
        consputc(*s);
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	ae6080e7          	jalr	-1306(ra) # 800001f2 <consputc>
      for(; *s; s++)
    80000714:	0485                	addi	s1,s1,1
    80000716:	0004c503          	lbu	a0,0(s1)
    8000071a:	f96d                	bnez	a0,8000070c <printf+0x16a>
    8000071c:	b705                	j	8000063c <printf+0x9a>
        s = "(null)";
    8000071e:	00008497          	auipc	s1,0x8
    80000722:	ada48493          	addi	s1,s1,-1318 # 800081f8 <userret+0x168>
      for(; *s; s++)
    80000726:	02800513          	li	a0,40
    8000072a:	b7cd                	j	8000070c <printf+0x16a>
      consputc('%');
    8000072c:	8556                	mv	a0,s5
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	ac4080e7          	jalr	-1340(ra) # 800001f2 <consputc>
      break;
    80000736:	b719                	j	8000063c <printf+0x9a>
      consputc('%');
    80000738:	8556                	mv	a0,s5
    8000073a:	00000097          	auipc	ra,0x0
    8000073e:	ab8080e7          	jalr	-1352(ra) # 800001f2 <consputc>
      consputc(c);
    80000742:	8526                	mv	a0,s1
    80000744:	00000097          	auipc	ra,0x0
    80000748:	aae080e7          	jalr	-1362(ra) # 800001f2 <consputc>
      break;
    8000074c:	bdc5                	j	8000063c <printf+0x9a>
  if(locking)
    8000074e:	020d9163          	bnez	s11,80000770 <printf+0x1ce>
}
    80000752:	70e6                	ld	ra,120(sp)
    80000754:	7446                	ld	s0,112(sp)
    80000756:	74a6                	ld	s1,104(sp)
    80000758:	7906                	ld	s2,96(sp)
    8000075a:	69e6                	ld	s3,88(sp)
    8000075c:	6a46                	ld	s4,80(sp)
    8000075e:	6aa6                	ld	s5,72(sp)
    80000760:	6b06                	ld	s6,64(sp)
    80000762:	7be2                	ld	s7,56(sp)
    80000764:	7c42                	ld	s8,48(sp)
    80000766:	7ca2                	ld	s9,40(sp)
    80000768:	7d02                	ld	s10,32(sp)
    8000076a:	6de2                	ld	s11,24(sp)
    8000076c:	6129                	addi	sp,sp,192
    8000076e:	8082                	ret
    release(&pr.lock);
    80000770:	00012517          	auipc	a0,0x12
    80000774:	14050513          	addi	a0,a0,320 # 800128b0 <pr>
    80000778:	00000097          	auipc	ra,0x0
    8000077c:	520080e7          	jalr	1312(ra) # 80000c98 <release>
}
    80000780:	bfc9                	j	80000752 <printf+0x1b0>

0000000080000782 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000782:	1101                	addi	sp,sp,-32
    80000784:	ec06                	sd	ra,24(sp)
    80000786:	e822                	sd	s0,16(sp)
    80000788:	e426                	sd	s1,8(sp)
    8000078a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000078c:	00012497          	auipc	s1,0x12
    80000790:	12448493          	addi	s1,s1,292 # 800128b0 <pr>
    80000794:	00008597          	auipc	a1,0x8
    80000798:	a7c58593          	addi	a1,a1,-1412 # 80008210 <userret+0x180>
    8000079c:	8526                	mv	a0,s1
    8000079e:	00000097          	auipc	ra,0x0
    800007a2:	33c080e7          	jalr	828(ra) # 80000ada <initlock>
  pr.locking = 1;
    800007a6:	4785                	li	a5,1
    800007a8:	d09c                	sw	a5,32(s1)
}
    800007aa:	60e2                	ld	ra,24(sp)
    800007ac:	6442                	ld	s0,16(sp)
    800007ae:	64a2                	ld	s1,8(sp)
    800007b0:	6105                	addi	sp,sp,32
    800007b2:	8082                	ret

00000000800007b4 <uartinit>:
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg, v) (*(Reg(reg)) = (v))

void
uartinit(void)
{
    800007b4:	1141                	addi	sp,sp,-16
    800007b6:	e422                	sd	s0,8(sp)
    800007b8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007ba:	100007b7          	lui	a5,0x10000
    800007be:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, 0x80);
    800007c2:	f8000713          	li	a4,-128
    800007c6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ca:	470d                	li	a4,3
    800007cc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007d0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, 0x03);
    800007d4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, 0x07);
    800007d8:	471d                	li	a4,7
    800007da:	00e78123          	sb	a4,2(a5)

  // enable receive interrupts.
  WriteReg(IER, 0x01);
    800007de:	4705                	li	a4,1
    800007e0:	00e780a3          	sb	a4,1(a5)
}
    800007e4:	6422                	ld	s0,8(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc>:

// write one output character to the UART.
void
uartputc(int c)
{
    800007ea:	1141                	addi	sp,sp,-16
    800007ec:	e422                	sd	s0,8(sp)
    800007ee:	0800                	addi	s0,sp,16
  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & (1 << 5)) == 0)
    800007f0:	10000737          	lui	a4,0x10000
    800007f4:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    800007f8:	0207f793          	andi	a5,a5,32
    800007fc:	dfe5                	beqz	a5,800007f4 <uartputc+0xa>
    ;
  WriteReg(THR, c);
    800007fe:	0ff57513          	andi	a0,a0,255
    80000802:	100007b7          	lui	a5,0x10000
    80000806:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
}
    8000080a:	6422                	ld	s0,8(sp)
    8000080c:	0141                	addi	sp,sp,16
    8000080e:	8082                	ret

0000000080000810 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e422                	sd	s0,8(sp)
    80000814:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000081e:	8b85                	andi	a5,a5,1
    80000820:	cb91                	beqz	a5,80000834 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000822:	100007b7          	lui	a5,0x10000
    80000826:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000082a:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000082e:	6422                	ld	s0,8(sp)
    80000830:	0141                	addi	sp,sp,16
    80000832:	8082                	ret
    return -1;
    80000834:	557d                	li	a0,-1
    80000836:	bfe5                	j	8000082e <uartgetc+0x1e>

0000000080000838 <uartintr>:

// trap.c calls here when the uart interrupts.
void
uartintr(void)
{
    80000838:	1101                	addi	sp,sp,-32
    8000083a:	ec06                	sd	ra,24(sp)
    8000083c:	e822                	sd	s0,16(sp)
    8000083e:	e426                	sd	s1,8(sp)
    80000840:	1000                	addi	s0,sp,32
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000842:	54fd                	li	s1,-1
    80000844:	a029                	j	8000084e <uartintr+0x16>
      break;
    consoleintr(c);
    80000846:	00000097          	auipc	ra,0x0
    8000084a:	a82080e7          	jalr	-1406(ra) # 800002c8 <consoleintr>
    int c = uartgetc();
    8000084e:	00000097          	auipc	ra,0x0
    80000852:	fc2080e7          	jalr	-62(ra) # 80000810 <uartgetc>
    if(c == -1)
    80000856:	fe9518e3          	bne	a0,s1,80000846 <uartintr+0xe>
  }
}
    8000085a:	60e2                	ld	ra,24(sp)
    8000085c:	6442                	ld	s0,16(sp)
    8000085e:	64a2                	ld	s1,8(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret

0000000080000864 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000864:	7139                	addi	sp,sp,-64
    80000866:	fc06                	sd	ra,56(sp)
    80000868:	f822                	sd	s0,48(sp)
    8000086a:	f426                	sd	s1,40(sp)
    8000086c:	f04a                	sd	s2,32(sp)
    8000086e:	ec4e                	sd	s3,24(sp)
    80000870:	e852                	sd	s4,16(sp)
    80000872:	e456                	sd	s5,8(sp)
    80000874:	0080                	addi	s0,sp,64
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000876:	03451793          	slli	a5,a0,0x34
    8000087a:	e3c9                	bnez	a5,800008fc <kfree+0x98>
    8000087c:	84aa                	mv	s1,a0
    8000087e:	0002f797          	auipc	a5,0x2f
    80000882:	7de78793          	addi	a5,a5,2014 # 8003005c <end>
    80000886:	06f56b63          	bltu	a0,a5,800008fc <kfree+0x98>
    8000088a:	47c5                	li	a5,17
    8000088c:	07ee                	slli	a5,a5,0x1b
    8000088e:	06f57763          	bgeu	a0,a5,800008fc <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000892:	6605                	lui	a2,0x1
    80000894:	4585                	li	a1,1
    80000896:	00000097          	auipc	ra,0x0
    8000089a:	600080e7          	jalr	1536(ra) # 80000e96 <memset>

  r = (struct run*)pa;
  push_off();
    8000089e:	00000097          	auipc	ra,0x0
    800008a2:	292080e7          	jalr	658(ra) # 80000b30 <push_off>
  int cpu_id=cpuid();
    800008a6:	00001097          	auipc	ra,0x1
    800008aa:	2ae080e7          	jalr	686(ra) # 80001b54 <cpuid>
    800008ae:	8a2a                	mv	s4,a0
  struct kmem* kmem_mem = &kmems[cpu_id];
  pop_off();
    800008b0:	00000097          	auipc	ra,0x0
    800008b4:	2cc080e7          	jalr	716(ra) # 80000b7c <pop_off>
  acquire(&kmem_mem->lock);
    800008b8:	00012a97          	auipc	s5,0x12
    800008bc:	020a8a93          	addi	s5,s5,32 # 800128d8 <kmems>
    800008c0:	002a1993          	slli	s3,s4,0x2
    800008c4:	01498933          	add	s2,s3,s4
    800008c8:	090e                	slli	s2,s2,0x3
    800008ca:	9956                	add	s2,s2,s5
    800008cc:	854a                	mv	a0,s2
    800008ce:	00000097          	auipc	ra,0x0
    800008d2:	35a080e7          	jalr	858(ra) # 80000c28 <acquire>
  r->next = kmem_mem->freelist;
    800008d6:	02093783          	ld	a5,32(s2)
    800008da:	e09c                	sd	a5,0(s1)
  kmem_mem->freelist = r;
    800008dc:	02993023          	sd	s1,32(s2)
  release(&kmem_mem->lock);
    800008e0:	854a                	mv	a0,s2
    800008e2:	00000097          	auipc	ra,0x0
    800008e6:	3b6080e7          	jalr	950(ra) # 80000c98 <release>
}
    800008ea:	70e2                	ld	ra,56(sp)
    800008ec:	7442                	ld	s0,48(sp)
    800008ee:	74a2                	ld	s1,40(sp)
    800008f0:	7902                	ld	s2,32(sp)
    800008f2:	69e2                	ld	s3,24(sp)
    800008f4:	6a42                	ld	s4,16(sp)
    800008f6:	6aa2                	ld	s5,8(sp)
    800008f8:	6121                	addi	sp,sp,64
    800008fa:	8082                	ret
    panic("kfree");
    800008fc:	00008517          	auipc	a0,0x8
    80000900:	91c50513          	addi	a0,a0,-1764 # 80008218 <userret+0x188>
    80000904:	00000097          	auipc	ra,0x0
    80000908:	c44080e7          	jalr	-956(ra) # 80000548 <panic>

000000008000090c <freerange>:
{
    8000090c:	7179                	addi	sp,sp,-48
    8000090e:	f406                	sd	ra,40(sp)
    80000910:	f022                	sd	s0,32(sp)
    80000912:	ec26                	sd	s1,24(sp)
    80000914:	e84a                	sd	s2,16(sp)
    80000916:	e44e                	sd	s3,8(sp)
    80000918:	e052                	sd	s4,0(sp)
    8000091a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    8000091c:	6785                	lui	a5,0x1
    8000091e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000922:	94aa                	add	s1,s1,a0
    80000924:	757d                	lui	a0,0xfffff
    80000926:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000928:	94be                	add	s1,s1,a5
    8000092a:	0095ee63          	bltu	a1,s1,80000946 <freerange+0x3a>
    8000092e:	892e                	mv	s2,a1
    kfree(p);
    80000930:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000932:	6985                	lui	s3,0x1
    kfree(p);
    80000934:	01448533          	add	a0,s1,s4
    80000938:	00000097          	auipc	ra,0x0
    8000093c:	f2c080e7          	jalr	-212(ra) # 80000864 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000940:	94ce                	add	s1,s1,s3
    80000942:	fe9979e3          	bgeu	s2,s1,80000934 <freerange+0x28>
}
    80000946:	70a2                	ld	ra,40(sp)
    80000948:	7402                	ld	s0,32(sp)
    8000094a:	64e2                	ld	s1,24(sp)
    8000094c:	6942                	ld	s2,16(sp)
    8000094e:	69a2                	ld	s3,8(sp)
    80000950:	6a02                	ld	s4,0(sp)
    80000952:	6145                	addi	sp,sp,48
    80000954:	8082                	ret

0000000080000956 <kinit>:
{
    80000956:	1141                	addi	sp,sp,-16
    80000958:	e406                	sd	ra,8(sp)
    8000095a:	e022                	sd	s0,0(sp)
    8000095c:	0800                	addi	s0,sp,16
   initlock(&kmems[i].lock, "kmem");
    8000095e:	00008597          	auipc	a1,0x8
    80000962:	8c258593          	addi	a1,a1,-1854 # 80008220 <userret+0x190>
    80000966:	00012517          	auipc	a0,0x12
    8000096a:	f7250513          	addi	a0,a0,-142 # 800128d8 <kmems>
    8000096e:	00000097          	auipc	ra,0x0
    80000972:	16c080e7          	jalr	364(ra) # 80000ada <initlock>
    80000976:	00008597          	auipc	a1,0x8
    8000097a:	8aa58593          	addi	a1,a1,-1878 # 80008220 <userret+0x190>
    8000097e:	00012517          	auipc	a0,0x12
    80000982:	f8250513          	addi	a0,a0,-126 # 80012900 <kmems+0x28>
    80000986:	00000097          	auipc	ra,0x0
    8000098a:	154080e7          	jalr	340(ra) # 80000ada <initlock>
    8000098e:	00008597          	auipc	a1,0x8
    80000992:	89258593          	addi	a1,a1,-1902 # 80008220 <userret+0x190>
    80000996:	00012517          	auipc	a0,0x12
    8000099a:	f9250513          	addi	a0,a0,-110 # 80012928 <kmems+0x50>
    8000099e:	00000097          	auipc	ra,0x0
    800009a2:	13c080e7          	jalr	316(ra) # 80000ada <initlock>
  freerange(end, (void*)PHYSTOP);
    800009a6:	45c5                	li	a1,17
    800009a8:	05ee                	slli	a1,a1,0x1b
    800009aa:	0002f517          	auipc	a0,0x2f
    800009ae:	6b250513          	addi	a0,a0,1714 # 8003005c <end>
    800009b2:	00000097          	auipc	ra,0x0
    800009b6:	f5a080e7          	jalr	-166(ra) # 8000090c <freerange>
}
    800009ba:	60a2                	ld	ra,8(sp)
    800009bc:	6402                	ld	s0,0(sp)
    800009be:	0141                	addi	sp,sp,16
    800009c0:	8082                	ret

00000000800009c2 <steal>:

void *
steal(int skip){
    800009c2:	7139                	addi	sp,sp,-64
    800009c4:	fc06                	sd	ra,56(sp)
    800009c6:	f822                	sd	s0,48(sp)
    800009c8:	f426                	sd	s1,40(sp)
    800009ca:	f04a                	sd	s2,32(sp)
    800009cc:	ec4e                	sd	s3,24(sp)
    800009ce:	e852                	sd	s4,16(sp)
    800009d0:	e456                	sd	s5,8(sp)
    800009d2:	0080                	addi	s0,sp,64
  // printf("cpu id %d\n",getcpu());
  struct run * rs=0;
  for(int i=0;i<3;i++){
    800009d4:	00012497          	auipc	s1,0x12
    800009d8:	f0448493          	addi	s1,s1,-252 # 800128d8 <kmems>
    800009dc:	4901                	li	s2,0
    800009de:	4a8d                	li	s5,3
    800009e0:	a80d                	j	80000a12 <steal+0x50>
      continue;
    }
    acquire(&kmems[i].lock);
    if(kmems[i].freelist!=0){
      rs=kmems[i].freelist;
      kmems[i].freelist=rs->next;
    800009e2:	0009b703          	ld	a4,0(s3) # 1000 <_entry-0x7ffff000>
    800009e6:	00291793          	slli	a5,s2,0x2
    800009ea:	993e                	add	s2,s2,a5
    800009ec:	090e                	slli	s2,s2,0x3
    800009ee:	00012797          	auipc	a5,0x12
    800009f2:	eea78793          	addi	a5,a5,-278 # 800128d8 <kmems>
    800009f6:	993e                	add	s2,s2,a5
    800009f8:	02e93023          	sd	a4,32(s2)
      release(&kmems[i].lock);
    800009fc:	8526                	mv	a0,s1
    800009fe:	00000097          	auipc	ra,0x0
    80000a02:	29a080e7          	jalr	666(ra) # 80000c98 <release>
      return (void *)rs;
    80000a06:	a825                	j	80000a3e <steal+0x7c>
  for(int i=0;i<3;i++){
    80000a08:	2905                	addiw	s2,s2,1
    80000a0a:	02848493          	addi	s1,s1,40
    80000a0e:	03590763          	beq	s2,s5,80000a3c <steal+0x7a>
    if(holding(&kmems[i].lock)){
    80000a12:	8526                	mv	a0,s1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	1d4080e7          	jalr	468(ra) # 80000be8 <holding>
    80000a1c:	f575                	bnez	a0,80000a08 <steal+0x46>
    acquire(&kmems[i].lock);
    80000a1e:	8526                	mv	a0,s1
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	208080e7          	jalr	520(ra) # 80000c28 <acquire>
    if(kmems[i].freelist!=0){
    80000a28:	0204b983          	ld	s3,32(s1)
    80000a2c:	fa099be3          	bnez	s3,800009e2 <steal+0x20>
    }
    release(&kmems[i].lock);
    80000a30:	8526                	mv	a0,s1
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	266080e7          	jalr	614(ra) # 80000c98 <release>
    80000a3a:	b7f9                	j	80000a08 <steal+0x46>
  }
  // 不管还有没有，都直接返回，不用panic
  return (void *)rs;
    80000a3c:	4981                	li	s3,0
}
    80000a3e:	854e                	mv	a0,s3
    80000a40:	70e2                	ld	ra,56(sp)
    80000a42:	7442                	ld	s0,48(sp)
    80000a44:	74a2                	ld	s1,40(sp)
    80000a46:	7902                	ld	s2,32(sp)
    80000a48:	69e2                	ld	s3,24(sp)
    80000a4a:	6a42                	ld	s4,16(sp)
    80000a4c:	6aa2                	ld	s5,8(sp)
    80000a4e:	6121                	addi	sp,sp,64
    80000a50:	8082                	ret

0000000080000a52 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000a52:	7179                	addi	sp,sp,-48
    80000a54:	f406                	sd	ra,40(sp)
    80000a56:	f022                	sd	s0,32(sp)
    80000a58:	ec26                	sd	s1,24(sp)
    80000a5a:	e84a                	sd	s2,16(sp)
    80000a5c:	e44e                	sd	s3,8(sp)
    80000a5e:	1800                	addi	s0,sp,48
  struct run *r;
  int hart=cpuid();
    80000a60:	00001097          	auipc	ra,0x1
    80000a64:	0f4080e7          	jalr	244(ra) # 80001b54 <cpuid>
    80000a68:	84aa                	mv	s1,a0
  acquire(&kmems[hart].lock);
    80000a6a:	00251913          	slli	s2,a0,0x2
    80000a6e:	992a                	add	s2,s2,a0
    80000a70:	00391793          	slli	a5,s2,0x3
    80000a74:	00012917          	auipc	s2,0x12
    80000a78:	e6490913          	addi	s2,s2,-412 # 800128d8 <kmems>
    80000a7c:	993e                	add	s2,s2,a5
    80000a7e:	854a                	mv	a0,s2
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	1a8080e7          	jalr	424(ra) # 80000c28 <acquire>
  r = kmems[hart].freelist;
    80000a88:	02093983          	ld	s3,32(s2)
  if(r)
    80000a8c:	02098a63          	beqz	s3,80000ac0 <kalloc+0x6e>
    kmems[hart].freelist = r->next;
    80000a90:	0009b703          	ld	a4,0(s3)
    80000a94:	02e93023          	sd	a4,32(s2)
  release(&kmems[hart].lock);
    80000a98:	854a                	mv	a0,s2
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	1fe080e7          	jalr	510(ra) # 80000c98 <release>
  {
    // 当前cpu对应的freelist为空 需要从其他cpu对应的freelist借
    r=steal(hart);
  }
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000aa2:	6605                	lui	a2,0x1
    80000aa4:	4595                	li	a1,5
    80000aa6:	854e                	mv	a0,s3
    80000aa8:	00000097          	auipc	ra,0x0
    80000aac:	3ee080e7          	jalr	1006(ra) # 80000e96 <memset>
  return (void*)r;

  
}
    80000ab0:	854e                	mv	a0,s3
    80000ab2:	70a2                	ld	ra,40(sp)
    80000ab4:	7402                	ld	s0,32(sp)
    80000ab6:	64e2                	ld	s1,24(sp)
    80000ab8:	6942                	ld	s2,16(sp)
    80000aba:	69a2                	ld	s3,8(sp)
    80000abc:	6145                	addi	sp,sp,48
    80000abe:	8082                	ret
  release(&kmems[hart].lock);
    80000ac0:	854a                	mv	a0,s2
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	1d6080e7          	jalr	470(ra) # 80000c98 <release>
    r=steal(hart);
    80000aca:	8526                	mv	a0,s1
    80000acc:	00000097          	auipc	ra,0x0
    80000ad0:	ef6080e7          	jalr	-266(ra) # 800009c2 <steal>
    80000ad4:	89aa                	mv	s3,a0
  if(r)
    80000ad6:	dd69                	beqz	a0,80000ab0 <kalloc+0x5e>
    80000ad8:	b7e9                	j	80000aa2 <kalloc+0x50>

0000000080000ada <initlock>:

// assumes locks are not freed
void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
    80000ada:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000adc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ae0:	00053823          	sd	zero,16(a0)
  lk->nts = 0;
    80000ae4:	00052e23          	sw	zero,28(a0)
  lk->n = 0;
    80000ae8:	00052c23          	sw	zero,24(a0)
  if(nlock >= NLOCK)
    80000aec:	0002f797          	auipc	a5,0x2f
    80000af0:	5387a783          	lw	a5,1336(a5) # 80030024 <nlock>
    80000af4:	3e700713          	li	a4,999
    80000af8:	02f74063          	blt	a4,a5,80000b18 <initlock+0x3e>
    panic("initlock");
  locks[nlock] = lk;
    80000afc:	00379693          	slli	a3,a5,0x3
    80000b00:	00012717          	auipc	a4,0x12
    80000b04:	f1870713          	addi	a4,a4,-232 # 80012a18 <locks>
    80000b08:	9736                	add	a4,a4,a3
    80000b0a:	e308                	sd	a0,0(a4)
  nlock++;
    80000b0c:	2785                	addiw	a5,a5,1
    80000b0e:	0002f717          	auipc	a4,0x2f
    80000b12:	50f72b23          	sw	a5,1302(a4) # 80030024 <nlock>
    80000b16:	8082                	ret
{
    80000b18:	1141                	addi	sp,sp,-16
    80000b1a:	e406                	sd	ra,8(sp)
    80000b1c:	e022                	sd	s0,0(sp)
    80000b1e:	0800                	addi	s0,sp,16
    panic("initlock");
    80000b20:	00007517          	auipc	a0,0x7
    80000b24:	70850513          	addi	a0,a0,1800 # 80008228 <userret+0x198>
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	a20080e7          	jalr	-1504(ra) # 80000548 <panic>

0000000080000b30 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b30:	1101                	addi	sp,sp,-32
    80000b32:	ec06                	sd	ra,24(sp)
    80000b34:	e822                	sd	s0,16(sp)
    80000b36:	e426                	sd	s1,8(sp)
    80000b38:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b3a:	100024f3          	csrr	s1,sstatus
    80000b3e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b42:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b44:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b48:	00001097          	auipc	ra,0x1
    80000b4c:	01c080e7          	jalr	28(ra) # 80001b64 <mycpu>
    80000b50:	5d3c                	lw	a5,120(a0)
    80000b52:	cf89                	beqz	a5,80000b6c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b54:	00001097          	auipc	ra,0x1
    80000b58:	010080e7          	jalr	16(ra) # 80001b64 <mycpu>
    80000b5c:	5d3c                	lw	a5,120(a0)
    80000b5e:	2785                	addiw	a5,a5,1
    80000b60:	dd3c                	sw	a5,120(a0)
}
    80000b62:	60e2                	ld	ra,24(sp)
    80000b64:	6442                	ld	s0,16(sp)
    80000b66:	64a2                	ld	s1,8(sp)
    80000b68:	6105                	addi	sp,sp,32
    80000b6a:	8082                	ret
    mycpu()->intena = old;
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	ff8080e7          	jalr	-8(ra) # 80001b64 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000b74:	8085                	srli	s1,s1,0x1
    80000b76:	8885                	andi	s1,s1,1
    80000b78:	dd64                	sw	s1,124(a0)
    80000b7a:	bfe9                	j	80000b54 <push_off+0x24>

0000000080000b7c <pop_off>:

void
pop_off(void)
{
    80000b7c:	1141                	addi	sp,sp,-16
    80000b7e:	e406                	sd	ra,8(sp)
    80000b80:	e022                	sd	s0,0(sp)
    80000b82:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	fe0080e7          	jalr	-32(ra) # 80001b64 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000b90:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000b92:	eb9d                	bnez	a5,80000bc8 <pop_off+0x4c>
    panic("pop_off - interruptible");
  c->noff -= 1;
    80000b94:	5d3c                	lw	a5,120(a0)
    80000b96:	37fd                	addiw	a5,a5,-1
    80000b98:	0007871b          	sext.w	a4,a5
    80000b9c:	dd3c                	sw	a5,120(a0)
  if(c->noff < 0)
    80000b9e:	02074d63          	bltz	a4,80000bd8 <pop_off+0x5c>
    panic("pop_off");
  if(c->noff == 0 && c->intena)
    80000ba2:	ef19                	bnez	a4,80000bc0 <pop_off+0x44>
    80000ba4:	5d7c                	lw	a5,124(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <pop_off+0x44>
  asm volatile("csrr %0, sie" : "=r" (x) );
    80000ba8:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000bac:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80000bb0:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bb4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000bb8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bbc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000bc0:	60a2                	ld	ra,8(sp)
    80000bc2:	6402                	ld	s0,0(sp)
    80000bc4:	0141                	addi	sp,sp,16
    80000bc6:	8082                	ret
    panic("pop_off - interruptible");
    80000bc8:	00007517          	auipc	a0,0x7
    80000bcc:	67050513          	addi	a0,a0,1648 # 80008238 <userret+0x1a8>
    80000bd0:	00000097          	auipc	ra,0x0
    80000bd4:	978080e7          	jalr	-1672(ra) # 80000548 <panic>
    panic("pop_off");
    80000bd8:	00007517          	auipc	a0,0x7
    80000bdc:	67850513          	addi	a0,a0,1656 # 80008250 <userret+0x1c0>
    80000be0:	00000097          	auipc	ra,0x0
    80000be4:	968080e7          	jalr	-1688(ra) # 80000548 <panic>

0000000080000be8 <holding>:
{
    80000be8:	1101                	addi	sp,sp,-32
    80000bea:	ec06                	sd	ra,24(sp)
    80000bec:	e822                	sd	s0,16(sp)
    80000bee:	e426                	sd	s1,8(sp)
    80000bf0:	1000                	addi	s0,sp,32
    80000bf2:	84aa                	mv	s1,a0
  push_off();
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	f3c080e7          	jalr	-196(ra) # 80000b30 <push_off>
  r = (lk->locked && lk->cpu == mycpu());
    80000bfc:	409c                	lw	a5,0(s1)
    80000bfe:	ef81                	bnez	a5,80000c16 <holding+0x2e>
    80000c00:	4481                	li	s1,0
  pop_off();
    80000c02:	00000097          	auipc	ra,0x0
    80000c06:	f7a080e7          	jalr	-134(ra) # 80000b7c <pop_off>
}
    80000c0a:	8526                	mv	a0,s1
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
  r = (lk->locked && lk->cpu == mycpu());
    80000c16:	6884                	ld	s1,16(s1)
    80000c18:	00001097          	auipc	ra,0x1
    80000c1c:	f4c080e7          	jalr	-180(ra) # 80001b64 <mycpu>
    80000c20:	8c89                	sub	s1,s1,a0
    80000c22:	0014b493          	seqz	s1,s1
    80000c26:	bff1                	j	80000c02 <holding+0x1a>

0000000080000c28 <acquire>:
{
    80000c28:	1101                	addi	sp,sp,-32
    80000c2a:	ec06                	sd	ra,24(sp)
    80000c2c:	e822                	sd	s0,16(sp)
    80000c2e:	e426                	sd	s1,8(sp)
    80000c30:	1000                	addi	s0,sp,32
    80000c32:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	efc080e7          	jalr	-260(ra) # 80000b30 <push_off>
  if(holding(lk))
    80000c3c:	8526                	mv	a0,s1
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	faa080e7          	jalr	-86(ra) # 80000be8 <holding>
    80000c46:	e911                	bnez	a0,80000c5a <acquire+0x32>
  __sync_fetch_and_add(&(lk->n), 1);
    80000c48:	4785                	li	a5,1
    80000c4a:	01848713          	addi	a4,s1,24
    80000c4e:	0f50000f          	fence	iorw,ow
    80000c52:	04f7202f          	amoadd.w.aq	zero,a5,(a4)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000c56:	4705                	li	a4,1
    80000c58:	a839                	j	80000c76 <acquire+0x4e>
    panic("acquire");
    80000c5a:	00007517          	auipc	a0,0x7
    80000c5e:	5fe50513          	addi	a0,a0,1534 # 80008258 <userret+0x1c8>
    80000c62:	00000097          	auipc	ra,0x0
    80000c66:	8e6080e7          	jalr	-1818(ra) # 80000548 <panic>
     __sync_fetch_and_add(&lk->nts, 1);
    80000c6a:	01c48793          	addi	a5,s1,28
    80000c6e:	0f50000f          	fence	iorw,ow
    80000c72:	04e7a02f          	amoadd.w.aq	zero,a4,(a5)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80000c76:	87ba                	mv	a5,a4
    80000c78:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c7c:	2781                	sext.w	a5,a5
    80000c7e:	f7f5                	bnez	a5,80000c6a <acquire+0x42>
  __sync_synchronize();
    80000c80:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c84:	00001097          	auipc	ra,0x1
    80000c88:	ee0080e7          	jalr	-288(ra) # 80001b64 <mycpu>
    80000c8c:	e888                	sd	a0,16(s1)
}
    80000c8e:	60e2                	ld	ra,24(sp)
    80000c90:	6442                	ld	s0,16(sp)
    80000c92:	64a2                	ld	s1,8(sp)
    80000c94:	6105                	addi	sp,sp,32
    80000c96:	8082                	ret

0000000080000c98 <release>:
{
    80000c98:	1101                	addi	sp,sp,-32
    80000c9a:	ec06                	sd	ra,24(sp)
    80000c9c:	e822                	sd	s0,16(sp)
    80000c9e:	e426                	sd	s1,8(sp)
    80000ca0:	1000                	addi	s0,sp,32
    80000ca2:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca4:	00000097          	auipc	ra,0x0
    80000ca8:	f44080e7          	jalr	-188(ra) # 80000be8 <holding>
    80000cac:	c115                	beqz	a0,80000cd0 <release+0x38>
  lk->cpu = 0;
    80000cae:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cb6:	0f50000f          	fence	iorw,ow
    80000cba:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cbe:	00000097          	auipc	ra,0x0
    80000cc2:	ebe080e7          	jalr	-322(ra) # 80000b7c <pop_off>
}
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	64a2                	ld	s1,8(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
    panic("release");
    80000cd0:	00007517          	auipc	a0,0x7
    80000cd4:	59050513          	addi	a0,a0,1424 # 80008260 <userret+0x1d0>
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	870080e7          	jalr	-1936(ra) # 80000548 <panic>

0000000080000ce0 <print_lock>:

void
print_lock(struct spinlock *lk)
{
  if(lk->n > 0) 
    80000ce0:	4d14                	lw	a3,24(a0)
    80000ce2:	e291                	bnez	a3,80000ce6 <print_lock+0x6>
    80000ce4:	8082                	ret
{
    80000ce6:	1141                	addi	sp,sp,-16
    80000ce8:	e406                	sd	ra,8(sp)
    80000cea:	e022                	sd	s0,0(sp)
    80000cec:	0800                	addi	s0,sp,16
    printf("lock: %s: #test-and-set %d #acquire() %d\n", lk->name, lk->nts, lk->n);
    80000cee:	4d50                	lw	a2,28(a0)
    80000cf0:	650c                	ld	a1,8(a0)
    80000cf2:	00007517          	auipc	a0,0x7
    80000cf6:	57650513          	addi	a0,a0,1398 # 80008268 <userret+0x1d8>
    80000cfa:	00000097          	auipc	ra,0x0
    80000cfe:	8a8080e7          	jalr	-1880(ra) # 800005a2 <printf>
}
    80000d02:	60a2                	ld	ra,8(sp)
    80000d04:	6402                	ld	s0,0(sp)
    80000d06:	0141                	addi	sp,sp,16
    80000d08:	8082                	ret

0000000080000d0a <sys_ntas>:

uint64
sys_ntas(void)
{
    80000d0a:	711d                	addi	sp,sp,-96
    80000d0c:	ec86                	sd	ra,88(sp)
    80000d0e:	e8a2                	sd	s0,80(sp)
    80000d10:	e4a6                	sd	s1,72(sp)
    80000d12:	e0ca                	sd	s2,64(sp)
    80000d14:	fc4e                	sd	s3,56(sp)
    80000d16:	f852                	sd	s4,48(sp)
    80000d18:	f456                	sd	s5,40(sp)
    80000d1a:	f05a                	sd	s6,32(sp)
    80000d1c:	ec5e                	sd	s7,24(sp)
    80000d1e:	e862                	sd	s8,16(sp)
    80000d20:	1080                	addi	s0,sp,96
  int zero = 0;
    80000d22:	fa042623          	sw	zero,-84(s0)
  int tot = 0;
  
  if (argint(0, &zero) < 0) {
    80000d26:	fac40593          	addi	a1,s0,-84
    80000d2a:	4501                	li	a0,0
    80000d2c:	00002097          	auipc	ra,0x2
    80000d30:	ece080e7          	jalr	-306(ra) # 80002bfa <argint>
    80000d34:	14054d63          	bltz	a0,80000e8e <sys_ntas+0x184>
    return -1;
  }
  if(zero == 0) {
    80000d38:	fac42783          	lw	a5,-84(s0)
    80000d3c:	e78d                	bnez	a5,80000d66 <sys_ntas+0x5c>
    80000d3e:	00012797          	auipc	a5,0x12
    80000d42:	cda78793          	addi	a5,a5,-806 # 80012a18 <locks>
    80000d46:	00014697          	auipc	a3,0x14
    80000d4a:	c1268693          	addi	a3,a3,-1006 # 80014958 <pid_lock>
    for(int i = 0; i < NLOCK; i++) {
      if(locks[i] == 0)
    80000d4e:	6398                	ld	a4,0(a5)
    80000d50:	14070163          	beqz	a4,80000e92 <sys_ntas+0x188>
        break;
      locks[i]->nts = 0;
    80000d54:	00072e23          	sw	zero,28(a4)
      locks[i]->n = 0;
    80000d58:	00072c23          	sw	zero,24(a4)
    for(int i = 0; i < NLOCK; i++) {
    80000d5c:	07a1                	addi	a5,a5,8
    80000d5e:	fed798e3          	bne	a5,a3,80000d4e <sys_ntas+0x44>
    }
    return 0;
    80000d62:	4501                	li	a0,0
    80000d64:	aa09                	j	80000e76 <sys_ntas+0x16c>
  }

  printf("=== lock kmem/bcache stats\n");
    80000d66:	00007517          	auipc	a0,0x7
    80000d6a:	53250513          	addi	a0,a0,1330 # 80008298 <userret+0x208>
    80000d6e:	00000097          	auipc	ra,0x0
    80000d72:	834080e7          	jalr	-1996(ra) # 800005a2 <printf>
  for(int i = 0; i < NLOCK; i++) {
    80000d76:	00012b17          	auipc	s6,0x12
    80000d7a:	ca2b0b13          	addi	s6,s6,-862 # 80012a18 <locks>
    80000d7e:	00014b97          	auipc	s7,0x14
    80000d82:	bdab8b93          	addi	s7,s7,-1062 # 80014958 <pid_lock>
  printf("=== lock kmem/bcache stats\n");
    80000d86:	84da                	mv	s1,s6
  int tot = 0;
    80000d88:	4981                	li	s3,0
    if(locks[i] == 0)
      break;
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000d8a:	00007a17          	auipc	s4,0x7
    80000d8e:	52ea0a13          	addi	s4,s4,1326 # 800082b8 <userret+0x228>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000d92:	00007c17          	auipc	s8,0x7
    80000d96:	48ec0c13          	addi	s8,s8,1166 # 80008220 <userret+0x190>
    80000d9a:	a829                	j	80000db4 <sys_ntas+0xaa>
      tot += locks[i]->nts;
    80000d9c:	00093503          	ld	a0,0(s2)
    80000da0:	4d5c                	lw	a5,28(a0)
    80000da2:	013789bb          	addw	s3,a5,s3
      print_lock(locks[i]);
    80000da6:	00000097          	auipc	ra,0x0
    80000daa:	f3a080e7          	jalr	-198(ra) # 80000ce0 <print_lock>
  for(int i = 0; i < NLOCK; i++) {
    80000dae:	04a1                	addi	s1,s1,8
    80000db0:	05748763          	beq	s1,s7,80000dfe <sys_ntas+0xf4>
    if(locks[i] == 0)
    80000db4:	8926                	mv	s2,s1
    80000db6:	609c                	ld	a5,0(s1)
    80000db8:	c3b9                	beqz	a5,80000dfe <sys_ntas+0xf4>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000dba:	0087ba83          	ld	s5,8(a5)
    80000dbe:	8552                	mv	a0,s4
    80000dc0:	00000097          	auipc	ra,0x0
    80000dc4:	25a080e7          	jalr	602(ra) # 8000101a <strlen>
    80000dc8:	0005061b          	sext.w	a2,a0
    80000dcc:	85d2                	mv	a1,s4
    80000dce:	8556                	mv	a0,s5
    80000dd0:	00000097          	auipc	ra,0x0
    80000dd4:	19e080e7          	jalr	414(ra) # 80000f6e <strncmp>
    80000dd8:	d171                	beqz	a0,80000d9c <sys_ntas+0x92>
       strncmp(locks[i]->name, "kmem", strlen("kmem")) == 0) {
    80000dda:	609c                	ld	a5,0(s1)
    80000ddc:	0087ba83          	ld	s5,8(a5)
    80000de0:	8562                	mv	a0,s8
    80000de2:	00000097          	auipc	ra,0x0
    80000de6:	238080e7          	jalr	568(ra) # 8000101a <strlen>
    80000dea:	0005061b          	sext.w	a2,a0
    80000dee:	85e2                	mv	a1,s8
    80000df0:	8556                	mv	a0,s5
    80000df2:	00000097          	auipc	ra,0x0
    80000df6:	17c080e7          	jalr	380(ra) # 80000f6e <strncmp>
    if(strncmp(locks[i]->name, "bcache", strlen("bcache")) == 0 ||
    80000dfa:	f955                	bnez	a0,80000dae <sys_ntas+0xa4>
    80000dfc:	b745                	j	80000d9c <sys_ntas+0x92>
    }
  }

  printf("=== top 5 contended locks:\n");
    80000dfe:	00007517          	auipc	a0,0x7
    80000e02:	4c250513          	addi	a0,a0,1218 # 800082c0 <userret+0x230>
    80000e06:	fffff097          	auipc	ra,0xfffff
    80000e0a:	79c080e7          	jalr	1948(ra) # 800005a2 <printf>
    80000e0e:	4a15                	li	s4,5
  int last = 100000000;
    80000e10:	05f5e537          	lui	a0,0x5f5e
    80000e14:	10050513          	addi	a0,a0,256 # 5f5e100 <_entry-0x7a0a1f00>
  // stupid way to compute top 5 contended locks
  for(int t= 0; t < 5; t++) {
    int top = 0;
    for(int i = 0; i < NLOCK; i++) {
    80000e18:	4a81                	li	s5,0
      if(locks[i] == 0)
        break;
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e1a:	00012497          	auipc	s1,0x12
    80000e1e:	bfe48493          	addi	s1,s1,-1026 # 80012a18 <locks>
    for(int i = 0; i < NLOCK; i++) {
    80000e22:	3e800913          	li	s2,1000
    80000e26:	a091                	j	80000e6a <sys_ntas+0x160>
    80000e28:	2705                	addiw	a4,a4,1
    80000e2a:	06a1                	addi	a3,a3,8
    80000e2c:	03270063          	beq	a4,s2,80000e4c <sys_ntas+0x142>
      if(locks[i] == 0)
    80000e30:	629c                	ld	a5,0(a3)
    80000e32:	cf89                	beqz	a5,80000e4c <sys_ntas+0x142>
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e34:	4fd0                	lw	a2,28(a5)
    80000e36:	00359793          	slli	a5,a1,0x3
    80000e3a:	97a6                	add	a5,a5,s1
    80000e3c:	639c                	ld	a5,0(a5)
    80000e3e:	4fdc                	lw	a5,28(a5)
    80000e40:	fec7f4e3          	bgeu	a5,a2,80000e28 <sys_ntas+0x11e>
    80000e44:	fea672e3          	bgeu	a2,a0,80000e28 <sys_ntas+0x11e>
    80000e48:	85ba                	mv	a1,a4
    80000e4a:	bff9                	j	80000e28 <sys_ntas+0x11e>
        top = i;
      }
    }
    print_lock(locks[top]);
    80000e4c:	058e                	slli	a1,a1,0x3
    80000e4e:	00b48bb3          	add	s7,s1,a1
    80000e52:	000bb503          	ld	a0,0(s7)
    80000e56:	00000097          	auipc	ra,0x0
    80000e5a:	e8a080e7          	jalr	-374(ra) # 80000ce0 <print_lock>
    last = locks[top]->nts;
    80000e5e:	000bb783          	ld	a5,0(s7)
    80000e62:	4fc8                	lw	a0,28(a5)
  for(int t= 0; t < 5; t++) {
    80000e64:	3a7d                	addiw	s4,s4,-1
    80000e66:	000a0763          	beqz	s4,80000e74 <sys_ntas+0x16a>
  int tot = 0;
    80000e6a:	86da                	mv	a3,s6
    for(int i = 0; i < NLOCK; i++) {
    80000e6c:	8756                	mv	a4,s5
    int top = 0;
    80000e6e:	85d6                	mv	a1,s5
      if(locks[i]->nts > locks[top]->nts && locks[i]->nts < last) {
    80000e70:	2501                	sext.w	a0,a0
    80000e72:	bf7d                	j	80000e30 <sys_ntas+0x126>
  }
  return tot;
    80000e74:	854e                	mv	a0,s3
}
    80000e76:	60e6                	ld	ra,88(sp)
    80000e78:	6446                	ld	s0,80(sp)
    80000e7a:	64a6                	ld	s1,72(sp)
    80000e7c:	6906                	ld	s2,64(sp)
    80000e7e:	79e2                	ld	s3,56(sp)
    80000e80:	7a42                	ld	s4,48(sp)
    80000e82:	7aa2                	ld	s5,40(sp)
    80000e84:	7b02                	ld	s6,32(sp)
    80000e86:	6be2                	ld	s7,24(sp)
    80000e88:	6c42                	ld	s8,16(sp)
    80000e8a:	6125                	addi	sp,sp,96
    80000e8c:	8082                	ret
    return -1;
    80000e8e:	557d                	li	a0,-1
    80000e90:	b7dd                	j	80000e76 <sys_ntas+0x16c>
    return 0;
    80000e92:	4501                	li	a0,0
    80000e94:	b7cd                	j	80000e76 <sys_ntas+0x16c>

0000000080000e96 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e96:	1141                	addi	sp,sp,-16
    80000e98:	e422                	sd	s0,8(sp)
    80000e9a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e9c:	ca19                	beqz	a2,80000eb2 <memset+0x1c>
    80000e9e:	87aa                	mv	a5,a0
    80000ea0:	1602                	slli	a2,a2,0x20
    80000ea2:	9201                	srli	a2,a2,0x20
    80000ea4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ea8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000eac:	0785                	addi	a5,a5,1
    80000eae:	fee79de3          	bne	a5,a4,80000ea8 <memset+0x12>
  }
  return dst;
}
    80000eb2:	6422                	ld	s0,8(sp)
    80000eb4:	0141                	addi	sp,sp,16
    80000eb6:	8082                	ret

0000000080000eb8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000eb8:	1141                	addi	sp,sp,-16
    80000eba:	e422                	sd	s0,8(sp)
    80000ebc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ebe:	ca05                	beqz	a2,80000eee <memcmp+0x36>
    80000ec0:	fff6069b          	addiw	a3,a2,-1
    80000ec4:	1682                	slli	a3,a3,0x20
    80000ec6:	9281                	srli	a3,a3,0x20
    80000ec8:	0685                	addi	a3,a3,1
    80000eca:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000ecc:	00054783          	lbu	a5,0(a0)
    80000ed0:	0005c703          	lbu	a4,0(a1)
    80000ed4:	00e79863          	bne	a5,a4,80000ee4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ed8:	0505                	addi	a0,a0,1
    80000eda:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000edc:	fed518e3          	bne	a0,a3,80000ecc <memcmp+0x14>
  }

  return 0;
    80000ee0:	4501                	li	a0,0
    80000ee2:	a019                	j	80000ee8 <memcmp+0x30>
      return *s1 - *s2;
    80000ee4:	40e7853b          	subw	a0,a5,a4
}
    80000ee8:	6422                	ld	s0,8(sp)
    80000eea:	0141                	addi	sp,sp,16
    80000eec:	8082                	ret
  return 0;
    80000eee:	4501                	li	a0,0
    80000ef0:	bfe5                	j	80000ee8 <memcmp+0x30>

0000000080000ef2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ef2:	1141                	addi	sp,sp,-16
    80000ef4:	e422                	sd	s0,8(sp)
    80000ef6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ef8:	02a5e563          	bltu	a1,a0,80000f22 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000efc:	fff6069b          	addiw	a3,a2,-1
    80000f00:	ce11                	beqz	a2,80000f1c <memmove+0x2a>
    80000f02:	1682                	slli	a3,a3,0x20
    80000f04:	9281                	srli	a3,a3,0x20
    80000f06:	0685                	addi	a3,a3,1
    80000f08:	96ae                	add	a3,a3,a1
    80000f0a:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000f0c:	0585                	addi	a1,a1,1
    80000f0e:	0785                	addi	a5,a5,1
    80000f10:	fff5c703          	lbu	a4,-1(a1)
    80000f14:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000f18:	fed59ae3          	bne	a1,a3,80000f0c <memmove+0x1a>

  return dst;
}
    80000f1c:	6422                	ld	s0,8(sp)
    80000f1e:	0141                	addi	sp,sp,16
    80000f20:	8082                	ret
  if(s < d && s + n > d){
    80000f22:	02061713          	slli	a4,a2,0x20
    80000f26:	9301                	srli	a4,a4,0x20
    80000f28:	00e587b3          	add	a5,a1,a4
    80000f2c:	fcf578e3          	bgeu	a0,a5,80000efc <memmove+0xa>
    d += n;
    80000f30:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000f32:	fff6069b          	addiw	a3,a2,-1
    80000f36:	d27d                	beqz	a2,80000f1c <memmove+0x2a>
    80000f38:	02069613          	slli	a2,a3,0x20
    80000f3c:	9201                	srli	a2,a2,0x20
    80000f3e:	fff64613          	not	a2,a2
    80000f42:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000f44:	17fd                	addi	a5,a5,-1
    80000f46:	177d                	addi	a4,a4,-1
    80000f48:	0007c683          	lbu	a3,0(a5)
    80000f4c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000f50:	fef61ae3          	bne	a2,a5,80000f44 <memmove+0x52>
    80000f54:	b7e1                	j	80000f1c <memmove+0x2a>

0000000080000f56 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f56:	1141                	addi	sp,sp,-16
    80000f58:	e406                	sd	ra,8(sp)
    80000f5a:	e022                	sd	s0,0(sp)
    80000f5c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f5e:	00000097          	auipc	ra,0x0
    80000f62:	f94080e7          	jalr	-108(ra) # 80000ef2 <memmove>
}
    80000f66:	60a2                	ld	ra,8(sp)
    80000f68:	6402                	ld	s0,0(sp)
    80000f6a:	0141                	addi	sp,sp,16
    80000f6c:	8082                	ret

0000000080000f6e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f6e:	1141                	addi	sp,sp,-16
    80000f70:	e422                	sd	s0,8(sp)
    80000f72:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f74:	ce11                	beqz	a2,80000f90 <strncmp+0x22>
    80000f76:	00054783          	lbu	a5,0(a0)
    80000f7a:	cf89                	beqz	a5,80000f94 <strncmp+0x26>
    80000f7c:	0005c703          	lbu	a4,0(a1)
    80000f80:	00f71a63          	bne	a4,a5,80000f94 <strncmp+0x26>
    n--, p++, q++;
    80000f84:	367d                	addiw	a2,a2,-1
    80000f86:	0505                	addi	a0,a0,1
    80000f88:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f8a:	f675                	bnez	a2,80000f76 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f8c:	4501                	li	a0,0
    80000f8e:	a809                	j	80000fa0 <strncmp+0x32>
    80000f90:	4501                	li	a0,0
    80000f92:	a039                	j	80000fa0 <strncmp+0x32>
  if(n == 0)
    80000f94:	ca09                	beqz	a2,80000fa6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000f96:	00054503          	lbu	a0,0(a0)
    80000f9a:	0005c783          	lbu	a5,0(a1)
    80000f9e:	9d1d                	subw	a0,a0,a5
}
    80000fa0:	6422                	ld	s0,8(sp)
    80000fa2:	0141                	addi	sp,sp,16
    80000fa4:	8082                	ret
    return 0;
    80000fa6:	4501                	li	a0,0
    80000fa8:	bfe5                	j	80000fa0 <strncmp+0x32>

0000000080000faa <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000faa:	1141                	addi	sp,sp,-16
    80000fac:	e422                	sd	s0,8(sp)
    80000fae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000fb0:	872a                	mv	a4,a0
    80000fb2:	8832                	mv	a6,a2
    80000fb4:	367d                	addiw	a2,a2,-1
    80000fb6:	01005963          	blez	a6,80000fc8 <strncpy+0x1e>
    80000fba:	0705                	addi	a4,a4,1
    80000fbc:	0005c783          	lbu	a5,0(a1)
    80000fc0:	fef70fa3          	sb	a5,-1(a4)
    80000fc4:	0585                	addi	a1,a1,1
    80000fc6:	f7f5                	bnez	a5,80000fb2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000fc8:	86ba                	mv	a3,a4
    80000fca:	00c05c63          	blez	a2,80000fe2 <strncpy+0x38>
    *s++ = 0;
    80000fce:	0685                	addi	a3,a3,1
    80000fd0:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000fd4:	fff6c793          	not	a5,a3
    80000fd8:	9fb9                	addw	a5,a5,a4
    80000fda:	010787bb          	addw	a5,a5,a6
    80000fde:	fef048e3          	bgtz	a5,80000fce <strncpy+0x24>
  return os;
}
    80000fe2:	6422                	ld	s0,8(sp)
    80000fe4:	0141                	addi	sp,sp,16
    80000fe6:	8082                	ret

0000000080000fe8 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000fee:	02c05363          	blez	a2,80001014 <safestrcpy+0x2c>
    80000ff2:	fff6069b          	addiw	a3,a2,-1
    80000ff6:	1682                	slli	a3,a3,0x20
    80000ff8:	9281                	srli	a3,a3,0x20
    80000ffa:	96ae                	add	a3,a3,a1
    80000ffc:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ffe:	00d58963          	beq	a1,a3,80001010 <safestrcpy+0x28>
    80001002:	0585                	addi	a1,a1,1
    80001004:	0785                	addi	a5,a5,1
    80001006:	fff5c703          	lbu	a4,-1(a1)
    8000100a:	fee78fa3          	sb	a4,-1(a5)
    8000100e:	fb65                	bnez	a4,80000ffe <safestrcpy+0x16>
    ;
  *s = 0;
    80001010:	00078023          	sb	zero,0(a5)
  return os;
}
    80001014:	6422                	ld	s0,8(sp)
    80001016:	0141                	addi	sp,sp,16
    80001018:	8082                	ret

000000008000101a <strlen>:

int
strlen(const char *s)
{
    8000101a:	1141                	addi	sp,sp,-16
    8000101c:	e422                	sd	s0,8(sp)
    8000101e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001020:	00054783          	lbu	a5,0(a0)
    80001024:	cf91                	beqz	a5,80001040 <strlen+0x26>
    80001026:	0505                	addi	a0,a0,1
    80001028:	87aa                	mv	a5,a0
    8000102a:	4685                	li	a3,1
    8000102c:	9e89                	subw	a3,a3,a0
    8000102e:	00f6853b          	addw	a0,a3,a5
    80001032:	0785                	addi	a5,a5,1
    80001034:	fff7c703          	lbu	a4,-1(a5)
    80001038:	fb7d                	bnez	a4,8000102e <strlen+0x14>
    ;
  return n;
}
    8000103a:	6422                	ld	s0,8(sp)
    8000103c:	0141                	addi	sp,sp,16
    8000103e:	8082                	ret
  for(n = 0; s[n]; n++)
    80001040:	4501                	li	a0,0
    80001042:	bfe5                	j	8000103a <strlen+0x20>

0000000080001044 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001044:	1141                	addi	sp,sp,-16
    80001046:	e406                	sd	ra,8(sp)
    80001048:	e022                	sd	s0,0(sp)
    8000104a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000104c:	00001097          	auipc	ra,0x1
    80001050:	b08080e7          	jalr	-1272(ra) # 80001b54 <cpuid>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80001054:	0002f717          	auipc	a4,0x2f
    80001058:	fd470713          	addi	a4,a4,-44 # 80030028 <started>
  if(cpuid() == 0){
    8000105c:	c139                	beqz	a0,800010a2 <main+0x5e>
    while(started == 0)
    8000105e:	431c                	lw	a5,0(a4)
    80001060:	2781                	sext.w	a5,a5
    80001062:	dff5                	beqz	a5,8000105e <main+0x1a>
      ;
    __sync_synchronize();
    80001064:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001068:	00001097          	auipc	ra,0x1
    8000106c:	aec080e7          	jalr	-1300(ra) # 80001b54 <cpuid>
    80001070:	85aa                	mv	a1,a0
    80001072:	00007517          	auipc	a0,0x7
    80001076:	28650513          	addi	a0,a0,646 # 800082f8 <userret+0x268>
    8000107a:	fffff097          	auipc	ra,0xfffff
    8000107e:	528080e7          	jalr	1320(ra) # 800005a2 <printf>
    kvminithart();    // turn on paging
    80001082:	00000097          	auipc	ra,0x0
    80001086:	1ea080e7          	jalr	490(ra) # 8000126c <kvminithart>
    trapinithart();   // install kernel trap vector
    8000108a:	00001097          	auipc	ra,0x1
    8000108e:	714080e7          	jalr	1812(ra) # 8000279e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001092:	00005097          	auipc	ra,0x5
    80001096:	eee080e7          	jalr	-274(ra) # 80005f80 <plicinithart>
  }

  scheduler();        
    8000109a:	00001097          	auipc	ra,0x1
    8000109e:	fc4080e7          	jalr	-60(ra) # 8000205e <scheduler>
    consoleinit();
    800010a2:	fffff097          	auipc	ra,0xfffff
    800010a6:	3b8080e7          	jalr	952(ra) # 8000045a <consoleinit>
    printfinit();
    800010aa:	fffff097          	auipc	ra,0xfffff
    800010ae:	6d8080e7          	jalr	1752(ra) # 80000782 <printfinit>
    printf("\n");
    800010b2:	00007517          	auipc	a0,0x7
    800010b6:	1de50513          	addi	a0,a0,478 # 80008290 <userret+0x200>
    800010ba:	fffff097          	auipc	ra,0xfffff
    800010be:	4e8080e7          	jalr	1256(ra) # 800005a2 <printf>
    printf("xv6 kernel is booting\n");
    800010c2:	00007517          	auipc	a0,0x7
    800010c6:	21e50513          	addi	a0,a0,542 # 800082e0 <userret+0x250>
    800010ca:	fffff097          	auipc	ra,0xfffff
    800010ce:	4d8080e7          	jalr	1240(ra) # 800005a2 <printf>
    printf("\n");
    800010d2:	00007517          	auipc	a0,0x7
    800010d6:	1be50513          	addi	a0,a0,446 # 80008290 <userret+0x200>
    800010da:	fffff097          	auipc	ra,0xfffff
    800010de:	4c8080e7          	jalr	1224(ra) # 800005a2 <printf>
    kinit();         // physical page allocator
    800010e2:	00000097          	auipc	ra,0x0
    800010e6:	874080e7          	jalr	-1932(ra) # 80000956 <kinit>
    kvminit();       // create kernel page table
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	30c080e7          	jalr	780(ra) # 800013f6 <kvminit>
    kvminithart();   // turn on paging
    800010f2:	00000097          	auipc	ra,0x0
    800010f6:	17a080e7          	jalr	378(ra) # 8000126c <kvminithart>
    procinit();      // process table
    800010fa:	00001097          	auipc	ra,0x1
    800010fe:	98a080e7          	jalr	-1654(ra) # 80001a84 <procinit>
    trapinit();      // trap vectors
    80001102:	00001097          	auipc	ra,0x1
    80001106:	674080e7          	jalr	1652(ra) # 80002776 <trapinit>
    trapinithart();  // install kernel trap vector
    8000110a:	00001097          	auipc	ra,0x1
    8000110e:	694080e7          	jalr	1684(ra) # 8000279e <trapinithart>
    plicinit();      // set up interrupt controller
    80001112:	00005097          	auipc	ra,0x5
    80001116:	e58080e7          	jalr	-424(ra) # 80005f6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000111a:	00005097          	auipc	ra,0x5
    8000111e:	e66080e7          	jalr	-410(ra) # 80005f80 <plicinithart>
    binit();         // buffer cache
    80001122:	00002097          	auipc	ra,0x2
    80001126:	dca080e7          	jalr	-566(ra) # 80002eec <binit>
    iinit();         // inode cache
    8000112a:	00002097          	auipc	ra,0x2
    8000112e:	57c080e7          	jalr	1404(ra) # 800036a6 <iinit>
    fileinit();      // file table
    80001132:	00003097          	auipc	ra,0x3
    80001136:	608080e7          	jalr	1544(ra) # 8000473a <fileinit>
    virtio_disk_init(minor(ROOTDEV)); // emulated hard disk
    8000113a:	4501                	li	a0,0
    8000113c:	00005097          	auipc	ra,0x5
    80001140:	f66080e7          	jalr	-154(ra) # 800060a2 <virtio_disk_init>
    userinit();      // first user process
    80001144:	00001097          	auipc	ra,0x1
    80001148:	cb0080e7          	jalr	-848(ra) # 80001df4 <userinit>
    __sync_synchronize();
    8000114c:	0ff0000f          	fence
    started = 1;
    80001150:	4785                	li	a5,1
    80001152:	0002f717          	auipc	a4,0x2f
    80001156:	ecf72b23          	sw	a5,-298(a4) # 80030028 <started>
    8000115a:	b781                	j	8000109a <main+0x56>

000000008000115c <walk>:
//   21..39 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..12 -- 12 bits of byte offset within the page.
static pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000115c:	7139                	addi	sp,sp,-64
    8000115e:	fc06                	sd	ra,56(sp)
    80001160:	f822                	sd	s0,48(sp)
    80001162:	f426                	sd	s1,40(sp)
    80001164:	f04a                	sd	s2,32(sp)
    80001166:	ec4e                	sd	s3,24(sp)
    80001168:	e852                	sd	s4,16(sp)
    8000116a:	e456                	sd	s5,8(sp)
    8000116c:	e05a                	sd	s6,0(sp)
    8000116e:	0080                	addi	s0,sp,64
    80001170:	84aa                	mv	s1,a0
    80001172:	89ae                	mv	s3,a1
    80001174:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001176:	57fd                	li	a5,-1
    80001178:	83e9                	srli	a5,a5,0x1a
    8000117a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000117c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000117e:	04b7f263          	bgeu	a5,a1,800011c2 <walk+0x66>
    panic("walk");
    80001182:	00007517          	auipc	a0,0x7
    80001186:	18e50513          	addi	a0,a0,398 # 80008310 <userret+0x280>
    8000118a:	fffff097          	auipc	ra,0xfffff
    8000118e:	3be080e7          	jalr	958(ra) # 80000548 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001192:	060a8663          	beqz	s5,800011fe <walk+0xa2>
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	8bc080e7          	jalr	-1860(ra) # 80000a52 <kalloc>
    8000119e:	84aa                	mv	s1,a0
    800011a0:	c529                	beqz	a0,800011ea <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800011a2:	6605                	lui	a2,0x1
    800011a4:	4581                	li	a1,0
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	cf0080e7          	jalr	-784(ra) # 80000e96 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800011ae:	00c4d793          	srli	a5,s1,0xc
    800011b2:	07aa                	slli	a5,a5,0xa
    800011b4:	0017e793          	ori	a5,a5,1
    800011b8:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800011bc:	3a5d                	addiw	s4,s4,-9
    800011be:	036a0063          	beq	s4,s6,800011de <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800011c2:	0149d933          	srl	s2,s3,s4
    800011c6:	1ff97913          	andi	s2,s2,511
    800011ca:	090e                	slli	s2,s2,0x3
    800011cc:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800011ce:	00093483          	ld	s1,0(s2)
    800011d2:	0014f793          	andi	a5,s1,1
    800011d6:	dfd5                	beqz	a5,80001192 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800011d8:	80a9                	srli	s1,s1,0xa
    800011da:	04b2                	slli	s1,s1,0xc
    800011dc:	b7c5                	j	800011bc <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800011de:	00c9d513          	srli	a0,s3,0xc
    800011e2:	1ff57513          	andi	a0,a0,511
    800011e6:	050e                	slli	a0,a0,0x3
    800011e8:	9526                	add	a0,a0,s1
}
    800011ea:	70e2                	ld	ra,56(sp)
    800011ec:	7442                	ld	s0,48(sp)
    800011ee:	74a2                	ld	s1,40(sp)
    800011f0:	7902                	ld	s2,32(sp)
    800011f2:	69e2                	ld	s3,24(sp)
    800011f4:	6a42                	ld	s4,16(sp)
    800011f6:	6aa2                	ld	s5,8(sp)
    800011f8:	6b02                	ld	s6,0(sp)
    800011fa:	6121                	addi	sp,sp,64
    800011fc:	8082                	ret
        return 0;
    800011fe:	4501                	li	a0,0
    80001200:	b7ed                	j	800011ea <walk+0x8e>

0000000080001202 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
static void
freewalk(pagetable_t pagetable)
{
    80001202:	7179                	addi	sp,sp,-48
    80001204:	f406                	sd	ra,40(sp)
    80001206:	f022                	sd	s0,32(sp)
    80001208:	ec26                	sd	s1,24(sp)
    8000120a:	e84a                	sd	s2,16(sp)
    8000120c:	e44e                	sd	s3,8(sp)
    8000120e:	e052                	sd	s4,0(sp)
    80001210:	1800                	addi	s0,sp,48
    80001212:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001214:	84aa                	mv	s1,a0
    80001216:	6905                	lui	s2,0x1
    80001218:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000121a:	4985                	li	s3,1
    8000121c:	a821                	j	80001234 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000121e:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001220:	0532                	slli	a0,a0,0xc
    80001222:	00000097          	auipc	ra,0x0
    80001226:	fe0080e7          	jalr	-32(ra) # 80001202 <freewalk>
      pagetable[i] = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000122e:	04a1                	addi	s1,s1,8
    80001230:	03248163          	beq	s1,s2,80001252 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001234:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001236:	00f57793          	andi	a5,a0,15
    8000123a:	ff3782e3          	beq	a5,s3,8000121e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000123e:	8905                	andi	a0,a0,1
    80001240:	d57d                	beqz	a0,8000122e <freewalk+0x2c>
      panic("freewalk: leaf");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	0d650513          	addi	a0,a0,214 # 80008318 <userret+0x288>
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	2fe080e7          	jalr	766(ra) # 80000548 <panic>
    }
  }
  kfree((void*)pagetable);
    80001252:	8552                	mv	a0,s4
    80001254:	fffff097          	auipc	ra,0xfffff
    80001258:	610080e7          	jalr	1552(ra) # 80000864 <kfree>
}
    8000125c:	70a2                	ld	ra,40(sp)
    8000125e:	7402                	ld	s0,32(sp)
    80001260:	64e2                	ld	s1,24(sp)
    80001262:	6942                	ld	s2,16(sp)
    80001264:	69a2                	ld	s3,8(sp)
    80001266:	6a02                	ld	s4,0(sp)
    80001268:	6145                	addi	sp,sp,48
    8000126a:	8082                	ret

000000008000126c <kvminithart>:
{
    8000126c:	1141                	addi	sp,sp,-16
    8000126e:	e422                	sd	s0,8(sp)
    80001270:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001272:	0002f797          	auipc	a5,0x2f
    80001276:	dbe7b783          	ld	a5,-578(a5) # 80030030 <kernel_pagetable>
    8000127a:	83b1                	srli	a5,a5,0xc
    8000127c:	577d                	li	a4,-1
    8000127e:	177e                	slli	a4,a4,0x3f
    80001280:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001282:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001286:	12000073          	sfence.vma
}
    8000128a:	6422                	ld	s0,8(sp)
    8000128c:	0141                	addi	sp,sp,16
    8000128e:	8082                	ret

0000000080001290 <walkaddr>:
  if(va >= MAXVA)
    80001290:	57fd                	li	a5,-1
    80001292:	83e9                	srli	a5,a5,0x1a
    80001294:	00b7f463          	bgeu	a5,a1,8000129c <walkaddr+0xc>
    return 0;
    80001298:	4501                	li	a0,0
}
    8000129a:	8082                	ret
{
    8000129c:	1141                	addi	sp,sp,-16
    8000129e:	e406                	sd	ra,8(sp)
    800012a0:	e022                	sd	s0,0(sp)
    800012a2:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800012a4:	4601                	li	a2,0
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	eb6080e7          	jalr	-330(ra) # 8000115c <walk>
  if(pte == 0)
    800012ae:	c105                	beqz	a0,800012ce <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800012b0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800012b2:	0117f693          	andi	a3,a5,17
    800012b6:	4745                	li	a4,17
    return 0;
    800012b8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800012ba:	00e68663          	beq	a3,a4,800012c6 <walkaddr+0x36>
}
    800012be:	60a2                	ld	ra,8(sp)
    800012c0:	6402                	ld	s0,0(sp)
    800012c2:	0141                	addi	sp,sp,16
    800012c4:	8082                	ret
  pa = PTE2PA(*pte);
    800012c6:	00a7d513          	srli	a0,a5,0xa
    800012ca:	0532                	slli	a0,a0,0xc
  return pa;
    800012cc:	bfcd                	j	800012be <walkaddr+0x2e>
    return 0;
    800012ce:	4501                	li	a0,0
    800012d0:	b7fd                	j	800012be <walkaddr+0x2e>

00000000800012d2 <kvmpa>:
{
    800012d2:	1101                	addi	sp,sp,-32
    800012d4:	ec06                	sd	ra,24(sp)
    800012d6:	e822                	sd	s0,16(sp)
    800012d8:	e426                	sd	s1,8(sp)
    800012da:	1000                	addi	s0,sp,32
    800012dc:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    800012de:	1552                	slli	a0,a0,0x34
    800012e0:	03455493          	srli	s1,a0,0x34
  pte = walk(kernel_pagetable, va, 0);
    800012e4:	4601                	li	a2,0
    800012e6:	0002f517          	auipc	a0,0x2f
    800012ea:	d4a53503          	ld	a0,-694(a0) # 80030030 <kernel_pagetable>
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	e6e080e7          	jalr	-402(ra) # 8000115c <walk>
  if(pte == 0)
    800012f6:	cd09                	beqz	a0,80001310 <kvmpa+0x3e>
  if((*pte & PTE_V) == 0)
    800012f8:	6108                	ld	a0,0(a0)
    800012fa:	00157793          	andi	a5,a0,1
    800012fe:	c38d                	beqz	a5,80001320 <kvmpa+0x4e>
  pa = PTE2PA(*pte);
    80001300:	8129                	srli	a0,a0,0xa
    80001302:	0532                	slli	a0,a0,0xc
}
    80001304:	9526                	add	a0,a0,s1
    80001306:	60e2                	ld	ra,24(sp)
    80001308:	6442                	ld	s0,16(sp)
    8000130a:	64a2                	ld	s1,8(sp)
    8000130c:	6105                	addi	sp,sp,32
    8000130e:	8082                	ret
    panic("kvmpa");
    80001310:	00007517          	auipc	a0,0x7
    80001314:	01850513          	addi	a0,a0,24 # 80008328 <userret+0x298>
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	230080e7          	jalr	560(ra) # 80000548 <panic>
    panic("kvmpa");
    80001320:	00007517          	auipc	a0,0x7
    80001324:	00850513          	addi	a0,a0,8 # 80008328 <userret+0x298>
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	220080e7          	jalr	544(ra) # 80000548 <panic>

0000000080001330 <mappages>:
{
    80001330:	715d                	addi	sp,sp,-80
    80001332:	e486                	sd	ra,72(sp)
    80001334:	e0a2                	sd	s0,64(sp)
    80001336:	fc26                	sd	s1,56(sp)
    80001338:	f84a                	sd	s2,48(sp)
    8000133a:	f44e                	sd	s3,40(sp)
    8000133c:	f052                	sd	s4,32(sp)
    8000133e:	ec56                	sd	s5,24(sp)
    80001340:	e85a                	sd	s6,16(sp)
    80001342:	e45e                	sd	s7,8(sp)
    80001344:	0880                	addi	s0,sp,80
    80001346:	8aaa                	mv	s5,a0
    80001348:	8b3a                	mv	s6,a4
  a = PGROUNDDOWN(va);
    8000134a:	777d                	lui	a4,0xfffff
    8000134c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001350:	167d                	addi	a2,a2,-1
    80001352:	00b609b3          	add	s3,a2,a1
    80001356:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000135a:	893e                	mv	s2,a5
    8000135c:	40f68a33          	sub	s4,a3,a5
    a += PGSIZE;
    80001360:	6b85                	lui	s7,0x1
    80001362:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001366:	4605                	li	a2,1
    80001368:	85ca                	mv	a1,s2
    8000136a:	8556                	mv	a0,s5
    8000136c:	00000097          	auipc	ra,0x0
    80001370:	df0080e7          	jalr	-528(ra) # 8000115c <walk>
    80001374:	c51d                	beqz	a0,800013a2 <mappages+0x72>
    if(*pte & PTE_V)
    80001376:	611c                	ld	a5,0(a0)
    80001378:	8b85                	andi	a5,a5,1
    8000137a:	ef81                	bnez	a5,80001392 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000137c:	80b1                	srli	s1,s1,0xc
    8000137e:	04aa                	slli	s1,s1,0xa
    80001380:	0164e4b3          	or	s1,s1,s6
    80001384:	0014e493          	ori	s1,s1,1
    80001388:	e104                	sd	s1,0(a0)
    if(a == last)
    8000138a:	03390863          	beq	s2,s3,800013ba <mappages+0x8a>
    a += PGSIZE;
    8000138e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001390:	bfc9                	j	80001362 <mappages+0x32>
      panic("remap");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	f9e50513          	addi	a0,a0,-98 # 80008330 <userret+0x2a0>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	1ae080e7          	jalr	430(ra) # 80000548 <panic>
      return -1;
    800013a2:	557d                	li	a0,-1
}
    800013a4:	60a6                	ld	ra,72(sp)
    800013a6:	6406                	ld	s0,64(sp)
    800013a8:	74e2                	ld	s1,56(sp)
    800013aa:	7942                	ld	s2,48(sp)
    800013ac:	79a2                	ld	s3,40(sp)
    800013ae:	7a02                	ld	s4,32(sp)
    800013b0:	6ae2                	ld	s5,24(sp)
    800013b2:	6b42                	ld	s6,16(sp)
    800013b4:	6ba2                	ld	s7,8(sp)
    800013b6:	6161                	addi	sp,sp,80
    800013b8:	8082                	ret
  return 0;
    800013ba:	4501                	li	a0,0
    800013bc:	b7e5                	j	800013a4 <mappages+0x74>

00000000800013be <kvmmap>:
{
    800013be:	1141                	addi	sp,sp,-16
    800013c0:	e406                	sd	ra,8(sp)
    800013c2:	e022                	sd	s0,0(sp)
    800013c4:	0800                	addi	s0,sp,16
    800013c6:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    800013c8:	86ae                	mv	a3,a1
    800013ca:	85aa                	mv	a1,a0
    800013cc:	0002f517          	auipc	a0,0x2f
    800013d0:	c6453503          	ld	a0,-924(a0) # 80030030 <kernel_pagetable>
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	f5c080e7          	jalr	-164(ra) # 80001330 <mappages>
    800013dc:	e509                	bnez	a0,800013e6 <kvmmap+0x28>
}
    800013de:	60a2                	ld	ra,8(sp)
    800013e0:	6402                	ld	s0,0(sp)
    800013e2:	0141                	addi	sp,sp,16
    800013e4:	8082                	ret
    panic("kvmmap");
    800013e6:	00007517          	auipc	a0,0x7
    800013ea:	f5250513          	addi	a0,a0,-174 # 80008338 <userret+0x2a8>
    800013ee:	fffff097          	auipc	ra,0xfffff
    800013f2:	15a080e7          	jalr	346(ra) # 80000548 <panic>

00000000800013f6 <kvminit>:
{
    800013f6:	1101                	addi	sp,sp,-32
    800013f8:	ec06                	sd	ra,24(sp)
    800013fa:	e822                	sd	s0,16(sp)
    800013fc:	e426                	sd	s1,8(sp)
    800013fe:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001400:	fffff097          	auipc	ra,0xfffff
    80001404:	652080e7          	jalr	1618(ra) # 80000a52 <kalloc>
    80001408:	0002f797          	auipc	a5,0x2f
    8000140c:	c2a7b423          	sd	a0,-984(a5) # 80030030 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001410:	6605                	lui	a2,0x1
    80001412:	4581                	li	a1,0
    80001414:	00000097          	auipc	ra,0x0
    80001418:	a82080e7          	jalr	-1406(ra) # 80000e96 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000141c:	4699                	li	a3,6
    8000141e:	6605                	lui	a2,0x1
    80001420:	100005b7          	lui	a1,0x10000
    80001424:	10000537          	lui	a0,0x10000
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	f96080e7          	jalr	-106(ra) # 800013be <kvmmap>
  kvmmap(VIRTION(0), VIRTION(0), PGSIZE, PTE_R | PTE_W);
    80001430:	4699                	li	a3,6
    80001432:	6605                	lui	a2,0x1
    80001434:	100015b7          	lui	a1,0x10001
    80001438:	10001537          	lui	a0,0x10001
    8000143c:	00000097          	auipc	ra,0x0
    80001440:	f82080e7          	jalr	-126(ra) # 800013be <kvmmap>
  kvmmap(VIRTION(1), VIRTION(1), PGSIZE, PTE_R | PTE_W);
    80001444:	4699                	li	a3,6
    80001446:	6605                	lui	a2,0x1
    80001448:	100025b7          	lui	a1,0x10002
    8000144c:	10002537          	lui	a0,0x10002
    80001450:	00000097          	auipc	ra,0x0
    80001454:	f6e080e7          	jalr	-146(ra) # 800013be <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001458:	4699                	li	a3,6
    8000145a:	6641                	lui	a2,0x10
    8000145c:	020005b7          	lui	a1,0x2000
    80001460:	02000537          	lui	a0,0x2000
    80001464:	00000097          	auipc	ra,0x0
    80001468:	f5a080e7          	jalr	-166(ra) # 800013be <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000146c:	4699                	li	a3,6
    8000146e:	00400637          	lui	a2,0x400
    80001472:	0c0005b7          	lui	a1,0xc000
    80001476:	0c000537          	lui	a0,0xc000
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f44080e7          	jalr	-188(ra) # 800013be <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001482:	00008497          	auipc	s1,0x8
    80001486:	b7e48493          	addi	s1,s1,-1154 # 80009000 <initcode>
    8000148a:	46a9                	li	a3,10
    8000148c:	80008617          	auipc	a2,0x80008
    80001490:	b7460613          	addi	a2,a2,-1164 # 9000 <_entry-0x7fff7000>
    80001494:	4585                	li	a1,1
    80001496:	05fe                	slli	a1,a1,0x1f
    80001498:	852e                	mv	a0,a1
    8000149a:	00000097          	auipc	ra,0x0
    8000149e:	f24080e7          	jalr	-220(ra) # 800013be <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800014a2:	4699                	li	a3,6
    800014a4:	4645                	li	a2,17
    800014a6:	066e                	slli	a2,a2,0x1b
    800014a8:	8e05                	sub	a2,a2,s1
    800014aa:	85a6                	mv	a1,s1
    800014ac:	8526                	mv	a0,s1
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f10080e7          	jalr	-240(ra) # 800013be <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800014b6:	46a9                	li	a3,10
    800014b8:	6605                	lui	a2,0x1
    800014ba:	00007597          	auipc	a1,0x7
    800014be:	b4658593          	addi	a1,a1,-1210 # 80008000 <trampoline>
    800014c2:	04000537          	lui	a0,0x4000
    800014c6:	157d                	addi	a0,a0,-1
    800014c8:	0532                	slli	a0,a0,0xc
    800014ca:	00000097          	auipc	ra,0x0
    800014ce:	ef4080e7          	jalr	-268(ra) # 800013be <kvmmap>
}
    800014d2:	60e2                	ld	ra,24(sp)
    800014d4:	6442                	ld	s0,16(sp)
    800014d6:	64a2                	ld	s1,8(sp)
    800014d8:	6105                	addi	sp,sp,32
    800014da:	8082                	ret

00000000800014dc <uvmunmap>:
{
    800014dc:	715d                	addi	sp,sp,-80
    800014de:	e486                	sd	ra,72(sp)
    800014e0:	e0a2                	sd	s0,64(sp)
    800014e2:	fc26                	sd	s1,56(sp)
    800014e4:	f84a                	sd	s2,48(sp)
    800014e6:	f44e                	sd	s3,40(sp)
    800014e8:	f052                	sd	s4,32(sp)
    800014ea:	ec56                	sd	s5,24(sp)
    800014ec:	e85a                	sd	s6,16(sp)
    800014ee:	e45e                	sd	s7,8(sp)
    800014f0:	0880                	addi	s0,sp,80
    800014f2:	8a2a                	mv	s4,a0
    800014f4:	8ab6                	mv	s5,a3
  a = PGROUNDDOWN(va);
    800014f6:	77fd                	lui	a5,0xfffff
    800014f8:	00f5f933          	and	s2,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800014fc:	167d                	addi	a2,a2,-1
    800014fe:	00b609b3          	add	s3,a2,a1
    80001502:	00f9f9b3          	and	s3,s3,a5
    if(PTE_FLAGS(*pte) == PTE_V)
    80001506:	4b05                	li	s6,1
    a += PGSIZE;
    80001508:	6b85                	lui	s7,0x1
    8000150a:	a0b9                	j	80001558 <uvmunmap+0x7c>
      panic("uvmunmap: walk");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	e3450513          	addi	a0,a0,-460 # 80008340 <userret+0x2b0>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	034080e7          	jalr	52(ra) # 80000548 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    8000151c:	85ca                	mv	a1,s2
    8000151e:	00007517          	auipc	a0,0x7
    80001522:	e3250513          	addi	a0,a0,-462 # 80008350 <userret+0x2c0>
    80001526:	fffff097          	auipc	ra,0xfffff
    8000152a:	07c080e7          	jalr	124(ra) # 800005a2 <printf>
      panic("uvmunmap: not mapped");
    8000152e:	00007517          	auipc	a0,0x7
    80001532:	e3250513          	addi	a0,a0,-462 # 80008360 <userret+0x2d0>
    80001536:	fffff097          	auipc	ra,0xfffff
    8000153a:	012080e7          	jalr	18(ra) # 80000548 <panic>
      panic("uvmunmap: not a leaf");
    8000153e:	00007517          	auipc	a0,0x7
    80001542:	e3a50513          	addi	a0,a0,-454 # 80008378 <userret+0x2e8>
    80001546:	fffff097          	auipc	ra,0xfffff
    8000154a:	002080e7          	jalr	2(ra) # 80000548 <panic>
    *pte = 0;
    8000154e:	0004b023          	sd	zero,0(s1)
    if(a == last)
    80001552:	03390e63          	beq	s2,s3,8000158e <uvmunmap+0xb2>
    a += PGSIZE;
    80001556:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 0)) == 0)
    80001558:	4601                	li	a2,0
    8000155a:	85ca                	mv	a1,s2
    8000155c:	8552                	mv	a0,s4
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	bfe080e7          	jalr	-1026(ra) # 8000115c <walk>
    80001566:	84aa                	mv	s1,a0
    80001568:	d155                	beqz	a0,8000150c <uvmunmap+0x30>
    if((*pte & PTE_V) == 0){
    8000156a:	6110                	ld	a2,0(a0)
    8000156c:	00167793          	andi	a5,a2,1
    80001570:	d7d5                	beqz	a5,8000151c <uvmunmap+0x40>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001572:	3ff67793          	andi	a5,a2,1023
    80001576:	fd6784e3          	beq	a5,s6,8000153e <uvmunmap+0x62>
    if(do_free){
    8000157a:	fc0a8ae3          	beqz	s5,8000154e <uvmunmap+0x72>
      pa = PTE2PA(*pte);
    8000157e:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80001580:	00c61513          	slli	a0,a2,0xc
    80001584:	fffff097          	auipc	ra,0xfffff
    80001588:	2e0080e7          	jalr	736(ra) # 80000864 <kfree>
    8000158c:	b7c9                	j	8000154e <uvmunmap+0x72>
}
    8000158e:	60a6                	ld	ra,72(sp)
    80001590:	6406                	ld	s0,64(sp)
    80001592:	74e2                	ld	s1,56(sp)
    80001594:	7942                	ld	s2,48(sp)
    80001596:	79a2                	ld	s3,40(sp)
    80001598:	7a02                	ld	s4,32(sp)
    8000159a:	6ae2                	ld	s5,24(sp)
    8000159c:	6b42                	ld	s6,16(sp)
    8000159e:	6ba2                	ld	s7,8(sp)
    800015a0:	6161                	addi	sp,sp,80
    800015a2:	8082                	ret

00000000800015a4 <uvmcreate>:
{
    800015a4:	1101                	addi	sp,sp,-32
    800015a6:	ec06                	sd	ra,24(sp)
    800015a8:	e822                	sd	s0,16(sp)
    800015aa:	e426                	sd	s1,8(sp)
    800015ac:	1000                	addi	s0,sp,32
  pagetable = (pagetable_t) kalloc();
    800015ae:	fffff097          	auipc	ra,0xfffff
    800015b2:	4a4080e7          	jalr	1188(ra) # 80000a52 <kalloc>
  if(pagetable == 0)
    800015b6:	cd11                	beqz	a0,800015d2 <uvmcreate+0x2e>
    800015b8:	84aa                	mv	s1,a0
  memset(pagetable, 0, PGSIZE);
    800015ba:	6605                	lui	a2,0x1
    800015bc:	4581                	li	a1,0
    800015be:	00000097          	auipc	ra,0x0
    800015c2:	8d8080e7          	jalr	-1832(ra) # 80000e96 <memset>
}
    800015c6:	8526                	mv	a0,s1
    800015c8:	60e2                	ld	ra,24(sp)
    800015ca:	6442                	ld	s0,16(sp)
    800015cc:	64a2                	ld	s1,8(sp)
    800015ce:	6105                	addi	sp,sp,32
    800015d0:	8082                	ret
    panic("uvmcreate: out of memory");
    800015d2:	00007517          	auipc	a0,0x7
    800015d6:	dbe50513          	addi	a0,a0,-578 # 80008390 <userret+0x300>
    800015da:	fffff097          	auipc	ra,0xfffff
    800015de:	f6e080e7          	jalr	-146(ra) # 80000548 <panic>

00000000800015e2 <uvminit>:
{
    800015e2:	7179                	addi	sp,sp,-48
    800015e4:	f406                	sd	ra,40(sp)
    800015e6:	f022                	sd	s0,32(sp)
    800015e8:	ec26                	sd	s1,24(sp)
    800015ea:	e84a                	sd	s2,16(sp)
    800015ec:	e44e                	sd	s3,8(sp)
    800015ee:	e052                	sd	s4,0(sp)
    800015f0:	1800                	addi	s0,sp,48
  if(sz >= PGSIZE)
    800015f2:	6785                	lui	a5,0x1
    800015f4:	04f67863          	bgeu	a2,a5,80001644 <uvminit+0x62>
    800015f8:	8a2a                	mv	s4,a0
    800015fa:	89ae                	mv	s3,a1
    800015fc:	84b2                	mv	s1,a2
  mem = kalloc();
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	454080e7          	jalr	1108(ra) # 80000a52 <kalloc>
    80001606:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001608:	6605                	lui	a2,0x1
    8000160a:	4581                	li	a1,0
    8000160c:	00000097          	auipc	ra,0x0
    80001610:	88a080e7          	jalr	-1910(ra) # 80000e96 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001614:	4779                	li	a4,30
    80001616:	86ca                	mv	a3,s2
    80001618:	6605                	lui	a2,0x1
    8000161a:	4581                	li	a1,0
    8000161c:	8552                	mv	a0,s4
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	d12080e7          	jalr	-750(ra) # 80001330 <mappages>
  memmove(mem, src, sz);
    80001626:	8626                	mv	a2,s1
    80001628:	85ce                	mv	a1,s3
    8000162a:	854a                	mv	a0,s2
    8000162c:	00000097          	auipc	ra,0x0
    80001630:	8c6080e7          	jalr	-1850(ra) # 80000ef2 <memmove>
}
    80001634:	70a2                	ld	ra,40(sp)
    80001636:	7402                	ld	s0,32(sp)
    80001638:	64e2                	ld	s1,24(sp)
    8000163a:	6942                	ld	s2,16(sp)
    8000163c:	69a2                	ld	s3,8(sp)
    8000163e:	6a02                	ld	s4,0(sp)
    80001640:	6145                	addi	sp,sp,48
    80001642:	8082                	ret
    panic("inituvm: more than a page");
    80001644:	00007517          	auipc	a0,0x7
    80001648:	d6c50513          	addi	a0,a0,-660 # 800083b0 <userret+0x320>
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	efc080e7          	jalr	-260(ra) # 80000548 <panic>

0000000080001654 <uvmdealloc>:
{
    80001654:	1101                	addi	sp,sp,-32
    80001656:	ec06                	sd	ra,24(sp)
    80001658:	e822                	sd	s0,16(sp)
    8000165a:	e426                	sd	s1,8(sp)
    8000165c:	1000                	addi	s0,sp,32
    return oldsz;
    8000165e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001660:	00b67d63          	bgeu	a2,a1,8000167a <uvmdealloc+0x26>
    80001664:	84b2                	mv	s1,a2
  uint64 newup = PGROUNDUP(newsz);
    80001666:	6785                	lui	a5,0x1
    80001668:	17fd                	addi	a5,a5,-1
    8000166a:	00f60733          	add	a4,a2,a5
    8000166e:	76fd                	lui	a3,0xfffff
    80001670:	8f75                	and	a4,a4,a3
  if(newup < PGROUNDUP(oldsz))
    80001672:	97ae                	add	a5,a5,a1
    80001674:	8ff5                	and	a5,a5,a3
    80001676:	00f76863          	bltu	a4,a5,80001686 <uvmdealloc+0x32>
}
    8000167a:	8526                	mv	a0,s1
    8000167c:	60e2                	ld	ra,24(sp)
    8000167e:	6442                	ld	s0,16(sp)
    80001680:	64a2                	ld	s1,8(sp)
    80001682:	6105                	addi	sp,sp,32
    80001684:	8082                	ret
    uvmunmap(pagetable, newup, oldsz - newup, 1);
    80001686:	4685                	li	a3,1
    80001688:	40e58633          	sub	a2,a1,a4
    8000168c:	85ba                	mv	a1,a4
    8000168e:	00000097          	auipc	ra,0x0
    80001692:	e4e080e7          	jalr	-434(ra) # 800014dc <uvmunmap>
    80001696:	b7d5                	j	8000167a <uvmdealloc+0x26>

0000000080001698 <uvmalloc>:
  if(newsz < oldsz)
    80001698:	0ab66163          	bltu	a2,a1,8000173a <uvmalloc+0xa2>
{
    8000169c:	7139                	addi	sp,sp,-64
    8000169e:	fc06                	sd	ra,56(sp)
    800016a0:	f822                	sd	s0,48(sp)
    800016a2:	f426                	sd	s1,40(sp)
    800016a4:	f04a                	sd	s2,32(sp)
    800016a6:	ec4e                	sd	s3,24(sp)
    800016a8:	e852                	sd	s4,16(sp)
    800016aa:	e456                	sd	s5,8(sp)
    800016ac:	0080                	addi	s0,sp,64
    800016ae:	8aaa                	mv	s5,a0
    800016b0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800016b2:	6985                	lui	s3,0x1
    800016b4:	19fd                	addi	s3,s3,-1
    800016b6:	95ce                	add	a1,a1,s3
    800016b8:	79fd                	lui	s3,0xfffff
    800016ba:	0135f9b3          	and	s3,a1,s3
  for(; a < newsz; a += PGSIZE){
    800016be:	08c9f063          	bgeu	s3,a2,8000173e <uvmalloc+0xa6>
  a = oldsz;
    800016c2:	894e                	mv	s2,s3
    mem = kalloc();
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	38e080e7          	jalr	910(ra) # 80000a52 <kalloc>
    800016cc:	84aa                	mv	s1,a0
    if(mem == 0){
    800016ce:	c51d                	beqz	a0,800016fc <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800016d0:	6605                	lui	a2,0x1
    800016d2:	4581                	li	a1,0
    800016d4:	fffff097          	auipc	ra,0xfffff
    800016d8:	7c2080e7          	jalr	1986(ra) # 80000e96 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800016dc:	4779                	li	a4,30
    800016de:	86a6                	mv	a3,s1
    800016e0:	6605                	lui	a2,0x1
    800016e2:	85ca                	mv	a1,s2
    800016e4:	8556                	mv	a0,s5
    800016e6:	00000097          	auipc	ra,0x0
    800016ea:	c4a080e7          	jalr	-950(ra) # 80001330 <mappages>
    800016ee:	e905                	bnez	a0,8000171e <uvmalloc+0x86>
  for(; a < newsz; a += PGSIZE){
    800016f0:	6785                	lui	a5,0x1
    800016f2:	993e                	add	s2,s2,a5
    800016f4:	fd4968e3          	bltu	s2,s4,800016c4 <uvmalloc+0x2c>
  return newsz;
    800016f8:	8552                	mv	a0,s4
    800016fa:	a809                	j	8000170c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    800016fc:	864e                	mv	a2,s3
    800016fe:	85ca                	mv	a1,s2
    80001700:	8556                	mv	a0,s5
    80001702:	00000097          	auipc	ra,0x0
    80001706:	f52080e7          	jalr	-174(ra) # 80001654 <uvmdealloc>
      return 0;
    8000170a:	4501                	li	a0,0
}
    8000170c:	70e2                	ld	ra,56(sp)
    8000170e:	7442                	ld	s0,48(sp)
    80001710:	74a2                	ld	s1,40(sp)
    80001712:	7902                	ld	s2,32(sp)
    80001714:	69e2                	ld	s3,24(sp)
    80001716:	6a42                	ld	s4,16(sp)
    80001718:	6aa2                	ld	s5,8(sp)
    8000171a:	6121                	addi	sp,sp,64
    8000171c:	8082                	ret
      kfree(mem);
    8000171e:	8526                	mv	a0,s1
    80001720:	fffff097          	auipc	ra,0xfffff
    80001724:	144080e7          	jalr	324(ra) # 80000864 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001728:	864e                	mv	a2,s3
    8000172a:	85ca                	mv	a1,s2
    8000172c:	8556                	mv	a0,s5
    8000172e:	00000097          	auipc	ra,0x0
    80001732:	f26080e7          	jalr	-218(ra) # 80001654 <uvmdealloc>
      return 0;
    80001736:	4501                	li	a0,0
    80001738:	bfd1                	j	8000170c <uvmalloc+0x74>
    return oldsz;
    8000173a:	852e                	mv	a0,a1
}
    8000173c:	8082                	ret
  return newsz;
    8000173e:	8532                	mv	a0,a2
    80001740:	b7f1                	j	8000170c <uvmalloc+0x74>

0000000080001742 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001742:	1101                	addi	sp,sp,-32
    80001744:	ec06                	sd	ra,24(sp)
    80001746:	e822                	sd	s0,16(sp)
    80001748:	e426                	sd	s1,8(sp)
    8000174a:	1000                	addi	s0,sp,32
    8000174c:	84aa                	mv	s1,a0
    8000174e:	862e                	mv	a2,a1
  uvmunmap(pagetable, 0, sz, 1);
    80001750:	4685                	li	a3,1
    80001752:	4581                	li	a1,0
    80001754:	00000097          	auipc	ra,0x0
    80001758:	d88080e7          	jalr	-632(ra) # 800014dc <uvmunmap>
  freewalk(pagetable);
    8000175c:	8526                	mv	a0,s1
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	aa4080e7          	jalr	-1372(ra) # 80001202 <freewalk>
}
    80001766:	60e2                	ld	ra,24(sp)
    80001768:	6442                	ld	s0,16(sp)
    8000176a:	64a2                	ld	s1,8(sp)
    8000176c:	6105                	addi	sp,sp,32
    8000176e:	8082                	ret

0000000080001770 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001770:	c671                	beqz	a2,8000183c <uvmcopy+0xcc>
{
    80001772:	715d                	addi	sp,sp,-80
    80001774:	e486                	sd	ra,72(sp)
    80001776:	e0a2                	sd	s0,64(sp)
    80001778:	fc26                	sd	s1,56(sp)
    8000177a:	f84a                	sd	s2,48(sp)
    8000177c:	f44e                	sd	s3,40(sp)
    8000177e:	f052                	sd	s4,32(sp)
    80001780:	ec56                	sd	s5,24(sp)
    80001782:	e85a                	sd	s6,16(sp)
    80001784:	e45e                	sd	s7,8(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8b2a                	mv	s6,a0
    8000178a:	8aae                	mv	s5,a1
    8000178c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000178e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001790:	4601                	li	a2,0
    80001792:	85ce                	mv	a1,s3
    80001794:	855a                	mv	a0,s6
    80001796:	00000097          	auipc	ra,0x0
    8000179a:	9c6080e7          	jalr	-1594(ra) # 8000115c <walk>
    8000179e:	c531                	beqz	a0,800017ea <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800017a0:	6118                	ld	a4,0(a0)
    800017a2:	00177793          	andi	a5,a4,1
    800017a6:	cbb1                	beqz	a5,800017fa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800017a8:	00a75593          	srli	a1,a4,0xa
    800017ac:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800017b0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800017b4:	fffff097          	auipc	ra,0xfffff
    800017b8:	29e080e7          	jalr	670(ra) # 80000a52 <kalloc>
    800017bc:	892a                	mv	s2,a0
    800017be:	c939                	beqz	a0,80001814 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800017c0:	6605                	lui	a2,0x1
    800017c2:	85de                	mv	a1,s7
    800017c4:	fffff097          	auipc	ra,0xfffff
    800017c8:	72e080e7          	jalr	1838(ra) # 80000ef2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800017cc:	8726                	mv	a4,s1
    800017ce:	86ca                	mv	a3,s2
    800017d0:	6605                	lui	a2,0x1
    800017d2:	85ce                	mv	a1,s3
    800017d4:	8556                	mv	a0,s5
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	b5a080e7          	jalr	-1190(ra) # 80001330 <mappages>
    800017de:	e515                	bnez	a0,8000180a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800017e0:	6785                	lui	a5,0x1
    800017e2:	99be                	add	s3,s3,a5
    800017e4:	fb49e6e3          	bltu	s3,s4,80001790 <uvmcopy+0x20>
    800017e8:	a83d                	j	80001826 <uvmcopy+0xb6>
      panic("uvmcopy: pte should exist");
    800017ea:	00007517          	auipc	a0,0x7
    800017ee:	be650513          	addi	a0,a0,-1050 # 800083d0 <userret+0x340>
    800017f2:	fffff097          	auipc	ra,0xfffff
    800017f6:	d56080e7          	jalr	-682(ra) # 80000548 <panic>
      panic("uvmcopy: page not present");
    800017fa:	00007517          	auipc	a0,0x7
    800017fe:	bf650513          	addi	a0,a0,-1034 # 800083f0 <userret+0x360>
    80001802:	fffff097          	auipc	ra,0xfffff
    80001806:	d46080e7          	jalr	-698(ra) # 80000548 <panic>
      kfree(mem);
    8000180a:	854a                	mv	a0,s2
    8000180c:	fffff097          	auipc	ra,0xfffff
    80001810:	058080e7          	jalr	88(ra) # 80000864 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i, 1);
    80001814:	4685                	li	a3,1
    80001816:	864e                	mv	a2,s3
    80001818:	4581                	li	a1,0
    8000181a:	8556                	mv	a0,s5
    8000181c:	00000097          	auipc	ra,0x0
    80001820:	cc0080e7          	jalr	-832(ra) # 800014dc <uvmunmap>
  return -1;
    80001824:	557d                	li	a0,-1
}
    80001826:	60a6                	ld	ra,72(sp)
    80001828:	6406                	ld	s0,64(sp)
    8000182a:	74e2                	ld	s1,56(sp)
    8000182c:	7942                	ld	s2,48(sp)
    8000182e:	79a2                	ld	s3,40(sp)
    80001830:	7a02                	ld	s4,32(sp)
    80001832:	6ae2                	ld	s5,24(sp)
    80001834:	6b42                	ld	s6,16(sp)
    80001836:	6ba2                	ld	s7,8(sp)
    80001838:	6161                	addi	sp,sp,80
    8000183a:	8082                	ret
  return 0;
    8000183c:	4501                	li	a0,0
}
    8000183e:	8082                	ret

0000000080001840 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001840:	1141                	addi	sp,sp,-16
    80001842:	e406                	sd	ra,8(sp)
    80001844:	e022                	sd	s0,0(sp)
    80001846:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001848:	4601                	li	a2,0
    8000184a:	00000097          	auipc	ra,0x0
    8000184e:	912080e7          	jalr	-1774(ra) # 8000115c <walk>
  if(pte == 0)
    80001852:	c901                	beqz	a0,80001862 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001854:	611c                	ld	a5,0(a0)
    80001856:	9bbd                	andi	a5,a5,-17
    80001858:	e11c                	sd	a5,0(a0)
}
    8000185a:	60a2                	ld	ra,8(sp)
    8000185c:	6402                	ld	s0,0(sp)
    8000185e:	0141                	addi	sp,sp,16
    80001860:	8082                	ret
    panic("uvmclear");
    80001862:	00007517          	auipc	a0,0x7
    80001866:	bae50513          	addi	a0,a0,-1106 # 80008410 <userret+0x380>
    8000186a:	fffff097          	auipc	ra,0xfffff
    8000186e:	cde080e7          	jalr	-802(ra) # 80000548 <panic>

0000000080001872 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001872:	c6bd                	beqz	a3,800018e0 <copyout+0x6e>
{
    80001874:	715d                	addi	sp,sp,-80
    80001876:	e486                	sd	ra,72(sp)
    80001878:	e0a2                	sd	s0,64(sp)
    8000187a:	fc26                	sd	s1,56(sp)
    8000187c:	f84a                	sd	s2,48(sp)
    8000187e:	f44e                	sd	s3,40(sp)
    80001880:	f052                	sd	s4,32(sp)
    80001882:	ec56                	sd	s5,24(sp)
    80001884:	e85a                	sd	s6,16(sp)
    80001886:	e45e                	sd	s7,8(sp)
    80001888:	e062                	sd	s8,0(sp)
    8000188a:	0880                	addi	s0,sp,80
    8000188c:	8b2a                	mv	s6,a0
    8000188e:	8c2e                	mv	s8,a1
    80001890:	8a32                	mv	s4,a2
    80001892:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001894:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001896:	6a85                	lui	s5,0x1
    80001898:	a015                	j	800018bc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000189a:	9562                	add	a0,a0,s8
    8000189c:	0004861b          	sext.w	a2,s1
    800018a0:	85d2                	mv	a1,s4
    800018a2:	41250533          	sub	a0,a0,s2
    800018a6:	fffff097          	auipc	ra,0xfffff
    800018aa:	64c080e7          	jalr	1612(ra) # 80000ef2 <memmove>

    len -= n;
    800018ae:	409989b3          	sub	s3,s3,s1
    src += n;
    800018b2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800018b4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800018b8:	02098263          	beqz	s3,800018dc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800018bc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018c0:	85ca                	mv	a1,s2
    800018c2:	855a                	mv	a0,s6
    800018c4:	00000097          	auipc	ra,0x0
    800018c8:	9cc080e7          	jalr	-1588(ra) # 80001290 <walkaddr>
    if(pa0 == 0)
    800018cc:	cd01                	beqz	a0,800018e4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800018ce:	418904b3          	sub	s1,s2,s8
    800018d2:	94d6                	add	s1,s1,s5
    if(n > len)
    800018d4:	fc99f3e3          	bgeu	s3,s1,8000189a <copyout+0x28>
    800018d8:	84ce                	mv	s1,s3
    800018da:	b7c1                	j	8000189a <copyout+0x28>
  }
  return 0;
    800018dc:	4501                	li	a0,0
    800018de:	a021                	j	800018e6 <copyout+0x74>
    800018e0:	4501                	li	a0,0
}
    800018e2:	8082                	ret
      return -1;
    800018e4:	557d                	li	a0,-1
}
    800018e6:	60a6                	ld	ra,72(sp)
    800018e8:	6406                	ld	s0,64(sp)
    800018ea:	74e2                	ld	s1,56(sp)
    800018ec:	7942                	ld	s2,48(sp)
    800018ee:	79a2                	ld	s3,40(sp)
    800018f0:	7a02                	ld	s4,32(sp)
    800018f2:	6ae2                	ld	s5,24(sp)
    800018f4:	6b42                	ld	s6,16(sp)
    800018f6:	6ba2                	ld	s7,8(sp)
    800018f8:	6c02                	ld	s8,0(sp)
    800018fa:	6161                	addi	sp,sp,80
    800018fc:	8082                	ret

00000000800018fe <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800018fe:	caa5                	beqz	a3,8000196e <copyin+0x70>
{
    80001900:	715d                	addi	sp,sp,-80
    80001902:	e486                	sd	ra,72(sp)
    80001904:	e0a2                	sd	s0,64(sp)
    80001906:	fc26                	sd	s1,56(sp)
    80001908:	f84a                	sd	s2,48(sp)
    8000190a:	f44e                	sd	s3,40(sp)
    8000190c:	f052                	sd	s4,32(sp)
    8000190e:	ec56                	sd	s5,24(sp)
    80001910:	e85a                	sd	s6,16(sp)
    80001912:	e45e                	sd	s7,8(sp)
    80001914:	e062                	sd	s8,0(sp)
    80001916:	0880                	addi	s0,sp,80
    80001918:	8b2a                	mv	s6,a0
    8000191a:	8a2e                	mv	s4,a1
    8000191c:	8c32                	mv	s8,a2
    8000191e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001920:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001922:	6a85                	lui	s5,0x1
    80001924:	a01d                	j	8000194a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001926:	018505b3          	add	a1,a0,s8
    8000192a:	0004861b          	sext.w	a2,s1
    8000192e:	412585b3          	sub	a1,a1,s2
    80001932:	8552                	mv	a0,s4
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	5be080e7          	jalr	1470(ra) # 80000ef2 <memmove>

    len -= n;
    8000193c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001940:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001942:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001946:	02098263          	beqz	s3,8000196a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000194a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000194e:	85ca                	mv	a1,s2
    80001950:	855a                	mv	a0,s6
    80001952:	00000097          	auipc	ra,0x0
    80001956:	93e080e7          	jalr	-1730(ra) # 80001290 <walkaddr>
    if(pa0 == 0)
    8000195a:	cd01                	beqz	a0,80001972 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000195c:	418904b3          	sub	s1,s2,s8
    80001960:	94d6                	add	s1,s1,s5
    if(n > len)
    80001962:	fc99f2e3          	bgeu	s3,s1,80001926 <copyin+0x28>
    80001966:	84ce                	mv	s1,s3
    80001968:	bf7d                	j	80001926 <copyin+0x28>
  }
  return 0;
    8000196a:	4501                	li	a0,0
    8000196c:	a021                	j	80001974 <copyin+0x76>
    8000196e:	4501                	li	a0,0
}
    80001970:	8082                	ret
      return -1;
    80001972:	557d                	li	a0,-1
}
    80001974:	60a6                	ld	ra,72(sp)
    80001976:	6406                	ld	s0,64(sp)
    80001978:	74e2                	ld	s1,56(sp)
    8000197a:	7942                	ld	s2,48(sp)
    8000197c:	79a2                	ld	s3,40(sp)
    8000197e:	7a02                	ld	s4,32(sp)
    80001980:	6ae2                	ld	s5,24(sp)
    80001982:	6b42                	ld	s6,16(sp)
    80001984:	6ba2                	ld	s7,8(sp)
    80001986:	6c02                	ld	s8,0(sp)
    80001988:	6161                	addi	sp,sp,80
    8000198a:	8082                	ret

000000008000198c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000198c:	c6c5                	beqz	a3,80001a34 <copyinstr+0xa8>
{
    8000198e:	715d                	addi	sp,sp,-80
    80001990:	e486                	sd	ra,72(sp)
    80001992:	e0a2                	sd	s0,64(sp)
    80001994:	fc26                	sd	s1,56(sp)
    80001996:	f84a                	sd	s2,48(sp)
    80001998:	f44e                	sd	s3,40(sp)
    8000199a:	f052                	sd	s4,32(sp)
    8000199c:	ec56                	sd	s5,24(sp)
    8000199e:	e85a                	sd	s6,16(sp)
    800019a0:	e45e                	sd	s7,8(sp)
    800019a2:	0880                	addi	s0,sp,80
    800019a4:	8a2a                	mv	s4,a0
    800019a6:	8b2e                	mv	s6,a1
    800019a8:	8bb2                	mv	s7,a2
    800019aa:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800019ac:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800019ae:	6985                	lui	s3,0x1
    800019b0:	a035                	j	800019dc <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800019b2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800019b6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800019b8:	0017b793          	seqz	a5,a5
    800019bc:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800019c0:	60a6                	ld	ra,72(sp)
    800019c2:	6406                	ld	s0,64(sp)
    800019c4:	74e2                	ld	s1,56(sp)
    800019c6:	7942                	ld	s2,48(sp)
    800019c8:	79a2                	ld	s3,40(sp)
    800019ca:	7a02                	ld	s4,32(sp)
    800019cc:	6ae2                	ld	s5,24(sp)
    800019ce:	6b42                	ld	s6,16(sp)
    800019d0:	6ba2                	ld	s7,8(sp)
    800019d2:	6161                	addi	sp,sp,80
    800019d4:	8082                	ret
    srcva = va0 + PGSIZE;
    800019d6:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800019da:	c8a9                	beqz	s1,80001a2c <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800019dc:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800019e0:	85ca                	mv	a1,s2
    800019e2:	8552                	mv	a0,s4
    800019e4:	00000097          	auipc	ra,0x0
    800019e8:	8ac080e7          	jalr	-1876(ra) # 80001290 <walkaddr>
    if(pa0 == 0)
    800019ec:	c131                	beqz	a0,80001a30 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800019ee:	41790833          	sub	a6,s2,s7
    800019f2:	984e                	add	a6,a6,s3
    if(n > max)
    800019f4:	0104f363          	bgeu	s1,a6,800019fa <copyinstr+0x6e>
    800019f8:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800019fa:	955e                	add	a0,a0,s7
    800019fc:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001a00:	fc080be3          	beqz	a6,800019d6 <copyinstr+0x4a>
    80001a04:	985a                	add	a6,a6,s6
    80001a06:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001a08:	41650633          	sub	a2,a0,s6
    80001a0c:	14fd                	addi	s1,s1,-1
    80001a0e:	9b26                	add	s6,s6,s1
    80001a10:	00f60733          	add	a4,a2,a5
    80001a14:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffcefa4>
    80001a18:	df49                	beqz	a4,800019b2 <copyinstr+0x26>
        *dst = *p;
    80001a1a:	00e78023          	sb	a4,0(a5)
      --max;
    80001a1e:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001a22:	0785                	addi	a5,a5,1
    while(n > 0){
    80001a24:	ff0796e3          	bne	a5,a6,80001a10 <copyinstr+0x84>
      dst++;
    80001a28:	8b42                	mv	s6,a6
    80001a2a:	b775                	j	800019d6 <copyinstr+0x4a>
    80001a2c:	4781                	li	a5,0
    80001a2e:	b769                	j	800019b8 <copyinstr+0x2c>
      return -1;
    80001a30:	557d                	li	a0,-1
    80001a32:	b779                	j	800019c0 <copyinstr+0x34>
  int got_null = 0;
    80001a34:	4781                	li	a5,0
  if(got_null){
    80001a36:	0017b793          	seqz	a5,a5
    80001a3a:	40f00533          	neg	a0,a5
}
    80001a3e:	8082                	ret

0000000080001a40 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80001a40:	1101                	addi	sp,sp,-32
    80001a42:	ec06                	sd	ra,24(sp)
    80001a44:	e822                	sd	s0,16(sp)
    80001a46:	e426                	sd	s1,8(sp)
    80001a48:	1000                	addi	s0,sp,32
    80001a4a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	19c080e7          	jalr	412(ra) # 80000be8 <holding>
    80001a54:	c909                	beqz	a0,80001a66 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80001a56:	789c                	ld	a5,48(s1)
    80001a58:	00978f63          	beq	a5,s1,80001a76 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001a5c:	60e2                	ld	ra,24(sp)
    80001a5e:	6442                	ld	s0,16(sp)
    80001a60:	64a2                	ld	s1,8(sp)
    80001a62:	6105                	addi	sp,sp,32
    80001a64:	8082                	ret
    panic("wakeup1");
    80001a66:	00007517          	auipc	a0,0x7
    80001a6a:	9ba50513          	addi	a0,a0,-1606 # 80008420 <userret+0x390>
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	ada080e7          	jalr	-1318(ra) # 80000548 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001a76:	5098                	lw	a4,32(s1)
    80001a78:	4785                	li	a5,1
    80001a7a:	fef711e3          	bne	a4,a5,80001a5c <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001a7e:	4789                	li	a5,2
    80001a80:	d09c                	sw	a5,32(s1)
}
    80001a82:	bfe9                	j	80001a5c <wakeup1+0x1c>

0000000080001a84 <procinit>:
{
    80001a84:	715d                	addi	sp,sp,-80
    80001a86:	e486                	sd	ra,72(sp)
    80001a88:	e0a2                	sd	s0,64(sp)
    80001a8a:	fc26                	sd	s1,56(sp)
    80001a8c:	f84a                	sd	s2,48(sp)
    80001a8e:	f44e                	sd	s3,40(sp)
    80001a90:	f052                	sd	s4,32(sp)
    80001a92:	ec56                	sd	s5,24(sp)
    80001a94:	e85a                	sd	s6,16(sp)
    80001a96:	e45e                	sd	s7,8(sp)
    80001a98:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001a9a:	00007597          	auipc	a1,0x7
    80001a9e:	98e58593          	addi	a1,a1,-1650 # 80008428 <userret+0x398>
    80001aa2:	00013517          	auipc	a0,0x13
    80001aa6:	eb650513          	addi	a0,a0,-330 # 80014958 <pid_lock>
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	030080e7          	jalr	48(ra) # 80000ada <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab2:	00013917          	auipc	s2,0x13
    80001ab6:	2c690913          	addi	s2,s2,710 # 80014d78 <proc>
      initlock(&p->lock, "proc");
    80001aba:	00007b97          	auipc	s7,0x7
    80001abe:	976b8b93          	addi	s7,s7,-1674 # 80008430 <userret+0x3a0>
      uint64 va = KSTACK((int) (p - proc));
    80001ac2:	8b4a                	mv	s6,s2
    80001ac4:	00007a97          	auipc	s5,0x7
    80001ac8:	10ca8a93          	addi	s5,s5,268 # 80008bd0 <syscalls+0xb8>
    80001acc:	040009b7          	lui	s3,0x4000
    80001ad0:	19fd                	addi	s3,s3,-1
    80001ad2:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad4:	00019a17          	auipc	s4,0x19
    80001ad8:	ea4a0a13          	addi	s4,s4,-348 # 8001a978 <tickslock>
      initlock(&p->lock, "proc");
    80001adc:	85de                	mv	a1,s7
    80001ade:	854a                	mv	a0,s2
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	ffa080e7          	jalr	-6(ra) # 80000ada <initlock>
      char *pa = kalloc();
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	f6a080e7          	jalr	-150(ra) # 80000a52 <kalloc>
    80001af0:	85aa                	mv	a1,a0
      if(pa == 0)
    80001af2:	c929                	beqz	a0,80001b44 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001af4:	416904b3          	sub	s1,s2,s6
    80001af8:	8491                	srai	s1,s1,0x4
    80001afa:	000ab783          	ld	a5,0(s5)
    80001afe:	02f484b3          	mul	s1,s1,a5
    80001b02:	2485                	addiw	s1,s1,1
    80001b04:	00d4949b          	slliw	s1,s1,0xd
    80001b08:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b0c:	4699                	li	a3,6
    80001b0e:	6605                	lui	a2,0x1
    80001b10:	8526                	mv	a0,s1
    80001b12:	00000097          	auipc	ra,0x0
    80001b16:	8ac080e7          	jalr	-1876(ra) # 800013be <kvmmap>
      p->kstack = va;
    80001b1a:	04993423          	sd	s1,72(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b1e:	17090913          	addi	s2,s2,368
    80001b22:	fb491de3          	bne	s2,s4,80001adc <procinit+0x58>
  kvminithart();
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	746080e7          	jalr	1862(ra) # 8000126c <kvminithart>
}
    80001b2e:	60a6                	ld	ra,72(sp)
    80001b30:	6406                	ld	s0,64(sp)
    80001b32:	74e2                	ld	s1,56(sp)
    80001b34:	7942                	ld	s2,48(sp)
    80001b36:	79a2                	ld	s3,40(sp)
    80001b38:	7a02                	ld	s4,32(sp)
    80001b3a:	6ae2                	ld	s5,24(sp)
    80001b3c:	6b42                	ld	s6,16(sp)
    80001b3e:	6ba2                	ld	s7,8(sp)
    80001b40:	6161                	addi	sp,sp,80
    80001b42:	8082                	ret
        panic("kalloc");
    80001b44:	00007517          	auipc	a0,0x7
    80001b48:	8f450513          	addi	a0,a0,-1804 # 80008438 <userret+0x3a8>
    80001b4c:	fffff097          	auipc	ra,0xfffff
    80001b50:	9fc080e7          	jalr	-1540(ra) # 80000548 <panic>

0000000080001b54 <cpuid>:
{
    80001b54:	1141                	addi	sp,sp,-16
    80001b56:	e422                	sd	s0,8(sp)
    80001b58:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b5a:	8512                	mv	a0,tp
}
    80001b5c:	2501                	sext.w	a0,a0
    80001b5e:	6422                	ld	s0,8(sp)
    80001b60:	0141                	addi	sp,sp,16
    80001b62:	8082                	ret

0000000080001b64 <mycpu>:
mycpu(void) {
    80001b64:	1141                	addi	sp,sp,-16
    80001b66:	e422                	sd	s0,8(sp)
    80001b68:	0800                	addi	s0,sp,16
    80001b6a:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001b6c:	2781                	sext.w	a5,a5
    80001b6e:	079e                	slli	a5,a5,0x7
}
    80001b70:	00013517          	auipc	a0,0x13
    80001b74:	e0850513          	addi	a0,a0,-504 # 80014978 <cpus>
    80001b78:	953e                	add	a0,a0,a5
    80001b7a:	6422                	ld	s0,8(sp)
    80001b7c:	0141                	addi	sp,sp,16
    80001b7e:	8082                	ret

0000000080001b80 <myproc>:
myproc(void) {
    80001b80:	1101                	addi	sp,sp,-32
    80001b82:	ec06                	sd	ra,24(sp)
    80001b84:	e822                	sd	s0,16(sp)
    80001b86:	e426                	sd	s1,8(sp)
    80001b88:	1000                	addi	s0,sp,32
  push_off();
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	fa6080e7          	jalr	-90(ra) # 80000b30 <push_off>
    80001b92:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001b94:	2781                	sext.w	a5,a5
    80001b96:	079e                	slli	a5,a5,0x7
    80001b98:	00013717          	auipc	a4,0x13
    80001b9c:	dc070713          	addi	a4,a4,-576 # 80014958 <pid_lock>
    80001ba0:	97ba                	add	a5,a5,a4
    80001ba2:	7384                	ld	s1,32(a5)
  pop_off();
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	fd8080e7          	jalr	-40(ra) # 80000b7c <pop_off>
}
    80001bac:	8526                	mv	a0,s1
    80001bae:	60e2                	ld	ra,24(sp)
    80001bb0:	6442                	ld	s0,16(sp)
    80001bb2:	64a2                	ld	s1,8(sp)
    80001bb4:	6105                	addi	sp,sp,32
    80001bb6:	8082                	ret

0000000080001bb8 <forkret>:
{
    80001bb8:	1141                	addi	sp,sp,-16
    80001bba:	e406                	sd	ra,8(sp)
    80001bbc:	e022                	sd	s0,0(sp)
    80001bbe:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001bc0:	00000097          	auipc	ra,0x0
    80001bc4:	fc0080e7          	jalr	-64(ra) # 80001b80 <myproc>
    80001bc8:	fffff097          	auipc	ra,0xfffff
    80001bcc:	0d0080e7          	jalr	208(ra) # 80000c98 <release>
  if (first) {
    80001bd0:	00007797          	auipc	a5,0x7
    80001bd4:	4647a783          	lw	a5,1124(a5) # 80009034 <first.1>
    80001bd8:	eb89                	bnez	a5,80001bea <forkret+0x32>
  usertrapret();
    80001bda:	00001097          	auipc	ra,0x1
    80001bde:	bdc080e7          	jalr	-1060(ra) # 800027b6 <usertrapret>
}
    80001be2:	60a2                	ld	ra,8(sp)
    80001be4:	6402                	ld	s0,0(sp)
    80001be6:	0141                	addi	sp,sp,16
    80001be8:	8082                	ret
    first = 0;
    80001bea:	00007797          	auipc	a5,0x7
    80001bee:	4407a523          	sw	zero,1098(a5) # 80009034 <first.1>
    fsinit(minor(ROOTDEV));
    80001bf2:	4501                	li	a0,0
    80001bf4:	00002097          	auipc	ra,0x2
    80001bf8:	a32080e7          	jalr	-1486(ra) # 80003626 <fsinit>
    80001bfc:	bff9                	j	80001bda <forkret+0x22>

0000000080001bfe <allocpid>:
allocpid() {
    80001bfe:	1101                	addi	sp,sp,-32
    80001c00:	ec06                	sd	ra,24(sp)
    80001c02:	e822                	sd	s0,16(sp)
    80001c04:	e426                	sd	s1,8(sp)
    80001c06:	e04a                	sd	s2,0(sp)
    80001c08:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001c0a:	00013917          	auipc	s2,0x13
    80001c0e:	d4e90913          	addi	s2,s2,-690 # 80014958 <pid_lock>
    80001c12:	854a                	mv	a0,s2
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	014080e7          	jalr	20(ra) # 80000c28 <acquire>
  pid = nextpid;
    80001c1c:	00007797          	auipc	a5,0x7
    80001c20:	41c78793          	addi	a5,a5,1052 # 80009038 <nextpid>
    80001c24:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001c26:	0014871b          	addiw	a4,s1,1
    80001c2a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001c2c:	854a                	mv	a0,s2
    80001c2e:	fffff097          	auipc	ra,0xfffff
    80001c32:	06a080e7          	jalr	106(ra) # 80000c98 <release>
}
    80001c36:	8526                	mv	a0,s1
    80001c38:	60e2                	ld	ra,24(sp)
    80001c3a:	6442                	ld	s0,16(sp)
    80001c3c:	64a2                	ld	s1,8(sp)
    80001c3e:	6902                	ld	s2,0(sp)
    80001c40:	6105                	addi	sp,sp,32
    80001c42:	8082                	ret

0000000080001c44 <proc_pagetable>:
{
    80001c44:	1101                	addi	sp,sp,-32
    80001c46:	ec06                	sd	ra,24(sp)
    80001c48:	e822                	sd	s0,16(sp)
    80001c4a:	e426                	sd	s1,8(sp)
    80001c4c:	e04a                	sd	s2,0(sp)
    80001c4e:	1000                	addi	s0,sp,32
    80001c50:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c52:	00000097          	auipc	ra,0x0
    80001c56:	952080e7          	jalr	-1710(ra) # 800015a4 <uvmcreate>
    80001c5a:	84aa                	mv	s1,a0
  mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c5c:	4729                	li	a4,10
    80001c5e:	00006697          	auipc	a3,0x6
    80001c62:	3a268693          	addi	a3,a3,930 # 80008000 <trampoline>
    80001c66:	6605                	lui	a2,0x1
    80001c68:	040005b7          	lui	a1,0x4000
    80001c6c:	15fd                	addi	a1,a1,-1
    80001c6e:	05b2                	slli	a1,a1,0xc
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	6c0080e7          	jalr	1728(ra) # 80001330 <mappages>
  mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c78:	4719                	li	a4,6
    80001c7a:	06093683          	ld	a3,96(s2)
    80001c7e:	6605                	lui	a2,0x1
    80001c80:	020005b7          	lui	a1,0x2000
    80001c84:	15fd                	addi	a1,a1,-1
    80001c86:	05b6                	slli	a1,a1,0xd
    80001c88:	8526                	mv	a0,s1
    80001c8a:	fffff097          	auipc	ra,0xfffff
    80001c8e:	6a6080e7          	jalr	1702(ra) # 80001330 <mappages>
}
    80001c92:	8526                	mv	a0,s1
    80001c94:	60e2                	ld	ra,24(sp)
    80001c96:	6442                	ld	s0,16(sp)
    80001c98:	64a2                	ld	s1,8(sp)
    80001c9a:	6902                	ld	s2,0(sp)
    80001c9c:	6105                	addi	sp,sp,32
    80001c9e:	8082                	ret

0000000080001ca0 <allocproc>:
{
    80001ca0:	1101                	addi	sp,sp,-32
    80001ca2:	ec06                	sd	ra,24(sp)
    80001ca4:	e822                	sd	s0,16(sp)
    80001ca6:	e426                	sd	s1,8(sp)
    80001ca8:	e04a                	sd	s2,0(sp)
    80001caa:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cac:	00013497          	auipc	s1,0x13
    80001cb0:	0cc48493          	addi	s1,s1,204 # 80014d78 <proc>
    80001cb4:	00019917          	auipc	s2,0x19
    80001cb8:	cc490913          	addi	s2,s2,-828 # 8001a978 <tickslock>
    acquire(&p->lock);
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	f6a080e7          	jalr	-150(ra) # 80000c28 <acquire>
    if(p->state == UNUSED) {
    80001cc6:	509c                	lw	a5,32(s1)
    80001cc8:	cf81                	beqz	a5,80001ce0 <allocproc+0x40>
      release(&p->lock);
    80001cca:	8526                	mv	a0,s1
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	fcc080e7          	jalr	-52(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cd4:	17048493          	addi	s1,s1,368
    80001cd8:	ff2492e3          	bne	s1,s2,80001cbc <allocproc+0x1c>
  return 0;
    80001cdc:	4481                	li	s1,0
    80001cde:	a0a9                	j	80001d28 <allocproc+0x88>
  p->pid = allocpid();
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	f1e080e7          	jalr	-226(ra) # 80001bfe <allocpid>
    80001ce8:	c0a8                	sw	a0,64(s1)
  if((p->tf = (struct trapframe *)kalloc()) == 0){
    80001cea:	fffff097          	auipc	ra,0xfffff
    80001cee:	d68080e7          	jalr	-664(ra) # 80000a52 <kalloc>
    80001cf2:	892a                	mv	s2,a0
    80001cf4:	f0a8                	sd	a0,96(s1)
    80001cf6:	c121                	beqz	a0,80001d36 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001cf8:	8526                	mv	a0,s1
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	f4a080e7          	jalr	-182(ra) # 80001c44 <proc_pagetable>
    80001d02:	eca8                	sd	a0,88(s1)
  memset(&p->context, 0, sizeof p->context);
    80001d04:	07000613          	li	a2,112
    80001d08:	4581                	li	a1,0
    80001d0a:	06848513          	addi	a0,s1,104
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	188080e7          	jalr	392(ra) # 80000e96 <memset>
  p->context.ra = (uint64)forkret;
    80001d16:	00000797          	auipc	a5,0x0
    80001d1a:	ea278793          	addi	a5,a5,-350 # 80001bb8 <forkret>
    80001d1e:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d20:	64bc                	ld	a5,72(s1)
    80001d22:	6705                	lui	a4,0x1
    80001d24:	97ba                	add	a5,a5,a4
    80001d26:	f8bc                	sd	a5,112(s1)
}
    80001d28:	8526                	mv	a0,s1
    80001d2a:	60e2                	ld	ra,24(sp)
    80001d2c:	6442                	ld	s0,16(sp)
    80001d2e:	64a2                	ld	s1,8(sp)
    80001d30:	6902                	ld	s2,0(sp)
    80001d32:	6105                	addi	sp,sp,32
    80001d34:	8082                	ret
    release(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	f60080e7          	jalr	-160(ra) # 80000c98 <release>
    return 0;
    80001d40:	84ca                	mv	s1,s2
    80001d42:	b7dd                	j	80001d28 <allocproc+0x88>

0000000080001d44 <proc_freepagetable>:
{
    80001d44:	1101                	addi	sp,sp,-32
    80001d46:	ec06                	sd	ra,24(sp)
    80001d48:	e822                	sd	s0,16(sp)
    80001d4a:	e426                	sd	s1,8(sp)
    80001d4c:	e04a                	sd	s2,0(sp)
    80001d4e:	1000                	addi	s0,sp,32
    80001d50:	84aa                	mv	s1,a0
    80001d52:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, PGSIZE, 0);
    80001d54:	4681                	li	a3,0
    80001d56:	6605                	lui	a2,0x1
    80001d58:	040005b7          	lui	a1,0x4000
    80001d5c:	15fd                	addi	a1,a1,-1
    80001d5e:	05b2                	slli	a1,a1,0xc
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	77c080e7          	jalr	1916(ra) # 800014dc <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, PGSIZE, 0);
    80001d68:	4681                	li	a3,0
    80001d6a:	6605                	lui	a2,0x1
    80001d6c:	020005b7          	lui	a1,0x2000
    80001d70:	15fd                	addi	a1,a1,-1
    80001d72:	05b6                	slli	a1,a1,0xd
    80001d74:	8526                	mv	a0,s1
    80001d76:	fffff097          	auipc	ra,0xfffff
    80001d7a:	766080e7          	jalr	1894(ra) # 800014dc <uvmunmap>
  if(sz > 0)
    80001d7e:	00091863          	bnez	s2,80001d8e <proc_freepagetable+0x4a>
}
    80001d82:	60e2                	ld	ra,24(sp)
    80001d84:	6442                	ld	s0,16(sp)
    80001d86:	64a2                	ld	s1,8(sp)
    80001d88:	6902                	ld	s2,0(sp)
    80001d8a:	6105                	addi	sp,sp,32
    80001d8c:	8082                	ret
    uvmfree(pagetable, sz);
    80001d8e:	85ca                	mv	a1,s2
    80001d90:	8526                	mv	a0,s1
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	9b0080e7          	jalr	-1616(ra) # 80001742 <uvmfree>
}
    80001d9a:	b7e5                	j	80001d82 <proc_freepagetable+0x3e>

0000000080001d9c <freeproc>:
{
    80001d9c:	1101                	addi	sp,sp,-32
    80001d9e:	ec06                	sd	ra,24(sp)
    80001da0:	e822                	sd	s0,16(sp)
    80001da2:	e426                	sd	s1,8(sp)
    80001da4:	1000                	addi	s0,sp,32
    80001da6:	84aa                	mv	s1,a0
  if(p->tf)
    80001da8:	7128                	ld	a0,96(a0)
    80001daa:	c509                	beqz	a0,80001db4 <freeproc+0x18>
    kfree((void*)p->tf);
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	ab8080e7          	jalr	-1352(ra) # 80000864 <kfree>
  p->tf = 0;
    80001db4:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001db8:	6ca8                	ld	a0,88(s1)
    80001dba:	c511                	beqz	a0,80001dc6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001dbc:	68ac                	ld	a1,80(s1)
    80001dbe:	00000097          	auipc	ra,0x0
    80001dc2:	f86080e7          	jalr	-122(ra) # 80001d44 <proc_freepagetable>
  p->pagetable = 0;
    80001dc6:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001dca:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001dce:	0404a023          	sw	zero,64(s1)
  p->parent = 0;
    80001dd2:	0204b423          	sd	zero,40(s1)
  p->name[0] = 0;
    80001dd6:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001dda:	0204b823          	sd	zero,48(s1)
  p->killed = 0;
    80001dde:	0204ac23          	sw	zero,56(s1)
  p->xstate = 0;
    80001de2:	0204ae23          	sw	zero,60(s1)
  p->state = UNUSED;
    80001de6:	0204a023          	sw	zero,32(s1)
}
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6105                	addi	sp,sp,32
    80001df2:	8082                	ret

0000000080001df4 <userinit>:
{
    80001df4:	1101                	addi	sp,sp,-32
    80001df6:	ec06                	sd	ra,24(sp)
    80001df8:	e822                	sd	s0,16(sp)
    80001dfa:	e426                	sd	s1,8(sp)
    80001dfc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	ea2080e7          	jalr	-350(ra) # 80001ca0 <allocproc>
    80001e06:	84aa                	mv	s1,a0
  initproc = p;
    80001e08:	0002e797          	auipc	a5,0x2e
    80001e0c:	22a7b823          	sd	a0,560(a5) # 80030038 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e10:	03300613          	li	a2,51
    80001e14:	00007597          	auipc	a1,0x7
    80001e18:	1ec58593          	addi	a1,a1,492 # 80009000 <initcode>
    80001e1c:	6d28                	ld	a0,88(a0)
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	7c4080e7          	jalr	1988(ra) # 800015e2 <uvminit>
  p->sz = PGSIZE;
    80001e26:	6785                	lui	a5,0x1
    80001e28:	e8bc                	sd	a5,80(s1)
  p->tf->epc = 0;      // user program counter
    80001e2a:	70b8                	ld	a4,96(s1)
    80001e2c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->tf->sp = PGSIZE;  // user stack pointer
    80001e30:	70b8                	ld	a4,96(s1)
    80001e32:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e34:	4641                	li	a2,16
    80001e36:	00006597          	auipc	a1,0x6
    80001e3a:	60a58593          	addi	a1,a1,1546 # 80008440 <userret+0x3b0>
    80001e3e:	16048513          	addi	a0,s1,352
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	1a6080e7          	jalr	422(ra) # 80000fe8 <safestrcpy>
  p->cwd = namei("/");
    80001e4a:	00006517          	auipc	a0,0x6
    80001e4e:	60650513          	addi	a0,a0,1542 # 80008450 <userret+0x3c0>
    80001e52:	00002097          	auipc	ra,0x2
    80001e56:	1d6080e7          	jalr	470(ra) # 80004028 <namei>
    80001e5a:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001e5e:	4789                	li	a5,2
    80001e60:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001e62:	8526                	mv	a0,s1
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	e34080e7          	jalr	-460(ra) # 80000c98 <release>
}
    80001e6c:	60e2                	ld	ra,24(sp)
    80001e6e:	6442                	ld	s0,16(sp)
    80001e70:	64a2                	ld	s1,8(sp)
    80001e72:	6105                	addi	sp,sp,32
    80001e74:	8082                	ret

0000000080001e76 <growproc>:
{
    80001e76:	1101                	addi	sp,sp,-32
    80001e78:	ec06                	sd	ra,24(sp)
    80001e7a:	e822                	sd	s0,16(sp)
    80001e7c:	e426                	sd	s1,8(sp)
    80001e7e:	e04a                	sd	s2,0(sp)
    80001e80:	1000                	addi	s0,sp,32
    80001e82:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e84:	00000097          	auipc	ra,0x0
    80001e88:	cfc080e7          	jalr	-772(ra) # 80001b80 <myproc>
    80001e8c:	892a                	mv	s2,a0
  sz = p->sz;
    80001e8e:	692c                	ld	a1,80(a0)
    80001e90:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e94:	00904f63          	bgtz	s1,80001eb2 <growproc+0x3c>
  } else if(n < 0){
    80001e98:	0204cc63          	bltz	s1,80001ed0 <growproc+0x5a>
  p->sz = sz;
    80001e9c:	1602                	slli	a2,a2,0x20
    80001e9e:	9201                	srli	a2,a2,0x20
    80001ea0:	04c93823          	sd	a2,80(s2)
  return 0;
    80001ea4:	4501                	li	a0,0
}
    80001ea6:	60e2                	ld	ra,24(sp)
    80001ea8:	6442                	ld	s0,16(sp)
    80001eaa:	64a2                	ld	s1,8(sp)
    80001eac:	6902                	ld	s2,0(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001eb2:	9e25                	addw	a2,a2,s1
    80001eb4:	1602                	slli	a2,a2,0x20
    80001eb6:	9201                	srli	a2,a2,0x20
    80001eb8:	1582                	slli	a1,a1,0x20
    80001eba:	9181                	srli	a1,a1,0x20
    80001ebc:	6d28                	ld	a0,88(a0)
    80001ebe:	fffff097          	auipc	ra,0xfffff
    80001ec2:	7da080e7          	jalr	2010(ra) # 80001698 <uvmalloc>
    80001ec6:	0005061b          	sext.w	a2,a0
    80001eca:	fa69                	bnez	a2,80001e9c <growproc+0x26>
      return -1;
    80001ecc:	557d                	li	a0,-1
    80001ece:	bfe1                	j	80001ea6 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ed0:	9e25                	addw	a2,a2,s1
    80001ed2:	1602                	slli	a2,a2,0x20
    80001ed4:	9201                	srli	a2,a2,0x20
    80001ed6:	1582                	slli	a1,a1,0x20
    80001ed8:	9181                	srli	a1,a1,0x20
    80001eda:	6d28                	ld	a0,88(a0)
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	778080e7          	jalr	1912(ra) # 80001654 <uvmdealloc>
    80001ee4:	0005061b          	sext.w	a2,a0
    80001ee8:	bf55                	j	80001e9c <growproc+0x26>

0000000080001eea <fork>:
{
    80001eea:	7139                	addi	sp,sp,-64
    80001eec:	fc06                	sd	ra,56(sp)
    80001eee:	f822                	sd	s0,48(sp)
    80001ef0:	f426                	sd	s1,40(sp)
    80001ef2:	f04a                	sd	s2,32(sp)
    80001ef4:	ec4e                	sd	s3,24(sp)
    80001ef6:	e852                	sd	s4,16(sp)
    80001ef8:	e456                	sd	s5,8(sp)
    80001efa:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001efc:	00000097          	auipc	ra,0x0
    80001f00:	c84080e7          	jalr	-892(ra) # 80001b80 <myproc>
    80001f04:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	d9a080e7          	jalr	-614(ra) # 80001ca0 <allocproc>
    80001f0e:	c17d                	beqz	a0,80001ff4 <fork+0x10a>
    80001f10:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f12:	050ab603          	ld	a2,80(s5)
    80001f16:	6d2c                	ld	a1,88(a0)
    80001f18:	058ab503          	ld	a0,88(s5)
    80001f1c:	00000097          	auipc	ra,0x0
    80001f20:	854080e7          	jalr	-1964(ra) # 80001770 <uvmcopy>
    80001f24:	04054a63          	bltz	a0,80001f78 <fork+0x8e>
  np->sz = p->sz;
    80001f28:	050ab783          	ld	a5,80(s5)
    80001f2c:	04fa3823          	sd	a5,80(s4)
  np->parent = p;
    80001f30:	035a3423          	sd	s5,40(s4)
  *(np->tf) = *(p->tf);
    80001f34:	060ab683          	ld	a3,96(s5)
    80001f38:	87b6                	mv	a5,a3
    80001f3a:	060a3703          	ld	a4,96(s4)
    80001f3e:	12068693          	addi	a3,a3,288
    80001f42:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f46:	6788                	ld	a0,8(a5)
    80001f48:	6b8c                	ld	a1,16(a5)
    80001f4a:	6f90                	ld	a2,24(a5)
    80001f4c:	01073023          	sd	a6,0(a4)
    80001f50:	e708                	sd	a0,8(a4)
    80001f52:	eb0c                	sd	a1,16(a4)
    80001f54:	ef10                	sd	a2,24(a4)
    80001f56:	02078793          	addi	a5,a5,32
    80001f5a:	02070713          	addi	a4,a4,32
    80001f5e:	fed792e3          	bne	a5,a3,80001f42 <fork+0x58>
  np->tf->a0 = 0;
    80001f62:	060a3783          	ld	a5,96(s4)
    80001f66:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f6a:	0d8a8493          	addi	s1,s5,216
    80001f6e:	0d8a0913          	addi	s2,s4,216
    80001f72:	158a8993          	addi	s3,s5,344
    80001f76:	a00d                	j	80001f98 <fork+0xae>
    freeproc(np);
    80001f78:	8552                	mv	a0,s4
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	e22080e7          	jalr	-478(ra) # 80001d9c <freeproc>
    release(&np->lock);
    80001f82:	8552                	mv	a0,s4
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	d14080e7          	jalr	-748(ra) # 80000c98 <release>
    return -1;
    80001f8c:	54fd                	li	s1,-1
    80001f8e:	a889                	j	80001fe0 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001f90:	04a1                	addi	s1,s1,8
    80001f92:	0921                	addi	s2,s2,8
    80001f94:	01348b63          	beq	s1,s3,80001faa <fork+0xc0>
    if(p->ofile[i])
    80001f98:	6088                	ld	a0,0(s1)
    80001f9a:	d97d                	beqz	a0,80001f90 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f9c:	00003097          	auipc	ra,0x3
    80001fa0:	830080e7          	jalr	-2000(ra) # 800047cc <filedup>
    80001fa4:	00a93023          	sd	a0,0(s2)
    80001fa8:	b7e5                	j	80001f90 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001faa:	158ab503          	ld	a0,344(s5)
    80001fae:	00002097          	auipc	ra,0x2
    80001fb2:	8b2080e7          	jalr	-1870(ra) # 80003860 <idup>
    80001fb6:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fba:	4641                	li	a2,16
    80001fbc:	160a8593          	addi	a1,s5,352
    80001fc0:	160a0513          	addi	a0,s4,352
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	024080e7          	jalr	36(ra) # 80000fe8 <safestrcpy>
  pid = np->pid;
    80001fcc:	040a2483          	lw	s1,64(s4)
  np->state = RUNNABLE;
    80001fd0:	4789                	li	a5,2
    80001fd2:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80001fd6:	8552                	mv	a0,s4
    80001fd8:	fffff097          	auipc	ra,0xfffff
    80001fdc:	cc0080e7          	jalr	-832(ra) # 80000c98 <release>
}
    80001fe0:	8526                	mv	a0,s1
    80001fe2:	70e2                	ld	ra,56(sp)
    80001fe4:	7442                	ld	s0,48(sp)
    80001fe6:	74a2                	ld	s1,40(sp)
    80001fe8:	7902                	ld	s2,32(sp)
    80001fea:	69e2                	ld	s3,24(sp)
    80001fec:	6a42                	ld	s4,16(sp)
    80001fee:	6aa2                	ld	s5,8(sp)
    80001ff0:	6121                	addi	sp,sp,64
    80001ff2:	8082                	ret
    return -1;
    80001ff4:	54fd                	li	s1,-1
    80001ff6:	b7ed                	j	80001fe0 <fork+0xf6>

0000000080001ff8 <reparent>:
{
    80001ff8:	7179                	addi	sp,sp,-48
    80001ffa:	f406                	sd	ra,40(sp)
    80001ffc:	f022                	sd	s0,32(sp)
    80001ffe:	ec26                	sd	s1,24(sp)
    80002000:	e84a                	sd	s2,16(sp)
    80002002:	e44e                	sd	s3,8(sp)
    80002004:	e052                	sd	s4,0(sp)
    80002006:	1800                	addi	s0,sp,48
    80002008:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000200a:	00013497          	auipc	s1,0x13
    8000200e:	d6e48493          	addi	s1,s1,-658 # 80014d78 <proc>
      pp->parent = initproc;
    80002012:	0002ea17          	auipc	s4,0x2e
    80002016:	026a0a13          	addi	s4,s4,38 # 80030038 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000201a:	00019997          	auipc	s3,0x19
    8000201e:	95e98993          	addi	s3,s3,-1698 # 8001a978 <tickslock>
    80002022:	a029                	j	8000202c <reparent+0x34>
    80002024:	17048493          	addi	s1,s1,368
    80002028:	03348363          	beq	s1,s3,8000204e <reparent+0x56>
    if(pp->parent == p){
    8000202c:	749c                	ld	a5,40(s1)
    8000202e:	ff279be3          	bne	a5,s2,80002024 <reparent+0x2c>
      acquire(&pp->lock);
    80002032:	8526                	mv	a0,s1
    80002034:	fffff097          	auipc	ra,0xfffff
    80002038:	bf4080e7          	jalr	-1036(ra) # 80000c28 <acquire>
      pp->parent = initproc;
    8000203c:	000a3783          	ld	a5,0(s4)
    80002040:	f49c                	sd	a5,40(s1)
      release(&pp->lock);
    80002042:	8526                	mv	a0,s1
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	c54080e7          	jalr	-940(ra) # 80000c98 <release>
    8000204c:	bfe1                	j	80002024 <reparent+0x2c>
}
    8000204e:	70a2                	ld	ra,40(sp)
    80002050:	7402                	ld	s0,32(sp)
    80002052:	64e2                	ld	s1,24(sp)
    80002054:	6942                	ld	s2,16(sp)
    80002056:	69a2                	ld	s3,8(sp)
    80002058:	6a02                	ld	s4,0(sp)
    8000205a:	6145                	addi	sp,sp,48
    8000205c:	8082                	ret

000000008000205e <scheduler>:
{
    8000205e:	715d                	addi	sp,sp,-80
    80002060:	e486                	sd	ra,72(sp)
    80002062:	e0a2                	sd	s0,64(sp)
    80002064:	fc26                	sd	s1,56(sp)
    80002066:	f84a                	sd	s2,48(sp)
    80002068:	f44e                	sd	s3,40(sp)
    8000206a:	f052                	sd	s4,32(sp)
    8000206c:	ec56                	sd	s5,24(sp)
    8000206e:	e85a                	sd	s6,16(sp)
    80002070:	e45e                	sd	s7,8(sp)
    80002072:	e062                	sd	s8,0(sp)
    80002074:	0880                	addi	s0,sp,80
    80002076:	8792                	mv	a5,tp
  int id = r_tp();
    80002078:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000207a:	00779b13          	slli	s6,a5,0x7
    8000207e:	00013717          	auipc	a4,0x13
    80002082:	8da70713          	addi	a4,a4,-1830 # 80014958 <pid_lock>
    80002086:	975a                	add	a4,a4,s6
    80002088:	02073023          	sd	zero,32(a4)
        swtch(&c->scheduler, &p->context);
    8000208c:	00013717          	auipc	a4,0x13
    80002090:	8f470713          	addi	a4,a4,-1804 # 80014980 <cpus+0x8>
    80002094:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80002096:	4c0d                	li	s8,3
        c->proc = p;
    80002098:	079e                	slli	a5,a5,0x7
    8000209a:	00013a17          	auipc	s4,0x13
    8000209e:	8bea0a13          	addi	s4,s4,-1858 # 80014958 <pid_lock>
    800020a2:	9a3e                	add	s4,s4,a5
        found = 1;
    800020a4:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800020a6:	00019997          	auipc	s3,0x19
    800020aa:	8d298993          	addi	s3,s3,-1838 # 8001a978 <tickslock>
    800020ae:	a08d                	j	80002110 <scheduler+0xb2>
      release(&p->lock);
    800020b0:	8526                	mv	a0,s1
    800020b2:	fffff097          	auipc	ra,0xfffff
    800020b6:	be6080e7          	jalr	-1050(ra) # 80000c98 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ba:	17048493          	addi	s1,s1,368
    800020be:	03348963          	beq	s1,s3,800020f0 <scheduler+0x92>
      acquire(&p->lock);
    800020c2:	8526                	mv	a0,s1
    800020c4:	fffff097          	auipc	ra,0xfffff
    800020c8:	b64080e7          	jalr	-1180(ra) # 80000c28 <acquire>
      if(p->state == RUNNABLE) {
    800020cc:	509c                	lw	a5,32(s1)
    800020ce:	ff2791e3          	bne	a5,s2,800020b0 <scheduler+0x52>
        p->state = RUNNING;
    800020d2:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800020d6:	029a3023          	sd	s1,32(s4)
        swtch(&c->scheduler, &p->context);
    800020da:	06848593          	addi	a1,s1,104
    800020de:	855a                	mv	a0,s6
    800020e0:	00000097          	auipc	ra,0x0
    800020e4:	62c080e7          	jalr	1580(ra) # 8000270c <swtch>
        c->proc = 0;
    800020e8:	020a3023          	sd	zero,32(s4)
        found = 1;
    800020ec:	8ade                	mv	s5,s7
    800020ee:	b7c9                	j	800020b0 <scheduler+0x52>
    if(found == 0){
    800020f0:	020a9063          	bnez	s5,80002110 <scheduler+0xb2>
  asm volatile("csrr %0, sie" : "=r" (x) );
    800020f4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800020f8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800020fc:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002100:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002104:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002108:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000210c:	10500073          	wfi
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002110:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80002114:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80002118:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000211c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002120:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002124:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002128:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000212a:	00013497          	auipc	s1,0x13
    8000212e:	c4e48493          	addi	s1,s1,-946 # 80014d78 <proc>
      if(p->state == RUNNABLE) {
    80002132:	4909                	li	s2,2
    80002134:	b779                	j	800020c2 <scheduler+0x64>

0000000080002136 <sched>:
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	e84a                	sd	s2,16(sp)
    80002140:	e44e                	sd	s3,8(sp)
    80002142:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002144:	00000097          	auipc	ra,0x0
    80002148:	a3c080e7          	jalr	-1476(ra) # 80001b80 <myproc>
    8000214c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	a9a080e7          	jalr	-1382(ra) # 80000be8 <holding>
    80002156:	c93d                	beqz	a0,800021cc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002158:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000215a:	2781                	sext.w	a5,a5
    8000215c:	079e                	slli	a5,a5,0x7
    8000215e:	00012717          	auipc	a4,0x12
    80002162:	7fa70713          	addi	a4,a4,2042 # 80014958 <pid_lock>
    80002166:	97ba                	add	a5,a5,a4
    80002168:	0987a703          	lw	a4,152(a5)
    8000216c:	4785                	li	a5,1
    8000216e:	06f71763          	bne	a4,a5,800021dc <sched+0xa6>
  if(p->state == RUNNING)
    80002172:	5098                	lw	a4,32(s1)
    80002174:	478d                	li	a5,3
    80002176:	06f70b63          	beq	a4,a5,800021ec <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000217a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000217e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002180:	efb5                	bnez	a5,800021fc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002182:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002184:	00012917          	auipc	s2,0x12
    80002188:	7d490913          	addi	s2,s2,2004 # 80014958 <pid_lock>
    8000218c:	2781                	sext.w	a5,a5
    8000218e:	079e                	slli	a5,a5,0x7
    80002190:	97ca                	add	a5,a5,s2
    80002192:	09c7a983          	lw	s3,156(a5)
    80002196:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->scheduler);
    80002198:	2781                	sext.w	a5,a5
    8000219a:	079e                	slli	a5,a5,0x7
    8000219c:	00012597          	auipc	a1,0x12
    800021a0:	7e458593          	addi	a1,a1,2020 # 80014980 <cpus+0x8>
    800021a4:	95be                	add	a1,a1,a5
    800021a6:	06848513          	addi	a0,s1,104
    800021aa:	00000097          	auipc	ra,0x0
    800021ae:	562080e7          	jalr	1378(ra) # 8000270c <swtch>
    800021b2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800021b4:	2781                	sext.w	a5,a5
    800021b6:	079e                	slli	a5,a5,0x7
    800021b8:	97ca                	add	a5,a5,s2
    800021ba:	0937ae23          	sw	s3,156(a5)
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6145                	addi	sp,sp,48
    800021ca:	8082                	ret
    panic("sched p->lock");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	28c50513          	addi	a0,a0,652 # 80008458 <userret+0x3c8>
    800021d4:	ffffe097          	auipc	ra,0xffffe
    800021d8:	374080e7          	jalr	884(ra) # 80000548 <panic>
    panic("sched locks");
    800021dc:	00006517          	auipc	a0,0x6
    800021e0:	28c50513          	addi	a0,a0,652 # 80008468 <userret+0x3d8>
    800021e4:	ffffe097          	auipc	ra,0xffffe
    800021e8:	364080e7          	jalr	868(ra) # 80000548 <panic>
    panic("sched running");
    800021ec:	00006517          	auipc	a0,0x6
    800021f0:	28c50513          	addi	a0,a0,652 # 80008478 <userret+0x3e8>
    800021f4:	ffffe097          	auipc	ra,0xffffe
    800021f8:	354080e7          	jalr	852(ra) # 80000548 <panic>
    panic("sched interruptible");
    800021fc:	00006517          	auipc	a0,0x6
    80002200:	28c50513          	addi	a0,a0,652 # 80008488 <userret+0x3f8>
    80002204:	ffffe097          	auipc	ra,0xffffe
    80002208:	344080e7          	jalr	836(ra) # 80000548 <panic>

000000008000220c <exit>:
{
    8000220c:	7179                	addi	sp,sp,-48
    8000220e:	f406                	sd	ra,40(sp)
    80002210:	f022                	sd	s0,32(sp)
    80002212:	ec26                	sd	s1,24(sp)
    80002214:	e84a                	sd	s2,16(sp)
    80002216:	e44e                	sd	s3,8(sp)
    80002218:	e052                	sd	s4,0(sp)
    8000221a:	1800                	addi	s0,sp,48
    8000221c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000221e:	00000097          	auipc	ra,0x0
    80002222:	962080e7          	jalr	-1694(ra) # 80001b80 <myproc>
    80002226:	89aa                	mv	s3,a0
  if(p == initproc)
    80002228:	0002e797          	auipc	a5,0x2e
    8000222c:	e107b783          	ld	a5,-496(a5) # 80030038 <initproc>
    80002230:	0d850493          	addi	s1,a0,216
    80002234:	15850913          	addi	s2,a0,344
    80002238:	02a79363          	bne	a5,a0,8000225e <exit+0x52>
    panic("init exiting");
    8000223c:	00006517          	auipc	a0,0x6
    80002240:	26450513          	addi	a0,a0,612 # 800084a0 <userret+0x410>
    80002244:	ffffe097          	auipc	ra,0xffffe
    80002248:	304080e7          	jalr	772(ra) # 80000548 <panic>
      fileclose(f);
    8000224c:	00002097          	auipc	ra,0x2
    80002250:	5d2080e7          	jalr	1490(ra) # 8000481e <fileclose>
      p->ofile[fd] = 0;
    80002254:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002258:	04a1                	addi	s1,s1,8
    8000225a:	01248563          	beq	s1,s2,80002264 <exit+0x58>
    if(p->ofile[fd]){
    8000225e:	6088                	ld	a0,0(s1)
    80002260:	f575                	bnez	a0,8000224c <exit+0x40>
    80002262:	bfdd                	j	80002258 <exit+0x4c>
  begin_op(ROOTDEV);
    80002264:	4501                	li	a0,0
    80002266:	00002097          	auipc	ra,0x2
    8000226a:	01e080e7          	jalr	30(ra) # 80004284 <begin_op>
  iput(p->cwd);
    8000226e:	1589b503          	ld	a0,344(s3)
    80002272:	00001097          	auipc	ra,0x1
    80002276:	73a080e7          	jalr	1850(ra) # 800039ac <iput>
  end_op(ROOTDEV);
    8000227a:	4501                	li	a0,0
    8000227c:	00002097          	auipc	ra,0x2
    80002280:	0b2080e7          	jalr	178(ra) # 8000432e <end_op>
  p->cwd = 0;
    80002284:	1409bc23          	sd	zero,344(s3)
  acquire(&initproc->lock);
    80002288:	0002e497          	auipc	s1,0x2e
    8000228c:	db048493          	addi	s1,s1,-592 # 80030038 <initproc>
    80002290:	6088                	ld	a0,0(s1)
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	996080e7          	jalr	-1642(ra) # 80000c28 <acquire>
  wakeup1(initproc);
    8000229a:	6088                	ld	a0,0(s1)
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	7a4080e7          	jalr	1956(ra) # 80001a40 <wakeup1>
  release(&initproc->lock);
    800022a4:	6088                	ld	a0,0(s1)
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	9f2080e7          	jalr	-1550(ra) # 80000c98 <release>
  acquire(&p->lock);
    800022ae:	854e                	mv	a0,s3
    800022b0:	fffff097          	auipc	ra,0xfffff
    800022b4:	978080e7          	jalr	-1672(ra) # 80000c28 <acquire>
  struct proc *original_parent = p->parent;
    800022b8:	0289b483          	ld	s1,40(s3)
  release(&p->lock);
    800022bc:	854e                	mv	a0,s3
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	9da080e7          	jalr	-1574(ra) # 80000c98 <release>
  acquire(&original_parent->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	960080e7          	jalr	-1696(ra) # 80000c28 <acquire>
  acquire(&p->lock);
    800022d0:	854e                	mv	a0,s3
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	956080e7          	jalr	-1706(ra) # 80000c28 <acquire>
  reparent(p);
    800022da:	854e                	mv	a0,s3
    800022dc:	00000097          	auipc	ra,0x0
    800022e0:	d1c080e7          	jalr	-740(ra) # 80001ff8 <reparent>
  wakeup1(original_parent);
    800022e4:	8526                	mv	a0,s1
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	75a080e7          	jalr	1882(ra) # 80001a40 <wakeup1>
  p->xstate = status;
    800022ee:	0349ae23          	sw	s4,60(s3)
  p->state = ZOMBIE;
    800022f2:	4791                	li	a5,4
    800022f4:	02f9a023          	sw	a5,32(s3)
  release(&original_parent->lock);
    800022f8:	8526                	mv	a0,s1
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	99e080e7          	jalr	-1634(ra) # 80000c98 <release>
  sched();
    80002302:	00000097          	auipc	ra,0x0
    80002306:	e34080e7          	jalr	-460(ra) # 80002136 <sched>
  panic("zombie exit");
    8000230a:	00006517          	auipc	a0,0x6
    8000230e:	1a650513          	addi	a0,a0,422 # 800084b0 <userret+0x420>
    80002312:	ffffe097          	auipc	ra,0xffffe
    80002316:	236080e7          	jalr	566(ra) # 80000548 <panic>

000000008000231a <yield>:
{
    8000231a:	1101                	addi	sp,sp,-32
    8000231c:	ec06                	sd	ra,24(sp)
    8000231e:	e822                	sd	s0,16(sp)
    80002320:	e426                	sd	s1,8(sp)
    80002322:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002324:	00000097          	auipc	ra,0x0
    80002328:	85c080e7          	jalr	-1956(ra) # 80001b80 <myproc>
    8000232c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	8fa080e7          	jalr	-1798(ra) # 80000c28 <acquire>
  p->state = RUNNABLE;
    80002336:	4789                	li	a5,2
    80002338:	d09c                	sw	a5,32(s1)
  sched();
    8000233a:	00000097          	auipc	ra,0x0
    8000233e:	dfc080e7          	jalr	-516(ra) # 80002136 <sched>
  release(&p->lock);
    80002342:	8526                	mv	a0,s1
    80002344:	fffff097          	auipc	ra,0xfffff
    80002348:	954080e7          	jalr	-1708(ra) # 80000c98 <release>
}
    8000234c:	60e2                	ld	ra,24(sp)
    8000234e:	6442                	ld	s0,16(sp)
    80002350:	64a2                	ld	s1,8(sp)
    80002352:	6105                	addi	sp,sp,32
    80002354:	8082                	ret

0000000080002356 <sleep>:
{
    80002356:	7179                	addi	sp,sp,-48
    80002358:	f406                	sd	ra,40(sp)
    8000235a:	f022                	sd	s0,32(sp)
    8000235c:	ec26                	sd	s1,24(sp)
    8000235e:	e84a                	sd	s2,16(sp)
    80002360:	e44e                	sd	s3,8(sp)
    80002362:	1800                	addi	s0,sp,48
    80002364:	89aa                	mv	s3,a0
    80002366:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	818080e7          	jalr	-2024(ra) # 80001b80 <myproc>
    80002370:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002372:	05250663          	beq	a0,s2,800023be <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	8b2080e7          	jalr	-1870(ra) # 80000c28 <acquire>
    release(lk);
    8000237e:	854a                	mv	a0,s2
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	918080e7          	jalr	-1768(ra) # 80000c98 <release>
  p->chan = chan;
    80002388:	0334b823          	sd	s3,48(s1)
  p->state = SLEEPING;
    8000238c:	4785                	li	a5,1
    8000238e:	d09c                	sw	a5,32(s1)
  sched();
    80002390:	00000097          	auipc	ra,0x0
    80002394:	da6080e7          	jalr	-602(ra) # 80002136 <sched>
  p->chan = 0;
    80002398:	0204b823          	sd	zero,48(s1)
    release(&p->lock);
    8000239c:	8526                	mv	a0,s1
    8000239e:	fffff097          	auipc	ra,0xfffff
    800023a2:	8fa080e7          	jalr	-1798(ra) # 80000c98 <release>
    acquire(lk);
    800023a6:	854a                	mv	a0,s2
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	880080e7          	jalr	-1920(ra) # 80000c28 <acquire>
}
    800023b0:	70a2                	ld	ra,40(sp)
    800023b2:	7402                	ld	s0,32(sp)
    800023b4:	64e2                	ld	s1,24(sp)
    800023b6:	6942                	ld	s2,16(sp)
    800023b8:	69a2                	ld	s3,8(sp)
    800023ba:	6145                	addi	sp,sp,48
    800023bc:	8082                	ret
  p->chan = chan;
    800023be:	03353823          	sd	s3,48(a0)
  p->state = SLEEPING;
    800023c2:	4785                	li	a5,1
    800023c4:	d11c                	sw	a5,32(a0)
  sched();
    800023c6:	00000097          	auipc	ra,0x0
    800023ca:	d70080e7          	jalr	-656(ra) # 80002136 <sched>
  p->chan = 0;
    800023ce:	0204b823          	sd	zero,48(s1)
  if(lk != &p->lock){
    800023d2:	bff9                	j	800023b0 <sleep+0x5a>

00000000800023d4 <wait>:
{
    800023d4:	715d                	addi	sp,sp,-80
    800023d6:	e486                	sd	ra,72(sp)
    800023d8:	e0a2                	sd	s0,64(sp)
    800023da:	fc26                	sd	s1,56(sp)
    800023dc:	f84a                	sd	s2,48(sp)
    800023de:	f44e                	sd	s3,40(sp)
    800023e0:	f052                	sd	s4,32(sp)
    800023e2:	ec56                	sd	s5,24(sp)
    800023e4:	e85a                	sd	s6,16(sp)
    800023e6:	e45e                	sd	s7,8(sp)
    800023e8:	0880                	addi	s0,sp,80
    800023ea:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	794080e7          	jalr	1940(ra) # 80001b80 <myproc>
    800023f4:	892a                	mv	s2,a0
  acquire(&p->lock);
    800023f6:	fffff097          	auipc	ra,0xfffff
    800023fa:	832080e7          	jalr	-1998(ra) # 80000c28 <acquire>
    havekids = 0;
    800023fe:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002400:	4a11                	li	s4,4
        havekids = 1;
    80002402:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002404:	00018997          	auipc	s3,0x18
    80002408:	57498993          	addi	s3,s3,1396 # 8001a978 <tickslock>
    havekids = 0;
    8000240c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000240e:	00013497          	auipc	s1,0x13
    80002412:	96a48493          	addi	s1,s1,-1686 # 80014d78 <proc>
    80002416:	a08d                	j	80002478 <wait+0xa4>
          pid = np->pid;
    80002418:	0404a983          	lw	s3,64(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000241c:	000b0e63          	beqz	s6,80002438 <wait+0x64>
    80002420:	4691                	li	a3,4
    80002422:	03c48613          	addi	a2,s1,60
    80002426:	85da                	mv	a1,s6
    80002428:	05893503          	ld	a0,88(s2)
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	446080e7          	jalr	1094(ra) # 80001872 <copyout>
    80002434:	02054263          	bltz	a0,80002458 <wait+0x84>
          freeproc(np);
    80002438:	8526                	mv	a0,s1
    8000243a:	00000097          	auipc	ra,0x0
    8000243e:	962080e7          	jalr	-1694(ra) # 80001d9c <freeproc>
          release(&np->lock);
    80002442:	8526                	mv	a0,s1
    80002444:	fffff097          	auipc	ra,0xfffff
    80002448:	854080e7          	jalr	-1964(ra) # 80000c98 <release>
          release(&p->lock);
    8000244c:	854a                	mv	a0,s2
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	84a080e7          	jalr	-1974(ra) # 80000c98 <release>
          return pid;
    80002456:	a8a9                	j	800024b0 <wait+0xdc>
            release(&np->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	83e080e7          	jalr	-1986(ra) # 80000c98 <release>
            release(&p->lock);
    80002462:	854a                	mv	a0,s2
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	834080e7          	jalr	-1996(ra) # 80000c98 <release>
            return -1;
    8000246c:	59fd                	li	s3,-1
    8000246e:	a089                	j	800024b0 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002470:	17048493          	addi	s1,s1,368
    80002474:	03348463          	beq	s1,s3,8000249c <wait+0xc8>
      if(np->parent == p){
    80002478:	749c                	ld	a5,40(s1)
    8000247a:	ff279be3          	bne	a5,s2,80002470 <wait+0x9c>
        acquire(&np->lock);
    8000247e:	8526                	mv	a0,s1
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	7a8080e7          	jalr	1960(ra) # 80000c28 <acquire>
        if(np->state == ZOMBIE){
    80002488:	509c                	lw	a5,32(s1)
    8000248a:	f94787e3          	beq	a5,s4,80002418 <wait+0x44>
        release(&np->lock);
    8000248e:	8526                	mv	a0,s1
    80002490:	fffff097          	auipc	ra,0xfffff
    80002494:	808080e7          	jalr	-2040(ra) # 80000c98 <release>
        havekids = 1;
    80002498:	8756                	mv	a4,s5
    8000249a:	bfd9                	j	80002470 <wait+0x9c>
    if(!havekids || p->killed){
    8000249c:	c701                	beqz	a4,800024a4 <wait+0xd0>
    8000249e:	03892783          	lw	a5,56(s2)
    800024a2:	c39d                	beqz	a5,800024c8 <wait+0xf4>
      release(&p->lock);
    800024a4:	854a                	mv	a0,s2
    800024a6:	ffffe097          	auipc	ra,0xffffe
    800024aa:	7f2080e7          	jalr	2034(ra) # 80000c98 <release>
      return -1;
    800024ae:	59fd                	li	s3,-1
}
    800024b0:	854e                	mv	a0,s3
    800024b2:	60a6                	ld	ra,72(sp)
    800024b4:	6406                	ld	s0,64(sp)
    800024b6:	74e2                	ld	s1,56(sp)
    800024b8:	7942                	ld	s2,48(sp)
    800024ba:	79a2                	ld	s3,40(sp)
    800024bc:	7a02                	ld	s4,32(sp)
    800024be:	6ae2                	ld	s5,24(sp)
    800024c0:	6b42                	ld	s6,16(sp)
    800024c2:	6ba2                	ld	s7,8(sp)
    800024c4:	6161                	addi	sp,sp,80
    800024c6:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800024c8:	85ca                	mv	a1,s2
    800024ca:	854a                	mv	a0,s2
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	e8a080e7          	jalr	-374(ra) # 80002356 <sleep>
    havekids = 0;
    800024d4:	bf25                	j	8000240c <wait+0x38>

00000000800024d6 <wakeup>:
{
    800024d6:	7139                	addi	sp,sp,-64
    800024d8:	fc06                	sd	ra,56(sp)
    800024da:	f822                	sd	s0,48(sp)
    800024dc:	f426                	sd	s1,40(sp)
    800024de:	f04a                	sd	s2,32(sp)
    800024e0:	ec4e                	sd	s3,24(sp)
    800024e2:	e852                	sd	s4,16(sp)
    800024e4:	e456                	sd	s5,8(sp)
    800024e6:	0080                	addi	s0,sp,64
    800024e8:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800024ea:	00013497          	auipc	s1,0x13
    800024ee:	88e48493          	addi	s1,s1,-1906 # 80014d78 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800024f2:	4985                	li	s3,1
      p->state = RUNNABLE;
    800024f4:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800024f6:	00018917          	auipc	s2,0x18
    800024fa:	48290913          	addi	s2,s2,1154 # 8001a978 <tickslock>
    800024fe:	a811                	j	80002512 <wakeup+0x3c>
    release(&p->lock);
    80002500:	8526                	mv	a0,s1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	796080e7          	jalr	1942(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000250a:	17048493          	addi	s1,s1,368
    8000250e:	03248063          	beq	s1,s2,8000252e <wakeup+0x58>
    acquire(&p->lock);
    80002512:	8526                	mv	a0,s1
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	714080e7          	jalr	1812(ra) # 80000c28 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    8000251c:	509c                	lw	a5,32(s1)
    8000251e:	ff3791e3          	bne	a5,s3,80002500 <wakeup+0x2a>
    80002522:	789c                	ld	a5,48(s1)
    80002524:	fd479ee3          	bne	a5,s4,80002500 <wakeup+0x2a>
      p->state = RUNNABLE;
    80002528:	0354a023          	sw	s5,32(s1)
    8000252c:	bfd1                	j	80002500 <wakeup+0x2a>
}
    8000252e:	70e2                	ld	ra,56(sp)
    80002530:	7442                	ld	s0,48(sp)
    80002532:	74a2                	ld	s1,40(sp)
    80002534:	7902                	ld	s2,32(sp)
    80002536:	69e2                	ld	s3,24(sp)
    80002538:	6a42                	ld	s4,16(sp)
    8000253a:	6aa2                	ld	s5,8(sp)
    8000253c:	6121                	addi	sp,sp,64
    8000253e:	8082                	ret

0000000080002540 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002540:	7179                	addi	sp,sp,-48
    80002542:	f406                	sd	ra,40(sp)
    80002544:	f022                	sd	s0,32(sp)
    80002546:	ec26                	sd	s1,24(sp)
    80002548:	e84a                	sd	s2,16(sp)
    8000254a:	e44e                	sd	s3,8(sp)
    8000254c:	1800                	addi	s0,sp,48
    8000254e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002550:	00013497          	auipc	s1,0x13
    80002554:	82848493          	addi	s1,s1,-2008 # 80014d78 <proc>
    80002558:	00018997          	auipc	s3,0x18
    8000255c:	42098993          	addi	s3,s3,1056 # 8001a978 <tickslock>
    acquire(&p->lock);
    80002560:	8526                	mv	a0,s1
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	6c6080e7          	jalr	1734(ra) # 80000c28 <acquire>
    if(p->pid == pid){
    8000256a:	40bc                	lw	a5,64(s1)
    8000256c:	01278d63          	beq	a5,s2,80002586 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	726080e7          	jalr	1830(ra) # 80000c98 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257a:	17048493          	addi	s1,s1,368
    8000257e:	ff3491e3          	bne	s1,s3,80002560 <kill+0x20>
  }
  return -1;
    80002582:	557d                	li	a0,-1
    80002584:	a821                	j	8000259c <kill+0x5c>
      p->killed = 1;
    80002586:	4785                	li	a5,1
    80002588:	dc9c                	sw	a5,56(s1)
      if(p->state == SLEEPING){
    8000258a:	5098                	lw	a4,32(s1)
    8000258c:	00f70f63          	beq	a4,a5,800025aa <kill+0x6a>
      release(&p->lock);
    80002590:	8526                	mv	a0,s1
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	706080e7          	jalr	1798(ra) # 80000c98 <release>
      return 0;
    8000259a:	4501                	li	a0,0
}
    8000259c:	70a2                	ld	ra,40(sp)
    8000259e:	7402                	ld	s0,32(sp)
    800025a0:	64e2                	ld	s1,24(sp)
    800025a2:	6942                	ld	s2,16(sp)
    800025a4:	69a2                	ld	s3,8(sp)
    800025a6:	6145                	addi	sp,sp,48
    800025a8:	8082                	ret
        p->state = RUNNABLE;
    800025aa:	4789                	li	a5,2
    800025ac:	d09c                	sw	a5,32(s1)
    800025ae:	b7cd                	j	80002590 <kill+0x50>

00000000800025b0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025b0:	7179                	addi	sp,sp,-48
    800025b2:	f406                	sd	ra,40(sp)
    800025b4:	f022                	sd	s0,32(sp)
    800025b6:	ec26                	sd	s1,24(sp)
    800025b8:	e84a                	sd	s2,16(sp)
    800025ba:	e44e                	sd	s3,8(sp)
    800025bc:	e052                	sd	s4,0(sp)
    800025be:	1800                	addi	s0,sp,48
    800025c0:	84aa                	mv	s1,a0
    800025c2:	892e                	mv	s2,a1
    800025c4:	89b2                	mv	s3,a2
    800025c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c8:	fffff097          	auipc	ra,0xfffff
    800025cc:	5b8080e7          	jalr	1464(ra) # 80001b80 <myproc>
  if(user_dst){
    800025d0:	c08d                	beqz	s1,800025f2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025d2:	86d2                	mv	a3,s4
    800025d4:	864e                	mv	a2,s3
    800025d6:	85ca                	mv	a1,s2
    800025d8:	6d28                	ld	a0,88(a0)
    800025da:	fffff097          	auipc	ra,0xfffff
    800025de:	298080e7          	jalr	664(ra) # 80001872 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025e2:	70a2                	ld	ra,40(sp)
    800025e4:	7402                	ld	s0,32(sp)
    800025e6:	64e2                	ld	s1,24(sp)
    800025e8:	6942                	ld	s2,16(sp)
    800025ea:	69a2                	ld	s3,8(sp)
    800025ec:	6a02                	ld	s4,0(sp)
    800025ee:	6145                	addi	sp,sp,48
    800025f0:	8082                	ret
    memmove((char *)dst, src, len);
    800025f2:	000a061b          	sext.w	a2,s4
    800025f6:	85ce                	mv	a1,s3
    800025f8:	854a                	mv	a0,s2
    800025fa:	fffff097          	auipc	ra,0xfffff
    800025fe:	8f8080e7          	jalr	-1800(ra) # 80000ef2 <memmove>
    return 0;
    80002602:	8526                	mv	a0,s1
    80002604:	bff9                	j	800025e2 <either_copyout+0x32>

0000000080002606 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002606:	7179                	addi	sp,sp,-48
    80002608:	f406                	sd	ra,40(sp)
    8000260a:	f022                	sd	s0,32(sp)
    8000260c:	ec26                	sd	s1,24(sp)
    8000260e:	e84a                	sd	s2,16(sp)
    80002610:	e44e                	sd	s3,8(sp)
    80002612:	e052                	sd	s4,0(sp)
    80002614:	1800                	addi	s0,sp,48
    80002616:	892a                	mv	s2,a0
    80002618:	84ae                	mv	s1,a1
    8000261a:	89b2                	mv	s3,a2
    8000261c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000261e:	fffff097          	auipc	ra,0xfffff
    80002622:	562080e7          	jalr	1378(ra) # 80001b80 <myproc>
  if(user_src){
    80002626:	c08d                	beqz	s1,80002648 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002628:	86d2                	mv	a3,s4
    8000262a:	864e                	mv	a2,s3
    8000262c:	85ca                	mv	a1,s2
    8000262e:	6d28                	ld	a0,88(a0)
    80002630:	fffff097          	auipc	ra,0xfffff
    80002634:	2ce080e7          	jalr	718(ra) # 800018fe <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002638:	70a2                	ld	ra,40(sp)
    8000263a:	7402                	ld	s0,32(sp)
    8000263c:	64e2                	ld	s1,24(sp)
    8000263e:	6942                	ld	s2,16(sp)
    80002640:	69a2                	ld	s3,8(sp)
    80002642:	6a02                	ld	s4,0(sp)
    80002644:	6145                	addi	sp,sp,48
    80002646:	8082                	ret
    memmove(dst, (char*)src, len);
    80002648:	000a061b          	sext.w	a2,s4
    8000264c:	85ce                	mv	a1,s3
    8000264e:	854a                	mv	a0,s2
    80002650:	fffff097          	auipc	ra,0xfffff
    80002654:	8a2080e7          	jalr	-1886(ra) # 80000ef2 <memmove>
    return 0;
    80002658:	8526                	mv	a0,s1
    8000265a:	bff9                	j	80002638 <either_copyin+0x32>

000000008000265c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000265c:	715d                	addi	sp,sp,-80
    8000265e:	e486                	sd	ra,72(sp)
    80002660:	e0a2                	sd	s0,64(sp)
    80002662:	fc26                	sd	s1,56(sp)
    80002664:	f84a                	sd	s2,48(sp)
    80002666:	f44e                	sd	s3,40(sp)
    80002668:	f052                	sd	s4,32(sp)
    8000266a:	ec56                	sd	s5,24(sp)
    8000266c:	e85a                	sd	s6,16(sp)
    8000266e:	e45e                	sd	s7,8(sp)
    80002670:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002672:	00006517          	auipc	a0,0x6
    80002676:	c1e50513          	addi	a0,a0,-994 # 80008290 <userret+0x200>
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	f28080e7          	jalr	-216(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002682:	00013497          	auipc	s1,0x13
    80002686:	85648493          	addi	s1,s1,-1962 # 80014ed8 <proc+0x160>
    8000268a:	00018917          	auipc	s2,0x18
    8000268e:	44e90913          	addi	s2,s2,1102 # 8001aad8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002692:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002694:	00006997          	auipc	s3,0x6
    80002698:	e2c98993          	addi	s3,s3,-468 # 800084c0 <userret+0x430>
    printf("%d %s %s", p->pid, state, p->name);
    8000269c:	00006a97          	auipc	s5,0x6
    800026a0:	e2ca8a93          	addi	s5,s5,-468 # 800084c8 <userret+0x438>
    printf("\n");
    800026a4:	00006a17          	auipc	s4,0x6
    800026a8:	beca0a13          	addi	s4,s4,-1044 # 80008290 <userret+0x200>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ac:	00006b97          	auipc	s7,0x6
    800026b0:	42cb8b93          	addi	s7,s7,1068 # 80008ad8 <states.0>
    800026b4:	a00d                	j	800026d6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026b6:	ee06a583          	lw	a1,-288(a3)
    800026ba:	8556                	mv	a0,s5
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	ee6080e7          	jalr	-282(ra) # 800005a2 <printf>
    printf("\n");
    800026c4:	8552                	mv	a0,s4
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	edc080e7          	jalr	-292(ra) # 800005a2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ce:	17048493          	addi	s1,s1,368
    800026d2:	03248263          	beq	s1,s2,800026f6 <procdump+0x9a>
    if(p->state == UNUSED)
    800026d6:	86a6                	mv	a3,s1
    800026d8:	ec04a783          	lw	a5,-320(s1)
    800026dc:	dbed                	beqz	a5,800026ce <procdump+0x72>
      state = "???";
    800026de:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e0:	fcfb6be3          	bltu	s6,a5,800026b6 <procdump+0x5a>
    800026e4:	02079713          	slli	a4,a5,0x20
    800026e8:	01d75793          	srli	a5,a4,0x1d
    800026ec:	97de                	add	a5,a5,s7
    800026ee:	6390                	ld	a2,0(a5)
    800026f0:	f279                	bnez	a2,800026b6 <procdump+0x5a>
      state = "???";
    800026f2:	864e                	mv	a2,s3
    800026f4:	b7c9                	j	800026b6 <procdump+0x5a>
  }
}
    800026f6:	60a6                	ld	ra,72(sp)
    800026f8:	6406                	ld	s0,64(sp)
    800026fa:	74e2                	ld	s1,56(sp)
    800026fc:	7942                	ld	s2,48(sp)
    800026fe:	79a2                	ld	s3,40(sp)
    80002700:	7a02                	ld	s4,32(sp)
    80002702:	6ae2                	ld	s5,24(sp)
    80002704:	6b42                	ld	s6,16(sp)
    80002706:	6ba2                	ld	s7,8(sp)
    80002708:	6161                	addi	sp,sp,80
    8000270a:	8082                	ret

000000008000270c <swtch>:
    8000270c:	00153023          	sd	ra,0(a0)
    80002710:	00253423          	sd	sp,8(a0)
    80002714:	e900                	sd	s0,16(a0)
    80002716:	ed04                	sd	s1,24(a0)
    80002718:	03253023          	sd	s2,32(a0)
    8000271c:	03353423          	sd	s3,40(a0)
    80002720:	03453823          	sd	s4,48(a0)
    80002724:	03553c23          	sd	s5,56(a0)
    80002728:	05653023          	sd	s6,64(a0)
    8000272c:	05753423          	sd	s7,72(a0)
    80002730:	05853823          	sd	s8,80(a0)
    80002734:	05953c23          	sd	s9,88(a0)
    80002738:	07a53023          	sd	s10,96(a0)
    8000273c:	07b53423          	sd	s11,104(a0)
    80002740:	0005b083          	ld	ra,0(a1)
    80002744:	0085b103          	ld	sp,8(a1)
    80002748:	6980                	ld	s0,16(a1)
    8000274a:	6d84                	ld	s1,24(a1)
    8000274c:	0205b903          	ld	s2,32(a1)
    80002750:	0285b983          	ld	s3,40(a1)
    80002754:	0305ba03          	ld	s4,48(a1)
    80002758:	0385ba83          	ld	s5,56(a1)
    8000275c:	0405bb03          	ld	s6,64(a1)
    80002760:	0485bb83          	ld	s7,72(a1)
    80002764:	0505bc03          	ld	s8,80(a1)
    80002768:	0585bc83          	ld	s9,88(a1)
    8000276c:	0605bd03          	ld	s10,96(a1)
    80002770:	0685bd83          	ld	s11,104(a1)
    80002774:	8082                	ret

0000000080002776 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002776:	1141                	addi	sp,sp,-16
    80002778:	e406                	sd	ra,8(sp)
    8000277a:	e022                	sd	s0,0(sp)
    8000277c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000277e:	00006597          	auipc	a1,0x6
    80002782:	d8258593          	addi	a1,a1,-638 # 80008500 <userret+0x470>
    80002786:	00018517          	auipc	a0,0x18
    8000278a:	1f250513          	addi	a0,a0,498 # 8001a978 <tickslock>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	34c080e7          	jalr	844(ra) # 80000ada <initlock>
}
    80002796:	60a2                	ld	ra,8(sp)
    80002798:	6402                	ld	s0,0(sp)
    8000279a:	0141                	addi	sp,sp,16
    8000279c:	8082                	ret

000000008000279e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000279e:	1141                	addi	sp,sp,-16
    800027a0:	e422                	sd	s0,8(sp)
    800027a2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a4:	00003797          	auipc	a5,0x3
    800027a8:	70c78793          	addi	a5,a5,1804 # 80005eb0 <kernelvec>
    800027ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027b0:	6422                	ld	s0,8(sp)
    800027b2:	0141                	addi	sp,sp,16
    800027b4:	8082                	ret

00000000800027b6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027b6:	1141                	addi	sp,sp,-16
    800027b8:	e406                	sd	ra,8(sp)
    800027ba:	e022                	sd	s0,0(sp)
    800027bc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027be:	fffff097          	auipc	ra,0xfffff
    800027c2:	3c2080e7          	jalr	962(ra) # 80001b80 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ca:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027cc:	10079073          	csrw	sstatus,a5
  // turn off interrupts, since we're switching
  // now from kerneltrap() to usertrap().
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027d0:	00006617          	auipc	a2,0x6
    800027d4:	83060613          	addi	a2,a2,-2000 # 80008000 <trampoline>
    800027d8:	00006697          	auipc	a3,0x6
    800027dc:	82868693          	addi	a3,a3,-2008 # 80008000 <trampoline>
    800027e0:	8e91                	sub	a3,a3,a2
    800027e2:	040007b7          	lui	a5,0x4000
    800027e6:	17fd                	addi	a5,a5,-1
    800027e8:	07b2                	slli	a5,a5,0xc
    800027ea:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ec:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->tf->kernel_satp = r_satp();         // kernel page table
    800027f0:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027f2:	180026f3          	csrr	a3,satp
    800027f6:	e314                	sd	a3,0(a4)
  p->tf->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027f8:	7138                	ld	a4,96(a0)
    800027fa:	6534                	ld	a3,72(a0)
    800027fc:	6585                	lui	a1,0x1
    800027fe:	96ae                	add	a3,a3,a1
    80002800:	e714                	sd	a3,8(a4)
  p->tf->kernel_trap = (uint64)usertrap;
    80002802:	7138                	ld	a4,96(a0)
    80002804:	00000697          	auipc	a3,0x0
    80002808:	12868693          	addi	a3,a3,296 # 8000292c <usertrap>
    8000280c:	eb14                	sd	a3,16(a4)
  p->tf->kernel_hartid = r_tp();         // hartid for cpuid()
    8000280e:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002810:	8692                	mv	a3,tp
    80002812:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002814:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002818:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000281c:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002820:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->tf->epc);
    80002824:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002826:	6f18                	ld	a4,24(a4)
    80002828:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000282c:	6d2c                	ld	a1,88(a0)
    8000282e:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002830:	00006717          	auipc	a4,0x6
    80002834:	86070713          	addi	a4,a4,-1952 # 80008090 <userret>
    80002838:	8f11                	sub	a4,a4,a2
    8000283a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    8000283c:	577d                	li	a4,-1
    8000283e:	177e                	slli	a4,a4,0x3f
    80002840:	8dd9                	or	a1,a1,a4
    80002842:	02000537          	lui	a0,0x2000
    80002846:	157d                	addi	a0,a0,-1
    80002848:	0536                	slli	a0,a0,0xd
    8000284a:	9782                	jalr	a5
}
    8000284c:	60a2                	ld	ra,8(sp)
    8000284e:	6402                	ld	s0,0(sp)
    80002850:	0141                	addi	sp,sp,16
    80002852:	8082                	ret

0000000080002854 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002854:	1101                	addi	sp,sp,-32
    80002856:	ec06                	sd	ra,24(sp)
    80002858:	e822                	sd	s0,16(sp)
    8000285a:	e426                	sd	s1,8(sp)
    8000285c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    8000285e:	00018497          	auipc	s1,0x18
    80002862:	11a48493          	addi	s1,s1,282 # 8001a978 <tickslock>
    80002866:	8526                	mv	a0,s1
    80002868:	ffffe097          	auipc	ra,0xffffe
    8000286c:	3c0080e7          	jalr	960(ra) # 80000c28 <acquire>
  ticks++;
    80002870:	0002d517          	auipc	a0,0x2d
    80002874:	7d050513          	addi	a0,a0,2000 # 80030040 <ticks>
    80002878:	411c                	lw	a5,0(a0)
    8000287a:	2785                	addiw	a5,a5,1
    8000287c:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	c58080e7          	jalr	-936(ra) # 800024d6 <wakeup>
  release(&tickslock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	410080e7          	jalr	1040(ra) # 80000c98 <release>
}
    80002890:	60e2                	ld	ra,24(sp)
    80002892:	6442                	ld	s0,16(sp)
    80002894:	64a2                	ld	s1,8(sp)
    80002896:	6105                	addi	sp,sp,32
    80002898:	8082                	ret

000000008000289a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000289a:	1101                	addi	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	e426                	sd	s1,8(sp)
    800028a2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800028a8:	00074d63          	bltz	a4,800028c2 <devintr+0x28>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    }

    plic_complete(irq);
    return 1;
  } else if(scause == 0x8000000000000001L){
    800028ac:	57fd                	li	a5,-1
    800028ae:	17fe                	slli	a5,a5,0x3f
    800028b0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028b2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028b4:	04f70b63          	beq	a4,a5,8000290a <devintr+0x70>
  }
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret
     (scause & 0xff) == 9){
    800028c2:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800028c6:	46a5                	li	a3,9
    800028c8:	fed792e3          	bne	a5,a3,800028ac <devintr+0x12>
    int irq = plic_claim();
    800028cc:	00003097          	auipc	ra,0x3
    800028d0:	6ec080e7          	jalr	1772(ra) # 80005fb8 <plic_claim>
    800028d4:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028d6:	47a9                	li	a5,10
    800028d8:	00f50e63          	beq	a0,a5,800028f4 <devintr+0x5a>
    } else if(irq == VIRTIO0_IRQ || irq == VIRTIO1_IRQ ){
    800028dc:	fff5079b          	addiw	a5,a0,-1
    800028e0:	4705                	li	a4,1
    800028e2:	00f77e63          	bgeu	a4,a5,800028fe <devintr+0x64>
    plic_complete(irq);
    800028e6:	8526                	mv	a0,s1
    800028e8:	00003097          	auipc	ra,0x3
    800028ec:	6f4080e7          	jalr	1780(ra) # 80005fdc <plic_complete>
    return 1;
    800028f0:	4505                	li	a0,1
    800028f2:	b7d9                	j	800028b8 <devintr+0x1e>
      uartintr();
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	f44080e7          	jalr	-188(ra) # 80000838 <uartintr>
    800028fc:	b7ed                	j	800028e6 <devintr+0x4c>
      virtio_disk_intr(irq - VIRTIO0_IRQ);
    800028fe:	853e                	mv	a0,a5
    80002900:	00004097          	auipc	ra,0x4
    80002904:	c86080e7          	jalr	-890(ra) # 80006586 <virtio_disk_intr>
    80002908:	bff9                	j	800028e6 <devintr+0x4c>
    if(cpuid() == 0){
    8000290a:	fffff097          	auipc	ra,0xfffff
    8000290e:	24a080e7          	jalr	586(ra) # 80001b54 <cpuid>
    80002912:	c901                	beqz	a0,80002922 <devintr+0x88>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002914:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002918:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000291a:	14479073          	csrw	sip,a5
    return 2;
    8000291e:	4509                	li	a0,2
    80002920:	bf61                	j	800028b8 <devintr+0x1e>
      clockintr();
    80002922:	00000097          	auipc	ra,0x0
    80002926:	f32080e7          	jalr	-206(ra) # 80002854 <clockintr>
    8000292a:	b7ed                	j	80002914 <devintr+0x7a>

000000008000292c <usertrap>:
{
    8000292c:	1101                	addi	sp,sp,-32
    8000292e:	ec06                	sd	ra,24(sp)
    80002930:	e822                	sd	s0,16(sp)
    80002932:	e426                	sd	s1,8(sp)
    80002934:	e04a                	sd	s2,0(sp)
    80002936:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002938:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000293c:	1007f793          	andi	a5,a5,256
    80002940:	e7bd                	bnez	a5,800029ae <usertrap+0x82>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002942:	00003797          	auipc	a5,0x3
    80002946:	56e78793          	addi	a5,a5,1390 # 80005eb0 <kernelvec>
    8000294a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000294e:	fffff097          	auipc	ra,0xfffff
    80002952:	232080e7          	jalr	562(ra) # 80001b80 <myproc>
    80002956:	84aa                	mv	s1,a0
  p->tf->epc = r_sepc();
    80002958:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000295a:	14102773          	csrr	a4,sepc
    8000295e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002960:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002964:	47a1                	li	a5,8
    80002966:	06f71263          	bne	a4,a5,800029ca <usertrap+0x9e>
    if(p->killed)
    8000296a:	5d1c                	lw	a5,56(a0)
    8000296c:	eba9                	bnez	a5,800029be <usertrap+0x92>
    p->tf->epc += 4;
    8000296e:	70b8                	ld	a4,96(s1)
    80002970:	6f1c                	ld	a5,24(a4)
    80002972:	0791                	addi	a5,a5,4
    80002974:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sie" : "=r" (x) );
    80002976:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000297a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000297e:	10479073          	csrw	sie,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002982:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002986:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000298a:	10079073          	csrw	sstatus,a5
    syscall();
    8000298e:	00000097          	auipc	ra,0x0
    80002992:	2e0080e7          	jalr	736(ra) # 80002c6e <syscall>
  if(p->killed)
    80002996:	5c9c                	lw	a5,56(s1)
    80002998:	ebc1                	bnez	a5,80002a28 <usertrap+0xfc>
  usertrapret();
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	e1c080e7          	jalr	-484(ra) # 800027b6 <usertrapret>
}
    800029a2:	60e2                	ld	ra,24(sp)
    800029a4:	6442                	ld	s0,16(sp)
    800029a6:	64a2                	ld	s1,8(sp)
    800029a8:	6902                	ld	s2,0(sp)
    800029aa:	6105                	addi	sp,sp,32
    800029ac:	8082                	ret
    panic("usertrap: not from user mode");
    800029ae:	00006517          	auipc	a0,0x6
    800029b2:	b5a50513          	addi	a0,a0,-1190 # 80008508 <userret+0x478>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	b92080e7          	jalr	-1134(ra) # 80000548 <panic>
      exit(-1);
    800029be:	557d                	li	a0,-1
    800029c0:	00000097          	auipc	ra,0x0
    800029c4:	84c080e7          	jalr	-1972(ra) # 8000220c <exit>
    800029c8:	b75d                	j	8000296e <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029ca:	00000097          	auipc	ra,0x0
    800029ce:	ed0080e7          	jalr	-304(ra) # 8000289a <devintr>
    800029d2:	892a                	mv	s2,a0
    800029d4:	c501                	beqz	a0,800029dc <usertrap+0xb0>
  if(p->killed)
    800029d6:	5c9c                	lw	a5,56(s1)
    800029d8:	c3a1                	beqz	a5,80002a18 <usertrap+0xec>
    800029da:	a815                	j	80002a0e <usertrap+0xe2>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029dc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029e0:	40b0                	lw	a2,64(s1)
    800029e2:	00006517          	auipc	a0,0x6
    800029e6:	b4650513          	addi	a0,a0,-1210 # 80008528 <userret+0x498>
    800029ea:	ffffe097          	auipc	ra,0xffffe
    800029ee:	bb8080e7          	jalr	-1096(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029f2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029f6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029fa:	00006517          	auipc	a0,0x6
    800029fe:	b5e50513          	addi	a0,a0,-1186 # 80008558 <userret+0x4c8>
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	ba0080e7          	jalr	-1120(ra) # 800005a2 <printf>
    p->killed = 1;
    80002a0a:	4785                	li	a5,1
    80002a0c:	dc9c                	sw	a5,56(s1)
    exit(-1);
    80002a0e:	557d                	li	a0,-1
    80002a10:	fffff097          	auipc	ra,0xfffff
    80002a14:	7fc080e7          	jalr	2044(ra) # 8000220c <exit>
  if(which_dev == 2)
    80002a18:	4789                	li	a5,2
    80002a1a:	f8f910e3          	bne	s2,a5,8000299a <usertrap+0x6e>
    yield();
    80002a1e:	00000097          	auipc	ra,0x0
    80002a22:	8fc080e7          	jalr	-1796(ra) # 8000231a <yield>
    80002a26:	bf95                	j	8000299a <usertrap+0x6e>
  int which_dev = 0;
    80002a28:	4901                	li	s2,0
    80002a2a:	b7d5                	j	80002a0e <usertrap+0xe2>

0000000080002a2c <kerneltrap>:
{
    80002a2c:	7179                	addi	sp,sp,-48
    80002a2e:	f406                	sd	ra,40(sp)
    80002a30:	f022                	sd	s0,32(sp)
    80002a32:	ec26                	sd	s1,24(sp)
    80002a34:	e84a                	sd	s2,16(sp)
    80002a36:	e44e                	sd	s3,8(sp)
    80002a38:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a3a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a42:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a46:	1004f793          	andi	a5,s1,256
    80002a4a:	cb85                	beqz	a5,80002a7a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a50:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a52:	ef85                	bnez	a5,80002a8a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	e46080e7          	jalr	-442(ra) # 8000289a <devintr>
    80002a5c:	cd1d                	beqz	a0,80002a9a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a5e:	4789                	li	a5,2
    80002a60:	06f50a63          	beq	a0,a5,80002ad4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a64:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a68:	10049073          	csrw	sstatus,s1
}
    80002a6c:	70a2                	ld	ra,40(sp)
    80002a6e:	7402                	ld	s0,32(sp)
    80002a70:	64e2                	ld	s1,24(sp)
    80002a72:	6942                	ld	s2,16(sp)
    80002a74:	69a2                	ld	s3,8(sp)
    80002a76:	6145                	addi	sp,sp,48
    80002a78:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	afe50513          	addi	a0,a0,-1282 # 80008578 <userret+0x4e8>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	ac6080e7          	jalr	-1338(ra) # 80000548 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	b1650513          	addi	a0,a0,-1258 # 800085a0 <userret+0x510>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	ab6080e7          	jalr	-1354(ra) # 80000548 <panic>
    printf("scause %p\n", scause);
    80002a9a:	85ce                	mv	a1,s3
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	b2450513          	addi	a0,a0,-1244 # 800085c0 <userret+0x530>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	afe080e7          	jalr	-1282(ra) # 800005a2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ab4:	00006517          	auipc	a0,0x6
    80002ab8:	b1c50513          	addi	a0,a0,-1252 # 800085d0 <userret+0x540>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	ae6080e7          	jalr	-1306(ra) # 800005a2 <printf>
    panic("kerneltrap");
    80002ac4:	00006517          	auipc	a0,0x6
    80002ac8:	b2450513          	addi	a0,a0,-1244 # 800085e8 <userret+0x558>
    80002acc:	ffffe097          	auipc	ra,0xffffe
    80002ad0:	a7c080e7          	jalr	-1412(ra) # 80000548 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	0ac080e7          	jalr	172(ra) # 80001b80 <myproc>
    80002adc:	d541                	beqz	a0,80002a64 <kerneltrap+0x38>
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	0a2080e7          	jalr	162(ra) # 80001b80 <myproc>
    80002ae6:	5118                	lw	a4,32(a0)
    80002ae8:	478d                	li	a5,3
    80002aea:	f6f71de3          	bne	a4,a5,80002a64 <kerneltrap+0x38>
    yield();
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	82c080e7          	jalr	-2004(ra) # 8000231a <yield>
    80002af6:	b7bd                	j	80002a64 <kerneltrap+0x38>

0000000080002af8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002af8:	1101                	addi	sp,sp,-32
    80002afa:	ec06                	sd	ra,24(sp)
    80002afc:	e822                	sd	s0,16(sp)
    80002afe:	e426                	sd	s1,8(sp)
    80002b00:	1000                	addi	s0,sp,32
    80002b02:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b04:	fffff097          	auipc	ra,0xfffff
    80002b08:	07c080e7          	jalr	124(ra) # 80001b80 <myproc>
  switch (n) {
    80002b0c:	4795                	li	a5,5
    80002b0e:	0497e163          	bltu	a5,s1,80002b50 <argraw+0x58>
    80002b12:	048a                	slli	s1,s1,0x2
    80002b14:	00006717          	auipc	a4,0x6
    80002b18:	fec70713          	addi	a4,a4,-20 # 80008b00 <states.0+0x28>
    80002b1c:	94ba                	add	s1,s1,a4
    80002b1e:	409c                	lw	a5,0(s1)
    80002b20:	97ba                	add	a5,a5,a4
    80002b22:	8782                	jr	a5
  case 0:
    return p->tf->a0;
    80002b24:	713c                	ld	a5,96(a0)
    80002b26:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->tf->a5;
  }
  panic("argraw");
  return -1;
}
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret
    return p->tf->a1;
    80002b32:	713c                	ld	a5,96(a0)
    80002b34:	7fa8                	ld	a0,120(a5)
    80002b36:	bfcd                	j	80002b28 <argraw+0x30>
    return p->tf->a2;
    80002b38:	713c                	ld	a5,96(a0)
    80002b3a:	63c8                	ld	a0,128(a5)
    80002b3c:	b7f5                	j	80002b28 <argraw+0x30>
    return p->tf->a3;
    80002b3e:	713c                	ld	a5,96(a0)
    80002b40:	67c8                	ld	a0,136(a5)
    80002b42:	b7dd                	j	80002b28 <argraw+0x30>
    return p->tf->a4;
    80002b44:	713c                	ld	a5,96(a0)
    80002b46:	6bc8                	ld	a0,144(a5)
    80002b48:	b7c5                	j	80002b28 <argraw+0x30>
    return p->tf->a5;
    80002b4a:	713c                	ld	a5,96(a0)
    80002b4c:	6fc8                	ld	a0,152(a5)
    80002b4e:	bfe9                	j	80002b28 <argraw+0x30>
  panic("argraw");
    80002b50:	00006517          	auipc	a0,0x6
    80002b54:	aa850513          	addi	a0,a0,-1368 # 800085f8 <userret+0x568>
    80002b58:	ffffe097          	auipc	ra,0xffffe
    80002b5c:	9f0080e7          	jalr	-1552(ra) # 80000548 <panic>

0000000080002b60 <fetchaddr>:
{
    80002b60:	1101                	addi	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	e04a                	sd	s2,0(sp)
    80002b6a:	1000                	addi	s0,sp,32
    80002b6c:	84aa                	mv	s1,a0
    80002b6e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	010080e7          	jalr	16(ra) # 80001b80 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b78:	693c                	ld	a5,80(a0)
    80002b7a:	02f4f863          	bgeu	s1,a5,80002baa <fetchaddr+0x4a>
    80002b7e:	00848713          	addi	a4,s1,8
    80002b82:	02e7e663          	bltu	a5,a4,80002bae <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b86:	46a1                	li	a3,8
    80002b88:	8626                	mv	a2,s1
    80002b8a:	85ca                	mv	a1,s2
    80002b8c:	6d28                	ld	a0,88(a0)
    80002b8e:	fffff097          	auipc	ra,0xfffff
    80002b92:	d70080e7          	jalr	-656(ra) # 800018fe <copyin>
    80002b96:	00a03533          	snez	a0,a0
    80002b9a:	40a00533          	neg	a0,a0
}
    80002b9e:	60e2                	ld	ra,24(sp)
    80002ba0:	6442                	ld	s0,16(sp)
    80002ba2:	64a2                	ld	s1,8(sp)
    80002ba4:	6902                	ld	s2,0(sp)
    80002ba6:	6105                	addi	sp,sp,32
    80002ba8:	8082                	ret
    return -1;
    80002baa:	557d                	li	a0,-1
    80002bac:	bfcd                	j	80002b9e <fetchaddr+0x3e>
    80002bae:	557d                	li	a0,-1
    80002bb0:	b7fd                	j	80002b9e <fetchaddr+0x3e>

0000000080002bb2 <fetchstr>:
{
    80002bb2:	7179                	addi	sp,sp,-48
    80002bb4:	f406                	sd	ra,40(sp)
    80002bb6:	f022                	sd	s0,32(sp)
    80002bb8:	ec26                	sd	s1,24(sp)
    80002bba:	e84a                	sd	s2,16(sp)
    80002bbc:	e44e                	sd	s3,8(sp)
    80002bbe:	1800                	addi	s0,sp,48
    80002bc0:	892a                	mv	s2,a0
    80002bc2:	84ae                	mv	s1,a1
    80002bc4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	fba080e7          	jalr	-70(ra) # 80001b80 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bce:	86ce                	mv	a3,s3
    80002bd0:	864a                	mv	a2,s2
    80002bd2:	85a6                	mv	a1,s1
    80002bd4:	6d28                	ld	a0,88(a0)
    80002bd6:	fffff097          	auipc	ra,0xfffff
    80002bda:	db6080e7          	jalr	-586(ra) # 8000198c <copyinstr>
  if(err < 0)
    80002bde:	00054763          	bltz	a0,80002bec <fetchstr+0x3a>
  return strlen(buf);
    80002be2:	8526                	mv	a0,s1
    80002be4:	ffffe097          	auipc	ra,0xffffe
    80002be8:	436080e7          	jalr	1078(ra) # 8000101a <strlen>
}
    80002bec:	70a2                	ld	ra,40(sp)
    80002bee:	7402                	ld	s0,32(sp)
    80002bf0:	64e2                	ld	s1,24(sp)
    80002bf2:	6942                	ld	s2,16(sp)
    80002bf4:	69a2                	ld	s3,8(sp)
    80002bf6:	6145                	addi	sp,sp,48
    80002bf8:	8082                	ret

0000000080002bfa <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bfa:	1101                	addi	sp,sp,-32
    80002bfc:	ec06                	sd	ra,24(sp)
    80002bfe:	e822                	sd	s0,16(sp)
    80002c00:	e426                	sd	s1,8(sp)
    80002c02:	1000                	addi	s0,sp,32
    80002c04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c06:	00000097          	auipc	ra,0x0
    80002c0a:	ef2080e7          	jalr	-270(ra) # 80002af8 <argraw>
    80002c0e:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c10:	4501                	li	a0,0
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	1000                	addi	s0,sp,32
    80002c26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c28:	00000097          	auipc	ra,0x0
    80002c2c:	ed0080e7          	jalr	-304(ra) # 80002af8 <argraw>
    80002c30:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c32:	4501                	li	a0,0
    80002c34:	60e2                	ld	ra,24(sp)
    80002c36:	6442                	ld	s0,16(sp)
    80002c38:	64a2                	ld	s1,8(sp)
    80002c3a:	6105                	addi	sp,sp,32
    80002c3c:	8082                	ret

0000000080002c3e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c3e:	1101                	addi	sp,sp,-32
    80002c40:	ec06                	sd	ra,24(sp)
    80002c42:	e822                	sd	s0,16(sp)
    80002c44:	e426                	sd	s1,8(sp)
    80002c46:	e04a                	sd	s2,0(sp)
    80002c48:	1000                	addi	s0,sp,32
    80002c4a:	84ae                	mv	s1,a1
    80002c4c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c4e:	00000097          	auipc	ra,0x0
    80002c52:	eaa080e7          	jalr	-342(ra) # 80002af8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c56:	864a                	mv	a2,s2
    80002c58:	85a6                	mv	a1,s1
    80002c5a:	00000097          	auipc	ra,0x0
    80002c5e:	f58080e7          	jalr	-168(ra) # 80002bb2 <fetchstr>
}
    80002c62:	60e2                	ld	ra,24(sp)
    80002c64:	6442                	ld	s0,16(sp)
    80002c66:	64a2                	ld	s1,8(sp)
    80002c68:	6902                	ld	s2,0(sp)
    80002c6a:	6105                	addi	sp,sp,32
    80002c6c:	8082                	ret

0000000080002c6e <syscall>:
[SYS_ntas]    sys_ntas,
};

void
syscall(void)
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	e04a                	sd	s2,0(sp)
    80002c78:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	f06080e7          	jalr	-250(ra) # 80001b80 <myproc>
    80002c82:	84aa                	mv	s1,a0

  num = p->tf->a7;
    80002c84:	06053903          	ld	s2,96(a0)
    80002c88:	0a893783          	ld	a5,168(s2)
    80002c8c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c90:	37fd                	addiw	a5,a5,-1
    80002c92:	4755                	li	a4,21
    80002c94:	00f76f63          	bltu	a4,a5,80002cb2 <syscall+0x44>
    80002c98:	00369713          	slli	a4,a3,0x3
    80002c9c:	00006797          	auipc	a5,0x6
    80002ca0:	e7c78793          	addi	a5,a5,-388 # 80008b18 <syscalls>
    80002ca4:	97ba                	add	a5,a5,a4
    80002ca6:	639c                	ld	a5,0(a5)
    80002ca8:	c789                	beqz	a5,80002cb2 <syscall+0x44>
    p->tf->a0 = syscalls[num]();
    80002caa:	9782                	jalr	a5
    80002cac:	06a93823          	sd	a0,112(s2)
    80002cb0:	a839                	j	80002cce <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cb2:	16048613          	addi	a2,s1,352
    80002cb6:	40ac                	lw	a1,64(s1)
    80002cb8:	00006517          	auipc	a0,0x6
    80002cbc:	94850513          	addi	a0,a0,-1720 # 80008600 <userret+0x570>
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	8e2080e7          	jalr	-1822(ra) # 800005a2 <printf>
            p->pid, p->name, num);
    p->tf->a0 = -1;
    80002cc8:	70bc                	ld	a5,96(s1)
    80002cca:	577d                	li	a4,-1
    80002ccc:	fbb8                	sd	a4,112(a5)
  }
}
    80002cce:	60e2                	ld	ra,24(sp)
    80002cd0:	6442                	ld	s0,16(sp)
    80002cd2:	64a2                	ld	s1,8(sp)
    80002cd4:	6902                	ld	s2,0(sp)
    80002cd6:	6105                	addi	sp,sp,32
    80002cd8:	8082                	ret

0000000080002cda <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cda:	1101                	addi	sp,sp,-32
    80002cdc:	ec06                	sd	ra,24(sp)
    80002cde:	e822                	sd	s0,16(sp)
    80002ce0:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ce2:	fec40593          	addi	a1,s0,-20
    80002ce6:	4501                	li	a0,0
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	f12080e7          	jalr	-238(ra) # 80002bfa <argint>
    return -1;
    80002cf0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002cf2:	00054963          	bltz	a0,80002d04 <sys_exit+0x2a>
  exit(n);
    80002cf6:	fec42503          	lw	a0,-20(s0)
    80002cfa:	fffff097          	auipc	ra,0xfffff
    80002cfe:	512080e7          	jalr	1298(ra) # 8000220c <exit>
  return 0;  // not reached
    80002d02:	4781                	li	a5,0
}
    80002d04:	853e                	mv	a0,a5
    80002d06:	60e2                	ld	ra,24(sp)
    80002d08:	6442                	ld	s0,16(sp)
    80002d0a:	6105                	addi	sp,sp,32
    80002d0c:	8082                	ret

0000000080002d0e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d0e:	1141                	addi	sp,sp,-16
    80002d10:	e406                	sd	ra,8(sp)
    80002d12:	e022                	sd	s0,0(sp)
    80002d14:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	e6a080e7          	jalr	-406(ra) # 80001b80 <myproc>
}
    80002d1e:	4128                	lw	a0,64(a0)
    80002d20:	60a2                	ld	ra,8(sp)
    80002d22:	6402                	ld	s0,0(sp)
    80002d24:	0141                	addi	sp,sp,16
    80002d26:	8082                	ret

0000000080002d28 <sys_fork>:

uint64
sys_fork(void)
{
    80002d28:	1141                	addi	sp,sp,-16
    80002d2a:	e406                	sd	ra,8(sp)
    80002d2c:	e022                	sd	s0,0(sp)
    80002d2e:	0800                	addi	s0,sp,16
  return fork();
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	1ba080e7          	jalr	442(ra) # 80001eea <fork>
}
    80002d38:	60a2                	ld	ra,8(sp)
    80002d3a:	6402                	ld	s0,0(sp)
    80002d3c:	0141                	addi	sp,sp,16
    80002d3e:	8082                	ret

0000000080002d40 <sys_wait>:

uint64
sys_wait(void)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d48:	fe840593          	addi	a1,s0,-24
    80002d4c:	4501                	li	a0,0
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	ece080e7          	jalr	-306(ra) # 80002c1c <argaddr>
    80002d56:	87aa                	mv	a5,a0
    return -1;
    80002d58:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d5a:	0007c863          	bltz	a5,80002d6a <sys_wait+0x2a>
  return wait(p);
    80002d5e:	fe843503          	ld	a0,-24(s0)
    80002d62:	fffff097          	auipc	ra,0xfffff
    80002d66:	672080e7          	jalr	1650(ra) # 800023d4 <wait>
}
    80002d6a:	60e2                	ld	ra,24(sp)
    80002d6c:	6442                	ld	s0,16(sp)
    80002d6e:	6105                	addi	sp,sp,32
    80002d70:	8082                	ret

0000000080002d72 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d72:	7179                	addi	sp,sp,-48
    80002d74:	f406                	sd	ra,40(sp)
    80002d76:	f022                	sd	s0,32(sp)
    80002d78:	ec26                	sd	s1,24(sp)
    80002d7a:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d7c:	fdc40593          	addi	a1,s0,-36
    80002d80:	4501                	li	a0,0
    80002d82:	00000097          	auipc	ra,0x0
    80002d86:	e78080e7          	jalr	-392(ra) # 80002bfa <argint>
    return -1;
    80002d8a:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002d8c:	00054f63          	bltz	a0,80002daa <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	df0080e7          	jalr	-528(ra) # 80001b80 <myproc>
    80002d98:	4924                	lw	s1,80(a0)
  if(growproc(n) < 0)
    80002d9a:	fdc42503          	lw	a0,-36(s0)
    80002d9e:	fffff097          	auipc	ra,0xfffff
    80002da2:	0d8080e7          	jalr	216(ra) # 80001e76 <growproc>
    80002da6:	00054863          	bltz	a0,80002db6 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002daa:	8526                	mv	a0,s1
    80002dac:	70a2                	ld	ra,40(sp)
    80002dae:	7402                	ld	s0,32(sp)
    80002db0:	64e2                	ld	s1,24(sp)
    80002db2:	6145                	addi	sp,sp,48
    80002db4:	8082                	ret
    return -1;
    80002db6:	54fd                	li	s1,-1
    80002db8:	bfcd                	j	80002daa <sys_sbrk+0x38>

0000000080002dba <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dba:	7139                	addi	sp,sp,-64
    80002dbc:	fc06                	sd	ra,56(sp)
    80002dbe:	f822                	sd	s0,48(sp)
    80002dc0:	f426                	sd	s1,40(sp)
    80002dc2:	f04a                	sd	s2,32(sp)
    80002dc4:	ec4e                	sd	s3,24(sp)
    80002dc6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002dc8:	fcc40593          	addi	a1,s0,-52
    80002dcc:	4501                	li	a0,0
    80002dce:	00000097          	auipc	ra,0x0
    80002dd2:	e2c080e7          	jalr	-468(ra) # 80002bfa <argint>
    return -1;
    80002dd6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dd8:	06054563          	bltz	a0,80002e42 <sys_sleep+0x88>
  acquire(&tickslock);
    80002ddc:	00018517          	auipc	a0,0x18
    80002de0:	b9c50513          	addi	a0,a0,-1124 # 8001a978 <tickslock>
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	e44080e7          	jalr	-444(ra) # 80000c28 <acquire>
  ticks0 = ticks;
    80002dec:	0002d917          	auipc	s2,0x2d
    80002df0:	25492903          	lw	s2,596(s2) # 80030040 <ticks>
  while(ticks - ticks0 < n){
    80002df4:	fcc42783          	lw	a5,-52(s0)
    80002df8:	cf85                	beqz	a5,80002e30 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dfa:	00018997          	auipc	s3,0x18
    80002dfe:	b7e98993          	addi	s3,s3,-1154 # 8001a978 <tickslock>
    80002e02:	0002d497          	auipc	s1,0x2d
    80002e06:	23e48493          	addi	s1,s1,574 # 80030040 <ticks>
    if(myproc()->killed){
    80002e0a:	fffff097          	auipc	ra,0xfffff
    80002e0e:	d76080e7          	jalr	-650(ra) # 80001b80 <myproc>
    80002e12:	5d1c                	lw	a5,56(a0)
    80002e14:	ef9d                	bnez	a5,80002e52 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e16:	85ce                	mv	a1,s3
    80002e18:	8526                	mv	a0,s1
    80002e1a:	fffff097          	auipc	ra,0xfffff
    80002e1e:	53c080e7          	jalr	1340(ra) # 80002356 <sleep>
  while(ticks - ticks0 < n){
    80002e22:	409c                	lw	a5,0(s1)
    80002e24:	412787bb          	subw	a5,a5,s2
    80002e28:	fcc42703          	lw	a4,-52(s0)
    80002e2c:	fce7efe3          	bltu	a5,a4,80002e0a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e30:	00018517          	auipc	a0,0x18
    80002e34:	b4850513          	addi	a0,a0,-1208 # 8001a978 <tickslock>
    80002e38:	ffffe097          	auipc	ra,0xffffe
    80002e3c:	e60080e7          	jalr	-416(ra) # 80000c98 <release>
  return 0;
    80002e40:	4781                	li	a5,0
}
    80002e42:	853e                	mv	a0,a5
    80002e44:	70e2                	ld	ra,56(sp)
    80002e46:	7442                	ld	s0,48(sp)
    80002e48:	74a2                	ld	s1,40(sp)
    80002e4a:	7902                	ld	s2,32(sp)
    80002e4c:	69e2                	ld	s3,24(sp)
    80002e4e:	6121                	addi	sp,sp,64
    80002e50:	8082                	ret
      release(&tickslock);
    80002e52:	00018517          	auipc	a0,0x18
    80002e56:	b2650513          	addi	a0,a0,-1242 # 8001a978 <tickslock>
    80002e5a:	ffffe097          	auipc	ra,0xffffe
    80002e5e:	e3e080e7          	jalr	-450(ra) # 80000c98 <release>
      return -1;
    80002e62:	57fd                	li	a5,-1
    80002e64:	bff9                	j	80002e42 <sys_sleep+0x88>

0000000080002e66 <sys_kill>:

uint64
sys_kill(void)
{
    80002e66:	1101                	addi	sp,sp,-32
    80002e68:	ec06                	sd	ra,24(sp)
    80002e6a:	e822                	sd	s0,16(sp)
    80002e6c:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e6e:	fec40593          	addi	a1,s0,-20
    80002e72:	4501                	li	a0,0
    80002e74:	00000097          	auipc	ra,0x0
    80002e78:	d86080e7          	jalr	-634(ra) # 80002bfa <argint>
    80002e7c:	87aa                	mv	a5,a0
    return -1;
    80002e7e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e80:	0007c863          	bltz	a5,80002e90 <sys_kill+0x2a>
  return kill(pid);
    80002e84:	fec42503          	lw	a0,-20(s0)
    80002e88:	fffff097          	auipc	ra,0xfffff
    80002e8c:	6b8080e7          	jalr	1720(ra) # 80002540 <kill>
}
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret

0000000080002e98 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e98:	1101                	addi	sp,sp,-32
    80002e9a:	ec06                	sd	ra,24(sp)
    80002e9c:	e822                	sd	s0,16(sp)
    80002e9e:	e426                	sd	s1,8(sp)
    80002ea0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ea2:	00018517          	auipc	a0,0x18
    80002ea6:	ad650513          	addi	a0,a0,-1322 # 8001a978 <tickslock>
    80002eaa:	ffffe097          	auipc	ra,0xffffe
    80002eae:	d7e080e7          	jalr	-642(ra) # 80000c28 <acquire>
  xticks = ticks;
    80002eb2:	0002d497          	auipc	s1,0x2d
    80002eb6:	18e4a483          	lw	s1,398(s1) # 80030040 <ticks>
  release(&tickslock);
    80002eba:	00018517          	auipc	a0,0x18
    80002ebe:	abe50513          	addi	a0,a0,-1346 # 8001a978 <tickslock>
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	dd6080e7          	jalr	-554(ra) # 80000c98 <release>
  return xticks;
}
    80002eca:	02049513          	slli	a0,s1,0x20
    80002ece:	9101                	srli	a0,a0,0x20
    80002ed0:	60e2                	ld	ra,24(sp)
    80002ed2:	6442                	ld	s0,16(sp)
    80002ed4:	64a2                	ld	s1,8(sp)
    80002ed6:	6105                	addi	sp,sp,32
    80002ed8:	8082                	ret

0000000080002eda <bhash>:
  // Linked list of all buffers, through prev/next.
  // head.next is most recently used.
  //struct buf head;
} bcache;

int bhash(int blockno){
    80002eda:	1141                	addi	sp,sp,-16
    80002edc:	e422                	sd	s0,8(sp)
    80002ede:	0800                	addi	s0,sp,16
  return blockno%NBUCKRTS;
}
    80002ee0:	47b5                	li	a5,13
    80002ee2:	02f5653b          	remw	a0,a0,a5
    80002ee6:	6422                	ld	s0,8(sp)
    80002ee8:	0141                	addi	sp,sp,16
    80002eea:	8082                	ret

0000000080002eec <binit>:
void
binit(void)
{
    80002eec:	7179                	addi	sp,sp,-48
    80002eee:	f406                	sd	ra,40(sp)
    80002ef0:	f022                	sd	s0,32(sp)
    80002ef2:	ec26                	sd	s1,24(sp)
    80002ef4:	e84a                	sd	s2,16(sp)
    80002ef6:	e44e                	sd	s3,8(sp)
    80002ef8:	e052                	sd	s4,0(sp)
    80002efa:	1800                	addi	s0,sp,48
  struct buf *b;

  for (int i=0;i<NBUCKRTS;i++){
    80002efc:	00018917          	auipc	s2,0x18
    80002f00:	a9c90913          	addi	s2,s2,-1380 # 8001a998 <bcache>
    80002f04:	00020497          	auipc	s1,0x20
    80002f08:	f9448493          	addi	s1,s1,-108 # 80022e98 <bcache+0x8500>
    80002f0c:	00024a17          	auipc	s4,0x24
    80002f10:	86ca0a13          	addi	s4,s4,-1940 # 80026778 <sb>
      initlock(&bcache.locks[i],"bcache.bucket");
    80002f14:	00005997          	auipc	s3,0x5
    80002f18:	70c98993          	addi	s3,s3,1804 # 80008620 <userret+0x590>
    80002f1c:	85ce                	mv	a1,s3
    80002f1e:	854a                	mv	a0,s2
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	bba080e7          	jalr	-1094(ra) # 80000ada <initlock>
      b=&bcache.hashbucket[i];
      b->prev=b;
    80002f28:	e8a4                	sd	s1,80(s1)
      b->next=b;
    80002f2a:	eca4                	sd	s1,88(s1)
  for (int i=0;i<NBUCKRTS;i++){
    80002f2c:	02090913          	addi	s2,s2,32
    80002f30:	46048493          	addi	s1,s1,1120
    80002f34:	ff4494e3          	bne	s1,s4,80002f1c <binit+0x30>
  }
  for(b=bcache.buf;b<bcache.buf+NBUF;b++){
    80002f38:	00018497          	auipc	s1,0x18
    80002f3c:	c2048493          	addi	s1,s1,-992 # 8001ab58 <bcache+0x1c0>
      b->next = bcache.hashbucket[0].next;
    80002f40:	00020917          	auipc	s2,0x20
    80002f44:	a5890913          	addi	s2,s2,-1448 # 80022998 <bcache+0x8000>
      b->prev = &bcache.hashbucket[0];
    80002f48:	00020997          	auipc	s3,0x20
    80002f4c:	f5098993          	addi	s3,s3,-176 # 80022e98 <bcache+0x8500>
      initsleeplock(&b->lock, "buffer");
    80002f50:	00005a17          	auipc	s4,0x5
    80002f54:	6e0a0a13          	addi	s4,s4,1760 # 80008630 <userret+0x5a0>
      b->next = bcache.hashbucket[0].next;
    80002f58:	55893783          	ld	a5,1368(s2)
    80002f5c:	ecbc                	sd	a5,88(s1)
      b->prev = &bcache.hashbucket[0];
    80002f5e:	0534b823          	sd	s3,80(s1)
      initsleeplock(&b->lock, "buffer");
    80002f62:	85d2                	mv	a1,s4
    80002f64:	01048513          	addi	a0,s1,16
    80002f68:	00001097          	auipc	ra,0x1
    80002f6c:	6a8080e7          	jalr	1704(ra) # 80004610 <initsleeplock>
      bcache.hashbucket[0].next->prev = b;
    80002f70:	55893783          	ld	a5,1368(s2)
    80002f74:	eba4                	sd	s1,80(a5)
      bcache.hashbucket[0].next = b;
    80002f76:	54993c23          	sd	s1,1368(s2)
  for(b=bcache.buf;b<bcache.buf+NBUF;b++){
    80002f7a:	46048493          	addi	s1,s1,1120
    80002f7e:	fd349de3          	bne	s1,s3,80002f58 <binit+0x6c>
  }
}
    80002f82:	70a2                	ld	ra,40(sp)
    80002f84:	7402                	ld	s0,32(sp)
    80002f86:	64e2                	ld	s1,24(sp)
    80002f88:	6942                	ld	s2,16(sp)
    80002f8a:	69a2                	ld	s3,8(sp)
    80002f8c:	6a02                	ld	s4,0(sp)
    80002f8e:	6145                	addi	sp,sp,48
    80002f90:	8082                	ret

0000000080002f92 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f92:	7119                	addi	sp,sp,-128
    80002f94:	fc86                	sd	ra,120(sp)
    80002f96:	f8a2                	sd	s0,112(sp)
    80002f98:	f4a6                	sd	s1,104(sp)
    80002f9a:	f0ca                	sd	s2,96(sp)
    80002f9c:	ecce                	sd	s3,88(sp)
    80002f9e:	e8d2                	sd	s4,80(sp)
    80002fa0:	e4d6                	sd	s5,72(sp)
    80002fa2:	e0da                	sd	s6,64(sp)
    80002fa4:	fc5e                	sd	s7,56(sp)
    80002fa6:	f862                	sd	s8,48(sp)
    80002fa8:	f466                	sd	s9,40(sp)
    80002faa:	f06a                	sd	s10,32(sp)
    80002fac:	ec6e                	sd	s11,24(sp)
    80002fae:	0100                	addi	s0,sp,128
    80002fb0:	89aa                	mv	s3,a0
    80002fb2:	8aae                	mv	s5,a1
  return blockno%NBUCKRTS;
    80002fb4:	4a35                	li	s4,13
    80002fb6:	0345ea3b          	remw	s4,a1,s4
    80002fba:	000a0b9b          	sext.w	s7,s4
  acquire(&bcache.locks[h]);
    80002fbe:	005b9c93          	slli	s9,s7,0x5
    80002fc2:	00018917          	auipc	s2,0x18
    80002fc6:	9d690913          	addi	s2,s2,-1578 # 8001a998 <bcache>
    80002fca:	012c87b3          	add	a5,s9,s2
    80002fce:	f8f43423          	sd	a5,-120(s0)
    80002fd2:	853e                	mv	a0,a5
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	c54080e7          	jalr	-940(ra) # 80000c28 <acquire>
  for(b = bcache.hashbucket[h].next; b != &bcache.hashbucket[h]; b = b->next){
    80002fdc:	46000793          	li	a5,1120
    80002fe0:	02fb87b3          	mul	a5,s7,a5
    80002fe4:	00f906b3          	add	a3,s2,a5
    80002fe8:	6721                	lui	a4,0x8
    80002fea:	96ba                	add	a3,a3,a4
    80002fec:	5586b483          	ld	s1,1368(a3)
    80002ff0:	50070713          	addi	a4,a4,1280 # 8500 <_entry-0x7fff7b00>
    80002ff4:	97ba                	add	a5,a5,a4
    80002ff6:	993e                	add	s2,s2,a5
    80002ff8:	03249563          	bne	s1,s2,80003022 <bread+0x90>
  int nh=(h+1)%NBUCKRTS; // nh表示下一个要探索的bucket，当它重新变成h，说明所有的buffer都bussy（refcnt不为0），此时
    80002ffc:	2a05                	addiw	s4,s4,1
    80002ffe:	47b5                	li	a5,13
    80003000:	02fa6a3b          	remw	s4,s4,a5
  while(nh!=h){
    80003004:	117a0f63          	beq	s4,s7,80003122 <bread+0x190>
    acquire(&bcache.locks[nh]);// 获取当前bocket的锁
    80003008:	00018c17          	auipc	s8,0x18
    8000300c:	990c0c13          	addi	s8,s8,-1648 # 8001a998 <bcache>
    for(b = bcache.hashbucket[nh].prev; b != &bcache.hashbucket[nh]; b = b->prev){
    80003010:	46000d93          	li	s11,1120
    80003014:	6d21                	lui	s10,0x8
    80003016:	500d0c93          	addi	s9,s10,1280 # 8500 <_entry-0x7fff7b00>
    8000301a:	a8d9                	j	800030f0 <bread+0x15e>
  for(b = bcache.hashbucket[h].next; b != &bcache.hashbucket[h]; b = b->next){
    8000301c:	6ca4                	ld	s1,88(s1)
    8000301e:	fd248fe3          	beq	s1,s2,80002ffc <bread+0x6a>
    if(b->dev == dev && b->blockno == blockno){
    80003022:	449c                	lw	a5,8(s1)
    80003024:	ff379ce3          	bne	a5,s3,8000301c <bread+0x8a>
    80003028:	44dc                	lw	a5,12(s1)
    8000302a:	ff5799e3          	bne	a5,s5,8000301c <bread+0x8a>
      b->refcnt++;
    8000302e:	44bc                	lw	a5,72(s1)
    80003030:	2785                	addiw	a5,a5,1
    80003032:	c4bc                	sw	a5,72(s1)
      release(&bcache.locks[h]);
    80003034:	f8843503          	ld	a0,-120(s0)
    80003038:	ffffe097          	auipc	ra,0xffffe
    8000303c:	c60080e7          	jalr	-928(ra) # 80000c98 <release>
      acquiresleep(&b->lock);
    80003040:	01048513          	addi	a0,s1,16
    80003044:	00001097          	auipc	ra,0x1
    80003048:	606080e7          	jalr	1542(ra) # 8000464a <acquiresleep>
      return b;
    8000304c:	a0ad                	j	800030b6 <bread+0x124>
        b->dev = dev;
    8000304e:	0134a423          	sw	s3,8(s1)
        b->blockno = blockno;
    80003052:	0154a623          	sw	s5,12(s1)
        b->valid = 0;
    80003056:	0004a023          	sw	zero,0(s1)
        b->refcnt = 1;
    8000305a:	4785                	li	a5,1
    8000305c:	c4bc                	sw	a5,72(s1)
        b->next->prev=b->prev;
    8000305e:	6cbc                	ld	a5,88(s1)
    80003060:	68b8                	ld	a4,80(s1)
    80003062:	ebb8                	sd	a4,80(a5)
        b->prev->next=b->next;
    80003064:	68bc                	ld	a5,80(s1)
    80003066:	6cb8                	ld	a4,88(s1)
    80003068:	efb8                	sd	a4,88(a5)
        release(&bcache.locks[nh]);
    8000306a:	855a                	mv	a0,s6
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	c2c080e7          	jalr	-980(ra) # 80000c98 <release>
        b->next=bcache.hashbucket[h].next;
    80003074:	46000793          	li	a5,1120
    80003078:	02fb8bb3          	mul	s7,s7,a5
    8000307c:	00018797          	auipc	a5,0x18
    80003080:	91c78793          	addi	a5,a5,-1764 # 8001a998 <bcache>
    80003084:	97de                	add	a5,a5,s7
    80003086:	6ba1                	lui	s7,0x8
    80003088:	9bbe                	add	s7,s7,a5
    8000308a:	558bb783          	ld	a5,1368(s7) # 8558 <_entry-0x7fff7aa8>
    8000308e:	ecbc                	sd	a5,88(s1)
        b->prev=&bcache.hashbucket[h];
    80003090:	0524b823          	sd	s2,80(s1)
        bcache.hashbucket[h].next->prev=b;
    80003094:	558bb783          	ld	a5,1368(s7)
    80003098:	eba4                	sd	s1,80(a5)
        bcache.hashbucket[h].next=b;
    8000309a:	549bbc23          	sd	s1,1368(s7)
        release(&bcache.locks[h]);
    8000309e:	f8843503          	ld	a0,-120(s0)
    800030a2:	ffffe097          	auipc	ra,0xffffe
    800030a6:	bf6080e7          	jalr	-1034(ra) # 80000c98 <release>
        acquiresleep(&b->lock);
    800030aa:	01048513          	addi	a0,s1,16
    800030ae:	00001097          	auipc	ra,0x1
    800030b2:	59c080e7          	jalr	1436(ra) # 8000464a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030b6:	409c                	lw	a5,0(s1)
    800030b8:	cfad                	beqz	a5,80003132 <bread+0x1a0>
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}
    800030ba:	8526                	mv	a0,s1
    800030bc:	70e6                	ld	ra,120(sp)
    800030be:	7446                	ld	s0,112(sp)
    800030c0:	74a6                	ld	s1,104(sp)
    800030c2:	7906                	ld	s2,96(sp)
    800030c4:	69e6                	ld	s3,88(sp)
    800030c6:	6a46                	ld	s4,80(sp)
    800030c8:	6aa6                	ld	s5,72(sp)
    800030ca:	6b06                	ld	s6,64(sp)
    800030cc:	7be2                	ld	s7,56(sp)
    800030ce:	7c42                	ld	s8,48(sp)
    800030d0:	7ca2                	ld	s9,40(sp)
    800030d2:	7d02                	ld	s10,32(sp)
    800030d4:	6de2                	ld	s11,24(sp)
    800030d6:	6109                	addi	sp,sp,128
    800030d8:	8082                	ret
    release(&bcache.locks[nh]);
    800030da:	855a                	mv	a0,s6
    800030dc:	ffffe097          	auipc	ra,0xffffe
    800030e0:	bbc080e7          	jalr	-1092(ra) # 80000c98 <release>
    nh=(nh+1)%NBUCKRTS;
    800030e4:	2a05                	addiw	s4,s4,1
    800030e6:	47b5                	li	a5,13
    800030e8:	02fa6a3b          	remw	s4,s4,a5
  while(nh!=h){
    800030ec:	037a0b63          	beq	s4,s7,80003122 <bread+0x190>
    acquire(&bcache.locks[nh]);// 获取当前bocket的锁
    800030f0:	005a1b13          	slli	s6,s4,0x5
    800030f4:	9b62                	add	s6,s6,s8
    800030f6:	855a                	mv	a0,s6
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	b30080e7          	jalr	-1232(ra) # 80000c28 <acquire>
    for(b = bcache.hashbucket[nh].prev; b != &bcache.hashbucket[nh]; b = b->prev){
    80003100:	03ba0733          	mul	a4,s4,s11
    80003104:	00ec07b3          	add	a5,s8,a4
    80003108:	97ea                	add	a5,a5,s10
    8000310a:	5507b483          	ld	s1,1360(a5)
    8000310e:	9766                	add	a4,a4,s9
    80003110:	9762                	add	a4,a4,s8
    80003112:	fc9704e3          	beq	a4,s1,800030da <bread+0x148>
      if(b->refcnt == 0) {
    80003116:	44bc                	lw	a5,72(s1)
    80003118:	db9d                	beqz	a5,8000304e <bread+0xbc>
    for(b = bcache.hashbucket[nh].prev; b != &bcache.hashbucket[nh]; b = b->prev){
    8000311a:	68a4                	ld	s1,80(s1)
    8000311c:	fe971de3          	bne	a4,s1,80003116 <bread+0x184>
    80003120:	bf6d                	j	800030da <bread+0x148>
  panic("bget: no buffers");
    80003122:	00005517          	auipc	a0,0x5
    80003126:	51650513          	addi	a0,a0,1302 # 80008638 <userret+0x5a8>
    8000312a:	ffffd097          	auipc	ra,0xffffd
    8000312e:	41e080e7          	jalr	1054(ra) # 80000548 <panic>
    virtio_disk_rw(b->dev, b, 0);
    80003132:	4601                	li	a2,0
    80003134:	85a6                	mv	a1,s1
    80003136:	4488                	lw	a0,8(s1)
    80003138:	00003097          	auipc	ra,0x3
    8000313c:	152080e7          	jalr	338(ra) # 8000628a <virtio_disk_rw>
    b->valid = 1;
    80003140:	4785                	li	a5,1
    80003142:	c09c                	sw	a5,0(s1)
  return b;
    80003144:	bf9d                	j	800030ba <bread+0x128>

0000000080003146 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003146:	1101                	addi	sp,sp,-32
    80003148:	ec06                	sd	ra,24(sp)
    8000314a:	e822                	sd	s0,16(sp)
    8000314c:	e426                	sd	s1,8(sp)
    8000314e:	1000                	addi	s0,sp,32
    80003150:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003152:	0541                	addi	a0,a0,16
    80003154:	00001097          	auipc	ra,0x1
    80003158:	590080e7          	jalr	1424(ra) # 800046e4 <holdingsleep>
    8000315c:	cd09                	beqz	a0,80003176 <bwrite+0x30>
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
    8000315e:	4605                	li	a2,1
    80003160:	85a6                	mv	a1,s1
    80003162:	4488                	lw	a0,8(s1)
    80003164:	00003097          	auipc	ra,0x3
    80003168:	126080e7          	jalr	294(ra) # 8000628a <virtio_disk_rw>
}
    8000316c:	60e2                	ld	ra,24(sp)
    8000316e:	6442                	ld	s0,16(sp)
    80003170:	64a2                	ld	s1,8(sp)
    80003172:	6105                	addi	sp,sp,32
    80003174:	8082                	ret
    panic("bwrite");
    80003176:	00005517          	auipc	a0,0x5
    8000317a:	4da50513          	addi	a0,a0,1242 # 80008650 <userret+0x5c0>
    8000317e:	ffffd097          	auipc	ra,0xffffd
    80003182:	3ca080e7          	jalr	970(ra) # 80000548 <panic>

0000000080003186 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
    80003186:	7179                	addi	sp,sp,-48
    80003188:	f406                	sd	ra,40(sp)
    8000318a:	f022                	sd	s0,32(sp)
    8000318c:	ec26                	sd	s1,24(sp)
    8000318e:	e84a                	sd	s2,16(sp)
    80003190:	e44e                	sd	s3,8(sp)
    80003192:	1800                	addi	s0,sp,48
    80003194:	84aa                	mv	s1,a0
  
  if(!holdingsleep(&b->lock))
    80003196:	01050913          	addi	s2,a0,16
    8000319a:	854a                	mv	a0,s2
    8000319c:	00001097          	auipc	ra,0x1
    800031a0:	548080e7          	jalr	1352(ra) # 800046e4 <holdingsleep>
    800031a4:	c951                	beqz	a0,80003238 <brelse+0xb2>
    panic("brelse");

  releasesleep(&b->lock);
    800031a6:	854a                	mv	a0,s2
    800031a8:	00001097          	auipc	ra,0x1
    800031ac:	4f8080e7          	jalr	1272(ra) # 800046a0 <releasesleep>
  return blockno%NBUCKRTS;
    800031b0:	00c4a903          	lw	s2,12(s1)
    800031b4:	47b5                	li	a5,13
    800031b6:	02f9693b          	remw	s2,s2,a5
  int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
    800031ba:	00591993          	slli	s3,s2,0x5
    800031be:	00017797          	auipc	a5,0x17
    800031c2:	7da78793          	addi	a5,a5,2010 # 8001a998 <bcache>
    800031c6:	99be                	add	s3,s3,a5
    800031c8:	854e                	mv	a0,s3
    800031ca:	ffffe097          	auipc	ra,0xffffe
    800031ce:	a5e080e7          	jalr	-1442(ra) # 80000c28 <acquire>
  b->refcnt--;
    800031d2:	44bc                	lw	a5,72(s1)
    800031d4:	37fd                	addiw	a5,a5,-1
    800031d6:	0007871b          	sext.w	a4,a5
    800031da:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800031dc:	e331                	bnez	a4,80003220 <brelse+0x9a>
    // no one is waiting for it.
    // 下面做的就是把b从原来的位置取下来 放在链表开头（头插法）
    b->next->prev = b->prev;
    800031de:	6cbc                	ld	a5,88(s1)
    800031e0:	68b8                	ld	a4,80(s1)
    800031e2:	ebb8                	sd	a4,80(a5)
    b->prev->next = b->next;
    800031e4:	68bc                	ld	a5,80(s1)
    800031e6:	6cb8                	ld	a4,88(s1)
    800031e8:	efb8                	sd	a4,88(a5)
    b->next = bcache.hashbucket[h].next;
    800031ea:	00017697          	auipc	a3,0x17
    800031ee:	7ae68693          	addi	a3,a3,1966 # 8001a998 <bcache>
    800031f2:	46000613          	li	a2,1120
    800031f6:	02c907b3          	mul	a5,s2,a2
    800031fa:	97b6                	add	a5,a5,a3
    800031fc:	6721                	lui	a4,0x8
    800031fe:	97ba                	add	a5,a5,a4
    80003200:	5587b583          	ld	a1,1368(a5)
    80003204:	ecac                	sd	a1,88(s1)
    b->prev = &bcache.hashbucket[h];
    80003206:	02c90933          	mul	s2,s2,a2
    8000320a:	50070713          	addi	a4,a4,1280 # 8500 <_entry-0x7fff7b00>
    8000320e:	993a                	add	s2,s2,a4
    80003210:	9936                	add	s2,s2,a3
    80003212:	0524b823          	sd	s2,80(s1)
    bcache.hashbucket[h].next->prev = b;
    80003216:	5587b703          	ld	a4,1368(a5)
    8000321a:	eb24                	sd	s1,80(a4)
    bcache.hashbucket[h].next = b;
    8000321c:	5497bc23          	sd	s1,1368(a5)
  }
  
  release(&bcache.locks[h]);
    80003220:	854e                	mv	a0,s3
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	a76080e7          	jalr	-1418(ra) # 80000c98 <release>
  
}
    8000322a:	70a2                	ld	ra,40(sp)
    8000322c:	7402                	ld	s0,32(sp)
    8000322e:	64e2                	ld	s1,24(sp)
    80003230:	6942                	ld	s2,16(sp)
    80003232:	69a2                	ld	s3,8(sp)
    80003234:	6145                	addi	sp,sp,48
    80003236:	8082                	ret
    panic("brelse");
    80003238:	00005517          	auipc	a0,0x5
    8000323c:	42050513          	addi	a0,a0,1056 # 80008658 <userret+0x5c8>
    80003240:	ffffd097          	auipc	ra,0xffffd
    80003244:	308080e7          	jalr	776(ra) # 80000548 <panic>

0000000080003248 <bpin>:

void
bpin(struct buf *b) {
    80003248:	1101                	addi	sp,sp,-32
    8000324a:	ec06                	sd	ra,24(sp)
    8000324c:	e822                	sd	s0,16(sp)
    8000324e:	e426                	sd	s1,8(sp)
    80003250:	e04a                	sd	s2,0(sp)
    80003252:	1000                	addi	s0,sp,32
    80003254:	892a                	mv	s2,a0
  return blockno%NBUCKRTS;
    80003256:	4544                	lw	s1,12(a0)
  int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
    80003258:	47b5                	li	a5,13
    8000325a:	02f4e4bb          	remw	s1,s1,a5
    8000325e:	0496                	slli	s1,s1,0x5
    80003260:	00017797          	auipc	a5,0x17
    80003264:	73878793          	addi	a5,a5,1848 # 8001a998 <bcache>
    80003268:	94be                	add	s1,s1,a5
    8000326a:	8526                	mv	a0,s1
    8000326c:	ffffe097          	auipc	ra,0xffffe
    80003270:	9bc080e7          	jalr	-1604(ra) # 80000c28 <acquire>
  b->refcnt++;
    80003274:	04892783          	lw	a5,72(s2)
    80003278:	2785                	addiw	a5,a5,1
    8000327a:	04f92423          	sw	a5,72(s2)
  release(&bcache.locks[h]);
    8000327e:	8526                	mv	a0,s1
    80003280:	ffffe097          	auipc	ra,0xffffe
    80003284:	a18080e7          	jalr	-1512(ra) # 80000c98 <release>
}
    80003288:	60e2                	ld	ra,24(sp)
    8000328a:	6442                	ld	s0,16(sp)
    8000328c:	64a2                	ld	s1,8(sp)
    8000328e:	6902                	ld	s2,0(sp)
    80003290:	6105                	addi	sp,sp,32
    80003292:	8082                	ret

0000000080003294 <bunpin>:

void
bunpin(struct buf *b) {
    80003294:	1101                	addi	sp,sp,-32
    80003296:	ec06                	sd	ra,24(sp)
    80003298:	e822                	sd	s0,16(sp)
    8000329a:	e426                	sd	s1,8(sp)
    8000329c:	e04a                	sd	s2,0(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	892a                	mv	s2,a0
  return blockno%NBUCKRTS;
    800032a2:	4544                	lw	s1,12(a0)
   int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
    800032a4:	47b5                	li	a5,13
    800032a6:	02f4e4bb          	remw	s1,s1,a5
    800032aa:	0496                	slli	s1,s1,0x5
    800032ac:	00017797          	auipc	a5,0x17
    800032b0:	6ec78793          	addi	a5,a5,1772 # 8001a998 <bcache>
    800032b4:	94be                	add	s1,s1,a5
    800032b6:	8526                	mv	a0,s1
    800032b8:	ffffe097          	auipc	ra,0xffffe
    800032bc:	970080e7          	jalr	-1680(ra) # 80000c28 <acquire>
  b->refcnt--;
    800032c0:	04892783          	lw	a5,72(s2)
    800032c4:	37fd                	addiw	a5,a5,-1
    800032c6:	04f92423          	sw	a5,72(s2)
  release(&bcache.locks[h]);
    800032ca:	8526                	mv	a0,s1
    800032cc:	ffffe097          	auipc	ra,0xffffe
    800032d0:	9cc080e7          	jalr	-1588(ra) # 80000c98 <release>
}
    800032d4:	60e2                	ld	ra,24(sp)
    800032d6:	6442                	ld	s0,16(sp)
    800032d8:	64a2                	ld	s1,8(sp)
    800032da:	6902                	ld	s2,0(sp)
    800032dc:	6105                	addi	sp,sp,32
    800032de:	8082                	ret

00000000800032e0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032e0:	1101                	addi	sp,sp,-32
    800032e2:	ec06                	sd	ra,24(sp)
    800032e4:	e822                	sd	s0,16(sp)
    800032e6:	e426                	sd	s1,8(sp)
    800032e8:	e04a                	sd	s2,0(sp)
    800032ea:	1000                	addi	s0,sp,32
    800032ec:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032ee:	00d5d59b          	srliw	a1,a1,0xd
    800032f2:	00023797          	auipc	a5,0x23
    800032f6:	4a27a783          	lw	a5,1186(a5) # 80026794 <sb+0x1c>
    800032fa:	9dbd                	addw	a1,a1,a5
    800032fc:	00000097          	auipc	ra,0x0
    80003300:	c96080e7          	jalr	-874(ra) # 80002f92 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003304:	0074f713          	andi	a4,s1,7
    80003308:	4785                	li	a5,1
    8000330a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000330e:	14ce                	slli	s1,s1,0x33
    80003310:	90d9                	srli	s1,s1,0x36
    80003312:	00950733          	add	a4,a0,s1
    80003316:	06074703          	lbu	a4,96(a4)
    8000331a:	00e7f6b3          	and	a3,a5,a4
    8000331e:	c69d                	beqz	a3,8000334c <bfree+0x6c>
    80003320:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003322:	94aa                	add	s1,s1,a0
    80003324:	fff7c793          	not	a5,a5
    80003328:	8ff9                	and	a5,a5,a4
    8000332a:	06f48023          	sb	a5,96(s1)
  log_write(bp);
    8000332e:	00001097          	auipc	ra,0x1
    80003332:	1a2080e7          	jalr	418(ra) # 800044d0 <log_write>
  brelse(bp);
    80003336:	854a                	mv	a0,s2
    80003338:	00000097          	auipc	ra,0x0
    8000333c:	e4e080e7          	jalr	-434(ra) # 80003186 <brelse>
}
    80003340:	60e2                	ld	ra,24(sp)
    80003342:	6442                	ld	s0,16(sp)
    80003344:	64a2                	ld	s1,8(sp)
    80003346:	6902                	ld	s2,0(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret
    panic("freeing free block");
    8000334c:	00005517          	auipc	a0,0x5
    80003350:	31450513          	addi	a0,a0,788 # 80008660 <userret+0x5d0>
    80003354:	ffffd097          	auipc	ra,0xffffd
    80003358:	1f4080e7          	jalr	500(ra) # 80000548 <panic>

000000008000335c <balloc>:
{
    8000335c:	711d                	addi	sp,sp,-96
    8000335e:	ec86                	sd	ra,88(sp)
    80003360:	e8a2                	sd	s0,80(sp)
    80003362:	e4a6                	sd	s1,72(sp)
    80003364:	e0ca                	sd	s2,64(sp)
    80003366:	fc4e                	sd	s3,56(sp)
    80003368:	f852                	sd	s4,48(sp)
    8000336a:	f456                	sd	s5,40(sp)
    8000336c:	f05a                	sd	s6,32(sp)
    8000336e:	ec5e                	sd	s7,24(sp)
    80003370:	e862                	sd	s8,16(sp)
    80003372:	e466                	sd	s9,8(sp)
    80003374:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003376:	00023797          	auipc	a5,0x23
    8000337a:	4067a783          	lw	a5,1030(a5) # 8002677c <sb+0x4>
    8000337e:	cbd1                	beqz	a5,80003412 <balloc+0xb6>
    80003380:	8baa                	mv	s7,a0
    80003382:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003384:	00023b17          	auipc	s6,0x23
    80003388:	3f4b0b13          	addi	s6,s6,1012 # 80026778 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000338c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000338e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003390:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003392:	6c89                	lui	s9,0x2
    80003394:	a831                	j	800033b0 <balloc+0x54>
    brelse(bp);
    80003396:	854a                	mv	a0,s2
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	dee080e7          	jalr	-530(ra) # 80003186 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800033a0:	015c87bb          	addw	a5,s9,s5
    800033a4:	00078a9b          	sext.w	s5,a5
    800033a8:	004b2703          	lw	a4,4(s6)
    800033ac:	06eaf363          	bgeu	s5,a4,80003412 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800033b0:	41fad79b          	sraiw	a5,s5,0x1f
    800033b4:	0137d79b          	srliw	a5,a5,0x13
    800033b8:	015787bb          	addw	a5,a5,s5
    800033bc:	40d7d79b          	sraiw	a5,a5,0xd
    800033c0:	01cb2583          	lw	a1,28(s6)
    800033c4:	9dbd                	addw	a1,a1,a5
    800033c6:	855e                	mv	a0,s7
    800033c8:	00000097          	auipc	ra,0x0
    800033cc:	bca080e7          	jalr	-1078(ra) # 80002f92 <bread>
    800033d0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033d2:	004b2503          	lw	a0,4(s6)
    800033d6:	000a849b          	sext.w	s1,s5
    800033da:	8662                	mv	a2,s8
    800033dc:	faa4fde3          	bgeu	s1,a0,80003396 <balloc+0x3a>
      m = 1 << (bi % 8);
    800033e0:	41f6579b          	sraiw	a5,a2,0x1f
    800033e4:	01d7d69b          	srliw	a3,a5,0x1d
    800033e8:	00c6873b          	addw	a4,a3,a2
    800033ec:	00777793          	andi	a5,a4,7
    800033f0:	9f95                	subw	a5,a5,a3
    800033f2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033f6:	4037571b          	sraiw	a4,a4,0x3
    800033fa:	00e906b3          	add	a3,s2,a4
    800033fe:	0606c683          	lbu	a3,96(a3)
    80003402:	00d7f5b3          	and	a1,a5,a3
    80003406:	cd91                	beqz	a1,80003422 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003408:	2605                	addiw	a2,a2,1
    8000340a:	2485                	addiw	s1,s1,1
    8000340c:	fd4618e3          	bne	a2,s4,800033dc <balloc+0x80>
    80003410:	b759                	j	80003396 <balloc+0x3a>
  panic("balloc: out of blocks");
    80003412:	00005517          	auipc	a0,0x5
    80003416:	26650513          	addi	a0,a0,614 # 80008678 <userret+0x5e8>
    8000341a:	ffffd097          	auipc	ra,0xffffd
    8000341e:	12e080e7          	jalr	302(ra) # 80000548 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003422:	974a                	add	a4,a4,s2
    80003424:	8fd5                	or	a5,a5,a3
    80003426:	06f70023          	sb	a5,96(a4)
        log_write(bp);
    8000342a:	854a                	mv	a0,s2
    8000342c:	00001097          	auipc	ra,0x1
    80003430:	0a4080e7          	jalr	164(ra) # 800044d0 <log_write>
        brelse(bp);
    80003434:	854a                	mv	a0,s2
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	d50080e7          	jalr	-688(ra) # 80003186 <brelse>
  bp = bread(dev, bno);
    8000343e:	85a6                	mv	a1,s1
    80003440:	855e                	mv	a0,s7
    80003442:	00000097          	auipc	ra,0x0
    80003446:	b50080e7          	jalr	-1200(ra) # 80002f92 <bread>
    8000344a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000344c:	40000613          	li	a2,1024
    80003450:	4581                	li	a1,0
    80003452:	06050513          	addi	a0,a0,96
    80003456:	ffffe097          	auipc	ra,0xffffe
    8000345a:	a40080e7          	jalr	-1472(ra) # 80000e96 <memset>
  log_write(bp);
    8000345e:	854a                	mv	a0,s2
    80003460:	00001097          	auipc	ra,0x1
    80003464:	070080e7          	jalr	112(ra) # 800044d0 <log_write>
  brelse(bp);
    80003468:	854a                	mv	a0,s2
    8000346a:	00000097          	auipc	ra,0x0
    8000346e:	d1c080e7          	jalr	-740(ra) # 80003186 <brelse>
}
    80003472:	8526                	mv	a0,s1
    80003474:	60e6                	ld	ra,88(sp)
    80003476:	6446                	ld	s0,80(sp)
    80003478:	64a6                	ld	s1,72(sp)
    8000347a:	6906                	ld	s2,64(sp)
    8000347c:	79e2                	ld	s3,56(sp)
    8000347e:	7a42                	ld	s4,48(sp)
    80003480:	7aa2                	ld	s5,40(sp)
    80003482:	7b02                	ld	s6,32(sp)
    80003484:	6be2                	ld	s7,24(sp)
    80003486:	6c42                	ld	s8,16(sp)
    80003488:	6ca2                	ld	s9,8(sp)
    8000348a:	6125                	addi	sp,sp,96
    8000348c:	8082                	ret

000000008000348e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000348e:	7179                	addi	sp,sp,-48
    80003490:	f406                	sd	ra,40(sp)
    80003492:	f022                	sd	s0,32(sp)
    80003494:	ec26                	sd	s1,24(sp)
    80003496:	e84a                	sd	s2,16(sp)
    80003498:	e44e                	sd	s3,8(sp)
    8000349a:	e052                	sd	s4,0(sp)
    8000349c:	1800                	addi	s0,sp,48
    8000349e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034a0:	47ad                	li	a5,11
    800034a2:	04b7fe63          	bgeu	a5,a1,800034fe <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800034a6:	ff45849b          	addiw	s1,a1,-12
    800034aa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034ae:	0ff00793          	li	a5,255
    800034b2:	0ae7e463          	bltu	a5,a4,8000355a <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800034b6:	08852583          	lw	a1,136(a0)
    800034ba:	c5b5                	beqz	a1,80003526 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800034bc:	00092503          	lw	a0,0(s2)
    800034c0:	00000097          	auipc	ra,0x0
    800034c4:	ad2080e7          	jalr	-1326(ra) # 80002f92 <bread>
    800034c8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034ca:	06050793          	addi	a5,a0,96
    if((addr = a[bn]) == 0){
    800034ce:	02049713          	slli	a4,s1,0x20
    800034d2:	01e75593          	srli	a1,a4,0x1e
    800034d6:	00b784b3          	add	s1,a5,a1
    800034da:	0004a983          	lw	s3,0(s1)
    800034de:	04098e63          	beqz	s3,8000353a <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034e2:	8552                	mv	a0,s4
    800034e4:	00000097          	auipc	ra,0x0
    800034e8:	ca2080e7          	jalr	-862(ra) # 80003186 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800034ec:	854e                	mv	a0,s3
    800034ee:	70a2                	ld	ra,40(sp)
    800034f0:	7402                	ld	s0,32(sp)
    800034f2:	64e2                	ld	s1,24(sp)
    800034f4:	6942                	ld	s2,16(sp)
    800034f6:	69a2                	ld	s3,8(sp)
    800034f8:	6a02                	ld	s4,0(sp)
    800034fa:	6145                	addi	sp,sp,48
    800034fc:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034fe:	02059793          	slli	a5,a1,0x20
    80003502:	01e7d593          	srli	a1,a5,0x1e
    80003506:	00b504b3          	add	s1,a0,a1
    8000350a:	0584a983          	lw	s3,88(s1)
    8000350e:	fc099fe3          	bnez	s3,800034ec <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003512:	4108                	lw	a0,0(a0)
    80003514:	00000097          	auipc	ra,0x0
    80003518:	e48080e7          	jalr	-440(ra) # 8000335c <balloc>
    8000351c:	0005099b          	sext.w	s3,a0
    80003520:	0534ac23          	sw	s3,88(s1)
    80003524:	b7e1                	j	800034ec <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003526:	4108                	lw	a0,0(a0)
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	e34080e7          	jalr	-460(ra) # 8000335c <balloc>
    80003530:	0005059b          	sext.w	a1,a0
    80003534:	08b92423          	sw	a1,136(s2)
    80003538:	b751                	j	800034bc <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000353a:	00092503          	lw	a0,0(s2)
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	e1e080e7          	jalr	-482(ra) # 8000335c <balloc>
    80003546:	0005099b          	sext.w	s3,a0
    8000354a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000354e:	8552                	mv	a0,s4
    80003550:	00001097          	auipc	ra,0x1
    80003554:	f80080e7          	jalr	-128(ra) # 800044d0 <log_write>
    80003558:	b769                	j	800034e2 <bmap+0x54>
  panic("bmap: out of range");
    8000355a:	00005517          	auipc	a0,0x5
    8000355e:	13650513          	addi	a0,a0,310 # 80008690 <userret+0x600>
    80003562:	ffffd097          	auipc	ra,0xffffd
    80003566:	fe6080e7          	jalr	-26(ra) # 80000548 <panic>

000000008000356a <iget>:
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	e44e                	sd	s3,8(sp)
    80003576:	e052                	sd	s4,0(sp)
    80003578:	1800                	addi	s0,sp,48
    8000357a:	89aa                	mv	s3,a0
    8000357c:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000357e:	00023517          	auipc	a0,0x23
    80003582:	21a50513          	addi	a0,a0,538 # 80026798 <icache>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	6a2080e7          	jalr	1698(ra) # 80000c28 <acquire>
  empty = 0;
    8000358e:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003590:	00023497          	auipc	s1,0x23
    80003594:	22848493          	addi	s1,s1,552 # 800267b8 <icache+0x20>
    80003598:	00025697          	auipc	a3,0x25
    8000359c:	e4068693          	addi	a3,a3,-448 # 800283d8 <log>
    800035a0:	a039                	j	800035ae <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035a2:	02090b63          	beqz	s2,800035d8 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800035a6:	09048493          	addi	s1,s1,144
    800035aa:	02d48a63          	beq	s1,a3,800035de <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035ae:	449c                	lw	a5,8(s1)
    800035b0:	fef059e3          	blez	a5,800035a2 <iget+0x38>
    800035b4:	4098                	lw	a4,0(s1)
    800035b6:	ff3716e3          	bne	a4,s3,800035a2 <iget+0x38>
    800035ba:	40d8                	lw	a4,4(s1)
    800035bc:	ff4713e3          	bne	a4,s4,800035a2 <iget+0x38>
      ip->ref++;
    800035c0:	2785                	addiw	a5,a5,1
    800035c2:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800035c4:	00023517          	auipc	a0,0x23
    800035c8:	1d450513          	addi	a0,a0,468 # 80026798 <icache>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	6cc080e7          	jalr	1740(ra) # 80000c98 <release>
      return ip;
    800035d4:	8926                	mv	s2,s1
    800035d6:	a03d                	j	80003604 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035d8:	f7f9                	bnez	a5,800035a6 <iget+0x3c>
    800035da:	8926                	mv	s2,s1
    800035dc:	b7e9                	j	800035a6 <iget+0x3c>
  if(empty == 0)
    800035de:	02090c63          	beqz	s2,80003616 <iget+0xac>
  ip->dev = dev;
    800035e2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035e6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035ea:	4785                	li	a5,1
    800035ec:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035f0:	04092423          	sw	zero,72(s2)
  release(&icache.lock);
    800035f4:	00023517          	auipc	a0,0x23
    800035f8:	1a450513          	addi	a0,a0,420 # 80026798 <icache>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	69c080e7          	jalr	1692(ra) # 80000c98 <release>
}
    80003604:	854a                	mv	a0,s2
    80003606:	70a2                	ld	ra,40(sp)
    80003608:	7402                	ld	s0,32(sp)
    8000360a:	64e2                	ld	s1,24(sp)
    8000360c:	6942                	ld	s2,16(sp)
    8000360e:	69a2                	ld	s3,8(sp)
    80003610:	6a02                	ld	s4,0(sp)
    80003612:	6145                	addi	sp,sp,48
    80003614:	8082                	ret
    panic("iget: no inodes");
    80003616:	00005517          	auipc	a0,0x5
    8000361a:	09250513          	addi	a0,a0,146 # 800086a8 <userret+0x618>
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	f2a080e7          	jalr	-214(ra) # 80000548 <panic>

0000000080003626 <fsinit>:
fsinit(int dev) {
    80003626:	7179                	addi	sp,sp,-48
    80003628:	f406                	sd	ra,40(sp)
    8000362a:	f022                	sd	s0,32(sp)
    8000362c:	ec26                	sd	s1,24(sp)
    8000362e:	e84a                	sd	s2,16(sp)
    80003630:	e44e                	sd	s3,8(sp)
    80003632:	1800                	addi	s0,sp,48
    80003634:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003636:	4585                	li	a1,1
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	95a080e7          	jalr	-1702(ra) # 80002f92 <bread>
    80003640:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003642:	00023997          	auipc	s3,0x23
    80003646:	13698993          	addi	s3,s3,310 # 80026778 <sb>
    8000364a:	02000613          	li	a2,32
    8000364e:	06050593          	addi	a1,a0,96
    80003652:	854e                	mv	a0,s3
    80003654:	ffffe097          	auipc	ra,0xffffe
    80003658:	89e080e7          	jalr	-1890(ra) # 80000ef2 <memmove>
  brelse(bp);
    8000365c:	8526                	mv	a0,s1
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	b28080e7          	jalr	-1240(ra) # 80003186 <brelse>
  if(sb.magic != FSMAGIC)
    80003666:	0009a703          	lw	a4,0(s3)
    8000366a:	102037b7          	lui	a5,0x10203
    8000366e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003672:	02f71263          	bne	a4,a5,80003696 <fsinit+0x70>
  initlog(dev, &sb);
    80003676:	00023597          	auipc	a1,0x23
    8000367a:	10258593          	addi	a1,a1,258 # 80026778 <sb>
    8000367e:	854a                	mv	a0,s2
    80003680:	00001097          	auipc	ra,0x1
    80003684:	b38080e7          	jalr	-1224(ra) # 800041b8 <initlog>
}
    80003688:	70a2                	ld	ra,40(sp)
    8000368a:	7402                	ld	s0,32(sp)
    8000368c:	64e2                	ld	s1,24(sp)
    8000368e:	6942                	ld	s2,16(sp)
    80003690:	69a2                	ld	s3,8(sp)
    80003692:	6145                	addi	sp,sp,48
    80003694:	8082                	ret
    panic("invalid file system");
    80003696:	00005517          	auipc	a0,0x5
    8000369a:	02250513          	addi	a0,a0,34 # 800086b8 <userret+0x628>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	eaa080e7          	jalr	-342(ra) # 80000548 <panic>

00000000800036a6 <iinit>:
{
    800036a6:	7179                	addi	sp,sp,-48
    800036a8:	f406                	sd	ra,40(sp)
    800036aa:	f022                	sd	s0,32(sp)
    800036ac:	ec26                	sd	s1,24(sp)
    800036ae:	e84a                	sd	s2,16(sp)
    800036b0:	e44e                	sd	s3,8(sp)
    800036b2:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800036b4:	00005597          	auipc	a1,0x5
    800036b8:	01c58593          	addi	a1,a1,28 # 800086d0 <userret+0x640>
    800036bc:	00023517          	auipc	a0,0x23
    800036c0:	0dc50513          	addi	a0,a0,220 # 80026798 <icache>
    800036c4:	ffffd097          	auipc	ra,0xffffd
    800036c8:	416080e7          	jalr	1046(ra) # 80000ada <initlock>
  for(i = 0; i < NINODE; i++) {
    800036cc:	00023497          	auipc	s1,0x23
    800036d0:	0fc48493          	addi	s1,s1,252 # 800267c8 <icache+0x30>
    800036d4:	00025997          	auipc	s3,0x25
    800036d8:	d1498993          	addi	s3,s3,-748 # 800283e8 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800036dc:	00005917          	auipc	s2,0x5
    800036e0:	ffc90913          	addi	s2,s2,-4 # 800086d8 <userret+0x648>
    800036e4:	85ca                	mv	a1,s2
    800036e6:	8526                	mv	a0,s1
    800036e8:	00001097          	auipc	ra,0x1
    800036ec:	f28080e7          	jalr	-216(ra) # 80004610 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036f0:	09048493          	addi	s1,s1,144
    800036f4:	ff3498e3          	bne	s1,s3,800036e4 <iinit+0x3e>
}
    800036f8:	70a2                	ld	ra,40(sp)
    800036fa:	7402                	ld	s0,32(sp)
    800036fc:	64e2                	ld	s1,24(sp)
    800036fe:	6942                	ld	s2,16(sp)
    80003700:	69a2                	ld	s3,8(sp)
    80003702:	6145                	addi	sp,sp,48
    80003704:	8082                	ret

0000000080003706 <ialloc>:
{
    80003706:	715d                	addi	sp,sp,-80
    80003708:	e486                	sd	ra,72(sp)
    8000370a:	e0a2                	sd	s0,64(sp)
    8000370c:	fc26                	sd	s1,56(sp)
    8000370e:	f84a                	sd	s2,48(sp)
    80003710:	f44e                	sd	s3,40(sp)
    80003712:	f052                	sd	s4,32(sp)
    80003714:	ec56                	sd	s5,24(sp)
    80003716:	e85a                	sd	s6,16(sp)
    80003718:	e45e                	sd	s7,8(sp)
    8000371a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000371c:	00023717          	auipc	a4,0x23
    80003720:	06872703          	lw	a4,104(a4) # 80026784 <sb+0xc>
    80003724:	4785                	li	a5,1
    80003726:	04e7fa63          	bgeu	a5,a4,8000377a <ialloc+0x74>
    8000372a:	8aaa                	mv	s5,a0
    8000372c:	8bae                	mv	s7,a1
    8000372e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003730:	00023a17          	auipc	s4,0x23
    80003734:	048a0a13          	addi	s4,s4,72 # 80026778 <sb>
    80003738:	00048b1b          	sext.w	s6,s1
    8000373c:	0044d793          	srli	a5,s1,0x4
    80003740:	018a2583          	lw	a1,24(s4)
    80003744:	9dbd                	addw	a1,a1,a5
    80003746:	8556                	mv	a0,s5
    80003748:	00000097          	auipc	ra,0x0
    8000374c:	84a080e7          	jalr	-1974(ra) # 80002f92 <bread>
    80003750:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003752:	06050993          	addi	s3,a0,96
    80003756:	00f4f793          	andi	a5,s1,15
    8000375a:	079a                	slli	a5,a5,0x6
    8000375c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000375e:	00099783          	lh	a5,0(s3)
    80003762:	c785                	beqz	a5,8000378a <ialloc+0x84>
    brelse(bp);
    80003764:	00000097          	auipc	ra,0x0
    80003768:	a22080e7          	jalr	-1502(ra) # 80003186 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000376c:	0485                	addi	s1,s1,1
    8000376e:	00ca2703          	lw	a4,12(s4)
    80003772:	0004879b          	sext.w	a5,s1
    80003776:	fce7e1e3          	bltu	a5,a4,80003738 <ialloc+0x32>
  panic("ialloc: no inodes");
    8000377a:	00005517          	auipc	a0,0x5
    8000377e:	f6650513          	addi	a0,a0,-154 # 800086e0 <userret+0x650>
    80003782:	ffffd097          	auipc	ra,0xffffd
    80003786:	dc6080e7          	jalr	-570(ra) # 80000548 <panic>
      memset(dip, 0, sizeof(*dip));
    8000378a:	04000613          	li	a2,64
    8000378e:	4581                	li	a1,0
    80003790:	854e                	mv	a0,s3
    80003792:	ffffd097          	auipc	ra,0xffffd
    80003796:	704080e7          	jalr	1796(ra) # 80000e96 <memset>
      dip->type = type;
    8000379a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000379e:	854a                	mv	a0,s2
    800037a0:	00001097          	auipc	ra,0x1
    800037a4:	d30080e7          	jalr	-720(ra) # 800044d0 <log_write>
      brelse(bp);
    800037a8:	854a                	mv	a0,s2
    800037aa:	00000097          	auipc	ra,0x0
    800037ae:	9dc080e7          	jalr	-1572(ra) # 80003186 <brelse>
      return iget(dev, inum);
    800037b2:	85da                	mv	a1,s6
    800037b4:	8556                	mv	a0,s5
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	db4080e7          	jalr	-588(ra) # 8000356a <iget>
}
    800037be:	60a6                	ld	ra,72(sp)
    800037c0:	6406                	ld	s0,64(sp)
    800037c2:	74e2                	ld	s1,56(sp)
    800037c4:	7942                	ld	s2,48(sp)
    800037c6:	79a2                	ld	s3,40(sp)
    800037c8:	7a02                	ld	s4,32(sp)
    800037ca:	6ae2                	ld	s5,24(sp)
    800037cc:	6b42                	ld	s6,16(sp)
    800037ce:	6ba2                	ld	s7,8(sp)
    800037d0:	6161                	addi	sp,sp,80
    800037d2:	8082                	ret

00000000800037d4 <iupdate>:
{
    800037d4:	1101                	addi	sp,sp,-32
    800037d6:	ec06                	sd	ra,24(sp)
    800037d8:	e822                	sd	s0,16(sp)
    800037da:	e426                	sd	s1,8(sp)
    800037dc:	e04a                	sd	s2,0(sp)
    800037de:	1000                	addi	s0,sp,32
    800037e0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037e2:	415c                	lw	a5,4(a0)
    800037e4:	0047d79b          	srliw	a5,a5,0x4
    800037e8:	00023597          	auipc	a1,0x23
    800037ec:	fa85a583          	lw	a1,-88(a1) # 80026790 <sb+0x18>
    800037f0:	9dbd                	addw	a1,a1,a5
    800037f2:	4108                	lw	a0,0(a0)
    800037f4:	fffff097          	auipc	ra,0xfffff
    800037f8:	79e080e7          	jalr	1950(ra) # 80002f92 <bread>
    800037fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037fe:	06050793          	addi	a5,a0,96
    80003802:	40c8                	lw	a0,4(s1)
    80003804:	893d                	andi	a0,a0,15
    80003806:	051a                	slli	a0,a0,0x6
    80003808:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000380a:	04c49703          	lh	a4,76(s1)
    8000380e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003812:	04e49703          	lh	a4,78(s1)
    80003816:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000381a:	05049703          	lh	a4,80(s1)
    8000381e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003822:	05249703          	lh	a4,82(s1)
    80003826:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    8000382a:	48f8                	lw	a4,84(s1)
    8000382c:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000382e:	03400613          	li	a2,52
    80003832:	05848593          	addi	a1,s1,88
    80003836:	0531                	addi	a0,a0,12
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	6ba080e7          	jalr	1722(ra) # 80000ef2 <memmove>
  log_write(bp);
    80003840:	854a                	mv	a0,s2
    80003842:	00001097          	auipc	ra,0x1
    80003846:	c8e080e7          	jalr	-882(ra) # 800044d0 <log_write>
  brelse(bp);
    8000384a:	854a                	mv	a0,s2
    8000384c:	00000097          	auipc	ra,0x0
    80003850:	93a080e7          	jalr	-1734(ra) # 80003186 <brelse>
}
    80003854:	60e2                	ld	ra,24(sp)
    80003856:	6442                	ld	s0,16(sp)
    80003858:	64a2                	ld	s1,8(sp)
    8000385a:	6902                	ld	s2,0(sp)
    8000385c:	6105                	addi	sp,sp,32
    8000385e:	8082                	ret

0000000080003860 <idup>:
{
    80003860:	1101                	addi	sp,sp,-32
    80003862:	ec06                	sd	ra,24(sp)
    80003864:	e822                	sd	s0,16(sp)
    80003866:	e426                	sd	s1,8(sp)
    80003868:	1000                	addi	s0,sp,32
    8000386a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000386c:	00023517          	auipc	a0,0x23
    80003870:	f2c50513          	addi	a0,a0,-212 # 80026798 <icache>
    80003874:	ffffd097          	auipc	ra,0xffffd
    80003878:	3b4080e7          	jalr	948(ra) # 80000c28 <acquire>
  ip->ref++;
    8000387c:	449c                	lw	a5,8(s1)
    8000387e:	2785                	addiw	a5,a5,1
    80003880:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003882:	00023517          	auipc	a0,0x23
    80003886:	f1650513          	addi	a0,a0,-234 # 80026798 <icache>
    8000388a:	ffffd097          	auipc	ra,0xffffd
    8000388e:	40e080e7          	jalr	1038(ra) # 80000c98 <release>
}
    80003892:	8526                	mv	a0,s1
    80003894:	60e2                	ld	ra,24(sp)
    80003896:	6442                	ld	s0,16(sp)
    80003898:	64a2                	ld	s1,8(sp)
    8000389a:	6105                	addi	sp,sp,32
    8000389c:	8082                	ret

000000008000389e <ilock>:
{
    8000389e:	1101                	addi	sp,sp,-32
    800038a0:	ec06                	sd	ra,24(sp)
    800038a2:	e822                	sd	s0,16(sp)
    800038a4:	e426                	sd	s1,8(sp)
    800038a6:	e04a                	sd	s2,0(sp)
    800038a8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038aa:	c115                	beqz	a0,800038ce <ilock+0x30>
    800038ac:	84aa                	mv	s1,a0
    800038ae:	451c                	lw	a5,8(a0)
    800038b0:	00f05f63          	blez	a5,800038ce <ilock+0x30>
  acquiresleep(&ip->lock);
    800038b4:	0541                	addi	a0,a0,16
    800038b6:	00001097          	auipc	ra,0x1
    800038ba:	d94080e7          	jalr	-620(ra) # 8000464a <acquiresleep>
  if(ip->valid == 0){
    800038be:	44bc                	lw	a5,72(s1)
    800038c0:	cf99                	beqz	a5,800038de <ilock+0x40>
}
    800038c2:	60e2                	ld	ra,24(sp)
    800038c4:	6442                	ld	s0,16(sp)
    800038c6:	64a2                	ld	s1,8(sp)
    800038c8:	6902                	ld	s2,0(sp)
    800038ca:	6105                	addi	sp,sp,32
    800038cc:	8082                	ret
    panic("ilock");
    800038ce:	00005517          	auipc	a0,0x5
    800038d2:	e2a50513          	addi	a0,a0,-470 # 800086f8 <userret+0x668>
    800038d6:	ffffd097          	auipc	ra,0xffffd
    800038da:	c72080e7          	jalr	-910(ra) # 80000548 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038de:	40dc                	lw	a5,4(s1)
    800038e0:	0047d79b          	srliw	a5,a5,0x4
    800038e4:	00023597          	auipc	a1,0x23
    800038e8:	eac5a583          	lw	a1,-340(a1) # 80026790 <sb+0x18>
    800038ec:	9dbd                	addw	a1,a1,a5
    800038ee:	4088                	lw	a0,0(s1)
    800038f0:	fffff097          	auipc	ra,0xfffff
    800038f4:	6a2080e7          	jalr	1698(ra) # 80002f92 <bread>
    800038f8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038fa:	06050593          	addi	a1,a0,96
    800038fe:	40dc                	lw	a5,4(s1)
    80003900:	8bbd                	andi	a5,a5,15
    80003902:	079a                	slli	a5,a5,0x6
    80003904:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003906:	00059783          	lh	a5,0(a1)
    8000390a:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    8000390e:	00259783          	lh	a5,2(a1)
    80003912:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    80003916:	00459783          	lh	a5,4(a1)
    8000391a:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    8000391e:	00659783          	lh	a5,6(a1)
    80003922:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    80003926:	459c                	lw	a5,8(a1)
    80003928:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000392a:	03400613          	li	a2,52
    8000392e:	05b1                	addi	a1,a1,12
    80003930:	05848513          	addi	a0,s1,88
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	5be080e7          	jalr	1470(ra) # 80000ef2 <memmove>
    brelse(bp);
    8000393c:	854a                	mv	a0,s2
    8000393e:	00000097          	auipc	ra,0x0
    80003942:	848080e7          	jalr	-1976(ra) # 80003186 <brelse>
    ip->valid = 1;
    80003946:	4785                	li	a5,1
    80003948:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    8000394a:	04c49783          	lh	a5,76(s1)
    8000394e:	fbb5                	bnez	a5,800038c2 <ilock+0x24>
      panic("ilock: no type");
    80003950:	00005517          	auipc	a0,0x5
    80003954:	db050513          	addi	a0,a0,-592 # 80008700 <userret+0x670>
    80003958:	ffffd097          	auipc	ra,0xffffd
    8000395c:	bf0080e7          	jalr	-1040(ra) # 80000548 <panic>

0000000080003960 <iunlock>:
{
    80003960:	1101                	addi	sp,sp,-32
    80003962:	ec06                	sd	ra,24(sp)
    80003964:	e822                	sd	s0,16(sp)
    80003966:	e426                	sd	s1,8(sp)
    80003968:	e04a                	sd	s2,0(sp)
    8000396a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000396c:	c905                	beqz	a0,8000399c <iunlock+0x3c>
    8000396e:	84aa                	mv	s1,a0
    80003970:	01050913          	addi	s2,a0,16
    80003974:	854a                	mv	a0,s2
    80003976:	00001097          	auipc	ra,0x1
    8000397a:	d6e080e7          	jalr	-658(ra) # 800046e4 <holdingsleep>
    8000397e:	cd19                	beqz	a0,8000399c <iunlock+0x3c>
    80003980:	449c                	lw	a5,8(s1)
    80003982:	00f05d63          	blez	a5,8000399c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003986:	854a                	mv	a0,s2
    80003988:	00001097          	auipc	ra,0x1
    8000398c:	d18080e7          	jalr	-744(ra) # 800046a0 <releasesleep>
}
    80003990:	60e2                	ld	ra,24(sp)
    80003992:	6442                	ld	s0,16(sp)
    80003994:	64a2                	ld	s1,8(sp)
    80003996:	6902                	ld	s2,0(sp)
    80003998:	6105                	addi	sp,sp,32
    8000399a:	8082                	ret
    panic("iunlock");
    8000399c:	00005517          	auipc	a0,0x5
    800039a0:	d7450513          	addi	a0,a0,-652 # 80008710 <userret+0x680>
    800039a4:	ffffd097          	auipc	ra,0xffffd
    800039a8:	ba4080e7          	jalr	-1116(ra) # 80000548 <panic>

00000000800039ac <iput>:
{
    800039ac:	7139                	addi	sp,sp,-64
    800039ae:	fc06                	sd	ra,56(sp)
    800039b0:	f822                	sd	s0,48(sp)
    800039b2:	f426                	sd	s1,40(sp)
    800039b4:	f04a                	sd	s2,32(sp)
    800039b6:	ec4e                	sd	s3,24(sp)
    800039b8:	e852                	sd	s4,16(sp)
    800039ba:	e456                	sd	s5,8(sp)
    800039bc:	0080                	addi	s0,sp,64
    800039be:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039c0:	00023517          	auipc	a0,0x23
    800039c4:	dd850513          	addi	a0,a0,-552 # 80026798 <icache>
    800039c8:	ffffd097          	auipc	ra,0xffffd
    800039cc:	260080e7          	jalr	608(ra) # 80000c28 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039d0:	4498                	lw	a4,8(s1)
    800039d2:	4785                	li	a5,1
    800039d4:	02f70663          	beq	a4,a5,80003a00 <iput+0x54>
  ip->ref--;
    800039d8:	449c                	lw	a5,8(s1)
    800039da:	37fd                	addiw	a5,a5,-1
    800039dc:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039de:	00023517          	auipc	a0,0x23
    800039e2:	dba50513          	addi	a0,a0,-582 # 80026798 <icache>
    800039e6:	ffffd097          	auipc	ra,0xffffd
    800039ea:	2b2080e7          	jalr	690(ra) # 80000c98 <release>
}
    800039ee:	70e2                	ld	ra,56(sp)
    800039f0:	7442                	ld	s0,48(sp)
    800039f2:	74a2                	ld	s1,40(sp)
    800039f4:	7902                	ld	s2,32(sp)
    800039f6:	69e2                	ld	s3,24(sp)
    800039f8:	6a42                	ld	s4,16(sp)
    800039fa:	6aa2                	ld	s5,8(sp)
    800039fc:	6121                	addi	sp,sp,64
    800039fe:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a00:	44bc                	lw	a5,72(s1)
    80003a02:	dbf9                	beqz	a5,800039d8 <iput+0x2c>
    80003a04:	05249783          	lh	a5,82(s1)
    80003a08:	fbe1                	bnez	a5,800039d8 <iput+0x2c>
    acquiresleep(&ip->lock);
    80003a0a:	01048a13          	addi	s4,s1,16
    80003a0e:	8552                	mv	a0,s4
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	c3a080e7          	jalr	-966(ra) # 8000464a <acquiresleep>
    release(&icache.lock);
    80003a18:	00023517          	auipc	a0,0x23
    80003a1c:	d8050513          	addi	a0,a0,-640 # 80026798 <icache>
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	278080e7          	jalr	632(ra) # 80000c98 <release>
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a28:	05848913          	addi	s2,s1,88
    80003a2c:	08848993          	addi	s3,s1,136
    80003a30:	a021                	j	80003a38 <iput+0x8c>
    80003a32:	0911                	addi	s2,s2,4
    80003a34:	01390d63          	beq	s2,s3,80003a4e <iput+0xa2>
    if(ip->addrs[i]){
    80003a38:	00092583          	lw	a1,0(s2)
    80003a3c:	d9fd                	beqz	a1,80003a32 <iput+0x86>
      bfree(ip->dev, ip->addrs[i]);
    80003a3e:	4088                	lw	a0,0(s1)
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	8a0080e7          	jalr	-1888(ra) # 800032e0 <bfree>
      ip->addrs[i] = 0;
    80003a48:	00092023          	sw	zero,0(s2)
    80003a4c:	b7dd                	j	80003a32 <iput+0x86>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a4e:	0884a583          	lw	a1,136(s1)
    80003a52:	ed9d                	bnez	a1,80003a90 <iput+0xe4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a54:	0404aa23          	sw	zero,84(s1)
  iupdate(ip);
    80003a58:	8526                	mv	a0,s1
    80003a5a:	00000097          	auipc	ra,0x0
    80003a5e:	d7a080e7          	jalr	-646(ra) # 800037d4 <iupdate>
    ip->type = 0;
    80003a62:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003a66:	8526                	mv	a0,s1
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	d6c080e7          	jalr	-660(ra) # 800037d4 <iupdate>
    ip->valid = 0;
    80003a70:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003a74:	8552                	mv	a0,s4
    80003a76:	00001097          	auipc	ra,0x1
    80003a7a:	c2a080e7          	jalr	-982(ra) # 800046a0 <releasesleep>
    acquire(&icache.lock);
    80003a7e:	00023517          	auipc	a0,0x23
    80003a82:	d1a50513          	addi	a0,a0,-742 # 80026798 <icache>
    80003a86:	ffffd097          	auipc	ra,0xffffd
    80003a8a:	1a2080e7          	jalr	418(ra) # 80000c28 <acquire>
    80003a8e:	b7a9                	j	800039d8 <iput+0x2c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a90:	4088                	lw	a0,0(s1)
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	500080e7          	jalr	1280(ra) # 80002f92 <bread>
    80003a9a:	8aaa                	mv	s5,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a9c:	06050913          	addi	s2,a0,96
    80003aa0:	46050993          	addi	s3,a0,1120
    80003aa4:	a021                	j	80003aac <iput+0x100>
    80003aa6:	0911                	addi	s2,s2,4
    80003aa8:	01390b63          	beq	s2,s3,80003abe <iput+0x112>
      if(a[j])
    80003aac:	00092583          	lw	a1,0(s2)
    80003ab0:	d9fd                	beqz	a1,80003aa6 <iput+0xfa>
        bfree(ip->dev, a[j]);
    80003ab2:	4088                	lw	a0,0(s1)
    80003ab4:	00000097          	auipc	ra,0x0
    80003ab8:	82c080e7          	jalr	-2004(ra) # 800032e0 <bfree>
    80003abc:	b7ed                	j	80003aa6 <iput+0xfa>
    brelse(bp);
    80003abe:	8556                	mv	a0,s5
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	6c6080e7          	jalr	1734(ra) # 80003186 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ac8:	0884a583          	lw	a1,136(s1)
    80003acc:	4088                	lw	a0,0(s1)
    80003ace:	00000097          	auipc	ra,0x0
    80003ad2:	812080e7          	jalr	-2030(ra) # 800032e0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ad6:	0804a423          	sw	zero,136(s1)
    80003ada:	bfad                	j	80003a54 <iput+0xa8>

0000000080003adc <iunlockput>:
{
    80003adc:	1101                	addi	sp,sp,-32
    80003ade:	ec06                	sd	ra,24(sp)
    80003ae0:	e822                	sd	s0,16(sp)
    80003ae2:	e426                	sd	s1,8(sp)
    80003ae4:	1000                	addi	s0,sp,32
    80003ae6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	e78080e7          	jalr	-392(ra) # 80003960 <iunlock>
  iput(ip);
    80003af0:	8526                	mv	a0,s1
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	eba080e7          	jalr	-326(ra) # 800039ac <iput>
}
    80003afa:	60e2                	ld	ra,24(sp)
    80003afc:	6442                	ld	s0,16(sp)
    80003afe:	64a2                	ld	s1,8(sp)
    80003b00:	6105                	addi	sp,sp,32
    80003b02:	8082                	ret

0000000080003b04 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b04:	1141                	addi	sp,sp,-16
    80003b06:	e422                	sd	s0,8(sp)
    80003b08:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b0a:	411c                	lw	a5,0(a0)
    80003b0c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b0e:	415c                	lw	a5,4(a0)
    80003b10:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b12:	04c51783          	lh	a5,76(a0)
    80003b16:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b1a:	05251783          	lh	a5,82(a0)
    80003b1e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b22:	05456783          	lwu	a5,84(a0)
    80003b26:	e99c                	sd	a5,16(a1)
}
    80003b28:	6422                	ld	s0,8(sp)
    80003b2a:	0141                	addi	sp,sp,16
    80003b2c:	8082                	ret

0000000080003b2e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2e:	497c                	lw	a5,84(a0)
    80003b30:	0ed7e563          	bltu	a5,a3,80003c1a <readi+0xec>
{
    80003b34:	7159                	addi	sp,sp,-112
    80003b36:	f486                	sd	ra,104(sp)
    80003b38:	f0a2                	sd	s0,96(sp)
    80003b3a:	eca6                	sd	s1,88(sp)
    80003b3c:	e8ca                	sd	s2,80(sp)
    80003b3e:	e4ce                	sd	s3,72(sp)
    80003b40:	e0d2                	sd	s4,64(sp)
    80003b42:	fc56                	sd	s5,56(sp)
    80003b44:	f85a                	sd	s6,48(sp)
    80003b46:	f45e                	sd	s7,40(sp)
    80003b48:	f062                	sd	s8,32(sp)
    80003b4a:	ec66                	sd	s9,24(sp)
    80003b4c:	e86a                	sd	s10,16(sp)
    80003b4e:	e46e                	sd	s11,8(sp)
    80003b50:	1880                	addi	s0,sp,112
    80003b52:	8baa                	mv	s7,a0
    80003b54:	8c2e                	mv	s8,a1
    80003b56:	8ab2                	mv	s5,a2
    80003b58:	8936                	mv	s2,a3
    80003b5a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b5c:	9f35                	addw	a4,a4,a3
    80003b5e:	0cd76063          	bltu	a4,a3,80003c1e <readi+0xf0>
    return -1;
  if(off + n > ip->size)
    80003b62:	00e7f463          	bgeu	a5,a4,80003b6a <readi+0x3c>
    n = ip->size - off;
    80003b66:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b6a:	080b0763          	beqz	s6,80003bf8 <readi+0xca>
    80003b6e:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b70:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b74:	5cfd                	li	s9,-1
    80003b76:	a82d                	j	80003bb0 <readi+0x82>
    80003b78:	02099d93          	slli	s11,s3,0x20
    80003b7c:	020ddd93          	srli	s11,s11,0x20
    80003b80:	06048793          	addi	a5,s1,96
    80003b84:	86ee                	mv	a3,s11
    80003b86:	963e                	add	a2,a2,a5
    80003b88:	85d6                	mv	a1,s5
    80003b8a:	8562                	mv	a0,s8
    80003b8c:	fffff097          	auipc	ra,0xfffff
    80003b90:	a24080e7          	jalr	-1500(ra) # 800025b0 <either_copyout>
    80003b94:	05950d63          	beq	a0,s9,80003bee <readi+0xc0>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b98:	8526                	mv	a0,s1
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	5ec080e7          	jalr	1516(ra) # 80003186 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba2:	01498a3b          	addw	s4,s3,s4
    80003ba6:	0129893b          	addw	s2,s3,s2
    80003baa:	9aee                	add	s5,s5,s11
    80003bac:	056a7663          	bgeu	s4,s6,80003bf8 <readi+0xca>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bb0:	000ba483          	lw	s1,0(s7)
    80003bb4:	00a9559b          	srliw	a1,s2,0xa
    80003bb8:	855e                	mv	a0,s7
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	8d4080e7          	jalr	-1836(ra) # 8000348e <bmap>
    80003bc2:	0005059b          	sext.w	a1,a0
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	fffff097          	auipc	ra,0xfffff
    80003bcc:	3ca080e7          	jalr	970(ra) # 80002f92 <bread>
    80003bd0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd2:	3ff97613          	andi	a2,s2,1023
    80003bd6:	40cd07bb          	subw	a5,s10,a2
    80003bda:	414b073b          	subw	a4,s6,s4
    80003bde:	89be                	mv	s3,a5
    80003be0:	2781                	sext.w	a5,a5
    80003be2:	0007069b          	sext.w	a3,a4
    80003be6:	f8f6f9e3          	bgeu	a3,a5,80003b78 <readi+0x4a>
    80003bea:	89ba                	mv	s3,a4
    80003bec:	b771                	j	80003b78 <readi+0x4a>
      brelse(bp);
    80003bee:	8526                	mv	a0,s1
    80003bf0:	fffff097          	auipc	ra,0xfffff
    80003bf4:	596080e7          	jalr	1430(ra) # 80003186 <brelse>
  }
  return n;
    80003bf8:	000b051b          	sext.w	a0,s6
}
    80003bfc:	70a6                	ld	ra,104(sp)
    80003bfe:	7406                	ld	s0,96(sp)
    80003c00:	64e6                	ld	s1,88(sp)
    80003c02:	6946                	ld	s2,80(sp)
    80003c04:	69a6                	ld	s3,72(sp)
    80003c06:	6a06                	ld	s4,64(sp)
    80003c08:	7ae2                	ld	s5,56(sp)
    80003c0a:	7b42                	ld	s6,48(sp)
    80003c0c:	7ba2                	ld	s7,40(sp)
    80003c0e:	7c02                	ld	s8,32(sp)
    80003c10:	6ce2                	ld	s9,24(sp)
    80003c12:	6d42                	ld	s10,16(sp)
    80003c14:	6da2                	ld	s11,8(sp)
    80003c16:	6165                	addi	sp,sp,112
    80003c18:	8082                	ret
    return -1;
    80003c1a:	557d                	li	a0,-1
}
    80003c1c:	8082                	ret
    return -1;
    80003c1e:	557d                	li	a0,-1
    80003c20:	bff1                	j	80003bfc <readi+0xce>

0000000080003c22 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c22:	497c                	lw	a5,84(a0)
    80003c24:	10d7e663          	bltu	a5,a3,80003d30 <writei+0x10e>
{
    80003c28:	7159                	addi	sp,sp,-112
    80003c2a:	f486                	sd	ra,104(sp)
    80003c2c:	f0a2                	sd	s0,96(sp)
    80003c2e:	eca6                	sd	s1,88(sp)
    80003c30:	e8ca                	sd	s2,80(sp)
    80003c32:	e4ce                	sd	s3,72(sp)
    80003c34:	e0d2                	sd	s4,64(sp)
    80003c36:	fc56                	sd	s5,56(sp)
    80003c38:	f85a                	sd	s6,48(sp)
    80003c3a:	f45e                	sd	s7,40(sp)
    80003c3c:	f062                	sd	s8,32(sp)
    80003c3e:	ec66                	sd	s9,24(sp)
    80003c40:	e86a                	sd	s10,16(sp)
    80003c42:	e46e                	sd	s11,8(sp)
    80003c44:	1880                	addi	s0,sp,112
    80003c46:	8baa                	mv	s7,a0
    80003c48:	8c2e                	mv	s8,a1
    80003c4a:	8ab2                	mv	s5,a2
    80003c4c:	8936                	mv	s2,a3
    80003c4e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c50:	00e687bb          	addw	a5,a3,a4
    80003c54:	0ed7e063          	bltu	a5,a3,80003d34 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c58:	00043737          	lui	a4,0x43
    80003c5c:	0cf76e63          	bltu	a4,a5,80003d38 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c60:	0a0b0763          	beqz	s6,80003d0e <writei+0xec>
    80003c64:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c66:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c6a:	5cfd                	li	s9,-1
    80003c6c:	a091                	j	80003cb0 <writei+0x8e>
    80003c6e:	02099d93          	slli	s11,s3,0x20
    80003c72:	020ddd93          	srli	s11,s11,0x20
    80003c76:	06048793          	addi	a5,s1,96
    80003c7a:	86ee                	mv	a3,s11
    80003c7c:	8656                	mv	a2,s5
    80003c7e:	85e2                	mv	a1,s8
    80003c80:	953e                	add	a0,a0,a5
    80003c82:	fffff097          	auipc	ra,0xfffff
    80003c86:	984080e7          	jalr	-1660(ra) # 80002606 <either_copyin>
    80003c8a:	07950263          	beq	a0,s9,80003cee <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c8e:	8526                	mv	a0,s1
    80003c90:	00001097          	auipc	ra,0x1
    80003c94:	840080e7          	jalr	-1984(ra) # 800044d0 <log_write>
    brelse(bp);
    80003c98:	8526                	mv	a0,s1
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	4ec080e7          	jalr	1260(ra) # 80003186 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ca2:	01498a3b          	addw	s4,s3,s4
    80003ca6:	0129893b          	addw	s2,s3,s2
    80003caa:	9aee                	add	s5,s5,s11
    80003cac:	056a7663          	bgeu	s4,s6,80003cf8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cb0:	000ba483          	lw	s1,0(s7)
    80003cb4:	00a9559b          	srliw	a1,s2,0xa
    80003cb8:	855e                	mv	a0,s7
    80003cba:	fffff097          	auipc	ra,0xfffff
    80003cbe:	7d4080e7          	jalr	2004(ra) # 8000348e <bmap>
    80003cc2:	0005059b          	sext.w	a1,a0
    80003cc6:	8526                	mv	a0,s1
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	2ca080e7          	jalr	714(ra) # 80002f92 <bread>
    80003cd0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd2:	3ff97513          	andi	a0,s2,1023
    80003cd6:	40ad07bb          	subw	a5,s10,a0
    80003cda:	414b073b          	subw	a4,s6,s4
    80003cde:	89be                	mv	s3,a5
    80003ce0:	2781                	sext.w	a5,a5
    80003ce2:	0007069b          	sext.w	a3,a4
    80003ce6:	f8f6f4e3          	bgeu	a3,a5,80003c6e <writei+0x4c>
    80003cea:	89ba                	mv	s3,a4
    80003cec:	b749                	j	80003c6e <writei+0x4c>
      brelse(bp);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	fffff097          	auipc	ra,0xfffff
    80003cf4:	496080e7          	jalr	1174(ra) # 80003186 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003cf8:	054ba783          	lw	a5,84(s7)
    80003cfc:	0127f463          	bgeu	a5,s2,80003d04 <writei+0xe2>
      ip->size = off;
    80003d00:	052baa23          	sw	s2,84(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003d04:	855e                	mv	a0,s7
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	ace080e7          	jalr	-1330(ra) # 800037d4 <iupdate>
  }

  return n;
    80003d0e:	000b051b          	sext.w	a0,s6
}
    80003d12:	70a6                	ld	ra,104(sp)
    80003d14:	7406                	ld	s0,96(sp)
    80003d16:	64e6                	ld	s1,88(sp)
    80003d18:	6946                	ld	s2,80(sp)
    80003d1a:	69a6                	ld	s3,72(sp)
    80003d1c:	6a06                	ld	s4,64(sp)
    80003d1e:	7ae2                	ld	s5,56(sp)
    80003d20:	7b42                	ld	s6,48(sp)
    80003d22:	7ba2                	ld	s7,40(sp)
    80003d24:	7c02                	ld	s8,32(sp)
    80003d26:	6ce2                	ld	s9,24(sp)
    80003d28:	6d42                	ld	s10,16(sp)
    80003d2a:	6da2                	ld	s11,8(sp)
    80003d2c:	6165                	addi	sp,sp,112
    80003d2e:	8082                	ret
    return -1;
    80003d30:	557d                	li	a0,-1
}
    80003d32:	8082                	ret
    return -1;
    80003d34:	557d                	li	a0,-1
    80003d36:	bff1                	j	80003d12 <writei+0xf0>
    return -1;
    80003d38:	557d                	li	a0,-1
    80003d3a:	bfe1                	j	80003d12 <writei+0xf0>

0000000080003d3c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d3c:	1141                	addi	sp,sp,-16
    80003d3e:	e406                	sd	ra,8(sp)
    80003d40:	e022                	sd	s0,0(sp)
    80003d42:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d44:	4639                	li	a2,14
    80003d46:	ffffd097          	auipc	ra,0xffffd
    80003d4a:	228080e7          	jalr	552(ra) # 80000f6e <strncmp>
}
    80003d4e:	60a2                	ld	ra,8(sp)
    80003d50:	6402                	ld	s0,0(sp)
    80003d52:	0141                	addi	sp,sp,16
    80003d54:	8082                	ret

0000000080003d56 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d56:	7139                	addi	sp,sp,-64
    80003d58:	fc06                	sd	ra,56(sp)
    80003d5a:	f822                	sd	s0,48(sp)
    80003d5c:	f426                	sd	s1,40(sp)
    80003d5e:	f04a                	sd	s2,32(sp)
    80003d60:	ec4e                	sd	s3,24(sp)
    80003d62:	e852                	sd	s4,16(sp)
    80003d64:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d66:	04c51703          	lh	a4,76(a0)
    80003d6a:	4785                	li	a5,1
    80003d6c:	00f71a63          	bne	a4,a5,80003d80 <dirlookup+0x2a>
    80003d70:	892a                	mv	s2,a0
    80003d72:	89ae                	mv	s3,a1
    80003d74:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d76:	497c                	lw	a5,84(a0)
    80003d78:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d7a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d7c:	e79d                	bnez	a5,80003daa <dirlookup+0x54>
    80003d7e:	a8a5                	j	80003df6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d80:	00005517          	auipc	a0,0x5
    80003d84:	99850513          	addi	a0,a0,-1640 # 80008718 <userret+0x688>
    80003d88:	ffffc097          	auipc	ra,0xffffc
    80003d8c:	7c0080e7          	jalr	1984(ra) # 80000548 <panic>
      panic("dirlookup read");
    80003d90:	00005517          	auipc	a0,0x5
    80003d94:	9a050513          	addi	a0,a0,-1632 # 80008730 <userret+0x6a0>
    80003d98:	ffffc097          	auipc	ra,0xffffc
    80003d9c:	7b0080e7          	jalr	1968(ra) # 80000548 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da0:	24c1                	addiw	s1,s1,16
    80003da2:	05492783          	lw	a5,84(s2)
    80003da6:	04f4f763          	bgeu	s1,a5,80003df4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003daa:	4741                	li	a4,16
    80003dac:	86a6                	mv	a3,s1
    80003dae:	fc040613          	addi	a2,s0,-64
    80003db2:	4581                	li	a1,0
    80003db4:	854a                	mv	a0,s2
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	d78080e7          	jalr	-648(ra) # 80003b2e <readi>
    80003dbe:	47c1                	li	a5,16
    80003dc0:	fcf518e3          	bne	a0,a5,80003d90 <dirlookup+0x3a>
    if(de.inum == 0)
    80003dc4:	fc045783          	lhu	a5,-64(s0)
    80003dc8:	dfe1                	beqz	a5,80003da0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003dca:	fc240593          	addi	a1,s0,-62
    80003dce:	854e                	mv	a0,s3
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	f6c080e7          	jalr	-148(ra) # 80003d3c <namecmp>
    80003dd8:	f561                	bnez	a0,80003da0 <dirlookup+0x4a>
      if(poff)
    80003dda:	000a0463          	beqz	s4,80003de2 <dirlookup+0x8c>
        *poff = off;
    80003dde:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003de2:	fc045583          	lhu	a1,-64(s0)
    80003de6:	00092503          	lw	a0,0(s2)
    80003dea:	fffff097          	auipc	ra,0xfffff
    80003dee:	780080e7          	jalr	1920(ra) # 8000356a <iget>
    80003df2:	a011                	j	80003df6 <dirlookup+0xa0>
  return 0;
    80003df4:	4501                	li	a0,0
}
    80003df6:	70e2                	ld	ra,56(sp)
    80003df8:	7442                	ld	s0,48(sp)
    80003dfa:	74a2                	ld	s1,40(sp)
    80003dfc:	7902                	ld	s2,32(sp)
    80003dfe:	69e2                	ld	s3,24(sp)
    80003e00:	6a42                	ld	s4,16(sp)
    80003e02:	6121                	addi	sp,sp,64
    80003e04:	8082                	ret

0000000080003e06 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e06:	711d                	addi	sp,sp,-96
    80003e08:	ec86                	sd	ra,88(sp)
    80003e0a:	e8a2                	sd	s0,80(sp)
    80003e0c:	e4a6                	sd	s1,72(sp)
    80003e0e:	e0ca                	sd	s2,64(sp)
    80003e10:	fc4e                	sd	s3,56(sp)
    80003e12:	f852                	sd	s4,48(sp)
    80003e14:	f456                	sd	s5,40(sp)
    80003e16:	f05a                	sd	s6,32(sp)
    80003e18:	ec5e                	sd	s7,24(sp)
    80003e1a:	e862                	sd	s8,16(sp)
    80003e1c:	e466                	sd	s9,8(sp)
    80003e1e:	1080                	addi	s0,sp,96
    80003e20:	84aa                	mv	s1,a0
    80003e22:	8aae                	mv	s5,a1
    80003e24:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e26:	00054703          	lbu	a4,0(a0)
    80003e2a:	02f00793          	li	a5,47
    80003e2e:	02f70363          	beq	a4,a5,80003e54 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e32:	ffffe097          	auipc	ra,0xffffe
    80003e36:	d4e080e7          	jalr	-690(ra) # 80001b80 <myproc>
    80003e3a:	15853503          	ld	a0,344(a0)
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	a22080e7          	jalr	-1502(ra) # 80003860 <idup>
    80003e46:	89aa                	mv	s3,a0
  while(*path == '/')
    80003e48:	02f00913          	li	s2,47
  len = path - s;
    80003e4c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003e4e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e50:	4b85                	li	s7,1
    80003e52:	a865                	j	80003f0a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003e54:	4585                	li	a1,1
    80003e56:	4501                	li	a0,0
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	712080e7          	jalr	1810(ra) # 8000356a <iget>
    80003e60:	89aa                	mv	s3,a0
    80003e62:	b7dd                	j	80003e48 <namex+0x42>
      iunlockput(ip);
    80003e64:	854e                	mv	a0,s3
    80003e66:	00000097          	auipc	ra,0x0
    80003e6a:	c76080e7          	jalr	-906(ra) # 80003adc <iunlockput>
      return 0;
    80003e6e:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e70:	854e                	mv	a0,s3
    80003e72:	60e6                	ld	ra,88(sp)
    80003e74:	6446                	ld	s0,80(sp)
    80003e76:	64a6                	ld	s1,72(sp)
    80003e78:	6906                	ld	s2,64(sp)
    80003e7a:	79e2                	ld	s3,56(sp)
    80003e7c:	7a42                	ld	s4,48(sp)
    80003e7e:	7aa2                	ld	s5,40(sp)
    80003e80:	7b02                	ld	s6,32(sp)
    80003e82:	6be2                	ld	s7,24(sp)
    80003e84:	6c42                	ld	s8,16(sp)
    80003e86:	6ca2                	ld	s9,8(sp)
    80003e88:	6125                	addi	sp,sp,96
    80003e8a:	8082                	ret
      iunlock(ip);
    80003e8c:	854e                	mv	a0,s3
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	ad2080e7          	jalr	-1326(ra) # 80003960 <iunlock>
      return ip;
    80003e96:	bfe9                	j	80003e70 <namex+0x6a>
      iunlockput(ip);
    80003e98:	854e                	mv	a0,s3
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	c42080e7          	jalr	-958(ra) # 80003adc <iunlockput>
      return 0;
    80003ea2:	89e6                	mv	s3,s9
    80003ea4:	b7f1                	j	80003e70 <namex+0x6a>
  len = path - s;
    80003ea6:	40b48633          	sub	a2,s1,a1
    80003eaa:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003eae:	099c5463          	bge	s8,s9,80003f36 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003eb2:	4639                	li	a2,14
    80003eb4:	8552                	mv	a0,s4
    80003eb6:	ffffd097          	auipc	ra,0xffffd
    80003eba:	03c080e7          	jalr	60(ra) # 80000ef2 <memmove>
  while(*path == '/')
    80003ebe:	0004c783          	lbu	a5,0(s1)
    80003ec2:	01279763          	bne	a5,s2,80003ed0 <namex+0xca>
    path++;
    80003ec6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ec8:	0004c783          	lbu	a5,0(s1)
    80003ecc:	ff278de3          	beq	a5,s2,80003ec6 <namex+0xc0>
    ilock(ip);
    80003ed0:	854e                	mv	a0,s3
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	9cc080e7          	jalr	-1588(ra) # 8000389e <ilock>
    if(ip->type != T_DIR){
    80003eda:	04c99783          	lh	a5,76(s3)
    80003ede:	f97793e3          	bne	a5,s7,80003e64 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003ee2:	000a8563          	beqz	s5,80003eec <namex+0xe6>
    80003ee6:	0004c783          	lbu	a5,0(s1)
    80003eea:	d3cd                	beqz	a5,80003e8c <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003eec:	865a                	mv	a2,s6
    80003eee:	85d2                	mv	a1,s4
    80003ef0:	854e                	mv	a0,s3
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	e64080e7          	jalr	-412(ra) # 80003d56 <dirlookup>
    80003efa:	8caa                	mv	s9,a0
    80003efc:	dd51                	beqz	a0,80003e98 <namex+0x92>
    iunlockput(ip);
    80003efe:	854e                	mv	a0,s3
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	bdc080e7          	jalr	-1060(ra) # 80003adc <iunlockput>
    ip = next;
    80003f08:	89e6                	mv	s3,s9
  while(*path == '/')
    80003f0a:	0004c783          	lbu	a5,0(s1)
    80003f0e:	05279763          	bne	a5,s2,80003f5c <namex+0x156>
    path++;
    80003f12:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f14:	0004c783          	lbu	a5,0(s1)
    80003f18:	ff278de3          	beq	a5,s2,80003f12 <namex+0x10c>
  if(*path == 0)
    80003f1c:	c79d                	beqz	a5,80003f4a <namex+0x144>
    path++;
    80003f1e:	85a6                	mv	a1,s1
  len = path - s;
    80003f20:	8cda                	mv	s9,s6
    80003f22:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003f24:	01278963          	beq	a5,s2,80003f36 <namex+0x130>
    80003f28:	dfbd                	beqz	a5,80003ea6 <namex+0xa0>
    path++;
    80003f2a:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003f2c:	0004c783          	lbu	a5,0(s1)
    80003f30:	ff279ce3          	bne	a5,s2,80003f28 <namex+0x122>
    80003f34:	bf8d                	j	80003ea6 <namex+0xa0>
    memmove(name, s, len);
    80003f36:	2601                	sext.w	a2,a2
    80003f38:	8552                	mv	a0,s4
    80003f3a:	ffffd097          	auipc	ra,0xffffd
    80003f3e:	fb8080e7          	jalr	-72(ra) # 80000ef2 <memmove>
    name[len] = 0;
    80003f42:	9cd2                	add	s9,s9,s4
    80003f44:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f48:	bf9d                	j	80003ebe <namex+0xb8>
  if(nameiparent){
    80003f4a:	f20a83e3          	beqz	s5,80003e70 <namex+0x6a>
    iput(ip);
    80003f4e:	854e                	mv	a0,s3
    80003f50:	00000097          	auipc	ra,0x0
    80003f54:	a5c080e7          	jalr	-1444(ra) # 800039ac <iput>
    return 0;
    80003f58:	4981                	li	s3,0
    80003f5a:	bf19                	j	80003e70 <namex+0x6a>
  if(*path == 0)
    80003f5c:	d7fd                	beqz	a5,80003f4a <namex+0x144>
  while(*path != '/' && *path != 0)
    80003f5e:	0004c783          	lbu	a5,0(s1)
    80003f62:	85a6                	mv	a1,s1
    80003f64:	b7d1                	j	80003f28 <namex+0x122>

0000000080003f66 <dirlink>:
{
    80003f66:	7139                	addi	sp,sp,-64
    80003f68:	fc06                	sd	ra,56(sp)
    80003f6a:	f822                	sd	s0,48(sp)
    80003f6c:	f426                	sd	s1,40(sp)
    80003f6e:	f04a                	sd	s2,32(sp)
    80003f70:	ec4e                	sd	s3,24(sp)
    80003f72:	e852                	sd	s4,16(sp)
    80003f74:	0080                	addi	s0,sp,64
    80003f76:	892a                	mv	s2,a0
    80003f78:	8a2e                	mv	s4,a1
    80003f7a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f7c:	4601                	li	a2,0
    80003f7e:	00000097          	auipc	ra,0x0
    80003f82:	dd8080e7          	jalr	-552(ra) # 80003d56 <dirlookup>
    80003f86:	e93d                	bnez	a0,80003ffc <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f88:	05492483          	lw	s1,84(s2)
    80003f8c:	c49d                	beqz	s1,80003fba <dirlink+0x54>
    80003f8e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f90:	4741                	li	a4,16
    80003f92:	86a6                	mv	a3,s1
    80003f94:	fc040613          	addi	a2,s0,-64
    80003f98:	4581                	li	a1,0
    80003f9a:	854a                	mv	a0,s2
    80003f9c:	00000097          	auipc	ra,0x0
    80003fa0:	b92080e7          	jalr	-1134(ra) # 80003b2e <readi>
    80003fa4:	47c1                	li	a5,16
    80003fa6:	06f51163          	bne	a0,a5,80004008 <dirlink+0xa2>
    if(de.inum == 0)
    80003faa:	fc045783          	lhu	a5,-64(s0)
    80003fae:	c791                	beqz	a5,80003fba <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb0:	24c1                	addiw	s1,s1,16
    80003fb2:	05492783          	lw	a5,84(s2)
    80003fb6:	fcf4ede3          	bltu	s1,a5,80003f90 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fba:	4639                	li	a2,14
    80003fbc:	85d2                	mv	a1,s4
    80003fbe:	fc240513          	addi	a0,s0,-62
    80003fc2:	ffffd097          	auipc	ra,0xffffd
    80003fc6:	fe8080e7          	jalr	-24(ra) # 80000faa <strncpy>
  de.inum = inum;
    80003fca:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fce:	4741                	li	a4,16
    80003fd0:	86a6                	mv	a3,s1
    80003fd2:	fc040613          	addi	a2,s0,-64
    80003fd6:	4581                	li	a1,0
    80003fd8:	854a                	mv	a0,s2
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	c48080e7          	jalr	-952(ra) # 80003c22 <writei>
    80003fe2:	872a                	mv	a4,a0
    80003fe4:	47c1                	li	a5,16
  return 0;
    80003fe6:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fe8:	02f71863          	bne	a4,a5,80004018 <dirlink+0xb2>
}
    80003fec:	70e2                	ld	ra,56(sp)
    80003fee:	7442                	ld	s0,48(sp)
    80003ff0:	74a2                	ld	s1,40(sp)
    80003ff2:	7902                	ld	s2,32(sp)
    80003ff4:	69e2                	ld	s3,24(sp)
    80003ff6:	6a42                	ld	s4,16(sp)
    80003ff8:	6121                	addi	sp,sp,64
    80003ffa:	8082                	ret
    iput(ip);
    80003ffc:	00000097          	auipc	ra,0x0
    80004000:	9b0080e7          	jalr	-1616(ra) # 800039ac <iput>
    return -1;
    80004004:	557d                	li	a0,-1
    80004006:	b7dd                	j	80003fec <dirlink+0x86>
      panic("dirlink read");
    80004008:	00004517          	auipc	a0,0x4
    8000400c:	73850513          	addi	a0,a0,1848 # 80008740 <userret+0x6b0>
    80004010:	ffffc097          	auipc	ra,0xffffc
    80004014:	538080e7          	jalr	1336(ra) # 80000548 <panic>
    panic("dirlink");
    80004018:	00005517          	auipc	a0,0x5
    8000401c:	84850513          	addi	a0,a0,-1976 # 80008860 <userret+0x7d0>
    80004020:	ffffc097          	auipc	ra,0xffffc
    80004024:	528080e7          	jalr	1320(ra) # 80000548 <panic>

0000000080004028 <namei>:

struct inode*
namei(char *path)
{
    80004028:	1101                	addi	sp,sp,-32
    8000402a:	ec06                	sd	ra,24(sp)
    8000402c:	e822                	sd	s0,16(sp)
    8000402e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004030:	fe040613          	addi	a2,s0,-32
    80004034:	4581                	li	a1,0
    80004036:	00000097          	auipc	ra,0x0
    8000403a:	dd0080e7          	jalr	-560(ra) # 80003e06 <namex>
}
    8000403e:	60e2                	ld	ra,24(sp)
    80004040:	6442                	ld	s0,16(sp)
    80004042:	6105                	addi	sp,sp,32
    80004044:	8082                	ret

0000000080004046 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004046:	1141                	addi	sp,sp,-16
    80004048:	e406                	sd	ra,8(sp)
    8000404a:	e022                	sd	s0,0(sp)
    8000404c:	0800                	addi	s0,sp,16
    8000404e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004050:	4585                	li	a1,1
    80004052:	00000097          	auipc	ra,0x0
    80004056:	db4080e7          	jalr	-588(ra) # 80003e06 <namex>
}
    8000405a:	60a2                	ld	ra,8(sp)
    8000405c:	6402                	ld	s0,0(sp)
    8000405e:	0141                	addi	sp,sp,16
    80004060:	8082                	ret

0000000080004062 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(int dev)
{
    80004062:	7179                	addi	sp,sp,-48
    80004064:	f406                	sd	ra,40(sp)
    80004066:	f022                	sd	s0,32(sp)
    80004068:	ec26                	sd	s1,24(sp)
    8000406a:	e84a                	sd	s2,16(sp)
    8000406c:	e44e                	sd	s3,8(sp)
    8000406e:	1800                	addi	s0,sp,48
    80004070:	84aa                	mv	s1,a0
  struct buf *buf = bread(dev, log[dev].start);
    80004072:	0b000993          	li	s3,176
    80004076:	033507b3          	mul	a5,a0,s3
    8000407a:	00024997          	auipc	s3,0x24
    8000407e:	35e98993          	addi	s3,s3,862 # 800283d8 <log>
    80004082:	99be                	add	s3,s3,a5
    80004084:	0209a583          	lw	a1,32(s3)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	f0a080e7          	jalr	-246(ra) # 80002f92 <bread>
    80004090:	892a                	mv	s2,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log[dev].lh.n;
    80004092:	0349a783          	lw	a5,52(s3)
    80004096:	d13c                	sw	a5,96(a0)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004098:	0349a783          	lw	a5,52(s3)
    8000409c:	02f05763          	blez	a5,800040ca <write_head+0x68>
    800040a0:	0b000793          	li	a5,176
    800040a4:	02f487b3          	mul	a5,s1,a5
    800040a8:	00024717          	auipc	a4,0x24
    800040ac:	36870713          	addi	a4,a4,872 # 80028410 <log+0x38>
    800040b0:	97ba                	add	a5,a5,a4
    800040b2:	06450693          	addi	a3,a0,100
    800040b6:	4701                	li	a4,0
    800040b8:	85ce                	mv	a1,s3
    hb->block[i] = log[dev].lh.block[i];
    800040ba:	4390                	lw	a2,0(a5)
    800040bc:	c290                	sw	a2,0(a3)
  for (i = 0; i < log[dev].lh.n; i++) {
    800040be:	2705                	addiw	a4,a4,1
    800040c0:	0791                	addi	a5,a5,4
    800040c2:	0691                	addi	a3,a3,4
    800040c4:	59d0                	lw	a2,52(a1)
    800040c6:	fec74ae3          	blt	a4,a2,800040ba <write_head+0x58>
  }
  bwrite(buf);
    800040ca:	854a                	mv	a0,s2
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	07a080e7          	jalr	122(ra) # 80003146 <bwrite>
  brelse(buf);
    800040d4:	854a                	mv	a0,s2
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	0b0080e7          	jalr	176(ra) # 80003186 <brelse>
}
    800040de:	70a2                	ld	ra,40(sp)
    800040e0:	7402                	ld	s0,32(sp)
    800040e2:	64e2                	ld	s1,24(sp)
    800040e4:	6942                	ld	s2,16(sp)
    800040e6:	69a2                	ld	s3,8(sp)
    800040e8:	6145                	addi	sp,sp,48
    800040ea:	8082                	ret

00000000800040ec <install_trans>:
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    800040ec:	0b000793          	li	a5,176
    800040f0:	02f50733          	mul	a4,a0,a5
    800040f4:	00024797          	auipc	a5,0x24
    800040f8:	2e478793          	addi	a5,a5,740 # 800283d8 <log>
    800040fc:	97ba                	add	a5,a5,a4
    800040fe:	5bdc                	lw	a5,52(a5)
    80004100:	0af05b63          	blez	a5,800041b6 <install_trans+0xca>
{
    80004104:	7139                	addi	sp,sp,-64
    80004106:	fc06                	sd	ra,56(sp)
    80004108:	f822                	sd	s0,48(sp)
    8000410a:	f426                	sd	s1,40(sp)
    8000410c:	f04a                	sd	s2,32(sp)
    8000410e:	ec4e                	sd	s3,24(sp)
    80004110:	e852                	sd	s4,16(sp)
    80004112:	e456                	sd	s5,8(sp)
    80004114:	e05a                	sd	s6,0(sp)
    80004116:	0080                	addi	s0,sp,64
    80004118:	00024797          	auipc	a5,0x24
    8000411c:	2f878793          	addi	a5,a5,760 # 80028410 <log+0x38>
    80004120:	00f70a33          	add	s4,a4,a5
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004124:	4981                	li	s3,0
    struct buf *lbuf = bread(dev, log[dev].start+tail+1); // read log block
    80004126:	00050b1b          	sext.w	s6,a0
    8000412a:	00024a97          	auipc	s5,0x24
    8000412e:	2aea8a93          	addi	s5,s5,686 # 800283d8 <log>
    80004132:	9aba                	add	s5,s5,a4
    80004134:	020aa583          	lw	a1,32(s5)
    80004138:	013585bb          	addw	a1,a1,s3
    8000413c:	2585                	addiw	a1,a1,1
    8000413e:	855a                	mv	a0,s6
    80004140:	fffff097          	auipc	ra,0xfffff
    80004144:	e52080e7          	jalr	-430(ra) # 80002f92 <bread>
    80004148:	892a                	mv	s2,a0
    struct buf *dbuf = bread(dev, log[dev].lh.block[tail]); // read dst
    8000414a:	000a2583          	lw	a1,0(s4)
    8000414e:	855a                	mv	a0,s6
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	e42080e7          	jalr	-446(ra) # 80002f92 <bread>
    80004158:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000415a:	40000613          	li	a2,1024
    8000415e:	06090593          	addi	a1,s2,96
    80004162:	06050513          	addi	a0,a0,96
    80004166:	ffffd097          	auipc	ra,0xffffd
    8000416a:	d8c080e7          	jalr	-628(ra) # 80000ef2 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000416e:	8526                	mv	a0,s1
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	fd6080e7          	jalr	-42(ra) # 80003146 <bwrite>
    bunpin(dbuf);
    80004178:	8526                	mv	a0,s1
    8000417a:	fffff097          	auipc	ra,0xfffff
    8000417e:	11a080e7          	jalr	282(ra) # 80003294 <bunpin>
    brelse(lbuf);
    80004182:	854a                	mv	a0,s2
    80004184:	fffff097          	auipc	ra,0xfffff
    80004188:	002080e7          	jalr	2(ra) # 80003186 <brelse>
    brelse(dbuf);
    8000418c:	8526                	mv	a0,s1
    8000418e:	fffff097          	auipc	ra,0xfffff
    80004192:	ff8080e7          	jalr	-8(ra) # 80003186 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004196:	2985                	addiw	s3,s3,1
    80004198:	0a11                	addi	s4,s4,4
    8000419a:	034aa783          	lw	a5,52(s5)
    8000419e:	f8f9cbe3          	blt	s3,a5,80004134 <install_trans+0x48>
}
    800041a2:	70e2                	ld	ra,56(sp)
    800041a4:	7442                	ld	s0,48(sp)
    800041a6:	74a2                	ld	s1,40(sp)
    800041a8:	7902                	ld	s2,32(sp)
    800041aa:	69e2                	ld	s3,24(sp)
    800041ac:	6a42                	ld	s4,16(sp)
    800041ae:	6aa2                	ld	s5,8(sp)
    800041b0:	6b02                	ld	s6,0(sp)
    800041b2:	6121                	addi	sp,sp,64
    800041b4:	8082                	ret
    800041b6:	8082                	ret

00000000800041b8 <initlog>:
{
    800041b8:	7179                	addi	sp,sp,-48
    800041ba:	f406                	sd	ra,40(sp)
    800041bc:	f022                	sd	s0,32(sp)
    800041be:	ec26                	sd	s1,24(sp)
    800041c0:	e84a                	sd	s2,16(sp)
    800041c2:	e44e                	sd	s3,8(sp)
    800041c4:	e052                	sd	s4,0(sp)
    800041c6:	1800                	addi	s0,sp,48
    800041c8:	892a                	mv	s2,a0
    800041ca:	8a2e                	mv	s4,a1
  initlock(&log[dev].lock, "log");
    800041cc:	0b000713          	li	a4,176
    800041d0:	02e504b3          	mul	s1,a0,a4
    800041d4:	00024997          	auipc	s3,0x24
    800041d8:	20498993          	addi	s3,s3,516 # 800283d8 <log>
    800041dc:	99a6                	add	s3,s3,s1
    800041de:	00004597          	auipc	a1,0x4
    800041e2:	57258593          	addi	a1,a1,1394 # 80008750 <userret+0x6c0>
    800041e6:	854e                	mv	a0,s3
    800041e8:	ffffd097          	auipc	ra,0xffffd
    800041ec:	8f2080e7          	jalr	-1806(ra) # 80000ada <initlock>
  log[dev].start = sb->logstart;
    800041f0:	014a2583          	lw	a1,20(s4)
    800041f4:	02b9a023          	sw	a1,32(s3)
  log[dev].size = sb->nlog;
    800041f8:	010a2783          	lw	a5,16(s4)
    800041fc:	02f9a223          	sw	a5,36(s3)
  log[dev].dev = dev;
    80004200:	0329a823          	sw	s2,48(s3)
  struct buf *buf = bread(dev, log[dev].start);
    80004204:	854a                	mv	a0,s2
    80004206:	fffff097          	auipc	ra,0xfffff
    8000420a:	d8c080e7          	jalr	-628(ra) # 80002f92 <bread>
  log[dev].lh.n = lh->n;
    8000420e:	5134                	lw	a3,96(a0)
    80004210:	02d9aa23          	sw	a3,52(s3)
  for (i = 0; i < log[dev].lh.n; i++) {
    80004214:	02d05763          	blez	a3,80004242 <initlog+0x8a>
    80004218:	06450793          	addi	a5,a0,100
    8000421c:	00024717          	auipc	a4,0x24
    80004220:	1f470713          	addi	a4,a4,500 # 80028410 <log+0x38>
    80004224:	9726                	add	a4,a4,s1
    80004226:	36fd                	addiw	a3,a3,-1
    80004228:	02069613          	slli	a2,a3,0x20
    8000422c:	01e65693          	srli	a3,a2,0x1e
    80004230:	06850613          	addi	a2,a0,104
    80004234:	96b2                	add	a3,a3,a2
    log[dev].lh.block[i] = lh->block[i];
    80004236:	4390                	lw	a2,0(a5)
    80004238:	c310                	sw	a2,0(a4)
  for (i = 0; i < log[dev].lh.n; i++) {
    8000423a:	0791                	addi	a5,a5,4
    8000423c:	0711                	addi	a4,a4,4
    8000423e:	fed79ce3          	bne	a5,a3,80004236 <initlog+0x7e>
  brelse(buf);
    80004242:	fffff097          	auipc	ra,0xfffff
    80004246:	f44080e7          	jalr	-188(ra) # 80003186 <brelse>

static void
recover_from_log(int dev)
{
  read_head(dev);
  install_trans(dev); // if committed, copy from log to disk
    8000424a:	854a                	mv	a0,s2
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	ea0080e7          	jalr	-352(ra) # 800040ec <install_trans>
  log[dev].lh.n = 0;
    80004254:	0b000793          	li	a5,176
    80004258:	02f90733          	mul	a4,s2,a5
    8000425c:	00024797          	auipc	a5,0x24
    80004260:	17c78793          	addi	a5,a5,380 # 800283d8 <log>
    80004264:	97ba                	add	a5,a5,a4
    80004266:	0207aa23          	sw	zero,52(a5)
  write_head(dev); // clear the log
    8000426a:	854a                	mv	a0,s2
    8000426c:	00000097          	auipc	ra,0x0
    80004270:	df6080e7          	jalr	-522(ra) # 80004062 <write_head>
}
    80004274:	70a2                	ld	ra,40(sp)
    80004276:	7402                	ld	s0,32(sp)
    80004278:	64e2                	ld	s1,24(sp)
    8000427a:	6942                	ld	s2,16(sp)
    8000427c:	69a2                	ld	s3,8(sp)
    8000427e:	6a02                	ld	s4,0(sp)
    80004280:	6145                	addi	sp,sp,48
    80004282:	8082                	ret

0000000080004284 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(int dev)
{
    80004284:	7139                	addi	sp,sp,-64
    80004286:	fc06                	sd	ra,56(sp)
    80004288:	f822                	sd	s0,48(sp)
    8000428a:	f426                	sd	s1,40(sp)
    8000428c:	f04a                	sd	s2,32(sp)
    8000428e:	ec4e                	sd	s3,24(sp)
    80004290:	e852                	sd	s4,16(sp)
    80004292:	e456                	sd	s5,8(sp)
    80004294:	0080                	addi	s0,sp,64
    80004296:	8aaa                	mv	s5,a0
  acquire(&log[dev].lock);
    80004298:	0b000913          	li	s2,176
    8000429c:	032507b3          	mul	a5,a0,s2
    800042a0:	00024917          	auipc	s2,0x24
    800042a4:	13890913          	addi	s2,s2,312 # 800283d8 <log>
    800042a8:	993e                	add	s2,s2,a5
    800042aa:	854a                	mv	a0,s2
    800042ac:	ffffd097          	auipc	ra,0xffffd
    800042b0:	97c080e7          	jalr	-1668(ra) # 80000c28 <acquire>
  while(1){
    if(log[dev].committing){
    800042b4:	00024997          	auipc	s3,0x24
    800042b8:	12498993          	addi	s3,s3,292 # 800283d8 <log>
    800042bc:	84ca                	mv	s1,s2
      sleep(&log, &log[dev].lock);
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042be:	4a79                	li	s4,30
    800042c0:	a039                	j	800042ce <begin_op+0x4a>
      sleep(&log, &log[dev].lock);
    800042c2:	85ca                	mv	a1,s2
    800042c4:	854e                	mv	a0,s3
    800042c6:	ffffe097          	auipc	ra,0xffffe
    800042ca:	090080e7          	jalr	144(ra) # 80002356 <sleep>
    if(log[dev].committing){
    800042ce:	54dc                	lw	a5,44(s1)
    800042d0:	fbed                	bnez	a5,800042c2 <begin_op+0x3e>
    } else if(log[dev].lh.n + (log[dev].outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042d2:	549c                	lw	a5,40(s1)
    800042d4:	0017871b          	addiw	a4,a5,1
    800042d8:	0007069b          	sext.w	a3,a4
    800042dc:	0027179b          	slliw	a5,a4,0x2
    800042e0:	9fb9                	addw	a5,a5,a4
    800042e2:	0017979b          	slliw	a5,a5,0x1
    800042e6:	58d8                	lw	a4,52(s1)
    800042e8:	9fb9                	addw	a5,a5,a4
    800042ea:	00fa5963          	bge	s4,a5,800042fc <begin_op+0x78>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log[dev].lock);
    800042ee:	85ca                	mv	a1,s2
    800042f0:	854e                	mv	a0,s3
    800042f2:	ffffe097          	auipc	ra,0xffffe
    800042f6:	064080e7          	jalr	100(ra) # 80002356 <sleep>
    800042fa:	bfd1                	j	800042ce <begin_op+0x4a>
    } else {
      log[dev].outstanding += 1;
    800042fc:	0b000513          	li	a0,176
    80004300:	02aa8ab3          	mul	s5,s5,a0
    80004304:	00024797          	auipc	a5,0x24
    80004308:	0d478793          	addi	a5,a5,212 # 800283d8 <log>
    8000430c:	9abe                	add	s5,s5,a5
    8000430e:	02daa423          	sw	a3,40(s5)
      release(&log[dev].lock);
    80004312:	854a                	mv	a0,s2
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	984080e7          	jalr	-1660(ra) # 80000c98 <release>
      break;
    }
  }
}
    8000431c:	70e2                	ld	ra,56(sp)
    8000431e:	7442                	ld	s0,48(sp)
    80004320:	74a2                	ld	s1,40(sp)
    80004322:	7902                	ld	s2,32(sp)
    80004324:	69e2                	ld	s3,24(sp)
    80004326:	6a42                	ld	s4,16(sp)
    80004328:	6aa2                	ld	s5,8(sp)
    8000432a:	6121                	addi	sp,sp,64
    8000432c:	8082                	ret

000000008000432e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(int dev)
{
    8000432e:	715d                	addi	sp,sp,-80
    80004330:	e486                	sd	ra,72(sp)
    80004332:	e0a2                	sd	s0,64(sp)
    80004334:	fc26                	sd	s1,56(sp)
    80004336:	f84a                	sd	s2,48(sp)
    80004338:	f44e                	sd	s3,40(sp)
    8000433a:	f052                	sd	s4,32(sp)
    8000433c:	ec56                	sd	s5,24(sp)
    8000433e:	e85a                	sd	s6,16(sp)
    80004340:	e45e                	sd	s7,8(sp)
    80004342:	e062                	sd	s8,0(sp)
    80004344:	0880                	addi	s0,sp,80
    80004346:	89aa                	mv	s3,a0
  int do_commit = 0;

  acquire(&log[dev].lock);
    80004348:	0b000913          	li	s2,176
    8000434c:	03250933          	mul	s2,a0,s2
    80004350:	00024497          	auipc	s1,0x24
    80004354:	08848493          	addi	s1,s1,136 # 800283d8 <log>
    80004358:	94ca                	add	s1,s1,s2
    8000435a:	8526                	mv	a0,s1
    8000435c:	ffffd097          	auipc	ra,0xffffd
    80004360:	8cc080e7          	jalr	-1844(ra) # 80000c28 <acquire>
  log[dev].outstanding -= 1;
    80004364:	549c                	lw	a5,40(s1)
    80004366:	37fd                	addiw	a5,a5,-1
    80004368:	00078a9b          	sext.w	s5,a5
    8000436c:	d49c                	sw	a5,40(s1)
  if(log[dev].committing)
    8000436e:	54dc                	lw	a5,44(s1)
    80004370:	e3b5                	bnez	a5,800043d4 <end_op+0xa6>
    panic("log[dev].committing");
  if(log[dev].outstanding == 0){
    80004372:	060a9963          	bnez	s5,800043e4 <end_op+0xb6>
    do_commit = 1;
    log[dev].committing = 1;
    80004376:	0b000a13          	li	s4,176
    8000437a:	034987b3          	mul	a5,s3,s4
    8000437e:	00024a17          	auipc	s4,0x24
    80004382:	05aa0a13          	addi	s4,s4,90 # 800283d8 <log>
    80004386:	9a3e                	add	s4,s4,a5
    80004388:	4785                	li	a5,1
    8000438a:	02fa2623          	sw	a5,44(s4)
    // begin_op() may be waiting for log space,
    // and decrementing log[dev].outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log[dev].lock);
    8000438e:	8526                	mv	a0,s1
    80004390:	ffffd097          	auipc	ra,0xffffd
    80004394:	908080e7          	jalr	-1784(ra) # 80000c98 <release>
}

static void
commit(int dev)
{
  if (log[dev].lh.n > 0) {
    80004398:	034a2783          	lw	a5,52(s4)
    8000439c:	06f04d63          	bgtz	a5,80004416 <end_op+0xe8>
    acquire(&log[dev].lock);
    800043a0:	8526                	mv	a0,s1
    800043a2:	ffffd097          	auipc	ra,0xffffd
    800043a6:	886080e7          	jalr	-1914(ra) # 80000c28 <acquire>
    log[dev].committing = 0;
    800043aa:	00024517          	auipc	a0,0x24
    800043ae:	02e50513          	addi	a0,a0,46 # 800283d8 <log>
    800043b2:	0b000793          	li	a5,176
    800043b6:	02f989b3          	mul	s3,s3,a5
    800043ba:	99aa                	add	s3,s3,a0
    800043bc:	0209a623          	sw	zero,44(s3)
    wakeup(&log);
    800043c0:	ffffe097          	auipc	ra,0xffffe
    800043c4:	116080e7          	jalr	278(ra) # 800024d6 <wakeup>
    release(&log[dev].lock);
    800043c8:	8526                	mv	a0,s1
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	8ce080e7          	jalr	-1842(ra) # 80000c98 <release>
}
    800043d2:	a035                	j	800043fe <end_op+0xd0>
    panic("log[dev].committing");
    800043d4:	00004517          	auipc	a0,0x4
    800043d8:	38450513          	addi	a0,a0,900 # 80008758 <userret+0x6c8>
    800043dc:	ffffc097          	auipc	ra,0xffffc
    800043e0:	16c080e7          	jalr	364(ra) # 80000548 <panic>
    wakeup(&log);
    800043e4:	00024517          	auipc	a0,0x24
    800043e8:	ff450513          	addi	a0,a0,-12 # 800283d8 <log>
    800043ec:	ffffe097          	auipc	ra,0xffffe
    800043f0:	0ea080e7          	jalr	234(ra) # 800024d6 <wakeup>
  release(&log[dev].lock);
    800043f4:	8526                	mv	a0,s1
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	8a2080e7          	jalr	-1886(ra) # 80000c98 <release>
}
    800043fe:	60a6                	ld	ra,72(sp)
    80004400:	6406                	ld	s0,64(sp)
    80004402:	74e2                	ld	s1,56(sp)
    80004404:	7942                	ld	s2,48(sp)
    80004406:	79a2                	ld	s3,40(sp)
    80004408:	7a02                	ld	s4,32(sp)
    8000440a:	6ae2                	ld	s5,24(sp)
    8000440c:	6b42                	ld	s6,16(sp)
    8000440e:	6ba2                	ld	s7,8(sp)
    80004410:	6c02                	ld	s8,0(sp)
    80004412:	6161                	addi	sp,sp,80
    80004414:	8082                	ret
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    80004416:	00024797          	auipc	a5,0x24
    8000441a:	ffa78793          	addi	a5,a5,-6 # 80028410 <log+0x38>
    8000441e:	993e                	add	s2,s2,a5
    struct buf *to = bread(dev, log[dev].start+tail+1); // log block
    80004420:	00098c1b          	sext.w	s8,s3
    80004424:	0b000b93          	li	s7,176
    80004428:	037987b3          	mul	a5,s3,s7
    8000442c:	00024b97          	auipc	s7,0x24
    80004430:	facb8b93          	addi	s7,s7,-84 # 800283d8 <log>
    80004434:	9bbe                	add	s7,s7,a5
    80004436:	020ba583          	lw	a1,32(s7)
    8000443a:	015585bb          	addw	a1,a1,s5
    8000443e:	2585                	addiw	a1,a1,1
    80004440:	8562                	mv	a0,s8
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	b50080e7          	jalr	-1200(ra) # 80002f92 <bread>
    8000444a:	8a2a                	mv	s4,a0
    struct buf *from = bread(dev, log[dev].lh.block[tail]); // cache block
    8000444c:	00092583          	lw	a1,0(s2)
    80004450:	8562                	mv	a0,s8
    80004452:	fffff097          	auipc	ra,0xfffff
    80004456:	b40080e7          	jalr	-1216(ra) # 80002f92 <bread>
    8000445a:	8b2a                	mv	s6,a0
    memmove(to->data, from->data, BSIZE);
    8000445c:	40000613          	li	a2,1024
    80004460:	06050593          	addi	a1,a0,96
    80004464:	060a0513          	addi	a0,s4,96
    80004468:	ffffd097          	auipc	ra,0xffffd
    8000446c:	a8a080e7          	jalr	-1398(ra) # 80000ef2 <memmove>
    bwrite(to);  // write the log
    80004470:	8552                	mv	a0,s4
    80004472:	fffff097          	auipc	ra,0xfffff
    80004476:	cd4080e7          	jalr	-812(ra) # 80003146 <bwrite>
    brelse(from);
    8000447a:	855a                	mv	a0,s6
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	d0a080e7          	jalr	-758(ra) # 80003186 <brelse>
    brelse(to);
    80004484:	8552                	mv	a0,s4
    80004486:	fffff097          	auipc	ra,0xfffff
    8000448a:	d00080e7          	jalr	-768(ra) # 80003186 <brelse>
  for (tail = 0; tail < log[dev].lh.n; tail++) {
    8000448e:	2a85                	addiw	s5,s5,1
    80004490:	0911                	addi	s2,s2,4
    80004492:	034ba783          	lw	a5,52(s7)
    80004496:	fafac0e3          	blt	s5,a5,80004436 <end_op+0x108>
    write_log(dev);     // Write modified blocks from cache to log
    write_head(dev);    // Write header to disk -- the real commit
    8000449a:	854e                	mv	a0,s3
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	bc6080e7          	jalr	-1082(ra) # 80004062 <write_head>
    install_trans(dev); // Now install writes to home locations
    800044a4:	854e                	mv	a0,s3
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	c46080e7          	jalr	-954(ra) # 800040ec <install_trans>
    log[dev].lh.n = 0;
    800044ae:	0b000793          	li	a5,176
    800044b2:	02f98733          	mul	a4,s3,a5
    800044b6:	00024797          	auipc	a5,0x24
    800044ba:	f2278793          	addi	a5,a5,-222 # 800283d8 <log>
    800044be:	97ba                	add	a5,a5,a4
    800044c0:	0207aa23          	sw	zero,52(a5)
    write_head(dev);    // Erase the transaction from the log
    800044c4:	854e                	mv	a0,s3
    800044c6:	00000097          	auipc	ra,0x0
    800044ca:	b9c080e7          	jalr	-1124(ra) # 80004062 <write_head>
    800044ce:	bdc9                	j	800043a0 <end_op+0x72>

00000000800044d0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044d0:	7179                	addi	sp,sp,-48
    800044d2:	f406                	sd	ra,40(sp)
    800044d4:	f022                	sd	s0,32(sp)
    800044d6:	ec26                	sd	s1,24(sp)
    800044d8:	e84a                	sd	s2,16(sp)
    800044da:	e44e                	sd	s3,8(sp)
    800044dc:	e052                	sd	s4,0(sp)
    800044de:	1800                	addi	s0,sp,48
  int i;

  int dev = b->dev;
    800044e0:	00852903          	lw	s2,8(a0)
  if (log[dev].lh.n >= LOGSIZE || log[dev].lh.n >= log[dev].size - 1)
    800044e4:	0b000793          	li	a5,176
    800044e8:	02f90733          	mul	a4,s2,a5
    800044ec:	00024797          	auipc	a5,0x24
    800044f0:	eec78793          	addi	a5,a5,-276 # 800283d8 <log>
    800044f4:	97ba                	add	a5,a5,a4
    800044f6:	5bd4                	lw	a3,52(a5)
    800044f8:	47f5                	li	a5,29
    800044fa:	0ad7cc63          	blt	a5,a3,800045b2 <log_write+0xe2>
    800044fe:	89aa                	mv	s3,a0
    80004500:	00024797          	auipc	a5,0x24
    80004504:	ed878793          	addi	a5,a5,-296 # 800283d8 <log>
    80004508:	97ba                	add	a5,a5,a4
    8000450a:	53dc                	lw	a5,36(a5)
    8000450c:	37fd                	addiw	a5,a5,-1
    8000450e:	0af6d263          	bge	a3,a5,800045b2 <log_write+0xe2>
    panic("too big a transaction");
  if (log[dev].outstanding < 1)
    80004512:	0b000793          	li	a5,176
    80004516:	02f90733          	mul	a4,s2,a5
    8000451a:	00024797          	auipc	a5,0x24
    8000451e:	ebe78793          	addi	a5,a5,-322 # 800283d8 <log>
    80004522:	97ba                	add	a5,a5,a4
    80004524:	579c                	lw	a5,40(a5)
    80004526:	08f05e63          	blez	a5,800045c2 <log_write+0xf2>
    panic("log_write outside of trans");

  acquire(&log[dev].lock);
    8000452a:	0b000793          	li	a5,176
    8000452e:	02f904b3          	mul	s1,s2,a5
    80004532:	00024a17          	auipc	s4,0x24
    80004536:	ea6a0a13          	addi	s4,s4,-346 # 800283d8 <log>
    8000453a:	9a26                	add	s4,s4,s1
    8000453c:	8552                	mv	a0,s4
    8000453e:	ffffc097          	auipc	ra,0xffffc
    80004542:	6ea080e7          	jalr	1770(ra) # 80000c28 <acquire>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004546:	034a2603          	lw	a2,52(s4)
    8000454a:	08c05463          	blez	a2,800045d2 <log_write+0x102>
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000454e:	00c9a583          	lw	a1,12(s3)
    80004552:	00024797          	auipc	a5,0x24
    80004556:	ebe78793          	addi	a5,a5,-322 # 80028410 <log+0x38>
    8000455a:	97a6                	add	a5,a5,s1
  for (i = 0; i < log[dev].lh.n; i++) {
    8000455c:	4701                	li	a4,0
    if (log[dev].lh.block[i] == b->blockno)   // log absorbtion
    8000455e:	4394                	lw	a3,0(a5)
    80004560:	06b68a63          	beq	a3,a1,800045d4 <log_write+0x104>
  for (i = 0; i < log[dev].lh.n; i++) {
    80004564:	2705                	addiw	a4,a4,1
    80004566:	0791                	addi	a5,a5,4
    80004568:	fec71be3          	bne	a4,a2,8000455e <log_write+0x8e>
      break;
  }
  log[dev].lh.block[i] = b->blockno;
    8000456c:	02c00793          	li	a5,44
    80004570:	02f907b3          	mul	a5,s2,a5
    80004574:	97b2                	add	a5,a5,a2
    80004576:	07b1                	addi	a5,a5,12
    80004578:	078a                	slli	a5,a5,0x2
    8000457a:	00024717          	auipc	a4,0x24
    8000457e:	e5e70713          	addi	a4,a4,-418 # 800283d8 <log>
    80004582:	97ba                	add	a5,a5,a4
    80004584:	00c9a703          	lw	a4,12(s3)
    80004588:	c798                	sw	a4,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    bpin(b);
    8000458a:	854e                	mv	a0,s3
    8000458c:	fffff097          	auipc	ra,0xfffff
    80004590:	cbc080e7          	jalr	-836(ra) # 80003248 <bpin>
    log[dev].lh.n++;
    80004594:	0b000793          	li	a5,176
    80004598:	02f90933          	mul	s2,s2,a5
    8000459c:	00024797          	auipc	a5,0x24
    800045a0:	e3c78793          	addi	a5,a5,-452 # 800283d8 <log>
    800045a4:	993e                	add	s2,s2,a5
    800045a6:	03492783          	lw	a5,52(s2)
    800045aa:	2785                	addiw	a5,a5,1
    800045ac:	02f92a23          	sw	a5,52(s2)
    800045b0:	a099                	j	800045f6 <log_write+0x126>
    panic("too big a transaction");
    800045b2:	00004517          	auipc	a0,0x4
    800045b6:	1be50513          	addi	a0,a0,446 # 80008770 <userret+0x6e0>
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	f8e080e7          	jalr	-114(ra) # 80000548 <panic>
    panic("log_write outside of trans");
    800045c2:	00004517          	auipc	a0,0x4
    800045c6:	1c650513          	addi	a0,a0,454 # 80008788 <userret+0x6f8>
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	f7e080e7          	jalr	-130(ra) # 80000548 <panic>
  for (i = 0; i < log[dev].lh.n; i++) {
    800045d2:	4701                	li	a4,0
  log[dev].lh.block[i] = b->blockno;
    800045d4:	02c00793          	li	a5,44
    800045d8:	02f907b3          	mul	a5,s2,a5
    800045dc:	97ba                	add	a5,a5,a4
    800045de:	07b1                	addi	a5,a5,12
    800045e0:	078a                	slli	a5,a5,0x2
    800045e2:	00024697          	auipc	a3,0x24
    800045e6:	df668693          	addi	a3,a3,-522 # 800283d8 <log>
    800045ea:	97b6                	add	a5,a5,a3
    800045ec:	00c9a683          	lw	a3,12(s3)
    800045f0:	c794                	sw	a3,8(a5)
  if (i == log[dev].lh.n) {  // Add new block to log?
    800045f2:	f8e60ce3          	beq	a2,a4,8000458a <log_write+0xba>
  }
  release(&log[dev].lock);
    800045f6:	8552                	mv	a0,s4
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	6a0080e7          	jalr	1696(ra) # 80000c98 <release>
}
    80004600:	70a2                	ld	ra,40(sp)
    80004602:	7402                	ld	s0,32(sp)
    80004604:	64e2                	ld	s1,24(sp)
    80004606:	6942                	ld	s2,16(sp)
    80004608:	69a2                	ld	s3,8(sp)
    8000460a:	6a02                	ld	s4,0(sp)
    8000460c:	6145                	addi	sp,sp,48
    8000460e:	8082                	ret

0000000080004610 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004610:	1101                	addi	sp,sp,-32
    80004612:	ec06                	sd	ra,24(sp)
    80004614:	e822                	sd	s0,16(sp)
    80004616:	e426                	sd	s1,8(sp)
    80004618:	e04a                	sd	s2,0(sp)
    8000461a:	1000                	addi	s0,sp,32
    8000461c:	84aa                	mv	s1,a0
    8000461e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004620:	00004597          	auipc	a1,0x4
    80004624:	18858593          	addi	a1,a1,392 # 800087a8 <userret+0x718>
    80004628:	0521                	addi	a0,a0,8
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	4b0080e7          	jalr	1200(ra) # 80000ada <initlock>
  lk->name = name;
    80004632:	0324b423          	sd	s2,40(s1)
  lk->locked = 0;
    80004636:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000463a:	0204a823          	sw	zero,48(s1)
}
    8000463e:	60e2                	ld	ra,24(sp)
    80004640:	6442                	ld	s0,16(sp)
    80004642:	64a2                	ld	s1,8(sp)
    80004644:	6902                	ld	s2,0(sp)
    80004646:	6105                	addi	sp,sp,32
    80004648:	8082                	ret

000000008000464a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000464a:	1101                	addi	sp,sp,-32
    8000464c:	ec06                	sd	ra,24(sp)
    8000464e:	e822                	sd	s0,16(sp)
    80004650:	e426                	sd	s1,8(sp)
    80004652:	e04a                	sd	s2,0(sp)
    80004654:	1000                	addi	s0,sp,32
    80004656:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004658:	00850913          	addi	s2,a0,8
    8000465c:	854a                	mv	a0,s2
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	5ca080e7          	jalr	1482(ra) # 80000c28 <acquire>
  while (lk->locked) {
    80004666:	409c                	lw	a5,0(s1)
    80004668:	cb89                	beqz	a5,8000467a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000466a:	85ca                	mv	a1,s2
    8000466c:	8526                	mv	a0,s1
    8000466e:	ffffe097          	auipc	ra,0xffffe
    80004672:	ce8080e7          	jalr	-792(ra) # 80002356 <sleep>
  while (lk->locked) {
    80004676:	409c                	lw	a5,0(s1)
    80004678:	fbed                	bnez	a5,8000466a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000467a:	4785                	li	a5,1
    8000467c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000467e:	ffffd097          	auipc	ra,0xffffd
    80004682:	502080e7          	jalr	1282(ra) # 80001b80 <myproc>
    80004686:	413c                	lw	a5,64(a0)
    80004688:	d89c                	sw	a5,48(s1)
  release(&lk->lk);
    8000468a:	854a                	mv	a0,s2
    8000468c:	ffffc097          	auipc	ra,0xffffc
    80004690:	60c080e7          	jalr	1548(ra) # 80000c98 <release>
}
    80004694:	60e2                	ld	ra,24(sp)
    80004696:	6442                	ld	s0,16(sp)
    80004698:	64a2                	ld	s1,8(sp)
    8000469a:	6902                	ld	s2,0(sp)
    8000469c:	6105                	addi	sp,sp,32
    8000469e:	8082                	ret

00000000800046a0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046a0:	1101                	addi	sp,sp,-32
    800046a2:	ec06                	sd	ra,24(sp)
    800046a4:	e822                	sd	s0,16(sp)
    800046a6:	e426                	sd	s1,8(sp)
    800046a8:	e04a                	sd	s2,0(sp)
    800046aa:	1000                	addi	s0,sp,32
    800046ac:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ae:	00850913          	addi	s2,a0,8
    800046b2:	854a                	mv	a0,s2
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	574080e7          	jalr	1396(ra) # 80000c28 <acquire>
  lk->locked = 0;
    800046bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046c0:	0204a823          	sw	zero,48(s1)
  wakeup(lk);
    800046c4:	8526                	mv	a0,s1
    800046c6:	ffffe097          	auipc	ra,0xffffe
    800046ca:	e10080e7          	jalr	-496(ra) # 800024d6 <wakeup>
  release(&lk->lk);
    800046ce:	854a                	mv	a0,s2
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	5c8080e7          	jalr	1480(ra) # 80000c98 <release>
}
    800046d8:	60e2                	ld	ra,24(sp)
    800046da:	6442                	ld	s0,16(sp)
    800046dc:	64a2                	ld	s1,8(sp)
    800046de:	6902                	ld	s2,0(sp)
    800046e0:	6105                	addi	sp,sp,32
    800046e2:	8082                	ret

00000000800046e4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046e4:	7179                	addi	sp,sp,-48
    800046e6:	f406                	sd	ra,40(sp)
    800046e8:	f022                	sd	s0,32(sp)
    800046ea:	ec26                	sd	s1,24(sp)
    800046ec:	e84a                	sd	s2,16(sp)
    800046ee:	e44e                	sd	s3,8(sp)
    800046f0:	1800                	addi	s0,sp,48
    800046f2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046f4:	00850913          	addi	s2,a0,8
    800046f8:	854a                	mv	a0,s2
    800046fa:	ffffc097          	auipc	ra,0xffffc
    800046fe:	52e080e7          	jalr	1326(ra) # 80000c28 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004702:	409c                	lw	a5,0(s1)
    80004704:	ef99                	bnez	a5,80004722 <holdingsleep+0x3e>
    80004706:	4481                	li	s1,0
  release(&lk->lk);
    80004708:	854a                	mv	a0,s2
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	58e080e7          	jalr	1422(ra) # 80000c98 <release>
  return r;
}
    80004712:	8526                	mv	a0,s1
    80004714:	70a2                	ld	ra,40(sp)
    80004716:	7402                	ld	s0,32(sp)
    80004718:	64e2                	ld	s1,24(sp)
    8000471a:	6942                	ld	s2,16(sp)
    8000471c:	69a2                	ld	s3,8(sp)
    8000471e:	6145                	addi	sp,sp,48
    80004720:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004722:	0304a983          	lw	s3,48(s1)
    80004726:	ffffd097          	auipc	ra,0xffffd
    8000472a:	45a080e7          	jalr	1114(ra) # 80001b80 <myproc>
    8000472e:	4124                	lw	s1,64(a0)
    80004730:	413484b3          	sub	s1,s1,s3
    80004734:	0014b493          	seqz	s1,s1
    80004738:	bfc1                	j	80004708 <holdingsleep+0x24>

000000008000473a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000473a:	1141                	addi	sp,sp,-16
    8000473c:	e406                	sd	ra,8(sp)
    8000473e:	e022                	sd	s0,0(sp)
    80004740:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004742:	00004597          	auipc	a1,0x4
    80004746:	07658593          	addi	a1,a1,118 # 800087b8 <userret+0x728>
    8000474a:	00024517          	auipc	a0,0x24
    8000474e:	e8e50513          	addi	a0,a0,-370 # 800285d8 <ftable>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	388080e7          	jalr	904(ra) # 80000ada <initlock>
}
    8000475a:	60a2                	ld	ra,8(sp)
    8000475c:	6402                	ld	s0,0(sp)
    8000475e:	0141                	addi	sp,sp,16
    80004760:	8082                	ret

0000000080004762 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004762:	1101                	addi	sp,sp,-32
    80004764:	ec06                	sd	ra,24(sp)
    80004766:	e822                	sd	s0,16(sp)
    80004768:	e426                	sd	s1,8(sp)
    8000476a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000476c:	00024517          	auipc	a0,0x24
    80004770:	e6c50513          	addi	a0,a0,-404 # 800285d8 <ftable>
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	4b4080e7          	jalr	1204(ra) # 80000c28 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000477c:	00024497          	auipc	s1,0x24
    80004780:	e7c48493          	addi	s1,s1,-388 # 800285f8 <ftable+0x20>
    80004784:	00025717          	auipc	a4,0x25
    80004788:	e1470713          	addi	a4,a4,-492 # 80029598 <ftable+0xfc0>
    if(f->ref == 0){
    8000478c:	40dc                	lw	a5,4(s1)
    8000478e:	cf99                	beqz	a5,800047ac <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004790:	02848493          	addi	s1,s1,40
    80004794:	fee49ce3          	bne	s1,a4,8000478c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004798:	00024517          	auipc	a0,0x24
    8000479c:	e4050513          	addi	a0,a0,-448 # 800285d8 <ftable>
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	4f8080e7          	jalr	1272(ra) # 80000c98 <release>
  return 0;
    800047a8:	4481                	li	s1,0
    800047aa:	a819                	j	800047c0 <filealloc+0x5e>
      f->ref = 1;
    800047ac:	4785                	li	a5,1
    800047ae:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047b0:	00024517          	auipc	a0,0x24
    800047b4:	e2850513          	addi	a0,a0,-472 # 800285d8 <ftable>
    800047b8:	ffffc097          	auipc	ra,0xffffc
    800047bc:	4e0080e7          	jalr	1248(ra) # 80000c98 <release>
}
    800047c0:	8526                	mv	a0,s1
    800047c2:	60e2                	ld	ra,24(sp)
    800047c4:	6442                	ld	s0,16(sp)
    800047c6:	64a2                	ld	s1,8(sp)
    800047c8:	6105                	addi	sp,sp,32
    800047ca:	8082                	ret

00000000800047cc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047cc:	1101                	addi	sp,sp,-32
    800047ce:	ec06                	sd	ra,24(sp)
    800047d0:	e822                	sd	s0,16(sp)
    800047d2:	e426                	sd	s1,8(sp)
    800047d4:	1000                	addi	s0,sp,32
    800047d6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047d8:	00024517          	auipc	a0,0x24
    800047dc:	e0050513          	addi	a0,a0,-512 # 800285d8 <ftable>
    800047e0:	ffffc097          	auipc	ra,0xffffc
    800047e4:	448080e7          	jalr	1096(ra) # 80000c28 <acquire>
  if(f->ref < 1)
    800047e8:	40dc                	lw	a5,4(s1)
    800047ea:	02f05263          	blez	a5,8000480e <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047ee:	2785                	addiw	a5,a5,1
    800047f0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047f2:	00024517          	auipc	a0,0x24
    800047f6:	de650513          	addi	a0,a0,-538 # 800285d8 <ftable>
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	49e080e7          	jalr	1182(ra) # 80000c98 <release>
  return f;
}
    80004802:	8526                	mv	a0,s1
    80004804:	60e2                	ld	ra,24(sp)
    80004806:	6442                	ld	s0,16(sp)
    80004808:	64a2                	ld	s1,8(sp)
    8000480a:	6105                	addi	sp,sp,32
    8000480c:	8082                	ret
    panic("filedup");
    8000480e:	00004517          	auipc	a0,0x4
    80004812:	fb250513          	addi	a0,a0,-78 # 800087c0 <userret+0x730>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	d32080e7          	jalr	-718(ra) # 80000548 <panic>

000000008000481e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000481e:	7139                	addi	sp,sp,-64
    80004820:	fc06                	sd	ra,56(sp)
    80004822:	f822                	sd	s0,48(sp)
    80004824:	f426                	sd	s1,40(sp)
    80004826:	f04a                	sd	s2,32(sp)
    80004828:	ec4e                	sd	s3,24(sp)
    8000482a:	e852                	sd	s4,16(sp)
    8000482c:	e456                	sd	s5,8(sp)
    8000482e:	0080                	addi	s0,sp,64
    80004830:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004832:	00024517          	auipc	a0,0x24
    80004836:	da650513          	addi	a0,a0,-602 # 800285d8 <ftable>
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	3ee080e7          	jalr	1006(ra) # 80000c28 <acquire>
  if(f->ref < 1)
    80004842:	40dc                	lw	a5,4(s1)
    80004844:	06f05563          	blez	a5,800048ae <fileclose+0x90>
    panic("fileclose");
  if(--f->ref > 0){
    80004848:	37fd                	addiw	a5,a5,-1
    8000484a:	0007871b          	sext.w	a4,a5
    8000484e:	c0dc                	sw	a5,4(s1)
    80004850:	06e04763          	bgtz	a4,800048be <fileclose+0xa0>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004854:	0004a903          	lw	s2,0(s1)
    80004858:	0094ca83          	lbu	s5,9(s1)
    8000485c:	0104ba03          	ld	s4,16(s1)
    80004860:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004864:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004868:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000486c:	00024517          	auipc	a0,0x24
    80004870:	d6c50513          	addi	a0,a0,-660 # 800285d8 <ftable>
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	424080e7          	jalr	1060(ra) # 80000c98 <release>

  if(ff.type == FD_PIPE){
    8000487c:	4785                	li	a5,1
    8000487e:	06f90163          	beq	s2,a5,800048e0 <fileclose+0xc2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004882:	3979                	addiw	s2,s2,-2
    80004884:	4785                	li	a5,1
    80004886:	0527e463          	bltu	a5,s2,800048ce <fileclose+0xb0>
    begin_op(ff.ip->dev);
    8000488a:	0009a503          	lw	a0,0(s3)
    8000488e:	00000097          	auipc	ra,0x0
    80004892:	9f6080e7          	jalr	-1546(ra) # 80004284 <begin_op>
    iput(ff.ip);
    80004896:	854e                	mv	a0,s3
    80004898:	fffff097          	auipc	ra,0xfffff
    8000489c:	114080e7          	jalr	276(ra) # 800039ac <iput>
    end_op(ff.ip->dev);
    800048a0:	0009a503          	lw	a0,0(s3)
    800048a4:	00000097          	auipc	ra,0x0
    800048a8:	a8a080e7          	jalr	-1398(ra) # 8000432e <end_op>
    800048ac:	a00d                	j	800048ce <fileclose+0xb0>
    panic("fileclose");
    800048ae:	00004517          	auipc	a0,0x4
    800048b2:	f1a50513          	addi	a0,a0,-230 # 800087c8 <userret+0x738>
    800048b6:	ffffc097          	auipc	ra,0xffffc
    800048ba:	c92080e7          	jalr	-878(ra) # 80000548 <panic>
    release(&ftable.lock);
    800048be:	00024517          	auipc	a0,0x24
    800048c2:	d1a50513          	addi	a0,a0,-742 # 800285d8 <ftable>
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	3d2080e7          	jalr	978(ra) # 80000c98 <release>
  }
}
    800048ce:	70e2                	ld	ra,56(sp)
    800048d0:	7442                	ld	s0,48(sp)
    800048d2:	74a2                	ld	s1,40(sp)
    800048d4:	7902                	ld	s2,32(sp)
    800048d6:	69e2                	ld	s3,24(sp)
    800048d8:	6a42                	ld	s4,16(sp)
    800048da:	6aa2                	ld	s5,8(sp)
    800048dc:	6121                	addi	sp,sp,64
    800048de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048e0:	85d6                	mv	a1,s5
    800048e2:	8552                	mv	a0,s4
    800048e4:	00000097          	auipc	ra,0x0
    800048e8:	376080e7          	jalr	886(ra) # 80004c5a <pipeclose>
    800048ec:	b7cd                	j	800048ce <fileclose+0xb0>

00000000800048ee <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ee:	715d                	addi	sp,sp,-80
    800048f0:	e486                	sd	ra,72(sp)
    800048f2:	e0a2                	sd	s0,64(sp)
    800048f4:	fc26                	sd	s1,56(sp)
    800048f6:	f84a                	sd	s2,48(sp)
    800048f8:	f44e                	sd	s3,40(sp)
    800048fa:	0880                	addi	s0,sp,80
    800048fc:	84aa                	mv	s1,a0
    800048fe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004900:	ffffd097          	auipc	ra,0xffffd
    80004904:	280080e7          	jalr	640(ra) # 80001b80 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004908:	409c                	lw	a5,0(s1)
    8000490a:	37f9                	addiw	a5,a5,-2
    8000490c:	4705                	li	a4,1
    8000490e:	04f76763          	bltu	a4,a5,8000495c <filestat+0x6e>
    80004912:	892a                	mv	s2,a0
    ilock(f->ip);
    80004914:	6c88                	ld	a0,24(s1)
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	f88080e7          	jalr	-120(ra) # 8000389e <ilock>
    stati(f->ip, &st);
    8000491e:	fb840593          	addi	a1,s0,-72
    80004922:	6c88                	ld	a0,24(s1)
    80004924:	fffff097          	auipc	ra,0xfffff
    80004928:	1e0080e7          	jalr	480(ra) # 80003b04 <stati>
    iunlock(f->ip);
    8000492c:	6c88                	ld	a0,24(s1)
    8000492e:	fffff097          	auipc	ra,0xfffff
    80004932:	032080e7          	jalr	50(ra) # 80003960 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004936:	46e1                	li	a3,24
    80004938:	fb840613          	addi	a2,s0,-72
    8000493c:	85ce                	mv	a1,s3
    8000493e:	05893503          	ld	a0,88(s2)
    80004942:	ffffd097          	auipc	ra,0xffffd
    80004946:	f30080e7          	jalr	-208(ra) # 80001872 <copyout>
    8000494a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000494e:	60a6                	ld	ra,72(sp)
    80004950:	6406                	ld	s0,64(sp)
    80004952:	74e2                	ld	s1,56(sp)
    80004954:	7942                	ld	s2,48(sp)
    80004956:	79a2                	ld	s3,40(sp)
    80004958:	6161                	addi	sp,sp,80
    8000495a:	8082                	ret
  return -1;
    8000495c:	557d                	li	a0,-1
    8000495e:	bfc5                	j	8000494e <filestat+0x60>

0000000080004960 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004960:	7179                	addi	sp,sp,-48
    80004962:	f406                	sd	ra,40(sp)
    80004964:	f022                	sd	s0,32(sp)
    80004966:	ec26                	sd	s1,24(sp)
    80004968:	e84a                	sd	s2,16(sp)
    8000496a:	e44e                	sd	s3,8(sp)
    8000496c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000496e:	00854783          	lbu	a5,8(a0)
    80004972:	c7c5                	beqz	a5,80004a1a <fileread+0xba>
    80004974:	84aa                	mv	s1,a0
    80004976:	89ae                	mv	s3,a1
    80004978:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000497a:	411c                	lw	a5,0(a0)
    8000497c:	4705                	li	a4,1
    8000497e:	04e78963          	beq	a5,a4,800049d0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004982:	470d                	li	a4,3
    80004984:	04e78d63          	beq	a5,a4,800049de <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004988:	4709                	li	a4,2
    8000498a:	08e79063          	bne	a5,a4,80004a0a <fileread+0xaa>
    ilock(f->ip);
    8000498e:	6d08                	ld	a0,24(a0)
    80004990:	fffff097          	auipc	ra,0xfffff
    80004994:	f0e080e7          	jalr	-242(ra) # 8000389e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004998:	874a                	mv	a4,s2
    8000499a:	5094                	lw	a3,32(s1)
    8000499c:	864e                	mv	a2,s3
    8000499e:	4585                	li	a1,1
    800049a0:	6c88                	ld	a0,24(s1)
    800049a2:	fffff097          	auipc	ra,0xfffff
    800049a6:	18c080e7          	jalr	396(ra) # 80003b2e <readi>
    800049aa:	892a                	mv	s2,a0
    800049ac:	00a05563          	blez	a0,800049b6 <fileread+0x56>
      f->off += r;
    800049b0:	509c                	lw	a5,32(s1)
    800049b2:	9fa9                	addw	a5,a5,a0
    800049b4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049b6:	6c88                	ld	a0,24(s1)
    800049b8:	fffff097          	auipc	ra,0xfffff
    800049bc:	fa8080e7          	jalr	-88(ra) # 80003960 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049c0:	854a                	mv	a0,s2
    800049c2:	70a2                	ld	ra,40(sp)
    800049c4:	7402                	ld	s0,32(sp)
    800049c6:	64e2                	ld	s1,24(sp)
    800049c8:	6942                	ld	s2,16(sp)
    800049ca:	69a2                	ld	s3,8(sp)
    800049cc:	6145                	addi	sp,sp,48
    800049ce:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049d0:	6908                	ld	a0,16(a0)
    800049d2:	00000097          	auipc	ra,0x0
    800049d6:	406080e7          	jalr	1030(ra) # 80004dd8 <piperead>
    800049da:	892a                	mv	s2,a0
    800049dc:	b7d5                	j	800049c0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049de:	02451783          	lh	a5,36(a0)
    800049e2:	03079693          	slli	a3,a5,0x30
    800049e6:	92c1                	srli	a3,a3,0x30
    800049e8:	4725                	li	a4,9
    800049ea:	02d76a63          	bltu	a4,a3,80004a1e <fileread+0xbe>
    800049ee:	0792                	slli	a5,a5,0x4
    800049f0:	00024717          	auipc	a4,0x24
    800049f4:	b4870713          	addi	a4,a4,-1208 # 80028538 <devsw>
    800049f8:	97ba                	add	a5,a5,a4
    800049fa:	639c                	ld	a5,0(a5)
    800049fc:	c39d                	beqz	a5,80004a22 <fileread+0xc2>
    r = devsw[f->major].read(f, 1, addr, n);
    800049fe:	86b2                	mv	a3,a2
    80004a00:	862e                	mv	a2,a1
    80004a02:	4585                	li	a1,1
    80004a04:	9782                	jalr	a5
    80004a06:	892a                	mv	s2,a0
    80004a08:	bf65                	j	800049c0 <fileread+0x60>
    panic("fileread");
    80004a0a:	00004517          	auipc	a0,0x4
    80004a0e:	dce50513          	addi	a0,a0,-562 # 800087d8 <userret+0x748>
    80004a12:	ffffc097          	auipc	ra,0xffffc
    80004a16:	b36080e7          	jalr	-1226(ra) # 80000548 <panic>
    return -1;
    80004a1a:	597d                	li	s2,-1
    80004a1c:	b755                	j	800049c0 <fileread+0x60>
      return -1;
    80004a1e:	597d                	li	s2,-1
    80004a20:	b745                	j	800049c0 <fileread+0x60>
    80004a22:	597d                	li	s2,-1
    80004a24:	bf71                	j	800049c0 <fileread+0x60>

0000000080004a26 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a26:	00954783          	lbu	a5,9(a0)
    80004a2a:	14078663          	beqz	a5,80004b76 <filewrite+0x150>
{
    80004a2e:	715d                	addi	sp,sp,-80
    80004a30:	e486                	sd	ra,72(sp)
    80004a32:	e0a2                	sd	s0,64(sp)
    80004a34:	fc26                	sd	s1,56(sp)
    80004a36:	f84a                	sd	s2,48(sp)
    80004a38:	f44e                	sd	s3,40(sp)
    80004a3a:	f052                	sd	s4,32(sp)
    80004a3c:	ec56                	sd	s5,24(sp)
    80004a3e:	e85a                	sd	s6,16(sp)
    80004a40:	e45e                	sd	s7,8(sp)
    80004a42:	e062                	sd	s8,0(sp)
    80004a44:	0880                	addi	s0,sp,80
    80004a46:	84aa                	mv	s1,a0
    80004a48:	8aae                	mv	s5,a1
    80004a4a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a4c:	411c                	lw	a5,0(a0)
    80004a4e:	4705                	li	a4,1
    80004a50:	02e78263          	beq	a5,a4,80004a74 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a54:	470d                	li	a4,3
    80004a56:	02e78563          	beq	a5,a4,80004a80 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(f, 1, addr, n);
  } else if(f->type == FD_INODE){
    80004a5a:	4709                	li	a4,2
    80004a5c:	10e79563          	bne	a5,a4,80004b66 <filewrite+0x140>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a60:	0ec05f63          	blez	a2,80004b5e <filewrite+0x138>
    int i = 0;
    80004a64:	4981                	li	s3,0
    80004a66:	6b05                	lui	s6,0x1
    80004a68:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a6c:	6b85                	lui	s7,0x1
    80004a6e:	c00b8b9b          	addiw	s7,s7,-1024
    80004a72:	a851                	j	80004b06 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004a74:	6908                	ld	a0,16(a0)
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	254080e7          	jalr	596(ra) # 80004cca <pipewrite>
    80004a7e:	a865                	j	80004b36 <filewrite+0x110>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a80:	02451783          	lh	a5,36(a0)
    80004a84:	03079693          	slli	a3,a5,0x30
    80004a88:	92c1                	srli	a3,a3,0x30
    80004a8a:	4725                	li	a4,9
    80004a8c:	0ed76763          	bltu	a4,a3,80004b7a <filewrite+0x154>
    80004a90:	0792                	slli	a5,a5,0x4
    80004a92:	00024717          	auipc	a4,0x24
    80004a96:	aa670713          	addi	a4,a4,-1370 # 80028538 <devsw>
    80004a9a:	97ba                	add	a5,a5,a4
    80004a9c:	679c                	ld	a5,8(a5)
    80004a9e:	c3e5                	beqz	a5,80004b7e <filewrite+0x158>
    ret = devsw[f->major].write(f, 1, addr, n);
    80004aa0:	86b2                	mv	a3,a2
    80004aa2:	862e                	mv	a2,a1
    80004aa4:	4585                	li	a1,1
    80004aa6:	9782                	jalr	a5
    80004aa8:	a079                	j	80004b36 <filewrite+0x110>
    80004aaa:	00090c1b          	sext.w	s8,s2
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op(f->ip->dev);
    80004aae:	6c9c                	ld	a5,24(s1)
    80004ab0:	4388                	lw	a0,0(a5)
    80004ab2:	fffff097          	auipc	ra,0xfffff
    80004ab6:	7d2080e7          	jalr	2002(ra) # 80004284 <begin_op>
      ilock(f->ip);
    80004aba:	6c88                	ld	a0,24(s1)
    80004abc:	fffff097          	auipc	ra,0xfffff
    80004ac0:	de2080e7          	jalr	-542(ra) # 8000389e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ac4:	8762                	mv	a4,s8
    80004ac6:	5094                	lw	a3,32(s1)
    80004ac8:	01598633          	add	a2,s3,s5
    80004acc:	4585                	li	a1,1
    80004ace:	6c88                	ld	a0,24(s1)
    80004ad0:	fffff097          	auipc	ra,0xfffff
    80004ad4:	152080e7          	jalr	338(ra) # 80003c22 <writei>
    80004ad8:	892a                	mv	s2,a0
    80004ada:	02a05e63          	blez	a0,80004b16 <filewrite+0xf0>
        f->off += r;
    80004ade:	509c                	lw	a5,32(s1)
    80004ae0:	9fa9                	addw	a5,a5,a0
    80004ae2:	d09c                	sw	a5,32(s1)
      iunlock(f->ip);
    80004ae4:	6c88                	ld	a0,24(s1)
    80004ae6:	fffff097          	auipc	ra,0xfffff
    80004aea:	e7a080e7          	jalr	-390(ra) # 80003960 <iunlock>
      end_op(f->ip->dev);
    80004aee:	6c9c                	ld	a5,24(s1)
    80004af0:	4388                	lw	a0,0(a5)
    80004af2:	00000097          	auipc	ra,0x0
    80004af6:	83c080e7          	jalr	-1988(ra) # 8000432e <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004afa:	052c1a63          	bne	s8,s2,80004b4e <filewrite+0x128>
        panic("short filewrite");
      i += r;
    80004afe:	013909bb          	addw	s3,s2,s3
    while(i < n){
    80004b02:	0349d763          	bge	s3,s4,80004b30 <filewrite+0x10a>
      int n1 = n - i;
    80004b06:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004b0a:	893e                	mv	s2,a5
    80004b0c:	2781                	sext.w	a5,a5
    80004b0e:	f8fb5ee3          	bge	s6,a5,80004aaa <filewrite+0x84>
    80004b12:	895e                	mv	s2,s7
    80004b14:	bf59                	j	80004aaa <filewrite+0x84>
      iunlock(f->ip);
    80004b16:	6c88                	ld	a0,24(s1)
    80004b18:	fffff097          	auipc	ra,0xfffff
    80004b1c:	e48080e7          	jalr	-440(ra) # 80003960 <iunlock>
      end_op(f->ip->dev);
    80004b20:	6c9c                	ld	a5,24(s1)
    80004b22:	4388                	lw	a0,0(a5)
    80004b24:	00000097          	auipc	ra,0x0
    80004b28:	80a080e7          	jalr	-2038(ra) # 8000432e <end_op>
      if(r < 0)
    80004b2c:	fc0957e3          	bgez	s2,80004afa <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004b30:	8552                	mv	a0,s4
    80004b32:	033a1863          	bne	s4,s3,80004b62 <filewrite+0x13c>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b36:	60a6                	ld	ra,72(sp)
    80004b38:	6406                	ld	s0,64(sp)
    80004b3a:	74e2                	ld	s1,56(sp)
    80004b3c:	7942                	ld	s2,48(sp)
    80004b3e:	79a2                	ld	s3,40(sp)
    80004b40:	7a02                	ld	s4,32(sp)
    80004b42:	6ae2                	ld	s5,24(sp)
    80004b44:	6b42                	ld	s6,16(sp)
    80004b46:	6ba2                	ld	s7,8(sp)
    80004b48:	6c02                	ld	s8,0(sp)
    80004b4a:	6161                	addi	sp,sp,80
    80004b4c:	8082                	ret
        panic("short filewrite");
    80004b4e:	00004517          	auipc	a0,0x4
    80004b52:	c9a50513          	addi	a0,a0,-870 # 800087e8 <userret+0x758>
    80004b56:	ffffc097          	auipc	ra,0xffffc
    80004b5a:	9f2080e7          	jalr	-1550(ra) # 80000548 <panic>
    int i = 0;
    80004b5e:	4981                	li	s3,0
    80004b60:	bfc1                	j	80004b30 <filewrite+0x10a>
    ret = (i == n ? n : -1);
    80004b62:	557d                	li	a0,-1
    80004b64:	bfc9                	j	80004b36 <filewrite+0x110>
    panic("filewrite");
    80004b66:	00004517          	auipc	a0,0x4
    80004b6a:	c9250513          	addi	a0,a0,-878 # 800087f8 <userret+0x768>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	9da080e7          	jalr	-1574(ra) # 80000548 <panic>
    return -1;
    80004b76:	557d                	li	a0,-1
}
    80004b78:	8082                	ret
      return -1;
    80004b7a:	557d                	li	a0,-1
    80004b7c:	bf6d                	j	80004b36 <filewrite+0x110>
    80004b7e:	557d                	li	a0,-1
    80004b80:	bf5d                	j	80004b36 <filewrite+0x110>

0000000080004b82 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b82:	7179                	addi	sp,sp,-48
    80004b84:	f406                	sd	ra,40(sp)
    80004b86:	f022                	sd	s0,32(sp)
    80004b88:	ec26                	sd	s1,24(sp)
    80004b8a:	e84a                	sd	s2,16(sp)
    80004b8c:	e44e                	sd	s3,8(sp)
    80004b8e:	e052                	sd	s4,0(sp)
    80004b90:	1800                	addi	s0,sp,48
    80004b92:	84aa                	mv	s1,a0
    80004b94:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b96:	0005b023          	sd	zero,0(a1)
    80004b9a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b9e:	00000097          	auipc	ra,0x0
    80004ba2:	bc4080e7          	jalr	-1084(ra) # 80004762 <filealloc>
    80004ba6:	e088                	sd	a0,0(s1)
    80004ba8:	c549                	beqz	a0,80004c32 <pipealloc+0xb0>
    80004baa:	00000097          	auipc	ra,0x0
    80004bae:	bb8080e7          	jalr	-1096(ra) # 80004762 <filealloc>
    80004bb2:	00aa3023          	sd	a0,0(s4)
    80004bb6:	c925                	beqz	a0,80004c26 <pipealloc+0xa4>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	e9a080e7          	jalr	-358(ra) # 80000a52 <kalloc>
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	cd39                	beqz	a0,80004c20 <pipealloc+0x9e>
    goto bad;
  pi->readopen = 1;
    80004bc4:	4985                	li	s3,1
    80004bc6:	23352423          	sw	s3,552(a0)
  pi->writeopen = 1;
    80004bca:	23352623          	sw	s3,556(a0)
  pi->nwrite = 0;
    80004bce:	22052223          	sw	zero,548(a0)
  pi->nread = 0;
    80004bd2:	22052023          	sw	zero,544(a0)
  memset(&pi->lock, 0, sizeof(pi->lock));
    80004bd6:	02000613          	li	a2,32
    80004bda:	4581                	li	a1,0
    80004bdc:	ffffc097          	auipc	ra,0xffffc
    80004be0:	2ba080e7          	jalr	698(ra) # 80000e96 <memset>
  (*f0)->type = FD_PIPE;
    80004be4:	609c                	ld	a5,0(s1)
    80004be6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004bea:	609c                	ld	a5,0(s1)
    80004bec:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bf0:	609c                	ld	a5,0(s1)
    80004bf2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bf6:	609c                	ld	a5,0(s1)
    80004bf8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bfc:	000a3783          	ld	a5,0(s4)
    80004c00:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c04:	000a3783          	ld	a5,0(s4)
    80004c08:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c0c:	000a3783          	ld	a5,0(s4)
    80004c10:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c14:	000a3783          	ld	a5,0(s4)
    80004c18:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c1c:	4501                	li	a0,0
    80004c1e:	a025                	j	80004c46 <pipealloc+0xc4>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c20:	6088                	ld	a0,0(s1)
    80004c22:	e501                	bnez	a0,80004c2a <pipealloc+0xa8>
    80004c24:	a039                	j	80004c32 <pipealloc+0xb0>
    80004c26:	6088                	ld	a0,0(s1)
    80004c28:	c51d                	beqz	a0,80004c56 <pipealloc+0xd4>
    fileclose(*f0);
    80004c2a:	00000097          	auipc	ra,0x0
    80004c2e:	bf4080e7          	jalr	-1036(ra) # 8000481e <fileclose>
  if(*f1)
    80004c32:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004c36:	557d                	li	a0,-1
  if(*f1)
    80004c38:	c799                	beqz	a5,80004c46 <pipealloc+0xc4>
    fileclose(*f1);
    80004c3a:	853e                	mv	a0,a5
    80004c3c:	00000097          	auipc	ra,0x0
    80004c40:	be2080e7          	jalr	-1054(ra) # 8000481e <fileclose>
  return -1;
    80004c44:	557d                	li	a0,-1
}
    80004c46:	70a2                	ld	ra,40(sp)
    80004c48:	7402                	ld	s0,32(sp)
    80004c4a:	64e2                	ld	s1,24(sp)
    80004c4c:	6942                	ld	s2,16(sp)
    80004c4e:	69a2                	ld	s3,8(sp)
    80004c50:	6a02                	ld	s4,0(sp)
    80004c52:	6145                	addi	sp,sp,48
    80004c54:	8082                	ret
  return -1;
    80004c56:	557d                	li	a0,-1
    80004c58:	b7fd                	j	80004c46 <pipealloc+0xc4>

0000000080004c5a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c5a:	1101                	addi	sp,sp,-32
    80004c5c:	ec06                	sd	ra,24(sp)
    80004c5e:	e822                	sd	s0,16(sp)
    80004c60:	e426                	sd	s1,8(sp)
    80004c62:	e04a                	sd	s2,0(sp)
    80004c64:	1000                	addi	s0,sp,32
    80004c66:	84aa                	mv	s1,a0
    80004c68:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	fbe080e7          	jalr	-66(ra) # 80000c28 <acquire>
  if(writable){
    80004c72:	02090d63          	beqz	s2,80004cac <pipeclose+0x52>
    pi->writeopen = 0;
    80004c76:	2204a623          	sw	zero,556(s1)
    wakeup(&pi->nread);
    80004c7a:	22048513          	addi	a0,s1,544
    80004c7e:	ffffe097          	auipc	ra,0xffffe
    80004c82:	858080e7          	jalr	-1960(ra) # 800024d6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c86:	2284b783          	ld	a5,552(s1)
    80004c8a:	eb95                	bnez	a5,80004cbe <pipeclose+0x64>
    release(&pi->lock);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	ffffc097          	auipc	ra,0xffffc
    80004c92:	00a080e7          	jalr	10(ra) # 80000c98 <release>
    kfree((char*)pi);
    80004c96:	8526                	mv	a0,s1
    80004c98:	ffffc097          	auipc	ra,0xffffc
    80004c9c:	bcc080e7          	jalr	-1076(ra) # 80000864 <kfree>
  } else
    release(&pi->lock);
}
    80004ca0:	60e2                	ld	ra,24(sp)
    80004ca2:	6442                	ld	s0,16(sp)
    80004ca4:	64a2                	ld	s1,8(sp)
    80004ca6:	6902                	ld	s2,0(sp)
    80004ca8:	6105                	addi	sp,sp,32
    80004caa:	8082                	ret
    pi->readopen = 0;
    80004cac:	2204a423          	sw	zero,552(s1)
    wakeup(&pi->nwrite);
    80004cb0:	22448513          	addi	a0,s1,548
    80004cb4:	ffffe097          	auipc	ra,0xffffe
    80004cb8:	822080e7          	jalr	-2014(ra) # 800024d6 <wakeup>
    80004cbc:	b7e9                	j	80004c86 <pipeclose+0x2c>
    release(&pi->lock);
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	ffffc097          	auipc	ra,0xffffc
    80004cc4:	fd8080e7          	jalr	-40(ra) # 80000c98 <release>
}
    80004cc8:	bfe1                	j	80004ca0 <pipeclose+0x46>

0000000080004cca <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004cca:	711d                	addi	sp,sp,-96
    80004ccc:	ec86                	sd	ra,88(sp)
    80004cce:	e8a2                	sd	s0,80(sp)
    80004cd0:	e4a6                	sd	s1,72(sp)
    80004cd2:	e0ca                	sd	s2,64(sp)
    80004cd4:	fc4e                	sd	s3,56(sp)
    80004cd6:	f852                	sd	s4,48(sp)
    80004cd8:	f456                	sd	s5,40(sp)
    80004cda:	f05a                	sd	s6,32(sp)
    80004cdc:	ec5e                	sd	s7,24(sp)
    80004cde:	e862                	sd	s8,16(sp)
    80004ce0:	1080                	addi	s0,sp,96
    80004ce2:	84aa                	mv	s1,a0
    80004ce4:	8aae                	mv	s5,a1
    80004ce6:	8a32                	mv	s4,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	e98080e7          	jalr	-360(ra) # 80001b80 <myproc>
    80004cf0:	8baa                	mv	s7,a0

  acquire(&pi->lock);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	ffffc097          	auipc	ra,0xffffc
    80004cf8:	f34080e7          	jalr	-204(ra) # 80000c28 <acquire>
  for(i = 0; i < n; i++){
    80004cfc:	09405f63          	blez	s4,80004d9a <pipewrite+0xd0>
    80004d00:	fffa0b1b          	addiw	s6,s4,-1
    80004d04:	1b02                	slli	s6,s6,0x20
    80004d06:	020b5b13          	srli	s6,s6,0x20
    80004d0a:	001a8793          	addi	a5,s5,1
    80004d0e:	9b3e                	add	s6,s6,a5
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || myproc()->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004d10:	22048993          	addi	s3,s1,544
      sleep(&pi->nwrite, &pi->lock);
    80004d14:	22448913          	addi	s2,s1,548
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d18:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d1a:	2204a783          	lw	a5,544(s1)
    80004d1e:	2244a703          	lw	a4,548(s1)
    80004d22:	2007879b          	addiw	a5,a5,512
    80004d26:	02f71e63          	bne	a4,a5,80004d62 <pipewrite+0x98>
      if(pi->readopen == 0 || myproc()->killed){
    80004d2a:	2284a783          	lw	a5,552(s1)
    80004d2e:	c3d9                	beqz	a5,80004db4 <pipewrite+0xea>
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	e50080e7          	jalr	-432(ra) # 80001b80 <myproc>
    80004d38:	5d1c                	lw	a5,56(a0)
    80004d3a:	efad                	bnez	a5,80004db4 <pipewrite+0xea>
      wakeup(&pi->nread);
    80004d3c:	854e                	mv	a0,s3
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	798080e7          	jalr	1944(ra) # 800024d6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d46:	85a6                	mv	a1,s1
    80004d48:	854a                	mv	a0,s2
    80004d4a:	ffffd097          	auipc	ra,0xffffd
    80004d4e:	60c080e7          	jalr	1548(ra) # 80002356 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004d52:	2204a783          	lw	a5,544(s1)
    80004d56:	2244a703          	lw	a4,548(s1)
    80004d5a:	2007879b          	addiw	a5,a5,512
    80004d5e:	fcf706e3          	beq	a4,a5,80004d2a <pipewrite+0x60>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d62:	4685                	li	a3,1
    80004d64:	8656                	mv	a2,s5
    80004d66:	faf40593          	addi	a1,s0,-81
    80004d6a:	058bb503          	ld	a0,88(s7) # 1058 <_entry-0x7fffefa8>
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	b90080e7          	jalr	-1136(ra) # 800018fe <copyin>
    80004d76:	03850263          	beq	a0,s8,80004d9a <pipewrite+0xd0>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d7a:	2244a783          	lw	a5,548(s1)
    80004d7e:	0017871b          	addiw	a4,a5,1
    80004d82:	22e4a223          	sw	a4,548(s1)
    80004d86:	1ff7f793          	andi	a5,a5,511
    80004d8a:	97a6                	add	a5,a5,s1
    80004d8c:	faf44703          	lbu	a4,-81(s0)
    80004d90:	02e78023          	sb	a4,32(a5)
  for(i = 0; i < n; i++){
    80004d94:	0a85                	addi	s5,s5,1
    80004d96:	f96a92e3          	bne	s5,s6,80004d1a <pipewrite+0x50>
  }
  wakeup(&pi->nread);
    80004d9a:	22048513          	addi	a0,s1,544
    80004d9e:	ffffd097          	auipc	ra,0xffffd
    80004da2:	738080e7          	jalr	1848(ra) # 800024d6 <wakeup>
  release(&pi->lock);
    80004da6:	8526                	mv	a0,s1
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	ef0080e7          	jalr	-272(ra) # 80000c98 <release>
  return n;
    80004db0:	8552                	mv	a0,s4
    80004db2:	a039                	j	80004dc0 <pipewrite+0xf6>
        release(&pi->lock);
    80004db4:	8526                	mv	a0,s1
    80004db6:	ffffc097          	auipc	ra,0xffffc
    80004dba:	ee2080e7          	jalr	-286(ra) # 80000c98 <release>
        return -1;
    80004dbe:	557d                	li	a0,-1
}
    80004dc0:	60e6                	ld	ra,88(sp)
    80004dc2:	6446                	ld	s0,80(sp)
    80004dc4:	64a6                	ld	s1,72(sp)
    80004dc6:	6906                	ld	s2,64(sp)
    80004dc8:	79e2                	ld	s3,56(sp)
    80004dca:	7a42                	ld	s4,48(sp)
    80004dcc:	7aa2                	ld	s5,40(sp)
    80004dce:	7b02                	ld	s6,32(sp)
    80004dd0:	6be2                	ld	s7,24(sp)
    80004dd2:	6c42                	ld	s8,16(sp)
    80004dd4:	6125                	addi	sp,sp,96
    80004dd6:	8082                	ret

0000000080004dd8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004dd8:	715d                	addi	sp,sp,-80
    80004dda:	e486                	sd	ra,72(sp)
    80004ddc:	e0a2                	sd	s0,64(sp)
    80004dde:	fc26                	sd	s1,56(sp)
    80004de0:	f84a                	sd	s2,48(sp)
    80004de2:	f44e                	sd	s3,40(sp)
    80004de4:	f052                	sd	s4,32(sp)
    80004de6:	ec56                	sd	s5,24(sp)
    80004de8:	e85a                	sd	s6,16(sp)
    80004dea:	0880                	addi	s0,sp,80
    80004dec:	84aa                	mv	s1,a0
    80004dee:	892e                	mv	s2,a1
    80004df0:	8a32                	mv	s4,a2
  int i;
  struct proc *pr = myproc();
    80004df2:	ffffd097          	auipc	ra,0xffffd
    80004df6:	d8e080e7          	jalr	-626(ra) # 80001b80 <myproc>
    80004dfa:	8aaa                	mv	s5,a0
  char ch;

  acquire(&pi->lock);
    80004dfc:	8526                	mv	a0,s1
    80004dfe:	ffffc097          	auipc	ra,0xffffc
    80004e02:	e2a080e7          	jalr	-470(ra) # 80000c28 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e06:	2204a703          	lw	a4,544(s1)
    80004e0a:	2244a783          	lw	a5,548(s1)
    if(myproc()->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e0e:	22048993          	addi	s3,s1,544
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e12:	02f71763          	bne	a4,a5,80004e40 <piperead+0x68>
    80004e16:	22c4a783          	lw	a5,556(s1)
    80004e1a:	c39d                	beqz	a5,80004e40 <piperead+0x68>
    if(myproc()->killed){
    80004e1c:	ffffd097          	auipc	ra,0xffffd
    80004e20:	d64080e7          	jalr	-668(ra) # 80001b80 <myproc>
    80004e24:	5d1c                	lw	a5,56(a0)
    80004e26:	ebc1                	bnez	a5,80004eb6 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e28:	85a6                	mv	a1,s1
    80004e2a:	854e                	mv	a0,s3
    80004e2c:	ffffd097          	auipc	ra,0xffffd
    80004e30:	52a080e7          	jalr	1322(ra) # 80002356 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e34:	2204a703          	lw	a4,544(s1)
    80004e38:	2244a783          	lw	a5,548(s1)
    80004e3c:	fcf70de3          	beq	a4,a5,80004e16 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e40:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e42:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e44:	05405363          	blez	s4,80004e8a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004e48:	2204a783          	lw	a5,544(s1)
    80004e4c:	2244a703          	lw	a4,548(s1)
    80004e50:	02f70d63          	beq	a4,a5,80004e8a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004e54:	0017871b          	addiw	a4,a5,1
    80004e58:	22e4a023          	sw	a4,544(s1)
    80004e5c:	1ff7f793          	andi	a5,a5,511
    80004e60:	97a6                	add	a5,a5,s1
    80004e62:	0207c783          	lbu	a5,32(a5)
    80004e66:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004e6a:	4685                	li	a3,1
    80004e6c:	fbf40613          	addi	a2,s0,-65
    80004e70:	85ca                	mv	a1,s2
    80004e72:	058ab503          	ld	a0,88(s5)
    80004e76:	ffffd097          	auipc	ra,0xffffd
    80004e7a:	9fc080e7          	jalr	-1540(ra) # 80001872 <copyout>
    80004e7e:	01650663          	beq	a0,s6,80004e8a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e82:	2985                	addiw	s3,s3,1
    80004e84:	0905                	addi	s2,s2,1
    80004e86:	fd3a11e3          	bne	s4,s3,80004e48 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e8a:	22448513          	addi	a0,s1,548
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	648080e7          	jalr	1608(ra) # 800024d6 <wakeup>
  release(&pi->lock);
    80004e96:	8526                	mv	a0,s1
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	e00080e7          	jalr	-512(ra) # 80000c98 <release>
  return i;
}
    80004ea0:	854e                	mv	a0,s3
    80004ea2:	60a6                	ld	ra,72(sp)
    80004ea4:	6406                	ld	s0,64(sp)
    80004ea6:	74e2                	ld	s1,56(sp)
    80004ea8:	7942                	ld	s2,48(sp)
    80004eaa:	79a2                	ld	s3,40(sp)
    80004eac:	7a02                	ld	s4,32(sp)
    80004eae:	6ae2                	ld	s5,24(sp)
    80004eb0:	6b42                	ld	s6,16(sp)
    80004eb2:	6161                	addi	sp,sp,80
    80004eb4:	8082                	ret
      release(&pi->lock);
    80004eb6:	8526                	mv	a0,s1
    80004eb8:	ffffc097          	auipc	ra,0xffffc
    80004ebc:	de0080e7          	jalr	-544(ra) # 80000c98 <release>
      return -1;
    80004ec0:	59fd                	li	s3,-1
    80004ec2:	bff9                	j	80004ea0 <piperead+0xc8>

0000000080004ec4 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004ec4:	de010113          	addi	sp,sp,-544
    80004ec8:	20113c23          	sd	ra,536(sp)
    80004ecc:	20813823          	sd	s0,528(sp)
    80004ed0:	20913423          	sd	s1,520(sp)
    80004ed4:	21213023          	sd	s2,512(sp)
    80004ed8:	ffce                	sd	s3,504(sp)
    80004eda:	fbd2                	sd	s4,496(sp)
    80004edc:	f7d6                	sd	s5,488(sp)
    80004ede:	f3da                	sd	s6,480(sp)
    80004ee0:	efde                	sd	s7,472(sp)
    80004ee2:	ebe2                	sd	s8,464(sp)
    80004ee4:	e7e6                	sd	s9,456(sp)
    80004ee6:	e3ea                	sd	s10,448(sp)
    80004ee8:	ff6e                	sd	s11,440(sp)
    80004eea:	1400                	addi	s0,sp,544
    80004eec:	892a                	mv	s2,a0
    80004eee:	dea43423          	sd	a0,-536(s0)
    80004ef2:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ef6:	ffffd097          	auipc	ra,0xffffd
    80004efa:	c8a080e7          	jalr	-886(ra) # 80001b80 <myproc>
    80004efe:	84aa                	mv	s1,a0

  begin_op(ROOTDEV);
    80004f00:	4501                	li	a0,0
    80004f02:	fffff097          	auipc	ra,0xfffff
    80004f06:	382080e7          	jalr	898(ra) # 80004284 <begin_op>

  if((ip = namei(path)) == 0){
    80004f0a:	854a                	mv	a0,s2
    80004f0c:	fffff097          	auipc	ra,0xfffff
    80004f10:	11c080e7          	jalr	284(ra) # 80004028 <namei>
    80004f14:	cd25                	beqz	a0,80004f8c <exec+0xc8>
    80004f16:	8aaa                	mv	s5,a0
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80004f18:	fffff097          	auipc	ra,0xfffff
    80004f1c:	986080e7          	jalr	-1658(ra) # 8000389e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f20:	04000713          	li	a4,64
    80004f24:	4681                	li	a3,0
    80004f26:	e4840613          	addi	a2,s0,-440
    80004f2a:	4581                	li	a1,0
    80004f2c:	8556                	mv	a0,s5
    80004f2e:	fffff097          	auipc	ra,0xfffff
    80004f32:	c00080e7          	jalr	-1024(ra) # 80003b2e <readi>
    80004f36:	04000793          	li	a5,64
    80004f3a:	00f51a63          	bne	a0,a5,80004f4e <exec+0x8a>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004f3e:	e4842703          	lw	a4,-440(s0)
    80004f42:	464c47b7          	lui	a5,0x464c4
    80004f46:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f4a:	04f70863          	beq	a4,a5,80004f9a <exec+0xd6>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f4e:	8556                	mv	a0,s5
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	b8c080e7          	jalr	-1140(ra) # 80003adc <iunlockput>
    end_op(ROOTDEV);
    80004f58:	4501                	li	a0,0
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	3d4080e7          	jalr	980(ra) # 8000432e <end_op>
  }
  return -1;
    80004f62:	557d                	li	a0,-1
}
    80004f64:	21813083          	ld	ra,536(sp)
    80004f68:	21013403          	ld	s0,528(sp)
    80004f6c:	20813483          	ld	s1,520(sp)
    80004f70:	20013903          	ld	s2,512(sp)
    80004f74:	79fe                	ld	s3,504(sp)
    80004f76:	7a5e                	ld	s4,496(sp)
    80004f78:	7abe                	ld	s5,488(sp)
    80004f7a:	7b1e                	ld	s6,480(sp)
    80004f7c:	6bfe                	ld	s7,472(sp)
    80004f7e:	6c5e                	ld	s8,464(sp)
    80004f80:	6cbe                	ld	s9,456(sp)
    80004f82:	6d1e                	ld	s10,448(sp)
    80004f84:	7dfa                	ld	s11,440(sp)
    80004f86:	22010113          	addi	sp,sp,544
    80004f8a:	8082                	ret
    end_op(ROOTDEV);
    80004f8c:	4501                	li	a0,0
    80004f8e:	fffff097          	auipc	ra,0xfffff
    80004f92:	3a0080e7          	jalr	928(ra) # 8000432e <end_op>
    return -1;
    80004f96:	557d                	li	a0,-1
    80004f98:	b7f1                	j	80004f64 <exec+0xa0>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f9a:	8526                	mv	a0,s1
    80004f9c:	ffffd097          	auipc	ra,0xffffd
    80004fa0:	ca8080e7          	jalr	-856(ra) # 80001c44 <proc_pagetable>
    80004fa4:	8b2a                	mv	s6,a0
    80004fa6:	d545                	beqz	a0,80004f4e <exec+0x8a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fa8:	e6842783          	lw	a5,-408(s0)
    80004fac:	e8045703          	lhu	a4,-384(s0)
    80004fb0:	10070263          	beqz	a4,800050b4 <exec+0x1f0>
  sz = 0;
    80004fb4:	de043c23          	sd	zero,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fb8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004fbc:	6a05                	lui	s4,0x1
    80004fbe:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004fc2:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004fc6:	6d85                	lui	s11,0x1
    80004fc8:	7d7d                	lui	s10,0xfffff
    80004fca:	a88d                	j	8000503c <exec+0x178>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004fcc:	00004517          	auipc	a0,0x4
    80004fd0:	83c50513          	addi	a0,a0,-1988 # 80008808 <userret+0x778>
    80004fd4:	ffffb097          	auipc	ra,0xffffb
    80004fd8:	574080e7          	jalr	1396(ra) # 80000548 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fdc:	874a                	mv	a4,s2
    80004fde:	009c86bb          	addw	a3,s9,s1
    80004fe2:	4581                	li	a1,0
    80004fe4:	8556                	mv	a0,s5
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	b48080e7          	jalr	-1208(ra) # 80003b2e <readi>
    80004fee:	2501                	sext.w	a0,a0
    80004ff0:	10a91863          	bne	s2,a0,80005100 <exec+0x23c>
  for(i = 0; i < sz; i += PGSIZE){
    80004ff4:	009d84bb          	addw	s1,s11,s1
    80004ff8:	013d09bb          	addw	s3,s10,s3
    80004ffc:	0374f263          	bgeu	s1,s7,80005020 <exec+0x15c>
    pa = walkaddr(pagetable, va + i);
    80005000:	02049593          	slli	a1,s1,0x20
    80005004:	9181                	srli	a1,a1,0x20
    80005006:	95e2                	add	a1,a1,s8
    80005008:	855a                	mv	a0,s6
    8000500a:	ffffc097          	auipc	ra,0xffffc
    8000500e:	286080e7          	jalr	646(ra) # 80001290 <walkaddr>
    80005012:	862a                	mv	a2,a0
    if(pa == 0)
    80005014:	dd45                	beqz	a0,80004fcc <exec+0x108>
      n = PGSIZE;
    80005016:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005018:	fd49f2e3          	bgeu	s3,s4,80004fdc <exec+0x118>
      n = sz - i;
    8000501c:	894e                	mv	s2,s3
    8000501e:	bf7d                	j	80004fdc <exec+0x118>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005020:	e0843783          	ld	a5,-504(s0)
    80005024:	0017869b          	addiw	a3,a5,1
    80005028:	e0d43423          	sd	a3,-504(s0)
    8000502c:	e0043783          	ld	a5,-512(s0)
    80005030:	0387879b          	addiw	a5,a5,56
    80005034:	e8045703          	lhu	a4,-384(s0)
    80005038:	08e6d063          	bge	a3,a4,800050b8 <exec+0x1f4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000503c:	2781                	sext.w	a5,a5
    8000503e:	e0f43023          	sd	a5,-512(s0)
    80005042:	03800713          	li	a4,56
    80005046:	86be                	mv	a3,a5
    80005048:	e1040613          	addi	a2,s0,-496
    8000504c:	4581                	li	a1,0
    8000504e:	8556                	mv	a0,s5
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	ade080e7          	jalr	-1314(ra) # 80003b2e <readi>
    80005058:	03800793          	li	a5,56
    8000505c:	0af51263          	bne	a0,a5,80005100 <exec+0x23c>
    if(ph.type != ELF_PROG_LOAD)
    80005060:	e1042783          	lw	a5,-496(s0)
    80005064:	4705                	li	a4,1
    80005066:	fae79de3          	bne	a5,a4,80005020 <exec+0x15c>
    if(ph.memsz < ph.filesz)
    8000506a:	e3843603          	ld	a2,-456(s0)
    8000506e:	e3043783          	ld	a5,-464(s0)
    80005072:	08f66763          	bltu	a2,a5,80005100 <exec+0x23c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005076:	e2043783          	ld	a5,-480(s0)
    8000507a:	963e                	add	a2,a2,a5
    8000507c:	08f66263          	bltu	a2,a5,80005100 <exec+0x23c>
    if((sz = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005080:	df843583          	ld	a1,-520(s0)
    80005084:	855a                	mv	a0,s6
    80005086:	ffffc097          	auipc	ra,0xffffc
    8000508a:	612080e7          	jalr	1554(ra) # 80001698 <uvmalloc>
    8000508e:	dea43c23          	sd	a0,-520(s0)
    80005092:	c53d                	beqz	a0,80005100 <exec+0x23c>
    if(ph.vaddr % PGSIZE != 0)
    80005094:	e2043c03          	ld	s8,-480(s0)
    80005098:	de043783          	ld	a5,-544(s0)
    8000509c:	00fc77b3          	and	a5,s8,a5
    800050a0:	e3a5                	bnez	a5,80005100 <exec+0x23c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050a2:	e1842c83          	lw	s9,-488(s0)
    800050a6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050aa:	f60b8be3          	beqz	s7,80005020 <exec+0x15c>
    800050ae:	89de                	mv	s3,s7
    800050b0:	4481                	li	s1,0
    800050b2:	b7b9                	j	80005000 <exec+0x13c>
  sz = 0;
    800050b4:	de043c23          	sd	zero,-520(s0)
  iunlockput(ip);
    800050b8:	8556                	mv	a0,s5
    800050ba:	fffff097          	auipc	ra,0xfffff
    800050be:	a22080e7          	jalr	-1502(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    800050c2:	4501                	li	a0,0
    800050c4:	fffff097          	auipc	ra,0xfffff
    800050c8:	26a080e7          	jalr	618(ra) # 8000432e <end_op>
  p = myproc();
    800050cc:	ffffd097          	auipc	ra,0xffffd
    800050d0:	ab4080e7          	jalr	-1356(ra) # 80001b80 <myproc>
    800050d4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800050d6:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    800050da:	6585                	lui	a1,0x1
    800050dc:	15fd                	addi	a1,a1,-1
    800050de:	df843783          	ld	a5,-520(s0)
    800050e2:	95be                	add	a1,a1,a5
    800050e4:	77fd                	lui	a5,0xfffff
    800050e6:	8dfd                	and	a1,a1,a5
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050e8:	6609                	lui	a2,0x2
    800050ea:	962e                	add	a2,a2,a1
    800050ec:	855a                	mv	a0,s6
    800050ee:	ffffc097          	auipc	ra,0xffffc
    800050f2:	5aa080e7          	jalr	1450(ra) # 80001698 <uvmalloc>
    800050f6:	892a                	mv	s2,a0
    800050f8:	dea43c23          	sd	a0,-520(s0)
  ip = 0;
    800050fc:	4a81                	li	s5,0
  if((sz = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050fe:	ed01                	bnez	a0,80005116 <exec+0x252>
    proc_freepagetable(pagetable, sz);
    80005100:	df843583          	ld	a1,-520(s0)
    80005104:	855a                	mv	a0,s6
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	c3e080e7          	jalr	-962(ra) # 80001d44 <proc_freepagetable>
  if(ip){
    8000510e:	e40a90e3          	bnez	s5,80004f4e <exec+0x8a>
  return -1;
    80005112:	557d                	li	a0,-1
    80005114:	bd81                	j	80004f64 <exec+0xa0>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005116:	75f9                	lui	a1,0xffffe
    80005118:	95aa                	add	a1,a1,a0
    8000511a:	855a                	mv	a0,s6
    8000511c:	ffffc097          	auipc	ra,0xffffc
    80005120:	724080e7          	jalr	1828(ra) # 80001840 <uvmclear>
  stackbase = sp - PGSIZE;
    80005124:	7c7d                	lui	s8,0xfffff
    80005126:	9c4a                	add	s8,s8,s2
  for(argc = 0; argv[argc]; argc++) {
    80005128:	df043783          	ld	a5,-528(s0)
    8000512c:	6388                	ld	a0,0(a5)
    8000512e:	c52d                	beqz	a0,80005198 <exec+0x2d4>
    80005130:	e8840993          	addi	s3,s0,-376
    80005134:	f8840a93          	addi	s5,s0,-120
    80005138:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000513a:	ffffc097          	auipc	ra,0xffffc
    8000513e:	ee0080e7          	jalr	-288(ra) # 8000101a <strlen>
    80005142:	0015079b          	addiw	a5,a0,1
    80005146:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000514a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000514e:	0f896b63          	bltu	s2,s8,80005244 <exec+0x380>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005152:	df043d03          	ld	s10,-528(s0)
    80005156:	000d3a03          	ld	s4,0(s10) # fffffffffffff000 <end+0xffffffff7ffcefa4>
    8000515a:	8552                	mv	a0,s4
    8000515c:	ffffc097          	auipc	ra,0xffffc
    80005160:	ebe080e7          	jalr	-322(ra) # 8000101a <strlen>
    80005164:	0015069b          	addiw	a3,a0,1
    80005168:	8652                	mv	a2,s4
    8000516a:	85ca                	mv	a1,s2
    8000516c:	855a                	mv	a0,s6
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	704080e7          	jalr	1796(ra) # 80001872 <copyout>
    80005176:	0c054963          	bltz	a0,80005248 <exec+0x384>
    ustack[argc] = sp;
    8000517a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000517e:	0485                	addi	s1,s1,1
    80005180:	008d0793          	addi	a5,s10,8
    80005184:	def43823          	sd	a5,-528(s0)
    80005188:	008d3503          	ld	a0,8(s10)
    8000518c:	c909                	beqz	a0,8000519e <exec+0x2da>
    if(argc >= MAXARG)
    8000518e:	09a1                	addi	s3,s3,8
    80005190:	fb3a95e3          	bne	s5,s3,8000513a <exec+0x276>
  ip = 0;
    80005194:	4a81                	li	s5,0
    80005196:	b7ad                	j	80005100 <exec+0x23c>
  sp = sz;
    80005198:	df843903          	ld	s2,-520(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000519c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000519e:	00349793          	slli	a5,s1,0x3
    800051a2:	f9040713          	addi	a4,s0,-112
    800051a6:	97ba                	add	a5,a5,a4
    800051a8:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffcee9c>
  sp -= (argc+1) * sizeof(uint64);
    800051ac:	00148693          	addi	a3,s1,1
    800051b0:	068e                	slli	a3,a3,0x3
    800051b2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051b6:	ff097913          	andi	s2,s2,-16
  ip = 0;
    800051ba:	4a81                	li	s5,0
  if(sp < stackbase)
    800051bc:	f58962e3          	bltu	s2,s8,80005100 <exec+0x23c>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051c0:	e8840613          	addi	a2,s0,-376
    800051c4:	85ca                	mv	a1,s2
    800051c6:	855a                	mv	a0,s6
    800051c8:	ffffc097          	auipc	ra,0xffffc
    800051cc:	6aa080e7          	jalr	1706(ra) # 80001872 <copyout>
    800051d0:	06054e63          	bltz	a0,8000524c <exec+0x388>
  p->tf->a1 = sp;
    800051d4:	060bb783          	ld	a5,96(s7)
    800051d8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051dc:	de843783          	ld	a5,-536(s0)
    800051e0:	0007c703          	lbu	a4,0(a5)
    800051e4:	cf11                	beqz	a4,80005200 <exec+0x33c>
    800051e6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051e8:	02f00693          	li	a3,47
    800051ec:	a039                	j	800051fa <exec+0x336>
      last = s+1;
    800051ee:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800051f2:	0785                	addi	a5,a5,1
    800051f4:	fff7c703          	lbu	a4,-1(a5)
    800051f8:	c701                	beqz	a4,80005200 <exec+0x33c>
    if(*s == '/')
    800051fa:	fed71ce3          	bne	a4,a3,800051f2 <exec+0x32e>
    800051fe:	bfc5                	j	800051ee <exec+0x32a>
  safestrcpy(p->name, last, sizeof(p->name));
    80005200:	4641                	li	a2,16
    80005202:	de843583          	ld	a1,-536(s0)
    80005206:	160b8513          	addi	a0,s7,352
    8000520a:	ffffc097          	auipc	ra,0xffffc
    8000520e:	dde080e7          	jalr	-546(ra) # 80000fe8 <safestrcpy>
  oldpagetable = p->pagetable;
    80005212:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    80005216:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    8000521a:	df843783          	ld	a5,-520(s0)
    8000521e:	04fbb823          	sd	a5,80(s7)
  p->tf->epc = elf.entry;  // initial program counter = main
    80005222:	060bb783          	ld	a5,96(s7)
    80005226:	e6043703          	ld	a4,-416(s0)
    8000522a:	ef98                	sd	a4,24(a5)
  p->tf->sp = sp; // initial stack pointer
    8000522c:	060bb783          	ld	a5,96(s7)
    80005230:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005234:	85e6                	mv	a1,s9
    80005236:	ffffd097          	auipc	ra,0xffffd
    8000523a:	b0e080e7          	jalr	-1266(ra) # 80001d44 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000523e:	0004851b          	sext.w	a0,s1
    80005242:	b30d                	j	80004f64 <exec+0xa0>
  ip = 0;
    80005244:	4a81                	li	s5,0
    80005246:	bd6d                	j	80005100 <exec+0x23c>
    80005248:	4a81                	li	s5,0
    8000524a:	bd5d                	j	80005100 <exec+0x23c>
    8000524c:	4a81                	li	s5,0
    8000524e:	bd4d                	j	80005100 <exec+0x23c>

0000000080005250 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005250:	7179                	addi	sp,sp,-48
    80005252:	f406                	sd	ra,40(sp)
    80005254:	f022                	sd	s0,32(sp)
    80005256:	ec26                	sd	s1,24(sp)
    80005258:	e84a                	sd	s2,16(sp)
    8000525a:	1800                	addi	s0,sp,48
    8000525c:	892e                	mv	s2,a1
    8000525e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005260:	fdc40593          	addi	a1,s0,-36
    80005264:	ffffe097          	auipc	ra,0xffffe
    80005268:	996080e7          	jalr	-1642(ra) # 80002bfa <argint>
    8000526c:	04054063          	bltz	a0,800052ac <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005270:	fdc42703          	lw	a4,-36(s0)
    80005274:	47bd                	li	a5,15
    80005276:	02e7ed63          	bltu	a5,a4,800052b0 <argfd+0x60>
    8000527a:	ffffd097          	auipc	ra,0xffffd
    8000527e:	906080e7          	jalr	-1786(ra) # 80001b80 <myproc>
    80005282:	fdc42703          	lw	a4,-36(s0)
    80005286:	01a70793          	addi	a5,a4,26
    8000528a:	078e                	slli	a5,a5,0x3
    8000528c:	953e                	add	a0,a0,a5
    8000528e:	651c                	ld	a5,8(a0)
    80005290:	c395                	beqz	a5,800052b4 <argfd+0x64>
    return -1;
  if(pfd)
    80005292:	00090463          	beqz	s2,8000529a <argfd+0x4a>
    *pfd = fd;
    80005296:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000529a:	4501                	li	a0,0
  if(pf)
    8000529c:	c091                	beqz	s1,800052a0 <argfd+0x50>
    *pf = f;
    8000529e:	e09c                	sd	a5,0(s1)
}
    800052a0:	70a2                	ld	ra,40(sp)
    800052a2:	7402                	ld	s0,32(sp)
    800052a4:	64e2                	ld	s1,24(sp)
    800052a6:	6942                	ld	s2,16(sp)
    800052a8:	6145                	addi	sp,sp,48
    800052aa:	8082                	ret
    return -1;
    800052ac:	557d                	li	a0,-1
    800052ae:	bfcd                	j	800052a0 <argfd+0x50>
    return -1;
    800052b0:	557d                	li	a0,-1
    800052b2:	b7fd                	j	800052a0 <argfd+0x50>
    800052b4:	557d                	li	a0,-1
    800052b6:	b7ed                	j	800052a0 <argfd+0x50>

00000000800052b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052b8:	1101                	addi	sp,sp,-32
    800052ba:	ec06                	sd	ra,24(sp)
    800052bc:	e822                	sd	s0,16(sp)
    800052be:	e426                	sd	s1,8(sp)
    800052c0:	1000                	addi	s0,sp,32
    800052c2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052c4:	ffffd097          	auipc	ra,0xffffd
    800052c8:	8bc080e7          	jalr	-1860(ra) # 80001b80 <myproc>
    800052cc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052ce:	0d850793          	addi	a5,a0,216
    800052d2:	4501                	li	a0,0
    800052d4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052d6:	6398                	ld	a4,0(a5)
    800052d8:	cb19                	beqz	a4,800052ee <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800052da:	2505                	addiw	a0,a0,1
    800052dc:	07a1                	addi	a5,a5,8
    800052de:	fed51ce3          	bne	a0,a3,800052d6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800052e2:	557d                	li	a0,-1
}
    800052e4:	60e2                	ld	ra,24(sp)
    800052e6:	6442                	ld	s0,16(sp)
    800052e8:	64a2                	ld	s1,8(sp)
    800052ea:	6105                	addi	sp,sp,32
    800052ec:	8082                	ret
      p->ofile[fd] = f;
    800052ee:	01a50793          	addi	a5,a0,26
    800052f2:	078e                	slli	a5,a5,0x3
    800052f4:	963e                	add	a2,a2,a5
    800052f6:	e604                	sd	s1,8(a2)
      return fd;
    800052f8:	b7f5                	j	800052e4 <fdalloc+0x2c>

00000000800052fa <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052fa:	715d                	addi	sp,sp,-80
    800052fc:	e486                	sd	ra,72(sp)
    800052fe:	e0a2                	sd	s0,64(sp)
    80005300:	fc26                	sd	s1,56(sp)
    80005302:	f84a                	sd	s2,48(sp)
    80005304:	f44e                	sd	s3,40(sp)
    80005306:	f052                	sd	s4,32(sp)
    80005308:	ec56                	sd	s5,24(sp)
    8000530a:	0880                	addi	s0,sp,80
    8000530c:	89ae                	mv	s3,a1
    8000530e:	8ab2                	mv	s5,a2
    80005310:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005312:	fb040593          	addi	a1,s0,-80
    80005316:	fffff097          	auipc	ra,0xfffff
    8000531a:	d30080e7          	jalr	-720(ra) # 80004046 <nameiparent>
    8000531e:	892a                	mv	s2,a0
    80005320:	12050e63          	beqz	a0,8000545c <create+0x162>
    return 0;

  ilock(dp);
    80005324:	ffffe097          	auipc	ra,0xffffe
    80005328:	57a080e7          	jalr	1402(ra) # 8000389e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000532c:	4601                	li	a2,0
    8000532e:	fb040593          	addi	a1,s0,-80
    80005332:	854a                	mv	a0,s2
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	a22080e7          	jalr	-1502(ra) # 80003d56 <dirlookup>
    8000533c:	84aa                	mv	s1,a0
    8000533e:	c921                	beqz	a0,8000538e <create+0x94>
    iunlockput(dp);
    80005340:	854a                	mv	a0,s2
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	79a080e7          	jalr	1946(ra) # 80003adc <iunlockput>
    ilock(ip);
    8000534a:	8526                	mv	a0,s1
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	552080e7          	jalr	1362(ra) # 8000389e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005354:	2981                	sext.w	s3,s3
    80005356:	4789                	li	a5,2
    80005358:	02f99463          	bne	s3,a5,80005380 <create+0x86>
    8000535c:	04c4d783          	lhu	a5,76(s1)
    80005360:	37f9                	addiw	a5,a5,-2
    80005362:	17c2                	slli	a5,a5,0x30
    80005364:	93c1                	srli	a5,a5,0x30
    80005366:	4705                	li	a4,1
    80005368:	00f76c63          	bltu	a4,a5,80005380 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000536c:	8526                	mv	a0,s1
    8000536e:	60a6                	ld	ra,72(sp)
    80005370:	6406                	ld	s0,64(sp)
    80005372:	74e2                	ld	s1,56(sp)
    80005374:	7942                	ld	s2,48(sp)
    80005376:	79a2                	ld	s3,40(sp)
    80005378:	7a02                	ld	s4,32(sp)
    8000537a:	6ae2                	ld	s5,24(sp)
    8000537c:	6161                	addi	sp,sp,80
    8000537e:	8082                	ret
    iunlockput(ip);
    80005380:	8526                	mv	a0,s1
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	75a080e7          	jalr	1882(ra) # 80003adc <iunlockput>
    return 0;
    8000538a:	4481                	li	s1,0
    8000538c:	b7c5                	j	8000536c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000538e:	85ce                	mv	a1,s3
    80005390:	00092503          	lw	a0,0(s2)
    80005394:	ffffe097          	auipc	ra,0xffffe
    80005398:	372080e7          	jalr	882(ra) # 80003706 <ialloc>
    8000539c:	84aa                	mv	s1,a0
    8000539e:	c521                	beqz	a0,800053e6 <create+0xec>
  ilock(ip);
    800053a0:	ffffe097          	auipc	ra,0xffffe
    800053a4:	4fe080e7          	jalr	1278(ra) # 8000389e <ilock>
  ip->major = major;
    800053a8:	05549723          	sh	s5,78(s1)
  ip->minor = minor;
    800053ac:	05449823          	sh	s4,80(s1)
  ip->nlink = 1;
    800053b0:	4a05                	li	s4,1
    800053b2:	05449923          	sh	s4,82(s1)
  iupdate(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	41c080e7          	jalr	1052(ra) # 800037d4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053c0:	2981                	sext.w	s3,s3
    800053c2:	03498a63          	beq	s3,s4,800053f6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800053c6:	40d0                	lw	a2,4(s1)
    800053c8:	fb040593          	addi	a1,s0,-80
    800053cc:	854a                	mv	a0,s2
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	b98080e7          	jalr	-1128(ra) # 80003f66 <dirlink>
    800053d6:	06054b63          	bltz	a0,8000544c <create+0x152>
  iunlockput(dp);
    800053da:	854a                	mv	a0,s2
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	700080e7          	jalr	1792(ra) # 80003adc <iunlockput>
  return ip;
    800053e4:	b761                	j	8000536c <create+0x72>
    panic("create: ialloc");
    800053e6:	00003517          	auipc	a0,0x3
    800053ea:	44250513          	addi	a0,a0,1090 # 80008828 <userret+0x798>
    800053ee:	ffffb097          	auipc	ra,0xffffb
    800053f2:	15a080e7          	jalr	346(ra) # 80000548 <panic>
    dp->nlink++;  // for ".."
    800053f6:	05295783          	lhu	a5,82(s2)
    800053fa:	2785                	addiw	a5,a5,1
    800053fc:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    80005400:	854a                	mv	a0,s2
    80005402:	ffffe097          	auipc	ra,0xffffe
    80005406:	3d2080e7          	jalr	978(ra) # 800037d4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000540a:	40d0                	lw	a2,4(s1)
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	42c58593          	addi	a1,a1,1068 # 80008838 <userret+0x7a8>
    80005414:	8526                	mv	a0,s1
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	b50080e7          	jalr	-1200(ra) # 80003f66 <dirlink>
    8000541e:	00054f63          	bltz	a0,8000543c <create+0x142>
    80005422:	00492603          	lw	a2,4(s2)
    80005426:	00003597          	auipc	a1,0x3
    8000542a:	41a58593          	addi	a1,a1,1050 # 80008840 <userret+0x7b0>
    8000542e:	8526                	mv	a0,s1
    80005430:	fffff097          	auipc	ra,0xfffff
    80005434:	b36080e7          	jalr	-1226(ra) # 80003f66 <dirlink>
    80005438:	f80557e3          	bgez	a0,800053c6 <create+0xcc>
      panic("create dots");
    8000543c:	00003517          	auipc	a0,0x3
    80005440:	40c50513          	addi	a0,a0,1036 # 80008848 <userret+0x7b8>
    80005444:	ffffb097          	auipc	ra,0xffffb
    80005448:	104080e7          	jalr	260(ra) # 80000548 <panic>
    panic("create: dirlink");
    8000544c:	00003517          	auipc	a0,0x3
    80005450:	40c50513          	addi	a0,a0,1036 # 80008858 <userret+0x7c8>
    80005454:	ffffb097          	auipc	ra,0xffffb
    80005458:	0f4080e7          	jalr	244(ra) # 80000548 <panic>
    return 0;
    8000545c:	84aa                	mv	s1,a0
    8000545e:	b739                	j	8000536c <create+0x72>

0000000080005460 <sys_dup>:
{
    80005460:	7179                	addi	sp,sp,-48
    80005462:	f406                	sd	ra,40(sp)
    80005464:	f022                	sd	s0,32(sp)
    80005466:	ec26                	sd	s1,24(sp)
    80005468:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000546a:	fd840613          	addi	a2,s0,-40
    8000546e:	4581                	li	a1,0
    80005470:	4501                	li	a0,0
    80005472:	00000097          	auipc	ra,0x0
    80005476:	dde080e7          	jalr	-546(ra) # 80005250 <argfd>
    return -1;
    8000547a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000547c:	02054363          	bltz	a0,800054a2 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005480:	fd843503          	ld	a0,-40(s0)
    80005484:	00000097          	auipc	ra,0x0
    80005488:	e34080e7          	jalr	-460(ra) # 800052b8 <fdalloc>
    8000548c:	84aa                	mv	s1,a0
    return -1;
    8000548e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005490:	00054963          	bltz	a0,800054a2 <sys_dup+0x42>
  filedup(f);
    80005494:	fd843503          	ld	a0,-40(s0)
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	334080e7          	jalr	820(ra) # 800047cc <filedup>
  return fd;
    800054a0:	87a6                	mv	a5,s1
}
    800054a2:	853e                	mv	a0,a5
    800054a4:	70a2                	ld	ra,40(sp)
    800054a6:	7402                	ld	s0,32(sp)
    800054a8:	64e2                	ld	s1,24(sp)
    800054aa:	6145                	addi	sp,sp,48
    800054ac:	8082                	ret

00000000800054ae <sys_read>:
{
    800054ae:	7179                	addi	sp,sp,-48
    800054b0:	f406                	sd	ra,40(sp)
    800054b2:	f022                	sd	s0,32(sp)
    800054b4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054b6:	fe840613          	addi	a2,s0,-24
    800054ba:	4581                	li	a1,0
    800054bc:	4501                	li	a0,0
    800054be:	00000097          	auipc	ra,0x0
    800054c2:	d92080e7          	jalr	-622(ra) # 80005250 <argfd>
    return -1;
    800054c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c8:	04054163          	bltz	a0,8000550a <sys_read+0x5c>
    800054cc:	fe440593          	addi	a1,s0,-28
    800054d0:	4509                	li	a0,2
    800054d2:	ffffd097          	auipc	ra,0xffffd
    800054d6:	728080e7          	jalr	1832(ra) # 80002bfa <argint>
    return -1;
    800054da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054dc:	02054763          	bltz	a0,8000550a <sys_read+0x5c>
    800054e0:	fd840593          	addi	a1,s0,-40
    800054e4:	4505                	li	a0,1
    800054e6:	ffffd097          	auipc	ra,0xffffd
    800054ea:	736080e7          	jalr	1846(ra) # 80002c1c <argaddr>
    return -1;
    800054ee:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f0:	00054d63          	bltz	a0,8000550a <sys_read+0x5c>
  return fileread(f, p, n);
    800054f4:	fe442603          	lw	a2,-28(s0)
    800054f8:	fd843583          	ld	a1,-40(s0)
    800054fc:	fe843503          	ld	a0,-24(s0)
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	460080e7          	jalr	1120(ra) # 80004960 <fileread>
    80005508:	87aa                	mv	a5,a0
}
    8000550a:	853e                	mv	a0,a5
    8000550c:	70a2                	ld	ra,40(sp)
    8000550e:	7402                	ld	s0,32(sp)
    80005510:	6145                	addi	sp,sp,48
    80005512:	8082                	ret

0000000080005514 <sys_write>:
{
    80005514:	7179                	addi	sp,sp,-48
    80005516:	f406                	sd	ra,40(sp)
    80005518:	f022                	sd	s0,32(sp)
    8000551a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000551c:	fe840613          	addi	a2,s0,-24
    80005520:	4581                	li	a1,0
    80005522:	4501                	li	a0,0
    80005524:	00000097          	auipc	ra,0x0
    80005528:	d2c080e7          	jalr	-724(ra) # 80005250 <argfd>
    return -1;
    8000552c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000552e:	04054163          	bltz	a0,80005570 <sys_write+0x5c>
    80005532:	fe440593          	addi	a1,s0,-28
    80005536:	4509                	li	a0,2
    80005538:	ffffd097          	auipc	ra,0xffffd
    8000553c:	6c2080e7          	jalr	1730(ra) # 80002bfa <argint>
    return -1;
    80005540:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005542:	02054763          	bltz	a0,80005570 <sys_write+0x5c>
    80005546:	fd840593          	addi	a1,s0,-40
    8000554a:	4505                	li	a0,1
    8000554c:	ffffd097          	auipc	ra,0xffffd
    80005550:	6d0080e7          	jalr	1744(ra) # 80002c1c <argaddr>
    return -1;
    80005554:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005556:	00054d63          	bltz	a0,80005570 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000555a:	fe442603          	lw	a2,-28(s0)
    8000555e:	fd843583          	ld	a1,-40(s0)
    80005562:	fe843503          	ld	a0,-24(s0)
    80005566:	fffff097          	auipc	ra,0xfffff
    8000556a:	4c0080e7          	jalr	1216(ra) # 80004a26 <filewrite>
    8000556e:	87aa                	mv	a5,a0
}
    80005570:	853e                	mv	a0,a5
    80005572:	70a2                	ld	ra,40(sp)
    80005574:	7402                	ld	s0,32(sp)
    80005576:	6145                	addi	sp,sp,48
    80005578:	8082                	ret

000000008000557a <sys_close>:
{
    8000557a:	1101                	addi	sp,sp,-32
    8000557c:	ec06                	sd	ra,24(sp)
    8000557e:	e822                	sd	s0,16(sp)
    80005580:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005582:	fe040613          	addi	a2,s0,-32
    80005586:	fec40593          	addi	a1,s0,-20
    8000558a:	4501                	li	a0,0
    8000558c:	00000097          	auipc	ra,0x0
    80005590:	cc4080e7          	jalr	-828(ra) # 80005250 <argfd>
    return -1;
    80005594:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005596:	02054463          	bltz	a0,800055be <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000559a:	ffffc097          	auipc	ra,0xffffc
    8000559e:	5e6080e7          	jalr	1510(ra) # 80001b80 <myproc>
    800055a2:	fec42783          	lw	a5,-20(s0)
    800055a6:	07e9                	addi	a5,a5,26
    800055a8:	078e                	slli	a5,a5,0x3
    800055aa:	97aa                	add	a5,a5,a0
    800055ac:	0007b423          	sd	zero,8(a5)
  fileclose(f);
    800055b0:	fe043503          	ld	a0,-32(s0)
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	26a080e7          	jalr	618(ra) # 8000481e <fileclose>
  return 0;
    800055bc:	4781                	li	a5,0
}
    800055be:	853e                	mv	a0,a5
    800055c0:	60e2                	ld	ra,24(sp)
    800055c2:	6442                	ld	s0,16(sp)
    800055c4:	6105                	addi	sp,sp,32
    800055c6:	8082                	ret

00000000800055c8 <sys_fstat>:
{
    800055c8:	1101                	addi	sp,sp,-32
    800055ca:	ec06                	sd	ra,24(sp)
    800055cc:	e822                	sd	s0,16(sp)
    800055ce:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055d0:	fe840613          	addi	a2,s0,-24
    800055d4:	4581                	li	a1,0
    800055d6:	4501                	li	a0,0
    800055d8:	00000097          	auipc	ra,0x0
    800055dc:	c78080e7          	jalr	-904(ra) # 80005250 <argfd>
    return -1;
    800055e0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055e2:	02054563          	bltz	a0,8000560c <sys_fstat+0x44>
    800055e6:	fe040593          	addi	a1,s0,-32
    800055ea:	4505                	li	a0,1
    800055ec:	ffffd097          	auipc	ra,0xffffd
    800055f0:	630080e7          	jalr	1584(ra) # 80002c1c <argaddr>
    return -1;
    800055f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055f6:	00054b63          	bltz	a0,8000560c <sys_fstat+0x44>
  return filestat(f, st);
    800055fa:	fe043583          	ld	a1,-32(s0)
    800055fe:	fe843503          	ld	a0,-24(s0)
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	2ec080e7          	jalr	748(ra) # 800048ee <filestat>
    8000560a:	87aa                	mv	a5,a0
}
    8000560c:	853e                	mv	a0,a5
    8000560e:	60e2                	ld	ra,24(sp)
    80005610:	6442                	ld	s0,16(sp)
    80005612:	6105                	addi	sp,sp,32
    80005614:	8082                	ret

0000000080005616 <sys_link>:
{
    80005616:	7169                	addi	sp,sp,-304
    80005618:	f606                	sd	ra,296(sp)
    8000561a:	f222                	sd	s0,288(sp)
    8000561c:	ee26                	sd	s1,280(sp)
    8000561e:	ea4a                	sd	s2,272(sp)
    80005620:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005622:	08000613          	li	a2,128
    80005626:	ed040593          	addi	a1,s0,-304
    8000562a:	4501                	li	a0,0
    8000562c:	ffffd097          	auipc	ra,0xffffd
    80005630:	612080e7          	jalr	1554(ra) # 80002c3e <argstr>
    return -1;
    80005634:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005636:	12054363          	bltz	a0,8000575c <sys_link+0x146>
    8000563a:	08000613          	li	a2,128
    8000563e:	f5040593          	addi	a1,s0,-176
    80005642:	4505                	li	a0,1
    80005644:	ffffd097          	auipc	ra,0xffffd
    80005648:	5fa080e7          	jalr	1530(ra) # 80002c3e <argstr>
    return -1;
    8000564c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000564e:	10054763          	bltz	a0,8000575c <sys_link+0x146>
  begin_op(ROOTDEV);
    80005652:	4501                	li	a0,0
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	c30080e7          	jalr	-976(ra) # 80004284 <begin_op>
  if((ip = namei(old)) == 0){
    8000565c:	ed040513          	addi	a0,s0,-304
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	9c8080e7          	jalr	-1592(ra) # 80004028 <namei>
    80005668:	84aa                	mv	s1,a0
    8000566a:	c559                	beqz	a0,800056f8 <sys_link+0xe2>
  ilock(ip);
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	232080e7          	jalr	562(ra) # 8000389e <ilock>
  if(ip->type == T_DIR){
    80005674:	04c49703          	lh	a4,76(s1)
    80005678:	4785                	li	a5,1
    8000567a:	08f70663          	beq	a4,a5,80005706 <sys_link+0xf0>
  ip->nlink++;
    8000567e:	0524d783          	lhu	a5,82(s1)
    80005682:	2785                	addiw	a5,a5,1
    80005684:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005688:	8526                	mv	a0,s1
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	14a080e7          	jalr	330(ra) # 800037d4 <iupdate>
  iunlock(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	2cc080e7          	jalr	716(ra) # 80003960 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000569c:	fd040593          	addi	a1,s0,-48
    800056a0:	f5040513          	addi	a0,s0,-176
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	9a2080e7          	jalr	-1630(ra) # 80004046 <nameiparent>
    800056ac:	892a                	mv	s2,a0
    800056ae:	cd2d                	beqz	a0,80005728 <sys_link+0x112>
  ilock(dp);
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	1ee080e7          	jalr	494(ra) # 8000389e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800056b8:	00092703          	lw	a4,0(s2)
    800056bc:	409c                	lw	a5,0(s1)
    800056be:	06f71063          	bne	a4,a5,8000571e <sys_link+0x108>
    800056c2:	40d0                	lw	a2,4(s1)
    800056c4:	fd040593          	addi	a1,s0,-48
    800056c8:	854a                	mv	a0,s2
    800056ca:	fffff097          	auipc	ra,0xfffff
    800056ce:	89c080e7          	jalr	-1892(ra) # 80003f66 <dirlink>
    800056d2:	04054663          	bltz	a0,8000571e <sys_link+0x108>
  iunlockput(dp);
    800056d6:	854a                	mv	a0,s2
    800056d8:	ffffe097          	auipc	ra,0xffffe
    800056dc:	404080e7          	jalr	1028(ra) # 80003adc <iunlockput>
  iput(ip);
    800056e0:	8526                	mv	a0,s1
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	2ca080e7          	jalr	714(ra) # 800039ac <iput>
  end_op(ROOTDEV);
    800056ea:	4501                	li	a0,0
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	c42080e7          	jalr	-958(ra) # 8000432e <end_op>
  return 0;
    800056f4:	4781                	li	a5,0
    800056f6:	a09d                	j	8000575c <sys_link+0x146>
    end_op(ROOTDEV);
    800056f8:	4501                	li	a0,0
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	c34080e7          	jalr	-972(ra) # 8000432e <end_op>
    return -1;
    80005702:	57fd                	li	a5,-1
    80005704:	a8a1                	j	8000575c <sys_link+0x146>
    iunlockput(ip);
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	3d4080e7          	jalr	980(ra) # 80003adc <iunlockput>
    end_op(ROOTDEV);
    80005710:	4501                	li	a0,0
    80005712:	fffff097          	auipc	ra,0xfffff
    80005716:	c1c080e7          	jalr	-996(ra) # 8000432e <end_op>
    return -1;
    8000571a:	57fd                	li	a5,-1
    8000571c:	a081                	j	8000575c <sys_link+0x146>
    iunlockput(dp);
    8000571e:	854a                	mv	a0,s2
    80005720:	ffffe097          	auipc	ra,0xffffe
    80005724:	3bc080e7          	jalr	956(ra) # 80003adc <iunlockput>
  ilock(ip);
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	174080e7          	jalr	372(ra) # 8000389e <ilock>
  ip->nlink--;
    80005732:	0524d783          	lhu	a5,82(s1)
    80005736:	37fd                	addiw	a5,a5,-1
    80005738:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    8000573c:	8526                	mv	a0,s1
    8000573e:	ffffe097          	auipc	ra,0xffffe
    80005742:	096080e7          	jalr	150(ra) # 800037d4 <iupdate>
  iunlockput(ip);
    80005746:	8526                	mv	a0,s1
    80005748:	ffffe097          	auipc	ra,0xffffe
    8000574c:	394080e7          	jalr	916(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    80005750:	4501                	li	a0,0
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	bdc080e7          	jalr	-1060(ra) # 8000432e <end_op>
  return -1;
    8000575a:	57fd                	li	a5,-1
}
    8000575c:	853e                	mv	a0,a5
    8000575e:	70b2                	ld	ra,296(sp)
    80005760:	7412                	ld	s0,288(sp)
    80005762:	64f2                	ld	s1,280(sp)
    80005764:	6952                	ld	s2,272(sp)
    80005766:	6155                	addi	sp,sp,304
    80005768:	8082                	ret

000000008000576a <sys_unlink>:
{
    8000576a:	7151                	addi	sp,sp,-240
    8000576c:	f586                	sd	ra,232(sp)
    8000576e:	f1a2                	sd	s0,224(sp)
    80005770:	eda6                	sd	s1,216(sp)
    80005772:	e9ca                	sd	s2,208(sp)
    80005774:	e5ce                	sd	s3,200(sp)
    80005776:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005778:	08000613          	li	a2,128
    8000577c:	f3040593          	addi	a1,s0,-208
    80005780:	4501                	li	a0,0
    80005782:	ffffd097          	auipc	ra,0xffffd
    80005786:	4bc080e7          	jalr	1212(ra) # 80002c3e <argstr>
    8000578a:	18054463          	bltz	a0,80005912 <sys_unlink+0x1a8>
  begin_op(ROOTDEV);
    8000578e:	4501                	li	a0,0
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	af4080e7          	jalr	-1292(ra) # 80004284 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005798:	fb040593          	addi	a1,s0,-80
    8000579c:	f3040513          	addi	a0,s0,-208
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	8a6080e7          	jalr	-1882(ra) # 80004046 <nameiparent>
    800057a8:	84aa                	mv	s1,a0
    800057aa:	cd61                	beqz	a0,80005882 <sys_unlink+0x118>
  ilock(dp);
    800057ac:	ffffe097          	auipc	ra,0xffffe
    800057b0:	0f2080e7          	jalr	242(ra) # 8000389e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800057b4:	00003597          	auipc	a1,0x3
    800057b8:	08458593          	addi	a1,a1,132 # 80008838 <userret+0x7a8>
    800057bc:	fb040513          	addi	a0,s0,-80
    800057c0:	ffffe097          	auipc	ra,0xffffe
    800057c4:	57c080e7          	jalr	1404(ra) # 80003d3c <namecmp>
    800057c8:	14050c63          	beqz	a0,80005920 <sys_unlink+0x1b6>
    800057cc:	00003597          	auipc	a1,0x3
    800057d0:	07458593          	addi	a1,a1,116 # 80008840 <userret+0x7b0>
    800057d4:	fb040513          	addi	a0,s0,-80
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	564080e7          	jalr	1380(ra) # 80003d3c <namecmp>
    800057e0:	14050063          	beqz	a0,80005920 <sys_unlink+0x1b6>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800057e4:	f2c40613          	addi	a2,s0,-212
    800057e8:	fb040593          	addi	a1,s0,-80
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	568080e7          	jalr	1384(ra) # 80003d56 <dirlookup>
    800057f6:	892a                	mv	s2,a0
    800057f8:	12050463          	beqz	a0,80005920 <sys_unlink+0x1b6>
  ilock(ip);
    800057fc:	ffffe097          	auipc	ra,0xffffe
    80005800:	0a2080e7          	jalr	162(ra) # 8000389e <ilock>
  if(ip->nlink < 1)
    80005804:	05291783          	lh	a5,82(s2)
    80005808:	08f05463          	blez	a5,80005890 <sys_unlink+0x126>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000580c:	04c91703          	lh	a4,76(s2)
    80005810:	4785                	li	a5,1
    80005812:	08f70763          	beq	a4,a5,800058a0 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    80005816:	4641                	li	a2,16
    80005818:	4581                	li	a1,0
    8000581a:	fc040513          	addi	a0,s0,-64
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	678080e7          	jalr	1656(ra) # 80000e96 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005826:	4741                	li	a4,16
    80005828:	f2c42683          	lw	a3,-212(s0)
    8000582c:	fc040613          	addi	a2,s0,-64
    80005830:	4581                	li	a1,0
    80005832:	8526                	mv	a0,s1
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	3ee080e7          	jalr	1006(ra) # 80003c22 <writei>
    8000583c:	47c1                	li	a5,16
    8000583e:	0af51763          	bne	a0,a5,800058ec <sys_unlink+0x182>
  if(ip->type == T_DIR){
    80005842:	04c91703          	lh	a4,76(s2)
    80005846:	4785                	li	a5,1
    80005848:	0af70a63          	beq	a4,a5,800058fc <sys_unlink+0x192>
  iunlockput(dp);
    8000584c:	8526                	mv	a0,s1
    8000584e:	ffffe097          	auipc	ra,0xffffe
    80005852:	28e080e7          	jalr	654(ra) # 80003adc <iunlockput>
  ip->nlink--;
    80005856:	05295783          	lhu	a5,82(s2)
    8000585a:	37fd                	addiw	a5,a5,-1
    8000585c:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005860:	854a                	mv	a0,s2
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	f72080e7          	jalr	-142(ra) # 800037d4 <iupdate>
  iunlockput(ip);
    8000586a:	854a                	mv	a0,s2
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	270080e7          	jalr	624(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    80005874:	4501                	li	a0,0
    80005876:	fffff097          	auipc	ra,0xfffff
    8000587a:	ab8080e7          	jalr	-1352(ra) # 8000432e <end_op>
  return 0;
    8000587e:	4501                	li	a0,0
    80005880:	a85d                	j	80005936 <sys_unlink+0x1cc>
    end_op(ROOTDEV);
    80005882:	4501                	li	a0,0
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	aaa080e7          	jalr	-1366(ra) # 8000432e <end_op>
    return -1;
    8000588c:	557d                	li	a0,-1
    8000588e:	a065                	j	80005936 <sys_unlink+0x1cc>
    panic("unlink: nlink < 1");
    80005890:	00003517          	auipc	a0,0x3
    80005894:	fd850513          	addi	a0,a0,-40 # 80008868 <userret+0x7d8>
    80005898:	ffffb097          	auipc	ra,0xffffb
    8000589c:	cb0080e7          	jalr	-848(ra) # 80000548 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058a0:	05492703          	lw	a4,84(s2)
    800058a4:	02000793          	li	a5,32
    800058a8:	f6e7f7e3          	bgeu	a5,a4,80005816 <sys_unlink+0xac>
    800058ac:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058b0:	4741                	li	a4,16
    800058b2:	86ce                	mv	a3,s3
    800058b4:	f1840613          	addi	a2,s0,-232
    800058b8:	4581                	li	a1,0
    800058ba:	854a                	mv	a0,s2
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	272080e7          	jalr	626(ra) # 80003b2e <readi>
    800058c4:	47c1                	li	a5,16
    800058c6:	00f51b63          	bne	a0,a5,800058dc <sys_unlink+0x172>
    if(de.inum != 0)
    800058ca:	f1845783          	lhu	a5,-232(s0)
    800058ce:	e7a1                	bnez	a5,80005916 <sys_unlink+0x1ac>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800058d0:	29c1                	addiw	s3,s3,16
    800058d2:	05492783          	lw	a5,84(s2)
    800058d6:	fcf9ede3          	bltu	s3,a5,800058b0 <sys_unlink+0x146>
    800058da:	bf35                	j	80005816 <sys_unlink+0xac>
      panic("isdirempty: readi");
    800058dc:	00003517          	auipc	a0,0x3
    800058e0:	fa450513          	addi	a0,a0,-92 # 80008880 <userret+0x7f0>
    800058e4:	ffffb097          	auipc	ra,0xffffb
    800058e8:	c64080e7          	jalr	-924(ra) # 80000548 <panic>
    panic("unlink: writei");
    800058ec:	00003517          	auipc	a0,0x3
    800058f0:	fac50513          	addi	a0,a0,-84 # 80008898 <userret+0x808>
    800058f4:	ffffb097          	auipc	ra,0xffffb
    800058f8:	c54080e7          	jalr	-940(ra) # 80000548 <panic>
    dp->nlink--;
    800058fc:	0524d783          	lhu	a5,82(s1)
    80005900:	37fd                	addiw	a5,a5,-1
    80005902:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    80005906:	8526                	mv	a0,s1
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	ecc080e7          	jalr	-308(ra) # 800037d4 <iupdate>
    80005910:	bf35                	j	8000584c <sys_unlink+0xe2>
    return -1;
    80005912:	557d                	li	a0,-1
    80005914:	a00d                	j	80005936 <sys_unlink+0x1cc>
    iunlockput(ip);
    80005916:	854a                	mv	a0,s2
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	1c4080e7          	jalr	452(ra) # 80003adc <iunlockput>
  iunlockput(dp);
    80005920:	8526                	mv	a0,s1
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	1ba080e7          	jalr	442(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    8000592a:	4501                	li	a0,0
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	a02080e7          	jalr	-1534(ra) # 8000432e <end_op>
  return -1;
    80005934:	557d                	li	a0,-1
}
    80005936:	70ae                	ld	ra,232(sp)
    80005938:	740e                	ld	s0,224(sp)
    8000593a:	64ee                	ld	s1,216(sp)
    8000593c:	694e                	ld	s2,208(sp)
    8000593e:	69ae                	ld	s3,200(sp)
    80005940:	616d                	addi	sp,sp,240
    80005942:	8082                	ret

0000000080005944 <sys_open>:

uint64
sys_open(void)
{
    80005944:	7131                	addi	sp,sp,-192
    80005946:	fd06                	sd	ra,184(sp)
    80005948:	f922                	sd	s0,176(sp)
    8000594a:	f526                	sd	s1,168(sp)
    8000594c:	f14a                	sd	s2,160(sp)
    8000594e:	ed4e                	sd	s3,152(sp)
    80005950:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005952:	08000613          	li	a2,128
    80005956:	f5040593          	addi	a1,s0,-176
    8000595a:	4501                	li	a0,0
    8000595c:	ffffd097          	auipc	ra,0xffffd
    80005960:	2e2080e7          	jalr	738(ra) # 80002c3e <argstr>
    return -1;
    80005964:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005966:	0a054963          	bltz	a0,80005a18 <sys_open+0xd4>
    8000596a:	f4c40593          	addi	a1,s0,-180
    8000596e:	4505                	li	a0,1
    80005970:	ffffd097          	auipc	ra,0xffffd
    80005974:	28a080e7          	jalr	650(ra) # 80002bfa <argint>
    80005978:	0a054063          	bltz	a0,80005a18 <sys_open+0xd4>

  begin_op(ROOTDEV);
    8000597c:	4501                	li	a0,0
    8000597e:	fffff097          	auipc	ra,0xfffff
    80005982:	906080e7          	jalr	-1786(ra) # 80004284 <begin_op>

  if(omode & O_CREATE){
    80005986:	f4c42783          	lw	a5,-180(s0)
    8000598a:	2007f793          	andi	a5,a5,512
    8000598e:	c3dd                	beqz	a5,80005a34 <sys_open+0xf0>
    ip = create(path, T_FILE, 0, 0);
    80005990:	4681                	li	a3,0
    80005992:	4601                	li	a2,0
    80005994:	4589                	li	a1,2
    80005996:	f5040513          	addi	a0,s0,-176
    8000599a:	00000097          	auipc	ra,0x0
    8000599e:	960080e7          	jalr	-1696(ra) # 800052fa <create>
    800059a2:	892a                	mv	s2,a0
    if(ip == 0){
    800059a4:	c151                	beqz	a0,80005a28 <sys_open+0xe4>
      end_op(ROOTDEV);
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800059a6:	04c91703          	lh	a4,76(s2)
    800059aa:	478d                	li	a5,3
    800059ac:	00f71763          	bne	a4,a5,800059ba <sys_open+0x76>
    800059b0:	04e95703          	lhu	a4,78(s2)
    800059b4:	47a5                	li	a5,9
    800059b6:	0ce7e663          	bltu	a5,a4,80005a82 <sys_open+0x13e>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	da8080e7          	jalr	-600(ra) # 80004762 <filealloc>
    800059c2:	89aa                	mv	s3,a0
    800059c4:	c97d                	beqz	a0,80005aba <sys_open+0x176>
    800059c6:	00000097          	auipc	ra,0x0
    800059ca:	8f2080e7          	jalr	-1806(ra) # 800052b8 <fdalloc>
    800059ce:	84aa                	mv	s1,a0
    800059d0:	0e054063          	bltz	a0,80005ab0 <sys_open+0x16c>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }

  if(ip->type == T_DEVICE){
    800059d4:	04c91703          	lh	a4,76(s2)
    800059d8:	478d                	li	a5,3
    800059da:	0cf70063          	beq	a4,a5,80005a9a <sys_open+0x156>
    f->type = FD_DEVICE;
    f->major = ip->major;
    f->minor = ip->minor;
  } else {
    f->type = FD_INODE;
    800059de:	4789                	li	a5,2
    800059e0:	00f9a023          	sw	a5,0(s3)
  }
  f->ip = ip;
    800059e4:	0129bc23          	sd	s2,24(s3)
  f->off = 0;
    800059e8:	0209a023          	sw	zero,32(s3)
  f->readable = !(omode & O_WRONLY);
    800059ec:	f4c42783          	lw	a5,-180(s0)
    800059f0:	0017c713          	xori	a4,a5,1
    800059f4:	8b05                	andi	a4,a4,1
    800059f6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059fa:	8b8d                	andi	a5,a5,3
    800059fc:	00f037b3          	snez	a5,a5
    80005a00:	00f984a3          	sb	a5,9(s3)

  iunlock(ip);
    80005a04:	854a                	mv	a0,s2
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	f5a080e7          	jalr	-166(ra) # 80003960 <iunlock>
  end_op(ROOTDEV);
    80005a0e:	4501                	li	a0,0
    80005a10:	fffff097          	auipc	ra,0xfffff
    80005a14:	91e080e7          	jalr	-1762(ra) # 8000432e <end_op>

  return fd;
}
    80005a18:	8526                	mv	a0,s1
    80005a1a:	70ea                	ld	ra,184(sp)
    80005a1c:	744a                	ld	s0,176(sp)
    80005a1e:	74aa                	ld	s1,168(sp)
    80005a20:	790a                	ld	s2,160(sp)
    80005a22:	69ea                	ld	s3,152(sp)
    80005a24:	6129                	addi	sp,sp,192
    80005a26:	8082                	ret
      end_op(ROOTDEV);
    80005a28:	4501                	li	a0,0
    80005a2a:	fffff097          	auipc	ra,0xfffff
    80005a2e:	904080e7          	jalr	-1788(ra) # 8000432e <end_op>
      return -1;
    80005a32:	b7dd                	j	80005a18 <sys_open+0xd4>
    if((ip = namei(path)) == 0){
    80005a34:	f5040513          	addi	a0,s0,-176
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	5f0080e7          	jalr	1520(ra) # 80004028 <namei>
    80005a40:	892a                	mv	s2,a0
    80005a42:	c90d                	beqz	a0,80005a74 <sys_open+0x130>
    ilock(ip);
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	e5a080e7          	jalr	-422(ra) # 8000389e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a4c:	04c91703          	lh	a4,76(s2)
    80005a50:	4785                	li	a5,1
    80005a52:	f4f71ae3          	bne	a4,a5,800059a6 <sys_open+0x62>
    80005a56:	f4c42783          	lw	a5,-180(s0)
    80005a5a:	d3a5                	beqz	a5,800059ba <sys_open+0x76>
      iunlockput(ip);
    80005a5c:	854a                	mv	a0,s2
    80005a5e:	ffffe097          	auipc	ra,0xffffe
    80005a62:	07e080e7          	jalr	126(ra) # 80003adc <iunlockput>
      end_op(ROOTDEV);
    80005a66:	4501                	li	a0,0
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	8c6080e7          	jalr	-1850(ra) # 8000432e <end_op>
      return -1;
    80005a70:	54fd                	li	s1,-1
    80005a72:	b75d                	j	80005a18 <sys_open+0xd4>
      end_op(ROOTDEV);
    80005a74:	4501                	li	a0,0
    80005a76:	fffff097          	auipc	ra,0xfffff
    80005a7a:	8b8080e7          	jalr	-1864(ra) # 8000432e <end_op>
      return -1;
    80005a7e:	54fd                	li	s1,-1
    80005a80:	bf61                	j	80005a18 <sys_open+0xd4>
    iunlockput(ip);
    80005a82:	854a                	mv	a0,s2
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	058080e7          	jalr	88(ra) # 80003adc <iunlockput>
    end_op(ROOTDEV);
    80005a8c:	4501                	li	a0,0
    80005a8e:	fffff097          	auipc	ra,0xfffff
    80005a92:	8a0080e7          	jalr	-1888(ra) # 8000432e <end_op>
    return -1;
    80005a96:	54fd                	li	s1,-1
    80005a98:	b741                	j	80005a18 <sys_open+0xd4>
    f->type = FD_DEVICE;
    80005a9a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a9e:	04e91783          	lh	a5,78(s2)
    80005aa2:	02f99223          	sh	a5,36(s3)
    f->minor = ip->minor;
    80005aa6:	05091783          	lh	a5,80(s2)
    80005aaa:	02f99323          	sh	a5,38(s3)
    80005aae:	bf1d                	j	800059e4 <sys_open+0xa0>
      fileclose(f);
    80005ab0:	854e                	mv	a0,s3
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	d6c080e7          	jalr	-660(ra) # 8000481e <fileclose>
    iunlockput(ip);
    80005aba:	854a                	mv	a0,s2
    80005abc:	ffffe097          	auipc	ra,0xffffe
    80005ac0:	020080e7          	jalr	32(ra) # 80003adc <iunlockput>
    end_op(ROOTDEV);
    80005ac4:	4501                	li	a0,0
    80005ac6:	fffff097          	auipc	ra,0xfffff
    80005aca:	868080e7          	jalr	-1944(ra) # 8000432e <end_op>
    return -1;
    80005ace:	54fd                	li	s1,-1
    80005ad0:	b7a1                	j	80005a18 <sys_open+0xd4>

0000000080005ad2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005ad2:	7175                	addi	sp,sp,-144
    80005ad4:	e506                	sd	ra,136(sp)
    80005ad6:	e122                	sd	s0,128(sp)
    80005ad8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op(ROOTDEV);
    80005ada:	4501                	li	a0,0
    80005adc:	ffffe097          	auipc	ra,0xffffe
    80005ae0:	7a8080e7          	jalr	1960(ra) # 80004284 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005ae4:	08000613          	li	a2,128
    80005ae8:	f7040593          	addi	a1,s0,-144
    80005aec:	4501                	li	a0,0
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	150080e7          	jalr	336(ra) # 80002c3e <argstr>
    80005af6:	02054a63          	bltz	a0,80005b2a <sys_mkdir+0x58>
    80005afa:	4681                	li	a3,0
    80005afc:	4601                	li	a2,0
    80005afe:	4585                	li	a1,1
    80005b00:	f7040513          	addi	a0,s0,-144
    80005b04:	fffff097          	auipc	ra,0xfffff
    80005b08:	7f6080e7          	jalr	2038(ra) # 800052fa <create>
    80005b0c:	cd19                	beqz	a0,80005b2a <sys_mkdir+0x58>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005b0e:	ffffe097          	auipc	ra,0xffffe
    80005b12:	fce080e7          	jalr	-50(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    80005b16:	4501                	li	a0,0
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	816080e7          	jalr	-2026(ra) # 8000432e <end_op>
  return 0;
    80005b20:	4501                	li	a0,0
}
    80005b22:	60aa                	ld	ra,136(sp)
    80005b24:	640a                	ld	s0,128(sp)
    80005b26:	6149                	addi	sp,sp,144
    80005b28:	8082                	ret
    end_op(ROOTDEV);
    80005b2a:	4501                	li	a0,0
    80005b2c:	fffff097          	auipc	ra,0xfffff
    80005b30:	802080e7          	jalr	-2046(ra) # 8000432e <end_op>
    return -1;
    80005b34:	557d                	li	a0,-1
    80005b36:	b7f5                	j	80005b22 <sys_mkdir+0x50>

0000000080005b38 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005b38:	7135                	addi	sp,sp,-160
    80005b3a:	ed06                	sd	ra,152(sp)
    80005b3c:	e922                	sd	s0,144(sp)
    80005b3e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op(ROOTDEV);
    80005b40:	4501                	li	a0,0
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	742080e7          	jalr	1858(ra) # 80004284 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b4a:	08000613          	li	a2,128
    80005b4e:	f7040593          	addi	a1,s0,-144
    80005b52:	4501                	li	a0,0
    80005b54:	ffffd097          	auipc	ra,0xffffd
    80005b58:	0ea080e7          	jalr	234(ra) # 80002c3e <argstr>
    80005b5c:	04054b63          	bltz	a0,80005bb2 <sys_mknod+0x7a>
     argint(1, &major) < 0 ||
    80005b60:	f6c40593          	addi	a1,s0,-148
    80005b64:	4505                	li	a0,1
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	094080e7          	jalr	148(ra) # 80002bfa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b6e:	04054263          	bltz	a0,80005bb2 <sys_mknod+0x7a>
     argint(2, &minor) < 0 ||
    80005b72:	f6840593          	addi	a1,s0,-152
    80005b76:	4509                	li	a0,2
    80005b78:	ffffd097          	auipc	ra,0xffffd
    80005b7c:	082080e7          	jalr	130(ra) # 80002bfa <argint>
     argint(1, &major) < 0 ||
    80005b80:	02054963          	bltz	a0,80005bb2 <sys_mknod+0x7a>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b84:	f6841683          	lh	a3,-152(s0)
    80005b88:	f6c41603          	lh	a2,-148(s0)
    80005b8c:	458d                	li	a1,3
    80005b8e:	f7040513          	addi	a0,s0,-144
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	768080e7          	jalr	1896(ra) # 800052fa <create>
     argint(2, &minor) < 0 ||
    80005b9a:	cd01                	beqz	a0,80005bb2 <sys_mknod+0x7a>
    end_op(ROOTDEV);
    return -1;
  }
  iunlockput(ip);
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	f40080e7          	jalr	-192(ra) # 80003adc <iunlockput>
  end_op(ROOTDEV);
    80005ba4:	4501                	li	a0,0
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	788080e7          	jalr	1928(ra) # 8000432e <end_op>
  return 0;
    80005bae:	4501                	li	a0,0
    80005bb0:	a039                	j	80005bbe <sys_mknod+0x86>
    end_op(ROOTDEV);
    80005bb2:	4501                	li	a0,0
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	77a080e7          	jalr	1914(ra) # 8000432e <end_op>
    return -1;
    80005bbc:	557d                	li	a0,-1
}
    80005bbe:	60ea                	ld	ra,152(sp)
    80005bc0:	644a                	ld	s0,144(sp)
    80005bc2:	610d                	addi	sp,sp,160
    80005bc4:	8082                	ret

0000000080005bc6 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005bc6:	7135                	addi	sp,sp,-160
    80005bc8:	ed06                	sd	ra,152(sp)
    80005bca:	e922                	sd	s0,144(sp)
    80005bcc:	e526                	sd	s1,136(sp)
    80005bce:	e14a                	sd	s2,128(sp)
    80005bd0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005bd2:	ffffc097          	auipc	ra,0xffffc
    80005bd6:	fae080e7          	jalr	-82(ra) # 80001b80 <myproc>
    80005bda:	892a                	mv	s2,a0
  
  begin_op(ROOTDEV);
    80005bdc:	4501                	li	a0,0
    80005bde:	ffffe097          	auipc	ra,0xffffe
    80005be2:	6a6080e7          	jalr	1702(ra) # 80004284 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005be6:	08000613          	li	a2,128
    80005bea:	f6040593          	addi	a1,s0,-160
    80005bee:	4501                	li	a0,0
    80005bf0:	ffffd097          	auipc	ra,0xffffd
    80005bf4:	04e080e7          	jalr	78(ra) # 80002c3e <argstr>
    80005bf8:	04054c63          	bltz	a0,80005c50 <sys_chdir+0x8a>
    80005bfc:	f6040513          	addi	a0,s0,-160
    80005c00:	ffffe097          	auipc	ra,0xffffe
    80005c04:	428080e7          	jalr	1064(ra) # 80004028 <namei>
    80005c08:	84aa                	mv	s1,a0
    80005c0a:	c139                	beqz	a0,80005c50 <sys_chdir+0x8a>
    end_op(ROOTDEV);
    return -1;
  }
  ilock(ip);
    80005c0c:	ffffe097          	auipc	ra,0xffffe
    80005c10:	c92080e7          	jalr	-878(ra) # 8000389e <ilock>
  if(ip->type != T_DIR){
    80005c14:	04c49703          	lh	a4,76(s1)
    80005c18:	4785                	li	a5,1
    80005c1a:	04f71263          	bne	a4,a5,80005c5e <sys_chdir+0x98>
    iunlockput(ip);
    end_op(ROOTDEV);
    return -1;
  }
  iunlock(ip);
    80005c1e:	8526                	mv	a0,s1
    80005c20:	ffffe097          	auipc	ra,0xffffe
    80005c24:	d40080e7          	jalr	-704(ra) # 80003960 <iunlock>
  iput(p->cwd);
    80005c28:	15893503          	ld	a0,344(s2)
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	d80080e7          	jalr	-640(ra) # 800039ac <iput>
  end_op(ROOTDEV);
    80005c34:	4501                	li	a0,0
    80005c36:	ffffe097          	auipc	ra,0xffffe
    80005c3a:	6f8080e7          	jalr	1784(ra) # 8000432e <end_op>
  p->cwd = ip;
    80005c3e:	14993c23          	sd	s1,344(s2)
  return 0;
    80005c42:	4501                	li	a0,0
}
    80005c44:	60ea                	ld	ra,152(sp)
    80005c46:	644a                	ld	s0,144(sp)
    80005c48:	64aa                	ld	s1,136(sp)
    80005c4a:	690a                	ld	s2,128(sp)
    80005c4c:	610d                	addi	sp,sp,160
    80005c4e:	8082                	ret
    end_op(ROOTDEV);
    80005c50:	4501                	li	a0,0
    80005c52:	ffffe097          	auipc	ra,0xffffe
    80005c56:	6dc080e7          	jalr	1756(ra) # 8000432e <end_op>
    return -1;
    80005c5a:	557d                	li	a0,-1
    80005c5c:	b7e5                	j	80005c44 <sys_chdir+0x7e>
    iunlockput(ip);
    80005c5e:	8526                	mv	a0,s1
    80005c60:	ffffe097          	auipc	ra,0xffffe
    80005c64:	e7c080e7          	jalr	-388(ra) # 80003adc <iunlockput>
    end_op(ROOTDEV);
    80005c68:	4501                	li	a0,0
    80005c6a:	ffffe097          	auipc	ra,0xffffe
    80005c6e:	6c4080e7          	jalr	1732(ra) # 8000432e <end_op>
    return -1;
    80005c72:	557d                	li	a0,-1
    80005c74:	bfc1                	j	80005c44 <sys_chdir+0x7e>

0000000080005c76 <sys_exec>:

uint64
sys_exec(void)
{
    80005c76:	7145                	addi	sp,sp,-464
    80005c78:	e786                	sd	ra,456(sp)
    80005c7a:	e3a2                	sd	s0,448(sp)
    80005c7c:	ff26                	sd	s1,440(sp)
    80005c7e:	fb4a                	sd	s2,432(sp)
    80005c80:	f74e                	sd	s3,424(sp)
    80005c82:	f352                	sd	s4,416(sp)
    80005c84:	ef56                	sd	s5,408(sp)
    80005c86:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c88:	08000613          	li	a2,128
    80005c8c:	f4040593          	addi	a1,s0,-192
    80005c90:	4501                	li	a0,0
    80005c92:	ffffd097          	auipc	ra,0xffffd
    80005c96:	fac080e7          	jalr	-84(ra) # 80002c3e <argstr>
    80005c9a:	0e054663          	bltz	a0,80005d86 <sys_exec+0x110>
    80005c9e:	e3840593          	addi	a1,s0,-456
    80005ca2:	4505                	li	a0,1
    80005ca4:	ffffd097          	auipc	ra,0xffffd
    80005ca8:	f78080e7          	jalr	-136(ra) # 80002c1c <argaddr>
    80005cac:	0e054763          	bltz	a0,80005d9a <sys_exec+0x124>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
    80005cb0:	10000613          	li	a2,256
    80005cb4:	4581                	li	a1,0
    80005cb6:	e4040513          	addi	a0,s0,-448
    80005cba:	ffffb097          	auipc	ra,0xffffb
    80005cbe:	1dc080e7          	jalr	476(ra) # 80000e96 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005cc2:	e4040913          	addi	s2,s0,-448
  memset(argv, 0, sizeof(argv));
    80005cc6:	89ca                	mv	s3,s2
    80005cc8:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80005cca:	02000a13          	li	s4,32
    80005cce:	00048a9b          	sext.w	s5,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005cd2:	00349793          	slli	a5,s1,0x3
    80005cd6:	e3040593          	addi	a1,s0,-464
    80005cda:	e3843503          	ld	a0,-456(s0)
    80005cde:	953e                	add	a0,a0,a5
    80005ce0:	ffffd097          	auipc	ra,0xffffd
    80005ce4:	e80080e7          	jalr	-384(ra) # 80002b60 <fetchaddr>
    80005ce8:	02054a63          	bltz	a0,80005d1c <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005cec:	e3043783          	ld	a5,-464(s0)
    80005cf0:	c7a1                	beqz	a5,80005d38 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005cf2:	ffffb097          	auipc	ra,0xffffb
    80005cf6:	d60080e7          	jalr	-672(ra) # 80000a52 <kalloc>
    80005cfa:	85aa                	mv	a1,a0
    80005cfc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d00:	c92d                	beqz	a0,80005d72 <sys_exec+0xfc>
      panic("sys_exec kalloc");
    if(fetchstr(uarg, argv[i], PGSIZE) < 0){
    80005d02:	6605                	lui	a2,0x1
    80005d04:	e3043503          	ld	a0,-464(s0)
    80005d08:	ffffd097          	auipc	ra,0xffffd
    80005d0c:	eaa080e7          	jalr	-342(ra) # 80002bb2 <fetchstr>
    80005d10:	00054663          	bltz	a0,80005d1c <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005d14:	0485                	addi	s1,s1,1
    80005d16:	09a1                	addi	s3,s3,8
    80005d18:	fb449be3          	bne	s1,s4,80005cce <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d1c:	10090493          	addi	s1,s2,256
    80005d20:	00093503          	ld	a0,0(s2)
    80005d24:	cd39                	beqz	a0,80005d82 <sys_exec+0x10c>
    kfree(argv[i]);
    80005d26:	ffffb097          	auipc	ra,0xffffb
    80005d2a:	b3e080e7          	jalr	-1218(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d2e:	0921                	addi	s2,s2,8
    80005d30:	fe9918e3          	bne	s2,s1,80005d20 <sys_exec+0xaa>
  return -1;
    80005d34:	557d                	li	a0,-1
    80005d36:	a889                	j	80005d88 <sys_exec+0x112>
      argv[i] = 0;
    80005d38:	0a8e                	slli	s5,s5,0x3
    80005d3a:	fc040793          	addi	a5,s0,-64
    80005d3e:	9abe                	add	s5,s5,a5
    80005d40:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005d44:	e4040593          	addi	a1,s0,-448
    80005d48:	f4040513          	addi	a0,s0,-192
    80005d4c:	fffff097          	auipc	ra,0xfffff
    80005d50:	178080e7          	jalr	376(ra) # 80004ec4 <exec>
    80005d54:	84aa                	mv	s1,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d56:	10090993          	addi	s3,s2,256
    80005d5a:	00093503          	ld	a0,0(s2)
    80005d5e:	c901                	beqz	a0,80005d6e <sys_exec+0xf8>
    kfree(argv[i]);
    80005d60:	ffffb097          	auipc	ra,0xffffb
    80005d64:	b04080e7          	jalr	-1276(ra) # 80000864 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d68:	0921                	addi	s2,s2,8
    80005d6a:	ff3918e3          	bne	s2,s3,80005d5a <sys_exec+0xe4>
  return ret;
    80005d6e:	8526                	mv	a0,s1
    80005d70:	a821                	j	80005d88 <sys_exec+0x112>
      panic("sys_exec kalloc");
    80005d72:	00003517          	auipc	a0,0x3
    80005d76:	b3650513          	addi	a0,a0,-1226 # 800088a8 <userret+0x818>
    80005d7a:	ffffa097          	auipc	ra,0xffffa
    80005d7e:	7ce080e7          	jalr	1998(ra) # 80000548 <panic>
  return -1;
    80005d82:	557d                	li	a0,-1
    80005d84:	a011                	j	80005d88 <sys_exec+0x112>
    return -1;
    80005d86:	557d                	li	a0,-1
}
    80005d88:	60be                	ld	ra,456(sp)
    80005d8a:	641e                	ld	s0,448(sp)
    80005d8c:	74fa                	ld	s1,440(sp)
    80005d8e:	795a                	ld	s2,432(sp)
    80005d90:	79ba                	ld	s3,424(sp)
    80005d92:	7a1a                	ld	s4,416(sp)
    80005d94:	6afa                	ld	s5,408(sp)
    80005d96:	6179                	addi	sp,sp,464
    80005d98:	8082                	ret
    return -1;
    80005d9a:	557d                	li	a0,-1
    80005d9c:	b7f5                	j	80005d88 <sys_exec+0x112>

0000000080005d9e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d9e:	7139                	addi	sp,sp,-64
    80005da0:	fc06                	sd	ra,56(sp)
    80005da2:	f822                	sd	s0,48(sp)
    80005da4:	f426                	sd	s1,40(sp)
    80005da6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	dd8080e7          	jalr	-552(ra) # 80001b80 <myproc>
    80005db0:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005db2:	fd840593          	addi	a1,s0,-40
    80005db6:	4501                	li	a0,0
    80005db8:	ffffd097          	auipc	ra,0xffffd
    80005dbc:	e64080e7          	jalr	-412(ra) # 80002c1c <argaddr>
    return -1;
    80005dc0:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005dc2:	0e054063          	bltz	a0,80005ea2 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005dc6:	fc840593          	addi	a1,s0,-56
    80005dca:	fd040513          	addi	a0,s0,-48
    80005dce:	fffff097          	auipc	ra,0xfffff
    80005dd2:	db4080e7          	jalr	-588(ra) # 80004b82 <pipealloc>
    return -1;
    80005dd6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005dd8:	0c054563          	bltz	a0,80005ea2 <sys_pipe+0x104>
  fd0 = -1;
    80005ddc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005de0:	fd043503          	ld	a0,-48(s0)
    80005de4:	fffff097          	auipc	ra,0xfffff
    80005de8:	4d4080e7          	jalr	1236(ra) # 800052b8 <fdalloc>
    80005dec:	fca42223          	sw	a0,-60(s0)
    80005df0:	08054c63          	bltz	a0,80005e88 <sys_pipe+0xea>
    80005df4:	fc843503          	ld	a0,-56(s0)
    80005df8:	fffff097          	auipc	ra,0xfffff
    80005dfc:	4c0080e7          	jalr	1216(ra) # 800052b8 <fdalloc>
    80005e00:	fca42023          	sw	a0,-64(s0)
    80005e04:	06054863          	bltz	a0,80005e74 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e08:	4691                	li	a3,4
    80005e0a:	fc440613          	addi	a2,s0,-60
    80005e0e:	fd843583          	ld	a1,-40(s0)
    80005e12:	6ca8                	ld	a0,88(s1)
    80005e14:	ffffc097          	auipc	ra,0xffffc
    80005e18:	a5e080e7          	jalr	-1442(ra) # 80001872 <copyout>
    80005e1c:	02054063          	bltz	a0,80005e3c <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e20:	4691                	li	a3,4
    80005e22:	fc040613          	addi	a2,s0,-64
    80005e26:	fd843583          	ld	a1,-40(s0)
    80005e2a:	0591                	addi	a1,a1,4
    80005e2c:	6ca8                	ld	a0,88(s1)
    80005e2e:	ffffc097          	auipc	ra,0xffffc
    80005e32:	a44080e7          	jalr	-1468(ra) # 80001872 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005e36:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e38:	06055563          	bgez	a0,80005ea2 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005e3c:	fc442783          	lw	a5,-60(s0)
    80005e40:	07e9                	addi	a5,a5,26
    80005e42:	078e                	slli	a5,a5,0x3
    80005e44:	97a6                	add	a5,a5,s1
    80005e46:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005e4a:	fc042503          	lw	a0,-64(s0)
    80005e4e:	0569                	addi	a0,a0,26
    80005e50:	050e                	slli	a0,a0,0x3
    80005e52:	9526                	add	a0,a0,s1
    80005e54:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e58:	fd043503          	ld	a0,-48(s0)
    80005e5c:	fffff097          	auipc	ra,0xfffff
    80005e60:	9c2080e7          	jalr	-1598(ra) # 8000481e <fileclose>
    fileclose(wf);
    80005e64:	fc843503          	ld	a0,-56(s0)
    80005e68:	fffff097          	auipc	ra,0xfffff
    80005e6c:	9b6080e7          	jalr	-1610(ra) # 8000481e <fileclose>
    return -1;
    80005e70:	57fd                	li	a5,-1
    80005e72:	a805                	j	80005ea2 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e74:	fc442783          	lw	a5,-60(s0)
    80005e78:	0007c863          	bltz	a5,80005e88 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e7c:	01a78513          	addi	a0,a5,26
    80005e80:	050e                	slli	a0,a0,0x3
    80005e82:	9526                	add	a0,a0,s1
    80005e84:	00053423          	sd	zero,8(a0)
    fileclose(rf);
    80005e88:	fd043503          	ld	a0,-48(s0)
    80005e8c:	fffff097          	auipc	ra,0xfffff
    80005e90:	992080e7          	jalr	-1646(ra) # 8000481e <fileclose>
    fileclose(wf);
    80005e94:	fc843503          	ld	a0,-56(s0)
    80005e98:	fffff097          	auipc	ra,0xfffff
    80005e9c:	986080e7          	jalr	-1658(ra) # 8000481e <fileclose>
    return -1;
    80005ea0:	57fd                	li	a5,-1
}
    80005ea2:	853e                	mv	a0,a5
    80005ea4:	70e2                	ld	ra,56(sp)
    80005ea6:	7442                	ld	s0,48(sp)
    80005ea8:	74a2                	ld	s1,40(sp)
    80005eaa:	6121                	addi	sp,sp,64
    80005eac:	8082                	ret
	...

0000000080005eb0 <kernelvec>:
    80005eb0:	7111                	addi	sp,sp,-256
    80005eb2:	e006                	sd	ra,0(sp)
    80005eb4:	e40a                	sd	sp,8(sp)
    80005eb6:	e80e                	sd	gp,16(sp)
    80005eb8:	ec12                	sd	tp,24(sp)
    80005eba:	f016                	sd	t0,32(sp)
    80005ebc:	f41a                	sd	t1,40(sp)
    80005ebe:	f81e                	sd	t2,48(sp)
    80005ec0:	fc22                	sd	s0,56(sp)
    80005ec2:	e0a6                	sd	s1,64(sp)
    80005ec4:	e4aa                	sd	a0,72(sp)
    80005ec6:	e8ae                	sd	a1,80(sp)
    80005ec8:	ecb2                	sd	a2,88(sp)
    80005eca:	f0b6                	sd	a3,96(sp)
    80005ecc:	f4ba                	sd	a4,104(sp)
    80005ece:	f8be                	sd	a5,112(sp)
    80005ed0:	fcc2                	sd	a6,120(sp)
    80005ed2:	e146                	sd	a7,128(sp)
    80005ed4:	e54a                	sd	s2,136(sp)
    80005ed6:	e94e                	sd	s3,144(sp)
    80005ed8:	ed52                	sd	s4,152(sp)
    80005eda:	f156                	sd	s5,160(sp)
    80005edc:	f55a                	sd	s6,168(sp)
    80005ede:	f95e                	sd	s7,176(sp)
    80005ee0:	fd62                	sd	s8,184(sp)
    80005ee2:	e1e6                	sd	s9,192(sp)
    80005ee4:	e5ea                	sd	s10,200(sp)
    80005ee6:	e9ee                	sd	s11,208(sp)
    80005ee8:	edf2                	sd	t3,216(sp)
    80005eea:	f1f6                	sd	t4,224(sp)
    80005eec:	f5fa                	sd	t5,232(sp)
    80005eee:	f9fe                	sd	t6,240(sp)
    80005ef0:	b3dfc0ef          	jal	ra,80002a2c <kerneltrap>
    80005ef4:	6082                	ld	ra,0(sp)
    80005ef6:	6122                	ld	sp,8(sp)
    80005ef8:	61c2                	ld	gp,16(sp)
    80005efa:	7282                	ld	t0,32(sp)
    80005efc:	7322                	ld	t1,40(sp)
    80005efe:	73c2                	ld	t2,48(sp)
    80005f00:	7462                	ld	s0,56(sp)
    80005f02:	6486                	ld	s1,64(sp)
    80005f04:	6526                	ld	a0,72(sp)
    80005f06:	65c6                	ld	a1,80(sp)
    80005f08:	6666                	ld	a2,88(sp)
    80005f0a:	7686                	ld	a3,96(sp)
    80005f0c:	7726                	ld	a4,104(sp)
    80005f0e:	77c6                	ld	a5,112(sp)
    80005f10:	7866                	ld	a6,120(sp)
    80005f12:	688a                	ld	a7,128(sp)
    80005f14:	692a                	ld	s2,136(sp)
    80005f16:	69ca                	ld	s3,144(sp)
    80005f18:	6a6a                	ld	s4,152(sp)
    80005f1a:	7a8a                	ld	s5,160(sp)
    80005f1c:	7b2a                	ld	s6,168(sp)
    80005f1e:	7bca                	ld	s7,176(sp)
    80005f20:	7c6a                	ld	s8,184(sp)
    80005f22:	6c8e                	ld	s9,192(sp)
    80005f24:	6d2e                	ld	s10,200(sp)
    80005f26:	6dce                	ld	s11,208(sp)
    80005f28:	6e6e                	ld	t3,216(sp)
    80005f2a:	7e8e                	ld	t4,224(sp)
    80005f2c:	7f2e                	ld	t5,232(sp)
    80005f2e:	7fce                	ld	t6,240(sp)
    80005f30:	6111                	addi	sp,sp,256
    80005f32:	10200073          	sret
    80005f36:	00000013          	nop
    80005f3a:	00000013          	nop
    80005f3e:	0001                	nop

0000000080005f40 <timervec>:
    80005f40:	34051573          	csrrw	a0,mscratch,a0
    80005f44:	e10c                	sd	a1,0(a0)
    80005f46:	e510                	sd	a2,8(a0)
    80005f48:	e914                	sd	a3,16(a0)
    80005f4a:	710c                	ld	a1,32(a0)
    80005f4c:	7510                	ld	a2,40(a0)
    80005f4e:	6194                	ld	a3,0(a1)
    80005f50:	96b2                	add	a3,a3,a2
    80005f52:	e194                	sd	a3,0(a1)
    80005f54:	4589                	li	a1,2
    80005f56:	14459073          	csrw	sip,a1
    80005f5a:	6914                	ld	a3,16(a0)
    80005f5c:	6510                	ld	a2,8(a0)
    80005f5e:	610c                	ld	a1,0(a0)
    80005f60:	34051573          	csrrw	a0,mscratch,a0
    80005f64:	30200073          	mret
	...

0000000080005f6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005f6a:	1141                	addi	sp,sp,-16
    80005f6c:	e422                	sd	s0,8(sp)
    80005f6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005f70:	0c0007b7          	lui	a5,0xc000
    80005f74:	4705                	li	a4,1
    80005f76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005f78:	c3d8                	sw	a4,4(a5)
}
    80005f7a:	6422                	ld	s0,8(sp)
    80005f7c:	0141                	addi	sp,sp,16
    80005f7e:	8082                	ret

0000000080005f80 <plicinithart>:

void
plicinithart(void)
{
    80005f80:	1141                	addi	sp,sp,-16
    80005f82:	e406                	sd	ra,8(sp)
    80005f84:	e022                	sd	s0,0(sp)
    80005f86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f88:	ffffc097          	auipc	ra,0xffffc
    80005f8c:	bcc080e7          	jalr	-1076(ra) # 80001b54 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f90:	0085171b          	slliw	a4,a0,0x8
    80005f94:	0c0027b7          	lui	a5,0xc002
    80005f98:	97ba                	add	a5,a5,a4
    80005f9a:	40200713          	li	a4,1026
    80005f9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005fa2:	00d5151b          	slliw	a0,a0,0xd
    80005fa6:	0c2017b7          	lui	a5,0xc201
    80005faa:	953e                	add	a0,a0,a5
    80005fac:	00052023          	sw	zero,0(a0)
}
    80005fb0:	60a2                	ld	ra,8(sp)
    80005fb2:	6402                	ld	s0,0(sp)
    80005fb4:	0141                	addi	sp,sp,16
    80005fb6:	8082                	ret

0000000080005fb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005fb8:	1141                	addi	sp,sp,-16
    80005fba:	e406                	sd	ra,8(sp)
    80005fbc:	e022                	sd	s0,0(sp)
    80005fbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005fc0:	ffffc097          	auipc	ra,0xffffc
    80005fc4:	b94080e7          	jalr	-1132(ra) # 80001b54 <cpuid>
  //int irq = *(uint32*)(PLIC + 0x201004);
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005fc8:	00d5179b          	slliw	a5,a0,0xd
    80005fcc:	0c201537          	lui	a0,0xc201
    80005fd0:	953e                	add	a0,a0,a5
  return irq;
}
    80005fd2:	4148                	lw	a0,4(a0)
    80005fd4:	60a2                	ld	ra,8(sp)
    80005fd6:	6402                	ld	s0,0(sp)
    80005fd8:	0141                	addi	sp,sp,16
    80005fda:	8082                	ret

0000000080005fdc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005fdc:	1101                	addi	sp,sp,-32
    80005fde:	ec06                	sd	ra,24(sp)
    80005fe0:	e822                	sd	s0,16(sp)
    80005fe2:	e426                	sd	s1,8(sp)
    80005fe4:	1000                	addi	s0,sp,32
    80005fe6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005fe8:	ffffc097          	auipc	ra,0xffffc
    80005fec:	b6c080e7          	jalr	-1172(ra) # 80001b54 <cpuid>
  //*(uint32*)(PLIC + 0x201004) = irq;
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005ff0:	00d5151b          	slliw	a0,a0,0xd
    80005ff4:	0c2017b7          	lui	a5,0xc201
    80005ff8:	97aa                	add	a5,a5,a0
    80005ffa:	c3c4                	sw	s1,4(a5)
}
    80005ffc:	60e2                	ld	ra,24(sp)
    80005ffe:	6442                	ld	s0,16(sp)
    80006000:	64a2                	ld	s1,8(sp)
    80006002:	6105                	addi	sp,sp,32
    80006004:	8082                	ret

0000000080006006 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int n, int i)
{
    80006006:	1141                	addi	sp,sp,-16
    80006008:	e406                	sd	ra,8(sp)
    8000600a:	e022                	sd	s0,0(sp)
    8000600c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000600e:	479d                	li	a5,7
    80006010:	06b7c963          	blt	a5,a1,80006082 <free_desc+0x7c>
    panic("virtio_disk_intr 1");
  if(disk[n].free[i])
    80006014:	00151793          	slli	a5,a0,0x1
    80006018:	97aa                	add	a5,a5,a0
    8000601a:	00c79713          	slli	a4,a5,0xc
    8000601e:	00024797          	auipc	a5,0x24
    80006022:	fe278793          	addi	a5,a5,-30 # 8002a000 <disk>
    80006026:	97ba                	add	a5,a5,a4
    80006028:	97ae                	add	a5,a5,a1
    8000602a:	6709                	lui	a4,0x2
    8000602c:	97ba                	add	a5,a5,a4
    8000602e:	0187c783          	lbu	a5,24(a5)
    80006032:	e3a5                	bnez	a5,80006092 <free_desc+0x8c>
    panic("virtio_disk_intr 2");
  disk[n].desc[i].addr = 0;
    80006034:	00024817          	auipc	a6,0x24
    80006038:	fcc80813          	addi	a6,a6,-52 # 8002a000 <disk>
    8000603c:	00151693          	slli	a3,a0,0x1
    80006040:	00a68733          	add	a4,a3,a0
    80006044:	0732                	slli	a4,a4,0xc
    80006046:	00e807b3          	add	a5,a6,a4
    8000604a:	6709                	lui	a4,0x2
    8000604c:	00f70633          	add	a2,a4,a5
    80006050:	6210                	ld	a2,0(a2)
    80006052:	00459893          	slli	a7,a1,0x4
    80006056:	9646                	add	a2,a2,a7
    80006058:	00063023          	sd	zero,0(a2) # 1000 <_entry-0x7ffff000>
  disk[n].free[i] = 1;
    8000605c:	97ae                	add	a5,a5,a1
    8000605e:	97ba                	add	a5,a5,a4
    80006060:	4605                	li	a2,1
    80006062:	00c78c23          	sb	a2,24(a5)
  wakeup(&disk[n].free[0]);
    80006066:	96aa                	add	a3,a3,a0
    80006068:	06b2                	slli	a3,a3,0xc
    8000606a:	0761                	addi	a4,a4,24
    8000606c:	96ba                	add	a3,a3,a4
    8000606e:	00d80533          	add	a0,a6,a3
    80006072:	ffffc097          	auipc	ra,0xffffc
    80006076:	464080e7          	jalr	1124(ra) # 800024d6 <wakeup>
}
    8000607a:	60a2                	ld	ra,8(sp)
    8000607c:	6402                	ld	s0,0(sp)
    8000607e:	0141                	addi	sp,sp,16
    80006080:	8082                	ret
    panic("virtio_disk_intr 1");
    80006082:	00003517          	auipc	a0,0x3
    80006086:	83650513          	addi	a0,a0,-1994 # 800088b8 <userret+0x828>
    8000608a:	ffffa097          	auipc	ra,0xffffa
    8000608e:	4be080e7          	jalr	1214(ra) # 80000548 <panic>
    panic("virtio_disk_intr 2");
    80006092:	00003517          	auipc	a0,0x3
    80006096:	83e50513          	addi	a0,a0,-1986 # 800088d0 <userret+0x840>
    8000609a:	ffffa097          	auipc	ra,0xffffa
    8000609e:	4ae080e7          	jalr	1198(ra) # 80000548 <panic>

00000000800060a2 <virtio_disk_init>:
  __sync_synchronize();
    800060a2:	0ff0000f          	fence
  if(disk[n].init)
    800060a6:	00151793          	slli	a5,a0,0x1
    800060aa:	97aa                	add	a5,a5,a0
    800060ac:	07b2                	slli	a5,a5,0xc
    800060ae:	00024717          	auipc	a4,0x24
    800060b2:	f5270713          	addi	a4,a4,-174 # 8002a000 <disk>
    800060b6:	973e                	add	a4,a4,a5
    800060b8:	6789                	lui	a5,0x2
    800060ba:	97ba                	add	a5,a5,a4
    800060bc:	0a87a783          	lw	a5,168(a5) # 20a8 <_entry-0x7fffdf58>
    800060c0:	c391                	beqz	a5,800060c4 <virtio_disk_init+0x22>
    800060c2:	8082                	ret
{
    800060c4:	7139                	addi	sp,sp,-64
    800060c6:	fc06                	sd	ra,56(sp)
    800060c8:	f822                	sd	s0,48(sp)
    800060ca:	f426                	sd	s1,40(sp)
    800060cc:	f04a                	sd	s2,32(sp)
    800060ce:	ec4e                	sd	s3,24(sp)
    800060d0:	e852                	sd	s4,16(sp)
    800060d2:	e456                	sd	s5,8(sp)
    800060d4:	0080                	addi	s0,sp,64
    800060d6:	84aa                	mv	s1,a0
  printf("virtio disk init %d\n", n);
    800060d8:	85aa                	mv	a1,a0
    800060da:	00003517          	auipc	a0,0x3
    800060de:	80e50513          	addi	a0,a0,-2034 # 800088e8 <userret+0x858>
    800060e2:	ffffa097          	auipc	ra,0xffffa
    800060e6:	4c0080e7          	jalr	1216(ra) # 800005a2 <printf>
  initlock(&disk[n].vdisk_lock, "virtio_disk");
    800060ea:	00149993          	slli	s3,s1,0x1
    800060ee:	99a6                	add	s3,s3,s1
    800060f0:	09b2                	slli	s3,s3,0xc
    800060f2:	6789                	lui	a5,0x2
    800060f4:	0b078793          	addi	a5,a5,176 # 20b0 <_entry-0x7fffdf50>
    800060f8:	97ce                	add	a5,a5,s3
    800060fa:	00003597          	auipc	a1,0x3
    800060fe:	80658593          	addi	a1,a1,-2042 # 80008900 <userret+0x870>
    80006102:	00024517          	auipc	a0,0x24
    80006106:	efe50513          	addi	a0,a0,-258 # 8002a000 <disk>
    8000610a:	953e                	add	a0,a0,a5
    8000610c:	ffffb097          	auipc	ra,0xffffb
    80006110:	9ce080e7          	jalr	-1586(ra) # 80000ada <initlock>
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006114:	0014891b          	addiw	s2,s1,1
    80006118:	00c9191b          	slliw	s2,s2,0xc
    8000611c:	100007b7          	lui	a5,0x10000
    80006120:	97ca                	add	a5,a5,s2
    80006122:	4398                	lw	a4,0(a5)
    80006124:	2701                	sext.w	a4,a4
    80006126:	747277b7          	lui	a5,0x74727
    8000612a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000612e:	12f71663          	bne	a4,a5,8000625a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006132:	100007b7          	lui	a5,0x10000
    80006136:	0791                	addi	a5,a5,4
    80006138:	97ca                	add	a5,a5,s2
    8000613a:	439c                	lw	a5,0(a5)
    8000613c:	2781                	sext.w	a5,a5
  if(*R(n, VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000613e:	4705                	li	a4,1
    80006140:	10e79d63          	bne	a5,a4,8000625a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006144:	100007b7          	lui	a5,0x10000
    80006148:	07a1                	addi	a5,a5,8
    8000614a:	97ca                	add	a5,a5,s2
    8000614c:	439c                	lw	a5,0(a5)
    8000614e:	2781                	sext.w	a5,a5
     *R(n, VIRTIO_MMIO_VERSION) != 1 ||
    80006150:	4709                	li	a4,2
    80006152:	10e79463          	bne	a5,a4,8000625a <virtio_disk_init+0x1b8>
     *R(n, VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006156:	100007b7          	lui	a5,0x10000
    8000615a:	07b1                	addi	a5,a5,12
    8000615c:	97ca                	add	a5,a5,s2
    8000615e:	4398                	lw	a4,0(a5)
    80006160:	2701                	sext.w	a4,a4
     *R(n, VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006162:	554d47b7          	lui	a5,0x554d4
    80006166:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000616a:	0ef71863          	bne	a4,a5,8000625a <virtio_disk_init+0x1b8>
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000616e:	100007b7          	lui	a5,0x10000
    80006172:	07078693          	addi	a3,a5,112 # 10000070 <_entry-0x6fffff90>
    80006176:	96ca                	add	a3,a3,s2
    80006178:	4705                	li	a4,1
    8000617a:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000617c:	470d                	li	a4,3
    8000617e:	c298                	sw	a4,0(a3)
  uint64 features = *R(n, VIRTIO_MMIO_DEVICE_FEATURES);
    80006180:	01078713          	addi	a4,a5,16
    80006184:	974a                	add	a4,a4,s2
    80006186:	430c                	lw	a1,0(a4)
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006188:	02078613          	addi	a2,a5,32
    8000618c:	964a                	add	a2,a2,s2
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000618e:	c7ffe737          	lui	a4,0xc7ffe
    80006192:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fce703>
    80006196:	8f6d                	and	a4,a4,a1
  *R(n, VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006198:	2701                	sext.w	a4,a4
    8000619a:	c218                	sw	a4,0(a2)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    8000619c:	472d                	li	a4,11
    8000619e:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_STATUS) = status;
    800061a0:	473d                	li	a4,15
    800061a2:	c298                	sw	a4,0(a3)
  *R(n, VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061a4:	02878713          	addi	a4,a5,40
    800061a8:	974a                	add	a4,a4,s2
    800061aa:	6685                	lui	a3,0x1
    800061ac:	c314                	sw	a3,0(a4)
  *R(n, VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061ae:	03078713          	addi	a4,a5,48
    800061b2:	974a                	add	a4,a4,s2
    800061b4:	00072023          	sw	zero,0(a4)
  uint32 max = *R(n, VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061b8:	03478793          	addi	a5,a5,52
    800061bc:	97ca                	add	a5,a5,s2
    800061be:	439c                	lw	a5,0(a5)
    800061c0:	2781                	sext.w	a5,a5
  if(max == 0)
    800061c2:	c7c5                	beqz	a5,8000626a <virtio_disk_init+0x1c8>
  if(max < NUM)
    800061c4:	471d                	li	a4,7
    800061c6:	0af77a63          	bgeu	a4,a5,8000627a <virtio_disk_init+0x1d8>
  *R(n, VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061ca:	10000ab7          	lui	s5,0x10000
    800061ce:	038a8793          	addi	a5,s5,56 # 10000038 <_entry-0x6fffffc8>
    800061d2:	97ca                	add	a5,a5,s2
    800061d4:	4721                	li	a4,8
    800061d6:	c398                	sw	a4,0(a5)
  memset(disk[n].pages, 0, sizeof(disk[n].pages));
    800061d8:	00024a17          	auipc	s4,0x24
    800061dc:	e28a0a13          	addi	s4,s4,-472 # 8002a000 <disk>
    800061e0:	99d2                	add	s3,s3,s4
    800061e2:	6609                	lui	a2,0x2
    800061e4:	4581                	li	a1,0
    800061e6:	854e                	mv	a0,s3
    800061e8:	ffffb097          	auipc	ra,0xffffb
    800061ec:	cae080e7          	jalr	-850(ra) # 80000e96 <memset>
  *R(n, VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk[n].pages) >> PGSHIFT;
    800061f0:	040a8a93          	addi	s5,s5,64
    800061f4:	9956                	add	s2,s2,s5
    800061f6:	00c9d793          	srli	a5,s3,0xc
    800061fa:	2781                	sext.w	a5,a5
    800061fc:	00f92023          	sw	a5,0(s2)
  disk[n].desc = (struct VRingDesc *) disk[n].pages;
    80006200:	00149693          	slli	a3,s1,0x1
    80006204:	009687b3          	add	a5,a3,s1
    80006208:	07b2                	slli	a5,a5,0xc
    8000620a:	97d2                	add	a5,a5,s4
    8000620c:	6609                	lui	a2,0x2
    8000620e:	97b2                	add	a5,a5,a2
    80006210:	0137b023          	sd	s3,0(a5)
  disk[n].avail = (uint16*)(((char*)disk[n].desc) + NUM*sizeof(struct VRingDesc));
    80006214:	08098713          	addi	a4,s3,128
    80006218:	e798                	sd	a4,8(a5)
  disk[n].used = (struct UsedArea *) (disk[n].pages + PGSIZE);
    8000621a:	6705                	lui	a4,0x1
    8000621c:	99ba                	add	s3,s3,a4
    8000621e:	0137b823          	sd	s3,16(a5)
    disk[n].free[i] = 1;
    80006222:	4705                	li	a4,1
    80006224:	00e78c23          	sb	a4,24(a5)
    80006228:	00e78ca3          	sb	a4,25(a5)
    8000622c:	00e78d23          	sb	a4,26(a5)
    80006230:	00e78da3          	sb	a4,27(a5)
    80006234:	00e78e23          	sb	a4,28(a5)
    80006238:	00e78ea3          	sb	a4,29(a5)
    8000623c:	00e78f23          	sb	a4,30(a5)
    80006240:	00e78fa3          	sb	a4,31(a5)
  disk[n].init = 1;
    80006244:	0ae7a423          	sw	a4,168(a5)
}
    80006248:	70e2                	ld	ra,56(sp)
    8000624a:	7442                	ld	s0,48(sp)
    8000624c:	74a2                	ld	s1,40(sp)
    8000624e:	7902                	ld	s2,32(sp)
    80006250:	69e2                	ld	s3,24(sp)
    80006252:	6a42                	ld	s4,16(sp)
    80006254:	6aa2                	ld	s5,8(sp)
    80006256:	6121                	addi	sp,sp,64
    80006258:	8082                	ret
    panic("could not find virtio disk");
    8000625a:	00002517          	auipc	a0,0x2
    8000625e:	6b650513          	addi	a0,a0,1718 # 80008910 <userret+0x880>
    80006262:	ffffa097          	auipc	ra,0xffffa
    80006266:	2e6080e7          	jalr	742(ra) # 80000548 <panic>
    panic("virtio disk has no queue 0");
    8000626a:	00002517          	auipc	a0,0x2
    8000626e:	6c650513          	addi	a0,a0,1734 # 80008930 <userret+0x8a0>
    80006272:	ffffa097          	auipc	ra,0xffffa
    80006276:	2d6080e7          	jalr	726(ra) # 80000548 <panic>
    panic("virtio disk max queue too short");
    8000627a:	00002517          	auipc	a0,0x2
    8000627e:	6d650513          	addi	a0,a0,1750 # 80008950 <userret+0x8c0>
    80006282:	ffffa097          	auipc	ra,0xffffa
    80006286:	2c6080e7          	jalr	710(ra) # 80000548 <panic>

000000008000628a <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(int n, struct buf *b, int write)
{
    8000628a:	7135                	addi	sp,sp,-160
    8000628c:	ed06                	sd	ra,152(sp)
    8000628e:	e922                	sd	s0,144(sp)
    80006290:	e526                	sd	s1,136(sp)
    80006292:	e14a                	sd	s2,128(sp)
    80006294:	fcce                	sd	s3,120(sp)
    80006296:	f8d2                	sd	s4,112(sp)
    80006298:	f4d6                	sd	s5,104(sp)
    8000629a:	f0da                	sd	s6,96(sp)
    8000629c:	ecde                	sd	s7,88(sp)
    8000629e:	e8e2                	sd	s8,80(sp)
    800062a0:	e4e6                	sd	s9,72(sp)
    800062a2:	e0ea                	sd	s10,64(sp)
    800062a4:	fc6e                	sd	s11,56(sp)
    800062a6:	1100                	addi	s0,sp,160
    800062a8:	8aaa                	mv	s5,a0
    800062aa:	8c2e                	mv	s8,a1
    800062ac:	8db2                	mv	s11,a2
  uint64 sector = b->blockno * (BSIZE / 512);
    800062ae:	45dc                	lw	a5,12(a1)
    800062b0:	0017979b          	slliw	a5,a5,0x1
    800062b4:	1782                	slli	a5,a5,0x20
    800062b6:	9381                	srli	a5,a5,0x20
    800062b8:	f6f43423          	sd	a5,-152(s0)

  acquire(&disk[n].vdisk_lock);
    800062bc:	00151493          	slli	s1,a0,0x1
    800062c0:	94aa                	add	s1,s1,a0
    800062c2:	04b2                	slli	s1,s1,0xc
    800062c4:	6909                	lui	s2,0x2
    800062c6:	0b090c93          	addi	s9,s2,176 # 20b0 <_entry-0x7fffdf50>
    800062ca:	9ca6                	add	s9,s9,s1
    800062cc:	00024997          	auipc	s3,0x24
    800062d0:	d3498993          	addi	s3,s3,-716 # 8002a000 <disk>
    800062d4:	9cce                	add	s9,s9,s3
    800062d6:	8566                	mv	a0,s9
    800062d8:	ffffb097          	auipc	ra,0xffffb
    800062dc:	950080e7          	jalr	-1712(ra) # 80000c28 <acquire>
  int idx[3];
  while(1){
    if(alloc3_desc(n, idx) == 0) {
      break;
    }
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    800062e0:	0961                	addi	s2,s2,24
    800062e2:	94ca                	add	s1,s1,s2
    800062e4:	99a6                	add	s3,s3,s1
  for(int i = 0; i < 3; i++){
    800062e6:	4a01                	li	s4,0
  for(int i = 0; i < NUM; i++){
    800062e8:	44a1                	li	s1,8
      disk[n].free[i] = 0;
    800062ea:	001a9793          	slli	a5,s5,0x1
    800062ee:	97d6                	add	a5,a5,s5
    800062f0:	07b2                	slli	a5,a5,0xc
    800062f2:	00024b97          	auipc	s7,0x24
    800062f6:	d0eb8b93          	addi	s7,s7,-754 # 8002a000 <disk>
    800062fa:	9bbe                	add	s7,s7,a5
    800062fc:	a8a9                	j	80006356 <virtio_disk_rw+0xcc>
    800062fe:	00fb8733          	add	a4,s7,a5
    80006302:	9742                	add	a4,a4,a6
    80006304:	00070c23          	sb	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    idx[i] = alloc_desc(n);
    80006308:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000630a:	0207c263          	bltz	a5,8000632e <virtio_disk_rw+0xa4>
  for(int i = 0; i < 3; i++){
    8000630e:	2905                	addiw	s2,s2,1
    80006310:	0611                	addi	a2,a2,4
    80006312:	1ca90463          	beq	s2,a0,800064da <virtio_disk_rw+0x250>
    idx[i] = alloc_desc(n);
    80006316:	85b2                	mv	a1,a2
    80006318:	874e                	mv	a4,s3
  for(int i = 0; i < NUM; i++){
    8000631a:	87d2                	mv	a5,s4
    if(disk[n].free[i]){
    8000631c:	00074683          	lbu	a3,0(a4)
    80006320:	fef9                	bnez	a3,800062fe <virtio_disk_rw+0x74>
  for(int i = 0; i < NUM; i++){
    80006322:	2785                	addiw	a5,a5,1
    80006324:	0705                	addi	a4,a4,1
    80006326:	fe979be3          	bne	a5,s1,8000631c <virtio_disk_rw+0x92>
    idx[i] = alloc_desc(n);
    8000632a:	57fd                	li	a5,-1
    8000632c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000632e:	01205e63          	blez	s2,8000634a <virtio_disk_rw+0xc0>
    80006332:	8d52                	mv	s10,s4
        free_desc(n, idx[j]);
    80006334:	000b2583          	lw	a1,0(s6)
    80006338:	8556                	mv	a0,s5
    8000633a:	00000097          	auipc	ra,0x0
    8000633e:	ccc080e7          	jalr	-820(ra) # 80006006 <free_desc>
      for(int j = 0; j < i; j++)
    80006342:	2d05                	addiw	s10,s10,1
    80006344:	0b11                	addi	s6,s6,4
    80006346:	ffa917e3          	bne	s2,s10,80006334 <virtio_disk_rw+0xaa>
    sleep(&disk[n].free[0], &disk[n].vdisk_lock);
    8000634a:	85e6                	mv	a1,s9
    8000634c:	854e                	mv	a0,s3
    8000634e:	ffffc097          	auipc	ra,0xffffc
    80006352:	008080e7          	jalr	8(ra) # 80002356 <sleep>
  for(int i = 0; i < 3; i++){
    80006356:	f8040b13          	addi	s6,s0,-128
{
    8000635a:	865a                	mv	a2,s6
  for(int i = 0; i < 3; i++){
    8000635c:	8952                	mv	s2,s4
      disk[n].free[i] = 0;
    8000635e:	6809                	lui	a6,0x2
  for(int i = 0; i < 3; i++){
    80006360:	450d                	li	a0,3
    80006362:	bf55                	j	80006316 <virtio_disk_rw+0x8c>
  disk[n].desc[idx[0]].next = idx[1];

  disk[n].desc[idx[1]].addr = (uint64) b->data;
  disk[n].desc[idx[1]].len = BSIZE;
  if(write)
    disk[n].desc[idx[1]].flags = 0; // device reads b->data
    80006364:	001a9793          	slli	a5,s5,0x1
    80006368:	97d6                	add	a5,a5,s5
    8000636a:	07b2                	slli	a5,a5,0xc
    8000636c:	00024717          	auipc	a4,0x24
    80006370:	c9470713          	addi	a4,a4,-876 # 8002a000 <disk>
    80006374:	973e                	add	a4,a4,a5
    80006376:	6789                	lui	a5,0x2
    80006378:	97ba                	add	a5,a5,a4
    8000637a:	639c                	ld	a5,0(a5)
    8000637c:	97b6                	add	a5,a5,a3
    8000637e:	00079623          	sh	zero,12(a5) # 200c <_entry-0x7fffdff4>
  else
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk[n].desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006382:	00024517          	auipc	a0,0x24
    80006386:	c7e50513          	addi	a0,a0,-898 # 8002a000 <disk>
    8000638a:	001a9793          	slli	a5,s5,0x1
    8000638e:	01578733          	add	a4,a5,s5
    80006392:	0732                	slli	a4,a4,0xc
    80006394:	972a                	add	a4,a4,a0
    80006396:	6609                	lui	a2,0x2
    80006398:	9732                	add	a4,a4,a2
    8000639a:	6310                	ld	a2,0(a4)
    8000639c:	9636                	add	a2,a2,a3
    8000639e:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800063a2:	0015e593          	ori	a1,a1,1
    800063a6:	00b61623          	sh	a1,12(a2)
  disk[n].desc[idx[1]].next = idx[2];
    800063aa:	f8842603          	lw	a2,-120(s0)
    800063ae:	630c                	ld	a1,0(a4)
    800063b0:	96ae                	add	a3,a3,a1
    800063b2:	00c69723          	sh	a2,14(a3) # 100e <_entry-0x7fffeff2>

  disk[n].info[idx[0]].status = 0;
    800063b6:	97d6                	add	a5,a5,s5
    800063b8:	07a2                	slli	a5,a5,0x8
    800063ba:	97a6                	add	a5,a5,s1
    800063bc:	20078793          	addi	a5,a5,512
    800063c0:	0792                	slli	a5,a5,0x4
    800063c2:	97aa                	add	a5,a5,a0
    800063c4:	02078823          	sb	zero,48(a5)
  disk[n].desc[idx[2]].addr = (uint64) &disk[n].info[idx[0]].status;
    800063c8:	00461693          	slli	a3,a2,0x4
    800063cc:	00073803          	ld	a6,0(a4)
    800063d0:	9836                	add	a6,a6,a3
    800063d2:	20348613          	addi	a2,s1,515
    800063d6:	001a9593          	slli	a1,s5,0x1
    800063da:	95d6                	add	a1,a1,s5
    800063dc:	05a2                	slli	a1,a1,0x8
    800063de:	962e                	add	a2,a2,a1
    800063e0:	0612                	slli	a2,a2,0x4
    800063e2:	962a                	add	a2,a2,a0
    800063e4:	00c83023          	sd	a2,0(a6) # 2000 <_entry-0x7fffe000>
  disk[n].desc[idx[2]].len = 1;
    800063e8:	630c                	ld	a1,0(a4)
    800063ea:	95b6                	add	a1,a1,a3
    800063ec:	4605                	li	a2,1
    800063ee:	c590                	sw	a2,8(a1)
  disk[n].desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063f0:	630c                	ld	a1,0(a4)
    800063f2:	95b6                	add	a1,a1,a3
    800063f4:	4509                	li	a0,2
    800063f6:	00a59623          	sh	a0,12(a1)
  disk[n].desc[idx[2]].next = 0;
    800063fa:	630c                	ld	a1,0(a4)
    800063fc:	96ae                	add	a3,a3,a1
    800063fe:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006402:	00cc2223          	sw	a2,4(s8) # fffffffffffff004 <end+0xffffffff7ffcefa8>
  disk[n].info[idx[0]].b = b;
    80006406:	0387b423          	sd	s8,40(a5)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk[n].avail[2 + (disk[n].avail[1] % NUM)] = idx[0];
    8000640a:	6714                	ld	a3,8(a4)
    8000640c:	0026d783          	lhu	a5,2(a3)
    80006410:	8b9d                	andi	a5,a5,7
    80006412:	0789                	addi	a5,a5,2
    80006414:	0786                	slli	a5,a5,0x1
    80006416:	97b6                	add	a5,a5,a3
    80006418:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    8000641c:	0ff0000f          	fence
  disk[n].avail[1] = disk[n].avail[1] + 1;
    80006420:	6718                	ld	a4,8(a4)
    80006422:	00275783          	lhu	a5,2(a4)
    80006426:	2785                	addiw	a5,a5,1
    80006428:	00f71123          	sh	a5,2(a4)

  *R(n, VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000642c:	001a879b          	addiw	a5,s5,1
    80006430:	00c7979b          	slliw	a5,a5,0xc
    80006434:	10000737          	lui	a4,0x10000
    80006438:	05070713          	addi	a4,a4,80 # 10000050 <_entry-0x6fffffb0>
    8000643c:	97ba                	add	a5,a5,a4
    8000643e:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006442:	004c2783          	lw	a5,4(s8)
    80006446:	00c79d63          	bne	a5,a2,80006460 <virtio_disk_rw+0x1d6>
    8000644a:	4485                	li	s1,1
    sleep(b, &disk[n].vdisk_lock);
    8000644c:	85e6                	mv	a1,s9
    8000644e:	8562                	mv	a0,s8
    80006450:	ffffc097          	auipc	ra,0xffffc
    80006454:	f06080e7          	jalr	-250(ra) # 80002356 <sleep>
  while(b->disk == 1) {
    80006458:	004c2783          	lw	a5,4(s8)
    8000645c:	fe9788e3          	beq	a5,s1,8000644c <virtio_disk_rw+0x1c2>
  }

  disk[n].info[idx[0]].b = 0;
    80006460:	f8042483          	lw	s1,-128(s0)
    80006464:	001a9793          	slli	a5,s5,0x1
    80006468:	97d6                	add	a5,a5,s5
    8000646a:	07a2                	slli	a5,a5,0x8
    8000646c:	97a6                	add	a5,a5,s1
    8000646e:	20078793          	addi	a5,a5,512
    80006472:	0792                	slli	a5,a5,0x4
    80006474:	00024717          	auipc	a4,0x24
    80006478:	b8c70713          	addi	a4,a4,-1140 # 8002a000 <disk>
    8000647c:	97ba                	add	a5,a5,a4
    8000647e:	0207b423          	sd	zero,40(a5)
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    80006482:	001a9793          	slli	a5,s5,0x1
    80006486:	97d6                	add	a5,a5,s5
    80006488:	07b2                	slli	a5,a5,0xc
    8000648a:	97ba                	add	a5,a5,a4
    8000648c:	6909                	lui	s2,0x2
    8000648e:	993e                	add	s2,s2,a5
    80006490:	a019                	j	80006496 <virtio_disk_rw+0x20c>
      i = disk[n].desc[i].next;
    80006492:	00e4d483          	lhu	s1,14(s1)
    free_desc(n, i);
    80006496:	85a6                	mv	a1,s1
    80006498:	8556                	mv	a0,s5
    8000649a:	00000097          	auipc	ra,0x0
    8000649e:	b6c080e7          	jalr	-1172(ra) # 80006006 <free_desc>
    if(disk[n].desc[i].flags & VRING_DESC_F_NEXT)
    800064a2:	0492                	slli	s1,s1,0x4
    800064a4:	00093783          	ld	a5,0(s2) # 2000 <_entry-0x7fffe000>
    800064a8:	94be                	add	s1,s1,a5
    800064aa:	00c4d783          	lhu	a5,12(s1)
    800064ae:	8b85                	andi	a5,a5,1
    800064b0:	f3ed                	bnez	a5,80006492 <virtio_disk_rw+0x208>
  free_chain(n, idx[0]);

  release(&disk[n].vdisk_lock);
    800064b2:	8566                	mv	a0,s9
    800064b4:	ffffa097          	auipc	ra,0xffffa
    800064b8:	7e4080e7          	jalr	2020(ra) # 80000c98 <release>
}
    800064bc:	60ea                	ld	ra,152(sp)
    800064be:	644a                	ld	s0,144(sp)
    800064c0:	64aa                	ld	s1,136(sp)
    800064c2:	690a                	ld	s2,128(sp)
    800064c4:	79e6                	ld	s3,120(sp)
    800064c6:	7a46                	ld	s4,112(sp)
    800064c8:	7aa6                	ld	s5,104(sp)
    800064ca:	7b06                	ld	s6,96(sp)
    800064cc:	6be6                	ld	s7,88(sp)
    800064ce:	6c46                	ld	s8,80(sp)
    800064d0:	6ca6                	ld	s9,72(sp)
    800064d2:	6d06                	ld	s10,64(sp)
    800064d4:	7de2                	ld	s11,56(sp)
    800064d6:	610d                	addi	sp,sp,160
    800064d8:	8082                	ret
  if(write)
    800064da:	01b037b3          	snez	a5,s11
    800064de:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800064e2:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800064e6:	f6843783          	ld	a5,-152(s0)
    800064ea:	f6f43c23          	sd	a5,-136(s0)
  disk[n].desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800064ee:	f8042483          	lw	s1,-128(s0)
    800064f2:	00449993          	slli	s3,s1,0x4
    800064f6:	001a9793          	slli	a5,s5,0x1
    800064fa:	97d6                	add	a5,a5,s5
    800064fc:	07b2                	slli	a5,a5,0xc
    800064fe:	00024917          	auipc	s2,0x24
    80006502:	b0290913          	addi	s2,s2,-1278 # 8002a000 <disk>
    80006506:	97ca                	add	a5,a5,s2
    80006508:	6909                	lui	s2,0x2
    8000650a:	993e                	add	s2,s2,a5
    8000650c:	00093a03          	ld	s4,0(s2) # 2000 <_entry-0x7fffe000>
    80006510:	9a4e                	add	s4,s4,s3
    80006512:	f7040513          	addi	a0,s0,-144
    80006516:	ffffb097          	auipc	ra,0xffffb
    8000651a:	dbc080e7          	jalr	-580(ra) # 800012d2 <kvmpa>
    8000651e:	00aa3023          	sd	a0,0(s4)
  disk[n].desc[idx[0]].len = sizeof(buf0);
    80006522:	00093783          	ld	a5,0(s2)
    80006526:	97ce                	add	a5,a5,s3
    80006528:	4741                	li	a4,16
    8000652a:	c798                	sw	a4,8(a5)
  disk[n].desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000652c:	00093783          	ld	a5,0(s2)
    80006530:	97ce                	add	a5,a5,s3
    80006532:	4705                	li	a4,1
    80006534:	00e79623          	sh	a4,12(a5)
  disk[n].desc[idx[0]].next = idx[1];
    80006538:	f8442683          	lw	a3,-124(s0)
    8000653c:	00093783          	ld	a5,0(s2)
    80006540:	99be                	add	s3,s3,a5
    80006542:	00d99723          	sh	a3,14(s3)
  disk[n].desc[idx[1]].addr = (uint64) b->data;
    80006546:	0692                	slli	a3,a3,0x4
    80006548:	00093783          	ld	a5,0(s2)
    8000654c:	97b6                	add	a5,a5,a3
    8000654e:	060c0713          	addi	a4,s8,96
    80006552:	e398                	sd	a4,0(a5)
  disk[n].desc[idx[1]].len = BSIZE;
    80006554:	00093783          	ld	a5,0(s2)
    80006558:	97b6                	add	a5,a5,a3
    8000655a:	40000713          	li	a4,1024
    8000655e:	c798                	sw	a4,8(a5)
  if(write)
    80006560:	e00d92e3          	bnez	s11,80006364 <virtio_disk_rw+0xda>
    disk[n].desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006564:	001a9793          	slli	a5,s5,0x1
    80006568:	97d6                	add	a5,a5,s5
    8000656a:	07b2                	slli	a5,a5,0xc
    8000656c:	00024717          	auipc	a4,0x24
    80006570:	a9470713          	addi	a4,a4,-1388 # 8002a000 <disk>
    80006574:	973e                	add	a4,a4,a5
    80006576:	6789                	lui	a5,0x2
    80006578:	97ba                	add	a5,a5,a4
    8000657a:	639c                	ld	a5,0(a5)
    8000657c:	97b6                	add	a5,a5,a3
    8000657e:	4709                	li	a4,2
    80006580:	00e79623          	sh	a4,12(a5) # 200c <_entry-0x7fffdff4>
    80006584:	bbfd                	j	80006382 <virtio_disk_rw+0xf8>

0000000080006586 <virtio_disk_intr>:

void
virtio_disk_intr(int n)
{
    80006586:	7139                	addi	sp,sp,-64
    80006588:	fc06                	sd	ra,56(sp)
    8000658a:	f822                	sd	s0,48(sp)
    8000658c:	f426                	sd	s1,40(sp)
    8000658e:	f04a                	sd	s2,32(sp)
    80006590:	ec4e                	sd	s3,24(sp)
    80006592:	e852                	sd	s4,16(sp)
    80006594:	e456                	sd	s5,8(sp)
    80006596:	0080                	addi	s0,sp,64
    80006598:	84aa                	mv	s1,a0
  acquire(&disk[n].vdisk_lock);
    8000659a:	00151913          	slli	s2,a0,0x1
    8000659e:	00a90a33          	add	s4,s2,a0
    800065a2:	0a32                	slli	s4,s4,0xc
    800065a4:	6989                	lui	s3,0x2
    800065a6:	0b098793          	addi	a5,s3,176 # 20b0 <_entry-0x7fffdf50>
    800065aa:	9a3e                	add	s4,s4,a5
    800065ac:	00024a97          	auipc	s5,0x24
    800065b0:	a54a8a93          	addi	s5,s5,-1452 # 8002a000 <disk>
    800065b4:	9a56                	add	s4,s4,s5
    800065b6:	8552                	mv	a0,s4
    800065b8:	ffffa097          	auipc	ra,0xffffa
    800065bc:	670080e7          	jalr	1648(ra) # 80000c28 <acquire>

  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    800065c0:	9926                	add	s2,s2,s1
    800065c2:	0932                	slli	s2,s2,0xc
    800065c4:	9956                	add	s2,s2,s5
    800065c6:	99ca                	add	s3,s3,s2
    800065c8:	0209d783          	lhu	a5,32(s3)
    800065cc:	0109b703          	ld	a4,16(s3)
    800065d0:	00275683          	lhu	a3,2(a4)
    800065d4:	8ebd                	xor	a3,a3,a5
    800065d6:	8a9d                	andi	a3,a3,7
    800065d8:	c2a5                	beqz	a3,80006638 <virtio_disk_intr+0xb2>
    int id = disk[n].used->elems[disk[n].used_idx].id;

    if(disk[n].info[id].status != 0)
    800065da:	8956                	mv	s2,s5
    800065dc:	00149693          	slli	a3,s1,0x1
    800065e0:	96a6                	add	a3,a3,s1
    800065e2:	00869993          	slli	s3,a3,0x8
      panic("virtio_disk_intr status");
    
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk[n].info[id].b);

    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    800065e6:	06b2                	slli	a3,a3,0xc
    800065e8:	96d6                	add	a3,a3,s5
    800065ea:	6489                	lui	s1,0x2
    800065ec:	94b6                	add	s1,s1,a3
    int id = disk[n].used->elems[disk[n].used_idx].id;
    800065ee:	078e                	slli	a5,a5,0x3
    800065f0:	97ba                	add	a5,a5,a4
    800065f2:	43dc                	lw	a5,4(a5)
    if(disk[n].info[id].status != 0)
    800065f4:	00f98733          	add	a4,s3,a5
    800065f8:	20070713          	addi	a4,a4,512
    800065fc:	0712                	slli	a4,a4,0x4
    800065fe:	974a                	add	a4,a4,s2
    80006600:	03074703          	lbu	a4,48(a4)
    80006604:	eb21                	bnez	a4,80006654 <virtio_disk_intr+0xce>
    disk[n].info[id].b->disk = 0;   // disk is done with buf
    80006606:	97ce                	add	a5,a5,s3
    80006608:	20078793          	addi	a5,a5,512
    8000660c:	0792                	slli	a5,a5,0x4
    8000660e:	97ca                	add	a5,a5,s2
    80006610:	7798                	ld	a4,40(a5)
    80006612:	00072223          	sw	zero,4(a4)
    wakeup(disk[n].info[id].b);
    80006616:	7788                	ld	a0,40(a5)
    80006618:	ffffc097          	auipc	ra,0xffffc
    8000661c:	ebe080e7          	jalr	-322(ra) # 800024d6 <wakeup>
    disk[n].used_idx = (disk[n].used_idx + 1) % NUM;
    80006620:	0204d783          	lhu	a5,32(s1) # 2020 <_entry-0x7fffdfe0>
    80006624:	2785                	addiw	a5,a5,1
    80006626:	8b9d                	andi	a5,a5,7
    80006628:	02f49023          	sh	a5,32(s1)
  while((disk[n].used_idx % NUM) != (disk[n].used->id % NUM)){
    8000662c:	6898                	ld	a4,16(s1)
    8000662e:	00275683          	lhu	a3,2(a4)
    80006632:	8a9d                	andi	a3,a3,7
    80006634:	faf69de3          	bne	a3,a5,800065ee <virtio_disk_intr+0x68>
  }

  release(&disk[n].vdisk_lock);
    80006638:	8552                	mv	a0,s4
    8000663a:	ffffa097          	auipc	ra,0xffffa
    8000663e:	65e080e7          	jalr	1630(ra) # 80000c98 <release>
}
    80006642:	70e2                	ld	ra,56(sp)
    80006644:	7442                	ld	s0,48(sp)
    80006646:	74a2                	ld	s1,40(sp)
    80006648:	7902                	ld	s2,32(sp)
    8000664a:	69e2                	ld	s3,24(sp)
    8000664c:	6a42                	ld	s4,16(sp)
    8000664e:	6aa2                	ld	s5,8(sp)
    80006650:	6121                	addi	sp,sp,64
    80006652:	8082                	ret
      panic("virtio_disk_intr status");
    80006654:	00002517          	auipc	a0,0x2
    80006658:	31c50513          	addi	a0,a0,796 # 80008970 <userret+0x8e0>
    8000665c:	ffffa097          	auipc	ra,0xffffa
    80006660:	eec080e7          	jalr	-276(ra) # 80000548 <panic>

0000000080006664 <bit_isset>:
static Sz_info *bd_sizes; 
static void *bd_base;   // start address of memory managed by the buddy allocator
static struct spinlock lock;

// Return 1 if bit at position index in array is set to 1
int bit_isset(char *array, int index) {
    80006664:	1141                	addi	sp,sp,-16
    80006666:	e422                	sd	s0,8(sp)
    80006668:	0800                	addi	s0,sp,16
  char b = array[index/8];
  char m = (1 << (index % 8));
    8000666a:	41f5d79b          	sraiw	a5,a1,0x1f
    8000666e:	01d7d79b          	srliw	a5,a5,0x1d
    80006672:	9dbd                	addw	a1,a1,a5
    80006674:	0075f713          	andi	a4,a1,7
    80006678:	9f1d                	subw	a4,a4,a5
    8000667a:	4785                	li	a5,1
    8000667c:	00e797bb          	sllw	a5,a5,a4
    80006680:	0ff7f793          	andi	a5,a5,255
  char b = array[index/8];
    80006684:	4035d59b          	sraiw	a1,a1,0x3
    80006688:	95aa                	add	a1,a1,a0
  return (b & m) == m;
    8000668a:	0005c503          	lbu	a0,0(a1)
    8000668e:	8d7d                	and	a0,a0,a5
    80006690:	8d1d                	sub	a0,a0,a5
}
    80006692:	00153513          	seqz	a0,a0
    80006696:	6422                	ld	s0,8(sp)
    80006698:	0141                	addi	sp,sp,16
    8000669a:	8082                	ret

000000008000669c <bit_set>:

// Set bit at position index in array to 1
void bit_set(char *array, int index) {
    8000669c:	1141                	addi	sp,sp,-16
    8000669e:	e422                	sd	s0,8(sp)
    800066a0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800066a2:	41f5d79b          	sraiw	a5,a1,0x1f
    800066a6:	01d7d79b          	srliw	a5,a5,0x1d
    800066aa:	9dbd                	addw	a1,a1,a5
    800066ac:	4035d71b          	sraiw	a4,a1,0x3
    800066b0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800066b2:	899d                	andi	a1,a1,7
    800066b4:	9d9d                	subw	a1,a1,a5
    800066b6:	4785                	li	a5,1
    800066b8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b | m);
    800066bc:	00054783          	lbu	a5,0(a0)
    800066c0:	8ddd                	or	a1,a1,a5
    800066c2:	00b50023          	sb	a1,0(a0)
}
    800066c6:	6422                	ld	s0,8(sp)
    800066c8:	0141                	addi	sp,sp,16
    800066ca:	8082                	ret

00000000800066cc <bit_clear>:

// Clear bit at position index in array
void bit_clear(char *array, int index) {
    800066cc:	1141                	addi	sp,sp,-16
    800066ce:	e422                	sd	s0,8(sp)
    800066d0:	0800                	addi	s0,sp,16
  char b = array[index/8];
    800066d2:	41f5d79b          	sraiw	a5,a1,0x1f
    800066d6:	01d7d79b          	srliw	a5,a5,0x1d
    800066da:	9dbd                	addw	a1,a1,a5
    800066dc:	4035d71b          	sraiw	a4,a1,0x3
    800066e0:	953a                	add	a0,a0,a4
  char m = (1 << (index % 8));
    800066e2:	899d                	andi	a1,a1,7
    800066e4:	9d9d                	subw	a1,a1,a5
    800066e6:	4785                	li	a5,1
    800066e8:	00b795bb          	sllw	a1,a5,a1
  array[index/8] = (b & ~m);
    800066ec:	fff5c593          	not	a1,a1
    800066f0:	00054783          	lbu	a5,0(a0)
    800066f4:	8dfd                	and	a1,a1,a5
    800066f6:	00b50023          	sb	a1,0(a0)
}
    800066fa:	6422                	ld	s0,8(sp)
    800066fc:	0141                	addi	sp,sp,16
    800066fe:	8082                	ret

0000000080006700 <bd_print_vector>:

// Print a bit vector as a list of ranges of 1 bits
void
bd_print_vector(char *vector, int len) {
    80006700:	715d                	addi	sp,sp,-80
    80006702:	e486                	sd	ra,72(sp)
    80006704:	e0a2                	sd	s0,64(sp)
    80006706:	fc26                	sd	s1,56(sp)
    80006708:	f84a                	sd	s2,48(sp)
    8000670a:	f44e                	sd	s3,40(sp)
    8000670c:	f052                	sd	s4,32(sp)
    8000670e:	ec56                	sd	s5,24(sp)
    80006710:	e85a                	sd	s6,16(sp)
    80006712:	e45e                	sd	s7,8(sp)
    80006714:	0880                	addi	s0,sp,80
    80006716:	8a2e                	mv	s4,a1
  int last, lb;
  
  last = 1;
  lb = 0;
  for (int b = 0; b < len; b++) {
    80006718:	08b05b63          	blez	a1,800067ae <bd_print_vector+0xae>
    8000671c:	89aa                	mv	s3,a0
    8000671e:	4481                	li	s1,0
  lb = 0;
    80006720:	4a81                	li	s5,0
  last = 1;
    80006722:	4905                	li	s2,1
    if (last == bit_isset(vector, b))
      continue;
    if(last == 1)
    80006724:	4b05                	li	s6,1
      printf(" [%d, %d)", lb, b);
    80006726:	00002b97          	auipc	s7,0x2
    8000672a:	262b8b93          	addi	s7,s7,610 # 80008988 <userret+0x8f8>
    8000672e:	a821                	j	80006746 <bd_print_vector+0x46>
    lb = b;
    last = bit_isset(vector, b);
    80006730:	85a6                	mv	a1,s1
    80006732:	854e                	mv	a0,s3
    80006734:	00000097          	auipc	ra,0x0
    80006738:	f30080e7          	jalr	-208(ra) # 80006664 <bit_isset>
    8000673c:	892a                	mv	s2,a0
    8000673e:	8aa6                	mv	s5,s1
  for (int b = 0; b < len; b++) {
    80006740:	2485                	addiw	s1,s1,1
    80006742:	029a0463          	beq	s4,s1,8000676a <bd_print_vector+0x6a>
    if (last == bit_isset(vector, b))
    80006746:	85a6                	mv	a1,s1
    80006748:	854e                	mv	a0,s3
    8000674a:	00000097          	auipc	ra,0x0
    8000674e:	f1a080e7          	jalr	-230(ra) # 80006664 <bit_isset>
    80006752:	ff2507e3          	beq	a0,s2,80006740 <bd_print_vector+0x40>
    if(last == 1)
    80006756:	fd691de3          	bne	s2,s6,80006730 <bd_print_vector+0x30>
      printf(" [%d, %d)", lb, b);
    8000675a:	8626                	mv	a2,s1
    8000675c:	85d6                	mv	a1,s5
    8000675e:	855e                	mv	a0,s7
    80006760:	ffffa097          	auipc	ra,0xffffa
    80006764:	e42080e7          	jalr	-446(ra) # 800005a2 <printf>
    80006768:	b7e1                	j	80006730 <bd_print_vector+0x30>
  }
  if(lb == 0 || last == 1) {
    8000676a:	000a8563          	beqz	s5,80006774 <bd_print_vector+0x74>
    8000676e:	4785                	li	a5,1
    80006770:	00f91c63          	bne	s2,a5,80006788 <bd_print_vector+0x88>
    printf(" [%d, %d)", lb, len);
    80006774:	8652                	mv	a2,s4
    80006776:	85d6                	mv	a1,s5
    80006778:	00002517          	auipc	a0,0x2
    8000677c:	21050513          	addi	a0,a0,528 # 80008988 <userret+0x8f8>
    80006780:	ffffa097          	auipc	ra,0xffffa
    80006784:	e22080e7          	jalr	-478(ra) # 800005a2 <printf>
  }
  printf("\n");
    80006788:	00002517          	auipc	a0,0x2
    8000678c:	b0850513          	addi	a0,a0,-1272 # 80008290 <userret+0x200>
    80006790:	ffffa097          	auipc	ra,0xffffa
    80006794:	e12080e7          	jalr	-494(ra) # 800005a2 <printf>
}
    80006798:	60a6                	ld	ra,72(sp)
    8000679a:	6406                	ld	s0,64(sp)
    8000679c:	74e2                	ld	s1,56(sp)
    8000679e:	7942                	ld	s2,48(sp)
    800067a0:	79a2                	ld	s3,40(sp)
    800067a2:	7a02                	ld	s4,32(sp)
    800067a4:	6ae2                	ld	s5,24(sp)
    800067a6:	6b42                	ld	s6,16(sp)
    800067a8:	6ba2                	ld	s7,8(sp)
    800067aa:	6161                	addi	sp,sp,80
    800067ac:	8082                	ret
  lb = 0;
    800067ae:	4a81                	li	s5,0
    800067b0:	b7d1                	j	80006774 <bd_print_vector+0x74>

00000000800067b2 <bd_print>:

// Print buddy's data structures
void
bd_print() {
  for (int k = 0; k < nsizes; k++) {
    800067b2:	0002a697          	auipc	a3,0x2a
    800067b6:	8a66a683          	lw	a3,-1882(a3) # 80030058 <nsizes>
    800067ba:	10d05063          	blez	a3,800068ba <bd_print+0x108>
bd_print() {
    800067be:	711d                	addi	sp,sp,-96
    800067c0:	ec86                	sd	ra,88(sp)
    800067c2:	e8a2                	sd	s0,80(sp)
    800067c4:	e4a6                	sd	s1,72(sp)
    800067c6:	e0ca                	sd	s2,64(sp)
    800067c8:	fc4e                	sd	s3,56(sp)
    800067ca:	f852                	sd	s4,48(sp)
    800067cc:	f456                	sd	s5,40(sp)
    800067ce:	f05a                	sd	s6,32(sp)
    800067d0:	ec5e                	sd	s7,24(sp)
    800067d2:	e862                	sd	s8,16(sp)
    800067d4:	e466                	sd	s9,8(sp)
    800067d6:	e06a                	sd	s10,0(sp)
    800067d8:	1080                	addi	s0,sp,96
  for (int k = 0; k < nsizes; k++) {
    800067da:	4481                	li	s1,0
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    800067dc:	4a85                	li	s5,1
    800067de:	4c41                	li	s8,16
    800067e0:	00002b97          	auipc	s7,0x2
    800067e4:	1b8b8b93          	addi	s7,s7,440 # 80008998 <userret+0x908>
    lst_print(&bd_sizes[k].free);
    800067e8:	0002aa17          	auipc	s4,0x2a
    800067ec:	868a0a13          	addi	s4,s4,-1944 # 80030050 <bd_sizes>
    printf("  alloc:");
    800067f0:	00002b17          	auipc	s6,0x2
    800067f4:	1d0b0b13          	addi	s6,s6,464 # 800089c0 <userret+0x930>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    800067f8:	0002a997          	auipc	s3,0x2a
    800067fc:	86098993          	addi	s3,s3,-1952 # 80030058 <nsizes>
    if(k > 0) {
      printf("  split:");
    80006800:	00002c97          	auipc	s9,0x2
    80006804:	1d0c8c93          	addi	s9,s9,464 # 800089d0 <userret+0x940>
    80006808:	a801                	j	80006818 <bd_print+0x66>
  for (int k = 0; k < nsizes; k++) {
    8000680a:	0009a683          	lw	a3,0(s3)
    8000680e:	0485                	addi	s1,s1,1
    80006810:	0004879b          	sext.w	a5,s1
    80006814:	08d7d563          	bge	a5,a3,8000689e <bd_print+0xec>
    80006818:	0004891b          	sext.w	s2,s1
    printf("size %d (blksz %d nblk %d): free list: ", k, BLK_SIZE(k), NBLK(k));
    8000681c:	36fd                	addiw	a3,a3,-1
    8000681e:	9e85                	subw	a3,a3,s1
    80006820:	00da96bb          	sllw	a3,s5,a3
    80006824:	009c1633          	sll	a2,s8,s1
    80006828:	85ca                	mv	a1,s2
    8000682a:	855e                	mv	a0,s7
    8000682c:	ffffa097          	auipc	ra,0xffffa
    80006830:	d76080e7          	jalr	-650(ra) # 800005a2 <printf>
    lst_print(&bd_sizes[k].free);
    80006834:	00549d13          	slli	s10,s1,0x5
    80006838:	000a3503          	ld	a0,0(s4)
    8000683c:	956a                	add	a0,a0,s10
    8000683e:	00001097          	auipc	ra,0x1
    80006842:	a56080e7          	jalr	-1450(ra) # 80007294 <lst_print>
    printf("  alloc:");
    80006846:	855a                	mv	a0,s6
    80006848:	ffffa097          	auipc	ra,0xffffa
    8000684c:	d5a080e7          	jalr	-678(ra) # 800005a2 <printf>
    bd_print_vector(bd_sizes[k].alloc, NBLK(k));
    80006850:	0009a583          	lw	a1,0(s3)
    80006854:	35fd                	addiw	a1,a1,-1
    80006856:	412585bb          	subw	a1,a1,s2
    8000685a:	000a3783          	ld	a5,0(s4)
    8000685e:	97ea                	add	a5,a5,s10
    80006860:	00ba95bb          	sllw	a1,s5,a1
    80006864:	6b88                	ld	a0,16(a5)
    80006866:	00000097          	auipc	ra,0x0
    8000686a:	e9a080e7          	jalr	-358(ra) # 80006700 <bd_print_vector>
    if(k > 0) {
    8000686e:	f9205ee3          	blez	s2,8000680a <bd_print+0x58>
      printf("  split:");
    80006872:	8566                	mv	a0,s9
    80006874:	ffffa097          	auipc	ra,0xffffa
    80006878:	d2e080e7          	jalr	-722(ra) # 800005a2 <printf>
      bd_print_vector(bd_sizes[k].split, NBLK(k));
    8000687c:	0009a583          	lw	a1,0(s3)
    80006880:	35fd                	addiw	a1,a1,-1
    80006882:	412585bb          	subw	a1,a1,s2
    80006886:	000a3783          	ld	a5,0(s4)
    8000688a:	9d3e                	add	s10,s10,a5
    8000688c:	00ba95bb          	sllw	a1,s5,a1
    80006890:	018d3503          	ld	a0,24(s10)
    80006894:	00000097          	auipc	ra,0x0
    80006898:	e6c080e7          	jalr	-404(ra) # 80006700 <bd_print_vector>
    8000689c:	b7bd                	j	8000680a <bd_print+0x58>
    }
  }
}
    8000689e:	60e6                	ld	ra,88(sp)
    800068a0:	6446                	ld	s0,80(sp)
    800068a2:	64a6                	ld	s1,72(sp)
    800068a4:	6906                	ld	s2,64(sp)
    800068a6:	79e2                	ld	s3,56(sp)
    800068a8:	7a42                	ld	s4,48(sp)
    800068aa:	7aa2                	ld	s5,40(sp)
    800068ac:	7b02                	ld	s6,32(sp)
    800068ae:	6be2                	ld	s7,24(sp)
    800068b0:	6c42                	ld	s8,16(sp)
    800068b2:	6ca2                	ld	s9,8(sp)
    800068b4:	6d02                	ld	s10,0(sp)
    800068b6:	6125                	addi	sp,sp,96
    800068b8:	8082                	ret
    800068ba:	8082                	ret

00000000800068bc <firstk>:

// What is the first k such that 2^k >= n?
int
firstk(uint64 n) {
    800068bc:	1141                	addi	sp,sp,-16
    800068be:	e422                	sd	s0,8(sp)
    800068c0:	0800                	addi	s0,sp,16
  int k = 0;
  uint64 size = LEAF_SIZE;

  while (size < n) {
    800068c2:	47c1                	li	a5,16
    800068c4:	00a7fb63          	bgeu	a5,a0,800068da <firstk+0x1e>
    800068c8:	872a                	mv	a4,a0
  int k = 0;
    800068ca:	4501                	li	a0,0
    k++;
    800068cc:	2505                	addiw	a0,a0,1
    size *= 2;
    800068ce:	0786                	slli	a5,a5,0x1
  while (size < n) {
    800068d0:	fee7eee3          	bltu	a5,a4,800068cc <firstk+0x10>
  }
  return k;
}
    800068d4:	6422                	ld	s0,8(sp)
    800068d6:	0141                	addi	sp,sp,16
    800068d8:	8082                	ret
  int k = 0;
    800068da:	4501                	li	a0,0
    800068dc:	bfe5                	j	800068d4 <firstk+0x18>

00000000800068de <blk_index>:

// Compute the block index for address p at size k
int
blk_index(int k, char *p) {
    800068de:	1141                	addi	sp,sp,-16
    800068e0:	e422                	sd	s0,8(sp)
    800068e2:	0800                	addi	s0,sp,16
  int n = p - (char *) bd_base;
  return n / BLK_SIZE(k);
    800068e4:	00029797          	auipc	a5,0x29
    800068e8:	7647b783          	ld	a5,1892(a5) # 80030048 <bd_base>
    800068ec:	9d9d                	subw	a1,a1,a5
    800068ee:	47c1                	li	a5,16
    800068f0:	00a797b3          	sll	a5,a5,a0
    800068f4:	02f5c5b3          	div	a1,a1,a5
}
    800068f8:	0005851b          	sext.w	a0,a1
    800068fc:	6422                	ld	s0,8(sp)
    800068fe:	0141                	addi	sp,sp,16
    80006900:	8082                	ret

0000000080006902 <addr>:

// Convert a block index at size k back into an address
void *addr(int k, int bi) {
    80006902:	1141                	addi	sp,sp,-16
    80006904:	e422                	sd	s0,8(sp)
    80006906:	0800                	addi	s0,sp,16
  int n = bi * BLK_SIZE(k);
    80006908:	47c1                	li	a5,16
    8000690a:	00a797b3          	sll	a5,a5,a0
  return (char *) bd_base + n;
    8000690e:	02b787bb          	mulw	a5,a5,a1
}
    80006912:	00029517          	auipc	a0,0x29
    80006916:	73653503          	ld	a0,1846(a0) # 80030048 <bd_base>
    8000691a:	953e                	add	a0,a0,a5
    8000691c:	6422                	ld	s0,8(sp)
    8000691e:	0141                	addi	sp,sp,16
    80006920:	8082                	ret

0000000080006922 <bd_malloc>:

// allocate nbytes, but malloc won't return anything smaller than LEAF_SIZE
void *
bd_malloc(uint64 nbytes)
{
    80006922:	7159                	addi	sp,sp,-112
    80006924:	f486                	sd	ra,104(sp)
    80006926:	f0a2                	sd	s0,96(sp)
    80006928:	eca6                	sd	s1,88(sp)
    8000692a:	e8ca                	sd	s2,80(sp)
    8000692c:	e4ce                	sd	s3,72(sp)
    8000692e:	e0d2                	sd	s4,64(sp)
    80006930:	fc56                	sd	s5,56(sp)
    80006932:	f85a                	sd	s6,48(sp)
    80006934:	f45e                	sd	s7,40(sp)
    80006936:	f062                	sd	s8,32(sp)
    80006938:	ec66                	sd	s9,24(sp)
    8000693a:	e86a                	sd	s10,16(sp)
    8000693c:	e46e                	sd	s11,8(sp)
    8000693e:	1880                	addi	s0,sp,112
    80006940:	84aa                	mv	s1,a0
  int fk, k;

  acquire(&lock);
    80006942:	00029517          	auipc	a0,0x29
    80006946:	6be50513          	addi	a0,a0,1726 # 80030000 <lock>
    8000694a:	ffffa097          	auipc	ra,0xffffa
    8000694e:	2de080e7          	jalr	734(ra) # 80000c28 <acquire>

  // Find a free block >= nbytes, starting with smallest k possible
  fk = firstk(nbytes);
    80006952:	8526                	mv	a0,s1
    80006954:	00000097          	auipc	ra,0x0
    80006958:	f68080e7          	jalr	-152(ra) # 800068bc <firstk>
  for (k = fk; k < nsizes; k++) {
    8000695c:	00029797          	auipc	a5,0x29
    80006960:	6fc7a783          	lw	a5,1788(a5) # 80030058 <nsizes>
    80006964:	02f55d63          	bge	a0,a5,8000699e <bd_malloc+0x7c>
    80006968:	8c2a                	mv	s8,a0
    8000696a:	00551913          	slli	s2,a0,0x5
    8000696e:	84aa                	mv	s1,a0
    if(!lst_empty(&bd_sizes[k].free))
    80006970:	00029997          	auipc	s3,0x29
    80006974:	6e098993          	addi	s3,s3,1760 # 80030050 <bd_sizes>
  for (k = fk; k < nsizes; k++) {
    80006978:	00029a17          	auipc	s4,0x29
    8000697c:	6e0a0a13          	addi	s4,s4,1760 # 80030058 <nsizes>
    if(!lst_empty(&bd_sizes[k].free))
    80006980:	0009b503          	ld	a0,0(s3)
    80006984:	954a                	add	a0,a0,s2
    80006986:	00001097          	auipc	ra,0x1
    8000698a:	894080e7          	jalr	-1900(ra) # 8000721a <lst_empty>
    8000698e:	c115                	beqz	a0,800069b2 <bd_malloc+0x90>
  for (k = fk; k < nsizes; k++) {
    80006990:	2485                	addiw	s1,s1,1
    80006992:	02090913          	addi	s2,s2,32
    80006996:	000a2783          	lw	a5,0(s4)
    8000699a:	fef4c3e3          	blt	s1,a5,80006980 <bd_malloc+0x5e>
      break;
  }
  if(k >= nsizes) { // No free blocks?
    release(&lock);
    8000699e:	00029517          	auipc	a0,0x29
    800069a2:	66250513          	addi	a0,a0,1634 # 80030000 <lock>
    800069a6:	ffffa097          	auipc	ra,0xffffa
    800069aa:	2f2080e7          	jalr	754(ra) # 80000c98 <release>
    return 0;
    800069ae:	4b01                	li	s6,0
    800069b0:	a0e1                	j	80006a78 <bd_malloc+0x156>
  if(k >= nsizes) { // No free blocks?
    800069b2:	00029797          	auipc	a5,0x29
    800069b6:	6a67a783          	lw	a5,1702(a5) # 80030058 <nsizes>
    800069ba:	fef4d2e3          	bge	s1,a5,8000699e <bd_malloc+0x7c>
  }

  // Found a block; pop it and potentially split it.
  char *p = lst_pop(&bd_sizes[k].free);
    800069be:	00549993          	slli	s3,s1,0x5
    800069c2:	00029917          	auipc	s2,0x29
    800069c6:	68e90913          	addi	s2,s2,1678 # 80030050 <bd_sizes>
    800069ca:	00093503          	ld	a0,0(s2)
    800069ce:	954e                	add	a0,a0,s3
    800069d0:	00001097          	auipc	ra,0x1
    800069d4:	876080e7          	jalr	-1930(ra) # 80007246 <lst_pop>
    800069d8:	8b2a                	mv	s6,a0
  return n / BLK_SIZE(k);
    800069da:	00029597          	auipc	a1,0x29
    800069de:	66e5b583          	ld	a1,1646(a1) # 80030048 <bd_base>
    800069e2:	40b505bb          	subw	a1,a0,a1
    800069e6:	47c1                	li	a5,16
    800069e8:	009797b3          	sll	a5,a5,s1
    800069ec:	02f5c5b3          	div	a1,a1,a5
  bit_set(bd_sizes[k].alloc, blk_index(k, p));
    800069f0:	00093783          	ld	a5,0(s2)
    800069f4:	97ce                	add	a5,a5,s3
    800069f6:	2581                	sext.w	a1,a1
    800069f8:	6b88                	ld	a0,16(a5)
    800069fa:	00000097          	auipc	ra,0x0
    800069fe:	ca2080e7          	jalr	-862(ra) # 8000669c <bit_set>
  for(; k > fk; k--) {
    80006a02:	069c5363          	bge	s8,s1,80006a68 <bd_malloc+0x146>
    // split a block at size k and mark one half allocated at size k-1
    // and put the buddy on the free list at size k-1
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006a06:	4bc1                	li	s7,16
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a08:	8dca                	mv	s11,s2
  int n = p - (char *) bd_base;
    80006a0a:	00029d17          	auipc	s10,0x29
    80006a0e:	63ed0d13          	addi	s10,s10,1598 # 80030048 <bd_base>
    char *q = p + BLK_SIZE(k-1);   // p's buddy
    80006a12:	85a6                	mv	a1,s1
    80006a14:	34fd                	addiw	s1,s1,-1
    80006a16:	009b9ab3          	sll	s5,s7,s1
    80006a1a:	015b0cb3          	add	s9,s6,s5
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a1e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
  int n = p - (char *) bd_base;
    80006a22:	000d3903          	ld	s2,0(s10)
  return n / BLK_SIZE(k);
    80006a26:	412b093b          	subw	s2,s6,s2
    80006a2a:	00bb95b3          	sll	a1,s7,a1
    80006a2e:	02b945b3          	div	a1,s2,a1
    bit_set(bd_sizes[k].split, blk_index(k, p));
    80006a32:	013a07b3          	add	a5,s4,s3
    80006a36:	2581                	sext.w	a1,a1
    80006a38:	6f88                	ld	a0,24(a5)
    80006a3a:	00000097          	auipc	ra,0x0
    80006a3e:	c62080e7          	jalr	-926(ra) # 8000669c <bit_set>
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a42:	1981                	addi	s3,s3,-32
    80006a44:	9a4e                	add	s4,s4,s3
  return n / BLK_SIZE(k);
    80006a46:	035945b3          	div	a1,s2,s5
    bit_set(bd_sizes[k-1].alloc, blk_index(k-1, p));
    80006a4a:	2581                	sext.w	a1,a1
    80006a4c:	010a3503          	ld	a0,16(s4)
    80006a50:	00000097          	auipc	ra,0x0
    80006a54:	c4c080e7          	jalr	-948(ra) # 8000669c <bit_set>
    lst_push(&bd_sizes[k-1].free, q);
    80006a58:	85e6                	mv	a1,s9
    80006a5a:	8552                	mv	a0,s4
    80006a5c:	00001097          	auipc	ra,0x1
    80006a60:	820080e7          	jalr	-2016(ra) # 8000727c <lst_push>
  for(; k > fk; k--) {
    80006a64:	fb8497e3          	bne	s1,s8,80006a12 <bd_malloc+0xf0>
  }
  release(&lock);
    80006a68:	00029517          	auipc	a0,0x29
    80006a6c:	59850513          	addi	a0,a0,1432 # 80030000 <lock>
    80006a70:	ffffa097          	auipc	ra,0xffffa
    80006a74:	228080e7          	jalr	552(ra) # 80000c98 <release>

  return p;
}
    80006a78:	855a                	mv	a0,s6
    80006a7a:	70a6                	ld	ra,104(sp)
    80006a7c:	7406                	ld	s0,96(sp)
    80006a7e:	64e6                	ld	s1,88(sp)
    80006a80:	6946                	ld	s2,80(sp)
    80006a82:	69a6                	ld	s3,72(sp)
    80006a84:	6a06                	ld	s4,64(sp)
    80006a86:	7ae2                	ld	s5,56(sp)
    80006a88:	7b42                	ld	s6,48(sp)
    80006a8a:	7ba2                	ld	s7,40(sp)
    80006a8c:	7c02                	ld	s8,32(sp)
    80006a8e:	6ce2                	ld	s9,24(sp)
    80006a90:	6d42                	ld	s10,16(sp)
    80006a92:	6da2                	ld	s11,8(sp)
    80006a94:	6165                	addi	sp,sp,112
    80006a96:	8082                	ret

0000000080006a98 <size>:

// Find the size of the block that p points to.
int
size(char *p) {
    80006a98:	7139                	addi	sp,sp,-64
    80006a9a:	fc06                	sd	ra,56(sp)
    80006a9c:	f822                	sd	s0,48(sp)
    80006a9e:	f426                	sd	s1,40(sp)
    80006aa0:	f04a                	sd	s2,32(sp)
    80006aa2:	ec4e                	sd	s3,24(sp)
    80006aa4:	e852                	sd	s4,16(sp)
    80006aa6:	e456                	sd	s5,8(sp)
    80006aa8:	e05a                	sd	s6,0(sp)
    80006aaa:	0080                	addi	s0,sp,64
  for (int k = 0; k < nsizes; k++) {
    80006aac:	00029a97          	auipc	s5,0x29
    80006ab0:	5acaaa83          	lw	s5,1452(s5) # 80030058 <nsizes>
  return n / BLK_SIZE(k);
    80006ab4:	00029a17          	auipc	s4,0x29
    80006ab8:	594a3a03          	ld	s4,1428(s4) # 80030048 <bd_base>
    80006abc:	41450a3b          	subw	s4,a0,s4
    80006ac0:	00029497          	auipc	s1,0x29
    80006ac4:	5904b483          	ld	s1,1424(s1) # 80030050 <bd_sizes>
    80006ac8:	03848493          	addi	s1,s1,56
  for (int k = 0; k < nsizes; k++) {
    80006acc:	4901                	li	s2,0
  return n / BLK_SIZE(k);
    80006ace:	4b41                	li	s6,16
  for (int k = 0; k < nsizes; k++) {
    80006ad0:	03595363          	bge	s2,s5,80006af6 <size+0x5e>
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ad4:	0019099b          	addiw	s3,s2,1
  return n / BLK_SIZE(k);
    80006ad8:	013b15b3          	sll	a1,s6,s3
    80006adc:	02ba45b3          	div	a1,s4,a1
    if(bit_isset(bd_sizes[k+1].split, blk_index(k+1, p))) {
    80006ae0:	2581                	sext.w	a1,a1
    80006ae2:	6088                	ld	a0,0(s1)
    80006ae4:	00000097          	auipc	ra,0x0
    80006ae8:	b80080e7          	jalr	-1152(ra) # 80006664 <bit_isset>
    80006aec:	02048493          	addi	s1,s1,32
    80006af0:	e501                	bnez	a0,80006af8 <size+0x60>
  for (int k = 0; k < nsizes; k++) {
    80006af2:	894e                	mv	s2,s3
    80006af4:	bff1                	j	80006ad0 <size+0x38>
      return k;
    }
  }
  return 0;
    80006af6:	4901                	li	s2,0
}
    80006af8:	854a                	mv	a0,s2
    80006afa:	70e2                	ld	ra,56(sp)
    80006afc:	7442                	ld	s0,48(sp)
    80006afe:	74a2                	ld	s1,40(sp)
    80006b00:	7902                	ld	s2,32(sp)
    80006b02:	69e2                	ld	s3,24(sp)
    80006b04:	6a42                	ld	s4,16(sp)
    80006b06:	6aa2                	ld	s5,8(sp)
    80006b08:	6b02                	ld	s6,0(sp)
    80006b0a:	6121                	addi	sp,sp,64
    80006b0c:	8082                	ret

0000000080006b0e <bd_free>:

// Free memory pointed to by p, which was earlier allocated using
// bd_malloc.
void
bd_free(void *p) {
    80006b0e:	7159                	addi	sp,sp,-112
    80006b10:	f486                	sd	ra,104(sp)
    80006b12:	f0a2                	sd	s0,96(sp)
    80006b14:	eca6                	sd	s1,88(sp)
    80006b16:	e8ca                	sd	s2,80(sp)
    80006b18:	e4ce                	sd	s3,72(sp)
    80006b1a:	e0d2                	sd	s4,64(sp)
    80006b1c:	fc56                	sd	s5,56(sp)
    80006b1e:	f85a                	sd	s6,48(sp)
    80006b20:	f45e                	sd	s7,40(sp)
    80006b22:	f062                	sd	s8,32(sp)
    80006b24:	ec66                	sd	s9,24(sp)
    80006b26:	e86a                	sd	s10,16(sp)
    80006b28:	e46e                	sd	s11,8(sp)
    80006b2a:	1880                	addi	s0,sp,112
    80006b2c:	8aaa                	mv	s5,a0
  void *q;
  int k;

  acquire(&lock);
    80006b2e:	00029517          	auipc	a0,0x29
    80006b32:	4d250513          	addi	a0,a0,1234 # 80030000 <lock>
    80006b36:	ffffa097          	auipc	ra,0xffffa
    80006b3a:	0f2080e7          	jalr	242(ra) # 80000c28 <acquire>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b3e:	8556                	mv	a0,s5
    80006b40:	00000097          	auipc	ra,0x0
    80006b44:	f58080e7          	jalr	-168(ra) # 80006a98 <size>
    80006b48:	84aa                	mv	s1,a0
    80006b4a:	00029797          	auipc	a5,0x29
    80006b4e:	50e7a783          	lw	a5,1294(a5) # 80030058 <nsizes>
    80006b52:	37fd                	addiw	a5,a5,-1
    80006b54:	0cf55063          	bge	a0,a5,80006c14 <bd_free+0x106>
    80006b58:	00150a13          	addi	s4,a0,1
    80006b5c:	0a16                	slli	s4,s4,0x5
  int n = p - (char *) bd_base;
    80006b5e:	00029c17          	auipc	s8,0x29
    80006b62:	4eac0c13          	addi	s8,s8,1258 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006b66:	4bc1                	li	s7,16
    int bi = blk_index(k, p);
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006b68:	00029b17          	auipc	s6,0x29
    80006b6c:	4e8b0b13          	addi	s6,s6,1256 # 80030050 <bd_sizes>
  for (k = size(p); k < MAXSIZE; k++) {
    80006b70:	00029c97          	auipc	s9,0x29
    80006b74:	4e8c8c93          	addi	s9,s9,1256 # 80030058 <nsizes>
    80006b78:	a82d                	j	80006bb2 <bd_free+0xa4>
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006b7a:	fff58d9b          	addiw	s11,a1,-1
    80006b7e:	a881                	j	80006bce <bd_free+0xc0>
    if(buddy % 2 == 0) {
      p = q;
    }
    // at size k+1, mark that the merged buddy pair isn't split
    // anymore
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006b80:	2485                	addiw	s1,s1,1
  int n = p - (char *) bd_base;
    80006b82:	000c3583          	ld	a1,0(s8)
  return n / BLK_SIZE(k);
    80006b86:	40ba85bb          	subw	a1,s5,a1
    80006b8a:	009b97b3          	sll	a5,s7,s1
    80006b8e:	02f5c5b3          	div	a1,a1,a5
    bit_clear(bd_sizes[k+1].split, blk_index(k+1, p));
    80006b92:	000b3783          	ld	a5,0(s6)
    80006b96:	97d2                	add	a5,a5,s4
    80006b98:	2581                	sext.w	a1,a1
    80006b9a:	6f88                	ld	a0,24(a5)
    80006b9c:	00000097          	auipc	ra,0x0
    80006ba0:	b30080e7          	jalr	-1232(ra) # 800066cc <bit_clear>
  for (k = size(p); k < MAXSIZE; k++) {
    80006ba4:	020a0a13          	addi	s4,s4,32
    80006ba8:	000ca783          	lw	a5,0(s9)
    80006bac:	37fd                	addiw	a5,a5,-1
    80006bae:	06f4d363          	bge	s1,a5,80006c14 <bd_free+0x106>
  int n = p - (char *) bd_base;
    80006bb2:	000c3903          	ld	s2,0(s8)
  return n / BLK_SIZE(k);
    80006bb6:	009b99b3          	sll	s3,s7,s1
    80006bba:	412a87bb          	subw	a5,s5,s2
    80006bbe:	0337c7b3          	div	a5,a5,s3
    80006bc2:	0007859b          	sext.w	a1,a5
    int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006bc6:	8b85                	andi	a5,a5,1
    80006bc8:	fbcd                	bnez	a5,80006b7a <bd_free+0x6c>
    80006bca:	00158d9b          	addiw	s11,a1,1
    bit_clear(bd_sizes[k].alloc, bi);  // free p at size k
    80006bce:	fe0a0d13          	addi	s10,s4,-32
    80006bd2:	000b3783          	ld	a5,0(s6)
    80006bd6:	9d3e                	add	s10,s10,a5
    80006bd8:	010d3503          	ld	a0,16(s10)
    80006bdc:	00000097          	auipc	ra,0x0
    80006be0:	af0080e7          	jalr	-1296(ra) # 800066cc <bit_clear>
    if (bit_isset(bd_sizes[k].alloc, buddy)) {  // is buddy allocated?
    80006be4:	85ee                	mv	a1,s11
    80006be6:	010d3503          	ld	a0,16(s10)
    80006bea:	00000097          	auipc	ra,0x0
    80006bee:	a7a080e7          	jalr	-1414(ra) # 80006664 <bit_isset>
    80006bf2:	e10d                	bnez	a0,80006c14 <bd_free+0x106>
  int n = bi * BLK_SIZE(k);
    80006bf4:	000d8d1b          	sext.w	s10,s11
  return (char *) bd_base + n;
    80006bf8:	03b989bb          	mulw	s3,s3,s11
    80006bfc:	994e                	add	s2,s2,s3
    lst_remove(q);    // remove buddy from free list
    80006bfe:	854a                	mv	a0,s2
    80006c00:	00000097          	auipc	ra,0x0
    80006c04:	630080e7          	jalr	1584(ra) # 80007230 <lst_remove>
    if(buddy % 2 == 0) {
    80006c08:	001d7d13          	andi	s10,s10,1
    80006c0c:	f60d1ae3          	bnez	s10,80006b80 <bd_free+0x72>
      p = q;
    80006c10:	8aca                	mv	s5,s2
    80006c12:	b7bd                	j	80006b80 <bd_free+0x72>
  }
  lst_push(&bd_sizes[k].free, p);
    80006c14:	0496                	slli	s1,s1,0x5
    80006c16:	85d6                	mv	a1,s5
    80006c18:	00029517          	auipc	a0,0x29
    80006c1c:	43853503          	ld	a0,1080(a0) # 80030050 <bd_sizes>
    80006c20:	9526                	add	a0,a0,s1
    80006c22:	00000097          	auipc	ra,0x0
    80006c26:	65a080e7          	jalr	1626(ra) # 8000727c <lst_push>
  release(&lock);
    80006c2a:	00029517          	auipc	a0,0x29
    80006c2e:	3d650513          	addi	a0,a0,982 # 80030000 <lock>
    80006c32:	ffffa097          	auipc	ra,0xffffa
    80006c36:	066080e7          	jalr	102(ra) # 80000c98 <release>
}
    80006c3a:	70a6                	ld	ra,104(sp)
    80006c3c:	7406                	ld	s0,96(sp)
    80006c3e:	64e6                	ld	s1,88(sp)
    80006c40:	6946                	ld	s2,80(sp)
    80006c42:	69a6                	ld	s3,72(sp)
    80006c44:	6a06                	ld	s4,64(sp)
    80006c46:	7ae2                	ld	s5,56(sp)
    80006c48:	7b42                	ld	s6,48(sp)
    80006c4a:	7ba2                	ld	s7,40(sp)
    80006c4c:	7c02                	ld	s8,32(sp)
    80006c4e:	6ce2                	ld	s9,24(sp)
    80006c50:	6d42                	ld	s10,16(sp)
    80006c52:	6da2                	ld	s11,8(sp)
    80006c54:	6165                	addi	sp,sp,112
    80006c56:	8082                	ret

0000000080006c58 <blk_index_next>:

// Compute the first block at size k that doesn't contain p
int
blk_index_next(int k, char *p) {
    80006c58:	1141                	addi	sp,sp,-16
    80006c5a:	e422                	sd	s0,8(sp)
    80006c5c:	0800                	addi	s0,sp,16
  int n = (p - (char *) bd_base) / BLK_SIZE(k);
    80006c5e:	00029797          	auipc	a5,0x29
    80006c62:	3ea7b783          	ld	a5,1002(a5) # 80030048 <bd_base>
    80006c66:	8d9d                	sub	a1,a1,a5
    80006c68:	47c1                	li	a5,16
    80006c6a:	00a797b3          	sll	a5,a5,a0
    80006c6e:	02f5c533          	div	a0,a1,a5
    80006c72:	2501                	sext.w	a0,a0
  if((p - (char*) bd_base) % BLK_SIZE(k) != 0)
    80006c74:	02f5e5b3          	rem	a1,a1,a5
    80006c78:	c191                	beqz	a1,80006c7c <blk_index_next+0x24>
      n++;
    80006c7a:	2505                	addiw	a0,a0,1
  return n ;
}
    80006c7c:	6422                	ld	s0,8(sp)
    80006c7e:	0141                	addi	sp,sp,16
    80006c80:	8082                	ret

0000000080006c82 <log2>:

int
log2(uint64 n) {
    80006c82:	1141                	addi	sp,sp,-16
    80006c84:	e422                	sd	s0,8(sp)
    80006c86:	0800                	addi	s0,sp,16
  int k = 0;
  while (n > 1) {
    80006c88:	4705                	li	a4,1
    80006c8a:	00a77b63          	bgeu	a4,a0,80006ca0 <log2+0x1e>
    80006c8e:	87aa                	mv	a5,a0
  int k = 0;
    80006c90:	4501                	li	a0,0
    k++;
    80006c92:	2505                	addiw	a0,a0,1
    n = n >> 1;
    80006c94:	8385                	srli	a5,a5,0x1
  while (n > 1) {
    80006c96:	fef76ee3          	bltu	a4,a5,80006c92 <log2+0x10>
  }
  return k;
}
    80006c9a:	6422                	ld	s0,8(sp)
    80006c9c:	0141                	addi	sp,sp,16
    80006c9e:	8082                	ret
  int k = 0;
    80006ca0:	4501                	li	a0,0
    80006ca2:	bfe5                	j	80006c9a <log2+0x18>

0000000080006ca4 <bd_mark>:

// Mark memory from [start, stop), starting at size 0, as allocated. 
void
bd_mark(void *start, void *stop)
{
    80006ca4:	711d                	addi	sp,sp,-96
    80006ca6:	ec86                	sd	ra,88(sp)
    80006ca8:	e8a2                	sd	s0,80(sp)
    80006caa:	e4a6                	sd	s1,72(sp)
    80006cac:	e0ca                	sd	s2,64(sp)
    80006cae:	fc4e                	sd	s3,56(sp)
    80006cb0:	f852                	sd	s4,48(sp)
    80006cb2:	f456                	sd	s5,40(sp)
    80006cb4:	f05a                	sd	s6,32(sp)
    80006cb6:	ec5e                	sd	s7,24(sp)
    80006cb8:	e862                	sd	s8,16(sp)
    80006cba:	e466                	sd	s9,8(sp)
    80006cbc:	e06a                	sd	s10,0(sp)
    80006cbe:	1080                	addi	s0,sp,96
  int bi, bj;

  if (((uint64) start % LEAF_SIZE != 0) || ((uint64) stop % LEAF_SIZE != 0))
    80006cc0:	00b56933          	or	s2,a0,a1
    80006cc4:	00f97913          	andi	s2,s2,15
    80006cc8:	04091263          	bnez	s2,80006d0c <bd_mark+0x68>
    80006ccc:	8b2a                	mv	s6,a0
    80006cce:	8bae                	mv	s7,a1
    panic("bd_mark");

  for (int k = 0; k < nsizes; k++) {
    80006cd0:	00029c17          	auipc	s8,0x29
    80006cd4:	388c2c03          	lw	s8,904(s8) # 80030058 <nsizes>
    80006cd8:	4981                	li	s3,0
  int n = p - (char *) bd_base;
    80006cda:	00029d17          	auipc	s10,0x29
    80006cde:	36ed0d13          	addi	s10,s10,878 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006ce2:	4cc1                	li	s9,16
    bi = blk_index(k, start);
    bj = blk_index_next(k, stop);
    for(; bi < bj; bi++) {
      if(k > 0) {
        // if a block is allocated at size k, mark it as split too.
        bit_set(bd_sizes[k].split, bi);
    80006ce4:	00029a97          	auipc	s5,0x29
    80006ce8:	36ca8a93          	addi	s5,s5,876 # 80030050 <bd_sizes>
  for (int k = 0; k < nsizes; k++) {
    80006cec:	07804563          	bgtz	s8,80006d56 <bd_mark+0xb2>
      }
      bit_set(bd_sizes[k].alloc, bi);
    }
  }
}
    80006cf0:	60e6                	ld	ra,88(sp)
    80006cf2:	6446                	ld	s0,80(sp)
    80006cf4:	64a6                	ld	s1,72(sp)
    80006cf6:	6906                	ld	s2,64(sp)
    80006cf8:	79e2                	ld	s3,56(sp)
    80006cfa:	7a42                	ld	s4,48(sp)
    80006cfc:	7aa2                	ld	s5,40(sp)
    80006cfe:	7b02                	ld	s6,32(sp)
    80006d00:	6be2                	ld	s7,24(sp)
    80006d02:	6c42                	ld	s8,16(sp)
    80006d04:	6ca2                	ld	s9,8(sp)
    80006d06:	6d02                	ld	s10,0(sp)
    80006d08:	6125                	addi	sp,sp,96
    80006d0a:	8082                	ret
    panic("bd_mark");
    80006d0c:	00002517          	auipc	a0,0x2
    80006d10:	cd450513          	addi	a0,a0,-812 # 800089e0 <userret+0x950>
    80006d14:	ffffa097          	auipc	ra,0xffffa
    80006d18:	834080e7          	jalr	-1996(ra) # 80000548 <panic>
      bit_set(bd_sizes[k].alloc, bi);
    80006d1c:	000ab783          	ld	a5,0(s5)
    80006d20:	97ca                	add	a5,a5,s2
    80006d22:	85a6                	mv	a1,s1
    80006d24:	6b88                	ld	a0,16(a5)
    80006d26:	00000097          	auipc	ra,0x0
    80006d2a:	976080e7          	jalr	-1674(ra) # 8000669c <bit_set>
    for(; bi < bj; bi++) {
    80006d2e:	2485                	addiw	s1,s1,1
    80006d30:	009a0e63          	beq	s4,s1,80006d4c <bd_mark+0xa8>
      if(k > 0) {
    80006d34:	ff3054e3          	blez	s3,80006d1c <bd_mark+0x78>
        bit_set(bd_sizes[k].split, bi);
    80006d38:	000ab783          	ld	a5,0(s5)
    80006d3c:	97ca                	add	a5,a5,s2
    80006d3e:	85a6                	mv	a1,s1
    80006d40:	6f88                	ld	a0,24(a5)
    80006d42:	00000097          	auipc	ra,0x0
    80006d46:	95a080e7          	jalr	-1702(ra) # 8000669c <bit_set>
    80006d4a:	bfc9                	j	80006d1c <bd_mark+0x78>
  for (int k = 0; k < nsizes; k++) {
    80006d4c:	2985                	addiw	s3,s3,1
    80006d4e:	02090913          	addi	s2,s2,32
    80006d52:	f9898fe3          	beq	s3,s8,80006cf0 <bd_mark+0x4c>
  int n = p - (char *) bd_base;
    80006d56:	000d3483          	ld	s1,0(s10)
  return n / BLK_SIZE(k);
    80006d5a:	409b04bb          	subw	s1,s6,s1
    80006d5e:	013c97b3          	sll	a5,s9,s3
    80006d62:	02f4c4b3          	div	s1,s1,a5
    80006d66:	2481                	sext.w	s1,s1
    bj = blk_index_next(k, stop);
    80006d68:	85de                	mv	a1,s7
    80006d6a:	854e                	mv	a0,s3
    80006d6c:	00000097          	auipc	ra,0x0
    80006d70:	eec080e7          	jalr	-276(ra) # 80006c58 <blk_index_next>
    80006d74:	8a2a                	mv	s4,a0
    for(; bi < bj; bi++) {
    80006d76:	faa4cfe3          	blt	s1,a0,80006d34 <bd_mark+0x90>
    80006d7a:	bfc9                	j	80006d4c <bd_mark+0xa8>

0000000080006d7c <bd_initfree_pair>:

// If a block is marked as allocated and the buddy is free, put the
// buddy on the free list at size k.
int
bd_initfree_pair(int k, int bi) {
    80006d7c:	7139                	addi	sp,sp,-64
    80006d7e:	fc06                	sd	ra,56(sp)
    80006d80:	f822                	sd	s0,48(sp)
    80006d82:	f426                	sd	s1,40(sp)
    80006d84:	f04a                	sd	s2,32(sp)
    80006d86:	ec4e                	sd	s3,24(sp)
    80006d88:	e852                	sd	s4,16(sp)
    80006d8a:	e456                	sd	s5,8(sp)
    80006d8c:	e05a                	sd	s6,0(sp)
    80006d8e:	0080                	addi	s0,sp,64
    80006d90:	89aa                	mv	s3,a0
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006d92:	00058a9b          	sext.w	s5,a1
    80006d96:	0015f793          	andi	a5,a1,1
    80006d9a:	ebad                	bnez	a5,80006e0c <bd_initfree_pair+0x90>
    80006d9c:	00158a1b          	addiw	s4,a1,1
  int free = 0;
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006da0:	00599493          	slli	s1,s3,0x5
    80006da4:	00029797          	auipc	a5,0x29
    80006da8:	2ac7b783          	ld	a5,684(a5) # 80030050 <bd_sizes>
    80006dac:	94be                	add	s1,s1,a5
    80006dae:	0104bb03          	ld	s6,16(s1)
    80006db2:	855a                	mv	a0,s6
    80006db4:	00000097          	auipc	ra,0x0
    80006db8:	8b0080e7          	jalr	-1872(ra) # 80006664 <bit_isset>
    80006dbc:	892a                	mv	s2,a0
    80006dbe:	85d2                	mv	a1,s4
    80006dc0:	855a                	mv	a0,s6
    80006dc2:	00000097          	auipc	ra,0x0
    80006dc6:	8a2080e7          	jalr	-1886(ra) # 80006664 <bit_isset>
  int free = 0;
    80006dca:	4b01                	li	s6,0
  if(bit_isset(bd_sizes[k].alloc, bi) !=  bit_isset(bd_sizes[k].alloc, buddy)) {
    80006dcc:	02a90563          	beq	s2,a0,80006df6 <bd_initfree_pair+0x7a>
    // one of the pair is free
    free = BLK_SIZE(k);
    80006dd0:	45c1                	li	a1,16
    80006dd2:	013599b3          	sll	s3,a1,s3
    80006dd6:	00098b1b          	sext.w	s6,s3
    if(bit_isset(bd_sizes[k].alloc, bi))
    80006dda:	02090c63          	beqz	s2,80006e12 <bd_initfree_pair+0x96>
  return (char *) bd_base + n;
    80006dde:	034989bb          	mulw	s3,s3,s4
      lst_push(&bd_sizes[k].free, addr(k, buddy));   // put buddy on free list
    80006de2:	00029597          	auipc	a1,0x29
    80006de6:	2665b583          	ld	a1,614(a1) # 80030048 <bd_base>
    80006dea:	95ce                	add	a1,a1,s3
    80006dec:	8526                	mv	a0,s1
    80006dee:	00000097          	auipc	ra,0x0
    80006df2:	48e080e7          	jalr	1166(ra) # 8000727c <lst_push>
    else
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
  }
  return free;
}
    80006df6:	855a                	mv	a0,s6
    80006df8:	70e2                	ld	ra,56(sp)
    80006dfa:	7442                	ld	s0,48(sp)
    80006dfc:	74a2                	ld	s1,40(sp)
    80006dfe:	7902                	ld	s2,32(sp)
    80006e00:	69e2                	ld	s3,24(sp)
    80006e02:	6a42                	ld	s4,16(sp)
    80006e04:	6aa2                	ld	s5,8(sp)
    80006e06:	6b02                	ld	s6,0(sp)
    80006e08:	6121                	addi	sp,sp,64
    80006e0a:	8082                	ret
  int buddy = (bi % 2 == 0) ? bi+1 : bi-1;
    80006e0c:	fff58a1b          	addiw	s4,a1,-1
    80006e10:	bf41                	j	80006da0 <bd_initfree_pair+0x24>
  return (char *) bd_base + n;
    80006e12:	035989bb          	mulw	s3,s3,s5
      lst_push(&bd_sizes[k].free, addr(k, bi));      // put bi on free list
    80006e16:	00029597          	auipc	a1,0x29
    80006e1a:	2325b583          	ld	a1,562(a1) # 80030048 <bd_base>
    80006e1e:	95ce                	add	a1,a1,s3
    80006e20:	8526                	mv	a0,s1
    80006e22:	00000097          	auipc	ra,0x0
    80006e26:	45a080e7          	jalr	1114(ra) # 8000727c <lst_push>
    80006e2a:	b7f1                	j	80006df6 <bd_initfree_pair+0x7a>

0000000080006e2c <bd_initfree>:
  
// Initialize the free lists for each size k.  For each size k, there
// are only two pairs that may have a buddy that should be on free list:
// bd_left and bd_right.
int
bd_initfree(void *bd_left, void *bd_right) {
    80006e2c:	711d                	addi	sp,sp,-96
    80006e2e:	ec86                	sd	ra,88(sp)
    80006e30:	e8a2                	sd	s0,80(sp)
    80006e32:	e4a6                	sd	s1,72(sp)
    80006e34:	e0ca                	sd	s2,64(sp)
    80006e36:	fc4e                	sd	s3,56(sp)
    80006e38:	f852                	sd	s4,48(sp)
    80006e3a:	f456                	sd	s5,40(sp)
    80006e3c:	f05a                	sd	s6,32(sp)
    80006e3e:	ec5e                	sd	s7,24(sp)
    80006e40:	e862                	sd	s8,16(sp)
    80006e42:	e466                	sd	s9,8(sp)
    80006e44:	e06a                	sd	s10,0(sp)
    80006e46:	1080                	addi	s0,sp,96
  int free = 0;

  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006e48:	00029717          	auipc	a4,0x29
    80006e4c:	21072703          	lw	a4,528(a4) # 80030058 <nsizes>
    80006e50:	4785                	li	a5,1
    80006e52:	06e7db63          	bge	a5,a4,80006ec8 <bd_initfree+0x9c>
    80006e56:	8aaa                	mv	s5,a0
    80006e58:	8b2e                	mv	s6,a1
    80006e5a:	4901                	li	s2,0
  int free = 0;
    80006e5c:	4a01                	li	s4,0
  int n = p - (char *) bd_base;
    80006e5e:	00029c97          	auipc	s9,0x29
    80006e62:	1eac8c93          	addi	s9,s9,490 # 80030048 <bd_base>
  return n / BLK_SIZE(k);
    80006e66:	4c41                	li	s8,16
  for (int k = 0; k < MAXSIZE; k++) {   // skip max size
    80006e68:	00029b97          	auipc	s7,0x29
    80006e6c:	1f0b8b93          	addi	s7,s7,496 # 80030058 <nsizes>
    80006e70:	a039                	j	80006e7e <bd_initfree+0x52>
    80006e72:	2905                	addiw	s2,s2,1
    80006e74:	000ba783          	lw	a5,0(s7)
    80006e78:	37fd                	addiw	a5,a5,-1
    80006e7a:	04f95863          	bge	s2,a5,80006eca <bd_initfree+0x9e>
    int left = blk_index_next(k, bd_left);
    80006e7e:	85d6                	mv	a1,s5
    80006e80:	854a                	mv	a0,s2
    80006e82:	00000097          	auipc	ra,0x0
    80006e86:	dd6080e7          	jalr	-554(ra) # 80006c58 <blk_index_next>
    80006e8a:	89aa                	mv	s3,a0
  int n = p - (char *) bd_base;
    80006e8c:	000cb483          	ld	s1,0(s9)
  return n / BLK_SIZE(k);
    80006e90:	409b04bb          	subw	s1,s6,s1
    80006e94:	012c17b3          	sll	a5,s8,s2
    80006e98:	02f4c4b3          	div	s1,s1,a5
    80006e9c:	2481                	sext.w	s1,s1
    int right = blk_index(k, bd_right);
    free += bd_initfree_pair(k, left);
    80006e9e:	85aa                	mv	a1,a0
    80006ea0:	854a                	mv	a0,s2
    80006ea2:	00000097          	auipc	ra,0x0
    80006ea6:	eda080e7          	jalr	-294(ra) # 80006d7c <bd_initfree_pair>
    80006eaa:	01450d3b          	addw	s10,a0,s4
    80006eae:	000d0a1b          	sext.w	s4,s10
    if(right <= left)
    80006eb2:	fc99d0e3          	bge	s3,s1,80006e72 <bd_initfree+0x46>
      continue;
    free += bd_initfree_pair(k, right);
    80006eb6:	85a6                	mv	a1,s1
    80006eb8:	854a                	mv	a0,s2
    80006eba:	00000097          	auipc	ra,0x0
    80006ebe:	ec2080e7          	jalr	-318(ra) # 80006d7c <bd_initfree_pair>
    80006ec2:	00ad0a3b          	addw	s4,s10,a0
    80006ec6:	b775                	j	80006e72 <bd_initfree+0x46>
  int free = 0;
    80006ec8:	4a01                	li	s4,0
  }
  return free;
}
    80006eca:	8552                	mv	a0,s4
    80006ecc:	60e6                	ld	ra,88(sp)
    80006ece:	6446                	ld	s0,80(sp)
    80006ed0:	64a6                	ld	s1,72(sp)
    80006ed2:	6906                	ld	s2,64(sp)
    80006ed4:	79e2                	ld	s3,56(sp)
    80006ed6:	7a42                	ld	s4,48(sp)
    80006ed8:	7aa2                	ld	s5,40(sp)
    80006eda:	7b02                	ld	s6,32(sp)
    80006edc:	6be2                	ld	s7,24(sp)
    80006ede:	6c42                	ld	s8,16(sp)
    80006ee0:	6ca2                	ld	s9,8(sp)
    80006ee2:	6d02                	ld	s10,0(sp)
    80006ee4:	6125                	addi	sp,sp,96
    80006ee6:	8082                	ret

0000000080006ee8 <bd_mark_data_structures>:

// Mark the range [bd_base,p) as allocated
int
bd_mark_data_structures(char *p) {
    80006ee8:	7179                	addi	sp,sp,-48
    80006eea:	f406                	sd	ra,40(sp)
    80006eec:	f022                	sd	s0,32(sp)
    80006eee:	ec26                	sd	s1,24(sp)
    80006ef0:	e84a                	sd	s2,16(sp)
    80006ef2:	e44e                	sd	s3,8(sp)
    80006ef4:	1800                	addi	s0,sp,48
    80006ef6:	892a                	mv	s2,a0
  int meta = p - (char*)bd_base;
    80006ef8:	00029997          	auipc	s3,0x29
    80006efc:	15098993          	addi	s3,s3,336 # 80030048 <bd_base>
    80006f00:	0009b483          	ld	s1,0(s3)
    80006f04:	409504bb          	subw	s1,a0,s1
  printf("bd: %d meta bytes for managing %d bytes of memory\n", meta, BLK_SIZE(MAXSIZE));
    80006f08:	00029797          	auipc	a5,0x29
    80006f0c:	1507a783          	lw	a5,336(a5) # 80030058 <nsizes>
    80006f10:	37fd                	addiw	a5,a5,-1
    80006f12:	4641                	li	a2,16
    80006f14:	00f61633          	sll	a2,a2,a5
    80006f18:	85a6                	mv	a1,s1
    80006f1a:	00002517          	auipc	a0,0x2
    80006f1e:	ace50513          	addi	a0,a0,-1330 # 800089e8 <userret+0x958>
    80006f22:	ffff9097          	auipc	ra,0xffff9
    80006f26:	680080e7          	jalr	1664(ra) # 800005a2 <printf>
  bd_mark(bd_base, p);
    80006f2a:	85ca                	mv	a1,s2
    80006f2c:	0009b503          	ld	a0,0(s3)
    80006f30:	00000097          	auipc	ra,0x0
    80006f34:	d74080e7          	jalr	-652(ra) # 80006ca4 <bd_mark>
  return meta;
}
    80006f38:	8526                	mv	a0,s1
    80006f3a:	70a2                	ld	ra,40(sp)
    80006f3c:	7402                	ld	s0,32(sp)
    80006f3e:	64e2                	ld	s1,24(sp)
    80006f40:	6942                	ld	s2,16(sp)
    80006f42:	69a2                	ld	s3,8(sp)
    80006f44:	6145                	addi	sp,sp,48
    80006f46:	8082                	ret

0000000080006f48 <bd_mark_unavailable>:

// Mark the range [end, HEAPSIZE) as allocated
int
bd_mark_unavailable(void *end, void *left) {
    80006f48:	1101                	addi	sp,sp,-32
    80006f4a:	ec06                	sd	ra,24(sp)
    80006f4c:	e822                	sd	s0,16(sp)
    80006f4e:	e426                	sd	s1,8(sp)
    80006f50:	1000                	addi	s0,sp,32
  int unavailable = BLK_SIZE(MAXSIZE)-(end-bd_base);
    80006f52:	00029497          	auipc	s1,0x29
    80006f56:	1064a483          	lw	s1,262(s1) # 80030058 <nsizes>
    80006f5a:	fff4879b          	addiw	a5,s1,-1
    80006f5e:	44c1                	li	s1,16
    80006f60:	00f494b3          	sll	s1,s1,a5
    80006f64:	00029797          	auipc	a5,0x29
    80006f68:	0e47b783          	ld	a5,228(a5) # 80030048 <bd_base>
    80006f6c:	8d1d                	sub	a0,a0,a5
    80006f6e:	40a4853b          	subw	a0,s1,a0
    80006f72:	0005049b          	sext.w	s1,a0
  if(unavailable > 0)
    80006f76:	00905a63          	blez	s1,80006f8a <bd_mark_unavailable+0x42>
    unavailable = ROUNDUP(unavailable, LEAF_SIZE);
    80006f7a:	357d                	addiw	a0,a0,-1
    80006f7c:	41f5549b          	sraiw	s1,a0,0x1f
    80006f80:	01c4d49b          	srliw	s1,s1,0x1c
    80006f84:	9ca9                	addw	s1,s1,a0
    80006f86:	98c1                	andi	s1,s1,-16
    80006f88:	24c1                	addiw	s1,s1,16
  printf("bd: 0x%x bytes unavailable\n", unavailable);
    80006f8a:	85a6                	mv	a1,s1
    80006f8c:	00002517          	auipc	a0,0x2
    80006f90:	a9450513          	addi	a0,a0,-1388 # 80008a20 <userret+0x990>
    80006f94:	ffff9097          	auipc	ra,0xffff9
    80006f98:	60e080e7          	jalr	1550(ra) # 800005a2 <printf>

  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80006f9c:	00029717          	auipc	a4,0x29
    80006fa0:	0ac73703          	ld	a4,172(a4) # 80030048 <bd_base>
    80006fa4:	00029597          	auipc	a1,0x29
    80006fa8:	0b45a583          	lw	a1,180(a1) # 80030058 <nsizes>
    80006fac:	fff5879b          	addiw	a5,a1,-1
    80006fb0:	45c1                	li	a1,16
    80006fb2:	00f595b3          	sll	a1,a1,a5
    80006fb6:	40958533          	sub	a0,a1,s1
  bd_mark(bd_end, bd_base+BLK_SIZE(MAXSIZE));
    80006fba:	95ba                	add	a1,a1,a4
    80006fbc:	953a                	add	a0,a0,a4
    80006fbe:	00000097          	auipc	ra,0x0
    80006fc2:	ce6080e7          	jalr	-794(ra) # 80006ca4 <bd_mark>
  return unavailable;
}
    80006fc6:	8526                	mv	a0,s1
    80006fc8:	60e2                	ld	ra,24(sp)
    80006fca:	6442                	ld	s0,16(sp)
    80006fcc:	64a2                	ld	s1,8(sp)
    80006fce:	6105                	addi	sp,sp,32
    80006fd0:	8082                	ret

0000000080006fd2 <bd_init>:

// Initialize the buddy allocator: it manages memory from [base, end).
void
bd_init(void *base, void *end) {
    80006fd2:	715d                	addi	sp,sp,-80
    80006fd4:	e486                	sd	ra,72(sp)
    80006fd6:	e0a2                	sd	s0,64(sp)
    80006fd8:	fc26                	sd	s1,56(sp)
    80006fda:	f84a                	sd	s2,48(sp)
    80006fdc:	f44e                	sd	s3,40(sp)
    80006fde:	f052                	sd	s4,32(sp)
    80006fe0:	ec56                	sd	s5,24(sp)
    80006fe2:	e85a                	sd	s6,16(sp)
    80006fe4:	e45e                	sd	s7,8(sp)
    80006fe6:	e062                	sd	s8,0(sp)
    80006fe8:	0880                	addi	s0,sp,80
    80006fea:	8c2e                	mv	s8,a1
  char *p = (char *) ROUNDUP((uint64)base, LEAF_SIZE);
    80006fec:	fff50493          	addi	s1,a0,-1
    80006ff0:	98c1                	andi	s1,s1,-16
    80006ff2:	04c1                	addi	s1,s1,16
  int sz;

  initlock(&lock, "buddy");
    80006ff4:	00002597          	auipc	a1,0x2
    80006ff8:	a4c58593          	addi	a1,a1,-1460 # 80008a40 <userret+0x9b0>
    80006ffc:	00029517          	auipc	a0,0x29
    80007000:	00450513          	addi	a0,a0,4 # 80030000 <lock>
    80007004:	ffffa097          	auipc	ra,0xffffa
    80007008:	ad6080e7          	jalr	-1322(ra) # 80000ada <initlock>
  bd_base = (void *) p;
    8000700c:	00029797          	auipc	a5,0x29
    80007010:	0297be23          	sd	s1,60(a5) # 80030048 <bd_base>

  // compute the number of sizes we need to manage [base, end)
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007014:	409c0933          	sub	s2,s8,s1
    80007018:	43f95513          	srai	a0,s2,0x3f
    8000701c:	893d                	andi	a0,a0,15
    8000701e:	954a                	add	a0,a0,s2
    80007020:	8511                	srai	a0,a0,0x4
    80007022:	00000097          	auipc	ra,0x0
    80007026:	c60080e7          	jalr	-928(ra) # 80006c82 <log2>
  if((char*)end-p > BLK_SIZE(MAXSIZE)) {
    8000702a:	47c1                	li	a5,16
    8000702c:	00a797b3          	sll	a5,a5,a0
    80007030:	1b27c663          	blt	a5,s2,800071dc <bd_init+0x20a>
  nsizes = log2(((char *)end-p)/LEAF_SIZE) + 1;
    80007034:	2505                	addiw	a0,a0,1
    80007036:	00029797          	auipc	a5,0x29
    8000703a:	02a7a123          	sw	a0,34(a5) # 80030058 <nsizes>
    nsizes++;  // round up to the next power of 2
  }

  printf("bd: memory sz is %d bytes; allocate an size array of length %d\n",
    8000703e:	00029997          	auipc	s3,0x29
    80007042:	01a98993          	addi	s3,s3,26 # 80030058 <nsizes>
    80007046:	0009a603          	lw	a2,0(s3)
    8000704a:	85ca                	mv	a1,s2
    8000704c:	00002517          	auipc	a0,0x2
    80007050:	9fc50513          	addi	a0,a0,-1540 # 80008a48 <userret+0x9b8>
    80007054:	ffff9097          	auipc	ra,0xffff9
    80007058:	54e080e7          	jalr	1358(ra) # 800005a2 <printf>
         (char*) end - p, nsizes);

  // allocate bd_sizes array
  bd_sizes = (Sz_info *) p;
    8000705c:	00029797          	auipc	a5,0x29
    80007060:	fe97ba23          	sd	s1,-12(a5) # 80030050 <bd_sizes>
  p += sizeof(Sz_info) * nsizes;
    80007064:	0009a603          	lw	a2,0(s3)
    80007068:	00561913          	slli	s2,a2,0x5
    8000706c:	9926                	add	s2,s2,s1
  memset(bd_sizes, 0, sizeof(Sz_info) * nsizes);
    8000706e:	0056161b          	slliw	a2,a2,0x5
    80007072:	4581                	li	a1,0
    80007074:	8526                	mv	a0,s1
    80007076:	ffffa097          	auipc	ra,0xffffa
    8000707a:	e20080e7          	jalr	-480(ra) # 80000e96 <memset>

  // initialize free list and allocate the alloc array for each size k
  for (int k = 0; k < nsizes; k++) {
    8000707e:	0009a783          	lw	a5,0(s3)
    80007082:	06f05a63          	blez	a5,800070f6 <bd_init+0x124>
    80007086:	4981                	li	s3,0
    lst_init(&bd_sizes[k].free);
    80007088:	00029a97          	auipc	s5,0x29
    8000708c:	fc8a8a93          	addi	s5,s5,-56 # 80030050 <bd_sizes>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    80007090:	00029a17          	auipc	s4,0x29
    80007094:	fc8a0a13          	addi	s4,s4,-56 # 80030058 <nsizes>
    80007098:	4b05                	li	s6,1
    lst_init(&bd_sizes[k].free);
    8000709a:	00599b93          	slli	s7,s3,0x5
    8000709e:	000ab503          	ld	a0,0(s5)
    800070a2:	955e                	add	a0,a0,s7
    800070a4:	00000097          	auipc	ra,0x0
    800070a8:	166080e7          	jalr	358(ra) # 8000720a <lst_init>
    sz = sizeof(char)* ROUNDUP(NBLK(k), 8)/8;
    800070ac:	000a2483          	lw	s1,0(s4)
    800070b0:	34fd                	addiw	s1,s1,-1
    800070b2:	413484bb          	subw	s1,s1,s3
    800070b6:	009b14bb          	sllw	s1,s6,s1
    800070ba:	fff4879b          	addiw	a5,s1,-1
    800070be:	41f7d49b          	sraiw	s1,a5,0x1f
    800070c2:	01d4d49b          	srliw	s1,s1,0x1d
    800070c6:	9cbd                	addw	s1,s1,a5
    800070c8:	98e1                	andi	s1,s1,-8
    800070ca:	24a1                	addiw	s1,s1,8
    bd_sizes[k].alloc = p;
    800070cc:	000ab783          	ld	a5,0(s5)
    800070d0:	9bbe                	add	s7,s7,a5
    800070d2:	012bb823          	sd	s2,16(s7)
    memset(bd_sizes[k].alloc, 0, sz);
    800070d6:	848d                	srai	s1,s1,0x3
    800070d8:	8626                	mv	a2,s1
    800070da:	4581                	li	a1,0
    800070dc:	854a                	mv	a0,s2
    800070de:	ffffa097          	auipc	ra,0xffffa
    800070e2:	db8080e7          	jalr	-584(ra) # 80000e96 <memset>
    p += sz;
    800070e6:	9926                	add	s2,s2,s1
  for (int k = 0; k < nsizes; k++) {
    800070e8:	0985                	addi	s3,s3,1
    800070ea:	000a2703          	lw	a4,0(s4)
    800070ee:	0009879b          	sext.w	a5,s3
    800070f2:	fae7c4e3          	blt	a5,a4,8000709a <bd_init+0xc8>
  }

  // allocate the split array for each size k, except for k = 0, since
  // we will not split blocks of size k = 0, the smallest size.
  for (int k = 1; k < nsizes; k++) {
    800070f6:	00029797          	auipc	a5,0x29
    800070fa:	f627a783          	lw	a5,-158(a5) # 80030058 <nsizes>
    800070fe:	4705                	li	a4,1
    80007100:	06f75163          	bge	a4,a5,80007162 <bd_init+0x190>
    80007104:	02000a13          	li	s4,32
    80007108:	4985                	li	s3,1
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000710a:	4b85                	li	s7,1
    bd_sizes[k].split = p;
    8000710c:	00029b17          	auipc	s6,0x29
    80007110:	f44b0b13          	addi	s6,s6,-188 # 80030050 <bd_sizes>
  for (int k = 1; k < nsizes; k++) {
    80007114:	00029a97          	auipc	s5,0x29
    80007118:	f44a8a93          	addi	s5,s5,-188 # 80030058 <nsizes>
    sz = sizeof(char)* (ROUNDUP(NBLK(k), 8))/8;
    8000711c:	37fd                	addiw	a5,a5,-1
    8000711e:	413787bb          	subw	a5,a5,s3
    80007122:	00fb94bb          	sllw	s1,s7,a5
    80007126:	fff4879b          	addiw	a5,s1,-1
    8000712a:	41f7d49b          	sraiw	s1,a5,0x1f
    8000712e:	01d4d49b          	srliw	s1,s1,0x1d
    80007132:	9cbd                	addw	s1,s1,a5
    80007134:	98e1                	andi	s1,s1,-8
    80007136:	24a1                	addiw	s1,s1,8
    bd_sizes[k].split = p;
    80007138:	000b3783          	ld	a5,0(s6)
    8000713c:	97d2                	add	a5,a5,s4
    8000713e:	0127bc23          	sd	s2,24(a5)
    memset(bd_sizes[k].split, 0, sz);
    80007142:	848d                	srai	s1,s1,0x3
    80007144:	8626                	mv	a2,s1
    80007146:	4581                	li	a1,0
    80007148:	854a                	mv	a0,s2
    8000714a:	ffffa097          	auipc	ra,0xffffa
    8000714e:	d4c080e7          	jalr	-692(ra) # 80000e96 <memset>
    p += sz;
    80007152:	9926                	add	s2,s2,s1
  for (int k = 1; k < nsizes; k++) {
    80007154:	2985                	addiw	s3,s3,1
    80007156:	000aa783          	lw	a5,0(s5)
    8000715a:	020a0a13          	addi	s4,s4,32
    8000715e:	faf9cfe3          	blt	s3,a5,8000711c <bd_init+0x14a>
  }
  p = (char *) ROUNDUP((uint64) p, LEAF_SIZE);
    80007162:	197d                	addi	s2,s2,-1
    80007164:	ff097913          	andi	s2,s2,-16
    80007168:	0941                	addi	s2,s2,16

  // done allocating; mark the memory range [base, p) as allocated, so
  // that buddy will not hand out that memory.
  int meta = bd_mark_data_structures(p);
    8000716a:	854a                	mv	a0,s2
    8000716c:	00000097          	auipc	ra,0x0
    80007170:	d7c080e7          	jalr	-644(ra) # 80006ee8 <bd_mark_data_structures>
    80007174:	8a2a                	mv	s4,a0
  
  // mark the unavailable memory range [end, HEAP_SIZE) as allocated,
  // so that buddy will not hand out that memory.
  int unavailable = bd_mark_unavailable(end, p);
    80007176:	85ca                	mv	a1,s2
    80007178:	8562                	mv	a0,s8
    8000717a:	00000097          	auipc	ra,0x0
    8000717e:	dce080e7          	jalr	-562(ra) # 80006f48 <bd_mark_unavailable>
    80007182:	89aa                	mv	s3,a0
  void *bd_end = bd_base+BLK_SIZE(MAXSIZE)-unavailable;
    80007184:	00029a97          	auipc	s5,0x29
    80007188:	ed4a8a93          	addi	s5,s5,-300 # 80030058 <nsizes>
    8000718c:	000aa783          	lw	a5,0(s5)
    80007190:	37fd                	addiw	a5,a5,-1
    80007192:	44c1                	li	s1,16
    80007194:	00f497b3          	sll	a5,s1,a5
    80007198:	8f89                	sub	a5,a5,a0
  
  // initialize free lists for each size k
  int free = bd_initfree(p, bd_end);
    8000719a:	00029597          	auipc	a1,0x29
    8000719e:	eae5b583          	ld	a1,-338(a1) # 80030048 <bd_base>
    800071a2:	95be                	add	a1,a1,a5
    800071a4:	854a                	mv	a0,s2
    800071a6:	00000097          	auipc	ra,0x0
    800071aa:	c86080e7          	jalr	-890(ra) # 80006e2c <bd_initfree>

  // check if the amount that is free is what we expect
  if(free != BLK_SIZE(MAXSIZE)-meta-unavailable) {
    800071ae:	000aa603          	lw	a2,0(s5)
    800071b2:	367d                	addiw	a2,a2,-1
    800071b4:	00c49633          	sll	a2,s1,a2
    800071b8:	41460633          	sub	a2,a2,s4
    800071bc:	41360633          	sub	a2,a2,s3
    800071c0:	02c51463          	bne	a0,a2,800071e8 <bd_init+0x216>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    panic("bd_init: free mem");
  }
}
    800071c4:	60a6                	ld	ra,72(sp)
    800071c6:	6406                	ld	s0,64(sp)
    800071c8:	74e2                	ld	s1,56(sp)
    800071ca:	7942                	ld	s2,48(sp)
    800071cc:	79a2                	ld	s3,40(sp)
    800071ce:	7a02                	ld	s4,32(sp)
    800071d0:	6ae2                	ld	s5,24(sp)
    800071d2:	6b42                	ld	s6,16(sp)
    800071d4:	6ba2                	ld	s7,8(sp)
    800071d6:	6c02                	ld	s8,0(sp)
    800071d8:	6161                	addi	sp,sp,80
    800071da:	8082                	ret
    nsizes++;  // round up to the next power of 2
    800071dc:	2509                	addiw	a0,a0,2
    800071de:	00029797          	auipc	a5,0x29
    800071e2:	e6a7ad23          	sw	a0,-390(a5) # 80030058 <nsizes>
    800071e6:	bda1                	j	8000703e <bd_init+0x6c>
    printf("free %d %d\n", free, BLK_SIZE(MAXSIZE)-meta-unavailable);
    800071e8:	85aa                	mv	a1,a0
    800071ea:	00002517          	auipc	a0,0x2
    800071ee:	89e50513          	addi	a0,a0,-1890 # 80008a88 <userret+0x9f8>
    800071f2:	ffff9097          	auipc	ra,0xffff9
    800071f6:	3b0080e7          	jalr	944(ra) # 800005a2 <printf>
    panic("bd_init: free mem");
    800071fa:	00002517          	auipc	a0,0x2
    800071fe:	89e50513          	addi	a0,a0,-1890 # 80008a98 <userret+0xa08>
    80007202:	ffff9097          	auipc	ra,0xffff9
    80007206:	346080e7          	jalr	838(ra) # 80000548 <panic>

000000008000720a <lst_init>:
// fast. circular simplifies code, because don't have to check for
// empty list in insert and remove.

void
lst_init(struct list *lst)
{
    8000720a:	1141                	addi	sp,sp,-16
    8000720c:	e422                	sd	s0,8(sp)
    8000720e:	0800                	addi	s0,sp,16
  lst->next = lst;
    80007210:	e108                	sd	a0,0(a0)
  lst->prev = lst;
    80007212:	e508                	sd	a0,8(a0)
}
    80007214:	6422                	ld	s0,8(sp)
    80007216:	0141                	addi	sp,sp,16
    80007218:	8082                	ret

000000008000721a <lst_empty>:

int
lst_empty(struct list *lst) {
    8000721a:	1141                	addi	sp,sp,-16
    8000721c:	e422                	sd	s0,8(sp)
    8000721e:	0800                	addi	s0,sp,16
  return lst->next == lst;
    80007220:	611c                	ld	a5,0(a0)
    80007222:	40a78533          	sub	a0,a5,a0
}
    80007226:	00153513          	seqz	a0,a0
    8000722a:	6422                	ld	s0,8(sp)
    8000722c:	0141                	addi	sp,sp,16
    8000722e:	8082                	ret

0000000080007230 <lst_remove>:

void
lst_remove(struct list *e) {
    80007230:	1141                	addi	sp,sp,-16
    80007232:	e422                	sd	s0,8(sp)
    80007234:	0800                	addi	s0,sp,16
  e->prev->next = e->next;
    80007236:	6518                	ld	a4,8(a0)
    80007238:	611c                	ld	a5,0(a0)
    8000723a:	e31c                	sd	a5,0(a4)
  e->next->prev = e->prev;
    8000723c:	6518                	ld	a4,8(a0)
    8000723e:	e798                	sd	a4,8(a5)
}
    80007240:	6422                	ld	s0,8(sp)
    80007242:	0141                	addi	sp,sp,16
    80007244:	8082                	ret

0000000080007246 <lst_pop>:

void*
lst_pop(struct list *lst) {
    80007246:	1101                	addi	sp,sp,-32
    80007248:	ec06                	sd	ra,24(sp)
    8000724a:	e822                	sd	s0,16(sp)
    8000724c:	e426                	sd	s1,8(sp)
    8000724e:	1000                	addi	s0,sp,32
  if(lst->next == lst)
    80007250:	6104                	ld	s1,0(a0)
    80007252:	00a48d63          	beq	s1,a0,8000726c <lst_pop+0x26>
    panic("lst_pop");
  struct list *p = lst->next;
  lst_remove(p);
    80007256:	8526                	mv	a0,s1
    80007258:	00000097          	auipc	ra,0x0
    8000725c:	fd8080e7          	jalr	-40(ra) # 80007230 <lst_remove>
  return (void *)p;
}
    80007260:	8526                	mv	a0,s1
    80007262:	60e2                	ld	ra,24(sp)
    80007264:	6442                	ld	s0,16(sp)
    80007266:	64a2                	ld	s1,8(sp)
    80007268:	6105                	addi	sp,sp,32
    8000726a:	8082                	ret
    panic("lst_pop");
    8000726c:	00002517          	auipc	a0,0x2
    80007270:	84450513          	addi	a0,a0,-1980 # 80008ab0 <userret+0xa20>
    80007274:	ffff9097          	auipc	ra,0xffff9
    80007278:	2d4080e7          	jalr	724(ra) # 80000548 <panic>

000000008000727c <lst_push>:

void
lst_push(struct list *lst, void *p)
{
    8000727c:	1141                	addi	sp,sp,-16
    8000727e:	e422                	sd	s0,8(sp)
    80007280:	0800                	addi	s0,sp,16
  struct list *e = (struct list *) p;
  e->next = lst->next;
    80007282:	611c                	ld	a5,0(a0)
    80007284:	e19c                	sd	a5,0(a1)
  e->prev = lst;
    80007286:	e588                	sd	a0,8(a1)
  lst->next->prev = p;
    80007288:	611c                	ld	a5,0(a0)
    8000728a:	e78c                	sd	a1,8(a5)
  lst->next = e;
    8000728c:	e10c                	sd	a1,0(a0)
}
    8000728e:	6422                	ld	s0,8(sp)
    80007290:	0141                	addi	sp,sp,16
    80007292:	8082                	ret

0000000080007294 <lst_print>:

void
lst_print(struct list *lst)
{
    80007294:	7179                	addi	sp,sp,-48
    80007296:	f406                	sd	ra,40(sp)
    80007298:	f022                	sd	s0,32(sp)
    8000729a:	ec26                	sd	s1,24(sp)
    8000729c:	e84a                	sd	s2,16(sp)
    8000729e:	e44e                	sd	s3,8(sp)
    800072a0:	1800                	addi	s0,sp,48
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800072a2:	6104                	ld	s1,0(a0)
    800072a4:	02950063          	beq	a0,s1,800072c4 <lst_print+0x30>
    800072a8:	892a                	mv	s2,a0
    printf(" %p", p);
    800072aa:	00002997          	auipc	s3,0x2
    800072ae:	80e98993          	addi	s3,s3,-2034 # 80008ab8 <userret+0xa28>
    800072b2:	85a6                	mv	a1,s1
    800072b4:	854e                	mv	a0,s3
    800072b6:	ffff9097          	auipc	ra,0xffff9
    800072ba:	2ec080e7          	jalr	748(ra) # 800005a2 <printf>
  for (struct list *p = lst->next; p != lst; p = p->next) {
    800072be:	6084                	ld	s1,0(s1)
    800072c0:	fe9919e3          	bne	s2,s1,800072b2 <lst_print+0x1e>
  }
  printf("\n");
    800072c4:	00001517          	auipc	a0,0x1
    800072c8:	fcc50513          	addi	a0,a0,-52 # 80008290 <userret+0x200>
    800072cc:	ffff9097          	auipc	ra,0xffff9
    800072d0:	2d6080e7          	jalr	726(ra) # 800005a2 <printf>
}
    800072d4:	70a2                	ld	ra,40(sp)
    800072d6:	7402                	ld	s0,32(sp)
    800072d8:	64e2                	ld	s1,24(sp)
    800072da:	6942                	ld	s2,16(sp)
    800072dc:	69a2                	ld	s3,8(sp)
    800072de:	6145                	addi	sp,sp,48
    800072e0:	8082                	ret
	...

0000000080008000 <trampoline>:
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
