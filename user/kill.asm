
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
   c:	4785                	li	a5,1
   e:	02a7dd63          	bge	a5,a0,48 <main+0x48>
  12:	00858493          	addi	s1,a1,8
  16:	ffe5091b          	addiw	s2,a0,-2
  1a:	02091793          	slli	a5,s2,0x20
  1e:	01d7d913          	srli	s2,a5,0x1d
  22:	05c1                	addi	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1ae080e7          	jalr	430(ra) # 1d6 <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	252080e7          	jalr	594(ra) # 282 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	addi	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	212080e7          	jalr	530(ra) # 252 <exit>
    fprintf(2, "usage: kill pid...\n");
  48:	00000597          	auipc	a1,0x0
  4c:	74858593          	addi	a1,a1,1864 # 790 <malloc+0xe8>
  50:	4509                	li	a0,2
  52:	00000097          	auipc	ra,0x0
  56:	56a080e7          	jalr	1386(ra) # 5bc <fprintf>
    exit(1);
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	1f6080e7          	jalr	502(ra) # 252 <exit>

0000000000000064 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6a:	87aa                	mv	a5,a0
  6c:	0585                	addi	a1,a1,1
  6e:	0785                	addi	a5,a5,1
  70:	fff5c703          	lbu	a4,-1(a1)
  74:	fee78fa3          	sb	a4,-1(a5)
  78:	fb75                	bnez	a4,6c <strcpy+0x8>
    ;
  return os;
}
  7a:	6422                	ld	s0,8(sp)
  7c:	0141                	addi	sp,sp,16
  7e:	8082                	ret

0000000000000080 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80:	1141                	addi	sp,sp,-16
  82:	e422                	sd	s0,8(sp)
  84:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	cb91                	beqz	a5,9e <strcmp+0x1e>
  8c:	0005c703          	lbu	a4,0(a1)
  90:	00f71763          	bne	a4,a5,9e <strcmp+0x1e>
    p++, q++;
  94:	0505                	addi	a0,a0,1
  96:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  98:	00054783          	lbu	a5,0(a0)
  9c:	fbe5                	bnez	a5,8c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9e:	0005c503          	lbu	a0,0(a1)
}
  a2:	40a7853b          	subw	a0,a5,a0
  a6:	6422                	ld	s0,8(sp)
  a8:	0141                	addi	sp,sp,16
  aa:	8082                	ret

00000000000000ac <strlen>:

uint
strlen(const char *s)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b2:	00054783          	lbu	a5,0(a0)
  b6:	cf91                	beqz	a5,d2 <strlen+0x26>
  b8:	0505                	addi	a0,a0,1
  ba:	87aa                	mv	a5,a0
  bc:	4685                	li	a3,1
  be:	9e89                	subw	a3,a3,a0
  c0:	00f6853b          	addw	a0,a3,a5
  c4:	0785                	addi	a5,a5,1
  c6:	fff7c703          	lbu	a4,-1(a5)
  ca:	fb7d                	bnez	a4,c0 <strlen+0x14>
    ;
  return n;
}
  cc:	6422                	ld	s0,8(sp)
  ce:	0141                	addi	sp,sp,16
  d0:	8082                	ret
  for(n = 0; s[n]; n++)
  d2:	4501                	li	a0,0
  d4:	bfe5                	j	cc <strlen+0x20>

00000000000000d6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  dc:	ca19                	beqz	a2,f2 <memset+0x1c>
  de:	87aa                	mv	a5,a0
  e0:	1602                	slli	a2,a2,0x20
  e2:	9201                	srli	a2,a2,0x20
  e4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ec:	0785                	addi	a5,a5,1
  ee:	fee79de3          	bne	a5,a4,e8 <memset+0x12>
  }
  return dst;
}
  f2:	6422                	ld	s0,8(sp)
  f4:	0141                	addi	sp,sp,16
  f6:	8082                	ret

00000000000000f8 <strchr>:

char*
strchr(const char *s, char c)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  fe:	00054783          	lbu	a5,0(a0)
 102:	cb99                	beqz	a5,118 <strchr+0x20>
    if(*s == c)
 104:	00f58763          	beq	a1,a5,112 <strchr+0x1a>
  for(; *s; s++)
 108:	0505                	addi	a0,a0,1
 10a:	00054783          	lbu	a5,0(a0)
 10e:	fbfd                	bnez	a5,104 <strchr+0xc>
      return (char*)s;
  return 0;
 110:	4501                	li	a0,0
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret
  return 0;
 118:	4501                	li	a0,0
 11a:	bfe5                	j	112 <strchr+0x1a>

000000000000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	711d                	addi	sp,sp,-96
 11e:	ec86                	sd	ra,88(sp)
 120:	e8a2                	sd	s0,80(sp)
 122:	e4a6                	sd	s1,72(sp)
 124:	e0ca                	sd	s2,64(sp)
 126:	fc4e                	sd	s3,56(sp)
 128:	f852                	sd	s4,48(sp)
 12a:	f456                	sd	s5,40(sp)
 12c:	f05a                	sd	s6,32(sp)
 12e:	ec5e                	sd	s7,24(sp)
 130:	1080                	addi	s0,sp,96
 132:	8baa                	mv	s7,a0
 134:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 136:	892a                	mv	s2,a0
 138:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13a:	4aa9                	li	s5,10
 13c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13e:	89a6                	mv	s3,s1
 140:	2485                	addiw	s1,s1,1
 142:	0344d863          	bge	s1,s4,172 <gets+0x56>
    cc = read(0, &c, 1);
 146:	4605                	li	a2,1
 148:	faf40593          	addi	a1,s0,-81
 14c:	4501                	li	a0,0
 14e:	00000097          	auipc	ra,0x0
 152:	11c080e7          	jalr	284(ra) # 26a <read>
    if(cc < 1)
 156:	00a05e63          	blez	a0,172 <gets+0x56>
    buf[i++] = c;
 15a:	faf44783          	lbu	a5,-81(s0)
 15e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 162:	01578763          	beq	a5,s5,170 <gets+0x54>
 166:	0905                	addi	s2,s2,1
 168:	fd679be3          	bne	a5,s6,13e <gets+0x22>
  for(i=0; i+1 < max; ){
 16c:	89a6                	mv	s3,s1
 16e:	a011                	j	172 <gets+0x56>
 170:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 172:	99de                	add	s3,s3,s7
 174:	00098023          	sb	zero,0(s3)
  return buf;
}
 178:	855e                	mv	a0,s7
 17a:	60e6                	ld	ra,88(sp)
 17c:	6446                	ld	s0,80(sp)
 17e:	64a6                	ld	s1,72(sp)
 180:	6906                	ld	s2,64(sp)
 182:	79e2                	ld	s3,56(sp)
 184:	7a42                	ld	s4,48(sp)
 186:	7aa2                	ld	s5,40(sp)
 188:	7b02                	ld	s6,32(sp)
 18a:	6be2                	ld	s7,24(sp)
 18c:	6125                	addi	sp,sp,96
 18e:	8082                	ret

0000000000000190 <stat>:

int
stat(const char *n, struct stat *st)
{
 190:	1101                	addi	sp,sp,-32
 192:	ec06                	sd	ra,24(sp)
 194:	e822                	sd	s0,16(sp)
 196:	e426                	sd	s1,8(sp)
 198:	e04a                	sd	s2,0(sp)
 19a:	1000                	addi	s0,sp,32
 19c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19e:	4581                	li	a1,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	0f2080e7          	jalr	242(ra) # 292 <open>
  if(fd < 0)
 1a8:	02054563          	bltz	a0,1d2 <stat+0x42>
 1ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ae:	85ca                	mv	a1,s2
 1b0:	00000097          	auipc	ra,0x0
 1b4:	0fa080e7          	jalr	250(ra) # 2aa <fstat>
 1b8:	892a                	mv	s2,a0
  close(fd);
 1ba:	8526                	mv	a0,s1
 1bc:	00000097          	auipc	ra,0x0
 1c0:	0be080e7          	jalr	190(ra) # 27a <close>
  return r;
}
 1c4:	854a                	mv	a0,s2
 1c6:	60e2                	ld	ra,24(sp)
 1c8:	6442                	ld	s0,16(sp)
 1ca:	64a2                	ld	s1,8(sp)
 1cc:	6902                	ld	s2,0(sp)
 1ce:	6105                	addi	sp,sp,32
 1d0:	8082                	ret
    return -1;
 1d2:	597d                	li	s2,-1
 1d4:	bfc5                	j	1c4 <stat+0x34>

00000000000001d6 <atoi>:

int
atoi(const char *s)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1dc:	00054603          	lbu	a2,0(a0)
 1e0:	fd06079b          	addiw	a5,a2,-48
 1e4:	0ff7f793          	andi	a5,a5,255
 1e8:	4725                	li	a4,9
 1ea:	02f76963          	bltu	a4,a5,21c <atoi+0x46>
 1ee:	86aa                	mv	a3,a0
  n = 0;
 1f0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1f2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1f4:	0685                	addi	a3,a3,1
 1f6:	0025179b          	slliw	a5,a0,0x2
 1fa:	9fa9                	addw	a5,a5,a0
 1fc:	0017979b          	slliw	a5,a5,0x1
 200:	9fb1                	addw	a5,a5,a2
 202:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 206:	0006c603          	lbu	a2,0(a3)
 20a:	fd06071b          	addiw	a4,a2,-48
 20e:	0ff77713          	andi	a4,a4,255
 212:	fee5f1e3          	bgeu	a1,a4,1f4 <atoi+0x1e>
  return n;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
  n = 0;
 21c:	4501                	li	a0,0
 21e:	bfe5                	j	216 <atoi+0x40>

0000000000000220 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 226:	00c05f63          	blez	a2,244 <memmove+0x24>
 22a:	1602                	slli	a2,a2,0x20
 22c:	9201                	srli	a2,a2,0x20
 22e:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 232:	87aa                	mv	a5,a0
    *dst++ = *src++;
 234:	0585                	addi	a1,a1,1
 236:	0785                	addi	a5,a5,1
 238:	fff5c703          	lbu	a4,-1(a1)
 23c:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 240:	fed79ae3          	bne	a5,a3,234 <memmove+0x14>
  return vdst;
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret

000000000000024a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 24a:	4885                	li	a7,1
 ecall
 24c:	00000073          	ecall
 ret
 250:	8082                	ret

0000000000000252 <exit>:
.global exit
exit:
 li a7, SYS_exit
 252:	4889                	li	a7,2
 ecall
 254:	00000073          	ecall
 ret
 258:	8082                	ret

000000000000025a <wait>:
.global wait
wait:
 li a7, SYS_wait
 25a:	488d                	li	a7,3
 ecall
 25c:	00000073          	ecall
 ret
 260:	8082                	ret

0000000000000262 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 262:	4891                	li	a7,4
 ecall
 264:	00000073          	ecall
 ret
 268:	8082                	ret

000000000000026a <read>:
.global read
read:
 li a7, SYS_read
 26a:	4895                	li	a7,5
 ecall
 26c:	00000073          	ecall
 ret
 270:	8082                	ret

0000000000000272 <write>:
.global write
write:
 li a7, SYS_write
 272:	48c1                	li	a7,16
 ecall
 274:	00000073          	ecall
 ret
 278:	8082                	ret

000000000000027a <close>:
.global close
close:
 li a7, SYS_close
 27a:	48d5                	li	a7,21
 ecall
 27c:	00000073          	ecall
 ret
 280:	8082                	ret

0000000000000282 <kill>:
.global kill
kill:
 li a7, SYS_kill
 282:	4899                	li	a7,6
 ecall
 284:	00000073          	ecall
 ret
 288:	8082                	ret

000000000000028a <exec>:
.global exec
exec:
 li a7, SYS_exec
 28a:	489d                	li	a7,7
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <open>:
.global open
open:
 li a7, SYS_open
 292:	48bd                	li	a7,15
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 29a:	48c5                	li	a7,17
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2a2:	48c9                	li	a7,18
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2aa:	48a1                	li	a7,8
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <link>:
.global link
link:
 li a7, SYS_link
 2b2:	48cd                	li	a7,19
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2ba:	48d1                	li	a7,20
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2c2:	48a5                	li	a7,9
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <dup>:
.global dup
dup:
 li a7, SYS_dup
 2ca:	48a9                	li	a7,10
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 2d2:	48ad                	li	a7,11
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 2da:	48b1                	li	a7,12
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 2e2:	48b5                	li	a7,13
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 2ea:	48b9                	li	a7,14
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 2f2:	48d9                	li	a7,22
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <crash>:
.global crash
crash:
 li a7, SYS_crash
 2fa:	48dd                	li	a7,23
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <mount>:
.global mount
mount:
 li a7, SYS_mount
 302:	48e1                	li	a7,24
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <umount>:
.global umount
umount:
 li a7, SYS_umount
 30a:	48e5                	li	a7,25
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 312:	1101                	addi	sp,sp,-32
 314:	ec06                	sd	ra,24(sp)
 316:	e822                	sd	s0,16(sp)
 318:	1000                	addi	s0,sp,32
 31a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 31e:	4605                	li	a2,1
 320:	fef40593          	addi	a1,s0,-17
 324:	00000097          	auipc	ra,0x0
 328:	f4e080e7          	jalr	-178(ra) # 272 <write>
}
 32c:	60e2                	ld	ra,24(sp)
 32e:	6442                	ld	s0,16(sp)
 330:	6105                	addi	sp,sp,32
 332:	8082                	ret

0000000000000334 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 334:	7139                	addi	sp,sp,-64
 336:	fc06                	sd	ra,56(sp)
 338:	f822                	sd	s0,48(sp)
 33a:	f426                	sd	s1,40(sp)
 33c:	f04a                	sd	s2,32(sp)
 33e:	ec4e                	sd	s3,24(sp)
 340:	0080                	addi	s0,sp,64
 342:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 344:	c299                	beqz	a3,34a <printint+0x16>
 346:	0805c863          	bltz	a1,3d6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 34a:	2581                	sext.w	a1,a1
  neg = 0;
 34c:	4881                	li	a7,0
 34e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 352:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 354:	2601                	sext.w	a2,a2
 356:	00000517          	auipc	a0,0x0
 35a:	45a50513          	addi	a0,a0,1114 # 7b0 <digits>
 35e:	883a                	mv	a6,a4
 360:	2705                	addiw	a4,a4,1
 362:	02c5f7bb          	remuw	a5,a1,a2
 366:	1782                	slli	a5,a5,0x20
 368:	9381                	srli	a5,a5,0x20
 36a:	97aa                	add	a5,a5,a0
 36c:	0007c783          	lbu	a5,0(a5)
 370:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 374:	0005879b          	sext.w	a5,a1
 378:	02c5d5bb          	divuw	a1,a1,a2
 37c:	0685                	addi	a3,a3,1
 37e:	fec7f0e3          	bgeu	a5,a2,35e <printint+0x2a>
  if(neg)
 382:	00088b63          	beqz	a7,398 <printint+0x64>
    buf[i++] = '-';
 386:	fd040793          	addi	a5,s0,-48
 38a:	973e                	add	a4,a4,a5
 38c:	02d00793          	li	a5,45
 390:	fef70823          	sb	a5,-16(a4)
 394:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 398:	02e05863          	blez	a4,3c8 <printint+0x94>
 39c:	fc040793          	addi	a5,s0,-64
 3a0:	00e78933          	add	s2,a5,a4
 3a4:	fff78993          	addi	s3,a5,-1
 3a8:	99ba                	add	s3,s3,a4
 3aa:	377d                	addiw	a4,a4,-1
 3ac:	1702                	slli	a4,a4,0x20
 3ae:	9301                	srli	a4,a4,0x20
 3b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3b4:	fff94583          	lbu	a1,-1(s2)
 3b8:	8526                	mv	a0,s1
 3ba:	00000097          	auipc	ra,0x0
 3be:	f58080e7          	jalr	-168(ra) # 312 <putc>
  while(--i >= 0)
 3c2:	197d                	addi	s2,s2,-1
 3c4:	ff3918e3          	bne	s2,s3,3b4 <printint+0x80>
}
 3c8:	70e2                	ld	ra,56(sp)
 3ca:	7442                	ld	s0,48(sp)
 3cc:	74a2                	ld	s1,40(sp)
 3ce:	7902                	ld	s2,32(sp)
 3d0:	69e2                	ld	s3,24(sp)
 3d2:	6121                	addi	sp,sp,64
 3d4:	8082                	ret
    x = -xx;
 3d6:	40b005bb          	negw	a1,a1
    neg = 1;
 3da:	4885                	li	a7,1
    x = -xx;
 3dc:	bf8d                	j	34e <printint+0x1a>

00000000000003de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 3de:	7119                	addi	sp,sp,-128
 3e0:	fc86                	sd	ra,120(sp)
 3e2:	f8a2                	sd	s0,112(sp)
 3e4:	f4a6                	sd	s1,104(sp)
 3e6:	f0ca                	sd	s2,96(sp)
 3e8:	ecce                	sd	s3,88(sp)
 3ea:	e8d2                	sd	s4,80(sp)
 3ec:	e4d6                	sd	s5,72(sp)
 3ee:	e0da                	sd	s6,64(sp)
 3f0:	fc5e                	sd	s7,56(sp)
 3f2:	f862                	sd	s8,48(sp)
 3f4:	f466                	sd	s9,40(sp)
 3f6:	f06a                	sd	s10,32(sp)
 3f8:	ec6e                	sd	s11,24(sp)
 3fa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 3fc:	0005c903          	lbu	s2,0(a1)
 400:	18090f63          	beqz	s2,59e <vprintf+0x1c0>
 404:	8aaa                	mv	s5,a0
 406:	8b32                	mv	s6,a2
 408:	00158493          	addi	s1,a1,1
  state = 0;
 40c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 40e:	02500a13          	li	s4,37
      if(c == 'd'){
 412:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 416:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 41a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 41e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 422:	00000b97          	auipc	s7,0x0
 426:	38eb8b93          	addi	s7,s7,910 # 7b0 <digits>
 42a:	a839                	j	448 <vprintf+0x6a>
        putc(fd, c);
 42c:	85ca                	mv	a1,s2
 42e:	8556                	mv	a0,s5
 430:	00000097          	auipc	ra,0x0
 434:	ee2080e7          	jalr	-286(ra) # 312 <putc>
 438:	a019                	j	43e <vprintf+0x60>
    } else if(state == '%'){
 43a:	01498f63          	beq	s3,s4,458 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 43e:	0485                	addi	s1,s1,1
 440:	fff4c903          	lbu	s2,-1(s1)
 444:	14090d63          	beqz	s2,59e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 448:	0009079b          	sext.w	a5,s2
    if(state == 0){
 44c:	fe0997e3          	bnez	s3,43a <vprintf+0x5c>
      if(c == '%'){
 450:	fd479ee3          	bne	a5,s4,42c <vprintf+0x4e>
        state = '%';
 454:	89be                	mv	s3,a5
 456:	b7e5                	j	43e <vprintf+0x60>
      if(c == 'd'){
 458:	05878063          	beq	a5,s8,498 <vprintf+0xba>
      } else if(c == 'l') {
 45c:	05978c63          	beq	a5,s9,4b4 <vprintf+0xd6>
      } else if(c == 'x') {
 460:	07a78863          	beq	a5,s10,4d0 <vprintf+0xf2>
      } else if(c == 'p') {
 464:	09b78463          	beq	a5,s11,4ec <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 468:	07300713          	li	a4,115
 46c:	0ce78663          	beq	a5,a4,538 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 470:	06300713          	li	a4,99
 474:	0ee78e63          	beq	a5,a4,570 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 478:	11478863          	beq	a5,s4,588 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 47c:	85d2                	mv	a1,s4
 47e:	8556                	mv	a0,s5
 480:	00000097          	auipc	ra,0x0
 484:	e92080e7          	jalr	-366(ra) # 312 <putc>
        putc(fd, c);
 488:	85ca                	mv	a1,s2
 48a:	8556                	mv	a0,s5
 48c:	00000097          	auipc	ra,0x0
 490:	e86080e7          	jalr	-378(ra) # 312 <putc>
      }
      state = 0;
 494:	4981                	li	s3,0
 496:	b765                	j	43e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 498:	008b0913          	addi	s2,s6,8
 49c:	4685                	li	a3,1
 49e:	4629                	li	a2,10
 4a0:	000b2583          	lw	a1,0(s6)
 4a4:	8556                	mv	a0,s5
 4a6:	00000097          	auipc	ra,0x0
 4aa:	e8e080e7          	jalr	-370(ra) # 334 <printint>
 4ae:	8b4a                	mv	s6,s2
      state = 0;
 4b0:	4981                	li	s3,0
 4b2:	b771                	j	43e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4b4:	008b0913          	addi	s2,s6,8
 4b8:	4681                	li	a3,0
 4ba:	4629                	li	a2,10
 4bc:	000b2583          	lw	a1,0(s6)
 4c0:	8556                	mv	a0,s5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	e72080e7          	jalr	-398(ra) # 334 <printint>
 4ca:	8b4a                	mv	s6,s2
      state = 0;
 4cc:	4981                	li	s3,0
 4ce:	bf85                	j	43e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4d0:	008b0913          	addi	s2,s6,8
 4d4:	4681                	li	a3,0
 4d6:	4641                	li	a2,16
 4d8:	000b2583          	lw	a1,0(s6)
 4dc:	8556                	mv	a0,s5
 4de:	00000097          	auipc	ra,0x0
 4e2:	e56080e7          	jalr	-426(ra) # 334 <printint>
 4e6:	8b4a                	mv	s6,s2
      state = 0;
 4e8:	4981                	li	s3,0
 4ea:	bf91                	j	43e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 4ec:	008b0793          	addi	a5,s6,8
 4f0:	f8f43423          	sd	a5,-120(s0)
 4f4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 4f8:	03000593          	li	a1,48
 4fc:	8556                	mv	a0,s5
 4fe:	00000097          	auipc	ra,0x0
 502:	e14080e7          	jalr	-492(ra) # 312 <putc>
  putc(fd, 'x');
 506:	85ea                	mv	a1,s10
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	e08080e7          	jalr	-504(ra) # 312 <putc>
 512:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 514:	03c9d793          	srli	a5,s3,0x3c
 518:	97de                	add	a5,a5,s7
 51a:	0007c583          	lbu	a1,0(a5)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	df2080e7          	jalr	-526(ra) # 312 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 528:	0992                	slli	s3,s3,0x4
 52a:	397d                	addiw	s2,s2,-1
 52c:	fe0914e3          	bnez	s2,514 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 530:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 534:	4981                	li	s3,0
 536:	b721                	j	43e <vprintf+0x60>
        s = va_arg(ap, char*);
 538:	008b0993          	addi	s3,s6,8
 53c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 540:	02090163          	beqz	s2,562 <vprintf+0x184>
        while(*s != 0){
 544:	00094583          	lbu	a1,0(s2)
 548:	c9a1                	beqz	a1,598 <vprintf+0x1ba>
          putc(fd, *s);
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	dc6080e7          	jalr	-570(ra) # 312 <putc>
          s++;
 554:	0905                	addi	s2,s2,1
        while(*s != 0){
 556:	00094583          	lbu	a1,0(s2)
 55a:	f9e5                	bnez	a1,54a <vprintf+0x16c>
        s = va_arg(ap, char*);
 55c:	8b4e                	mv	s6,s3
      state = 0;
 55e:	4981                	li	s3,0
 560:	bdf9                	j	43e <vprintf+0x60>
          s = "(null)";
 562:	00000917          	auipc	s2,0x0
 566:	24690913          	addi	s2,s2,582 # 7a8 <malloc+0x100>
        while(*s != 0){
 56a:	02800593          	li	a1,40
 56e:	bff1                	j	54a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 570:	008b0913          	addi	s2,s6,8
 574:	000b4583          	lbu	a1,0(s6)
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	d98080e7          	jalr	-616(ra) # 312 <putc>
 582:	8b4a                	mv	s6,s2
      state = 0;
 584:	4981                	li	s3,0
 586:	bd65                	j	43e <vprintf+0x60>
        putc(fd, c);
 588:	85d2                	mv	a1,s4
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	d86080e7          	jalr	-634(ra) # 312 <putc>
      state = 0;
 594:	4981                	li	s3,0
 596:	b565                	j	43e <vprintf+0x60>
        s = va_arg(ap, char*);
 598:	8b4e                	mv	s6,s3
      state = 0;
 59a:	4981                	li	s3,0
 59c:	b54d                	j	43e <vprintf+0x60>
    }
  }
}
 59e:	70e6                	ld	ra,120(sp)
 5a0:	7446                	ld	s0,112(sp)
 5a2:	74a6                	ld	s1,104(sp)
 5a4:	7906                	ld	s2,96(sp)
 5a6:	69e6                	ld	s3,88(sp)
 5a8:	6a46                	ld	s4,80(sp)
 5aa:	6aa6                	ld	s5,72(sp)
 5ac:	6b06                	ld	s6,64(sp)
 5ae:	7be2                	ld	s7,56(sp)
 5b0:	7c42                	ld	s8,48(sp)
 5b2:	7ca2                	ld	s9,40(sp)
 5b4:	7d02                	ld	s10,32(sp)
 5b6:	6de2                	ld	s11,24(sp)
 5b8:	6109                	addi	sp,sp,128
 5ba:	8082                	ret

00000000000005bc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5bc:	715d                	addi	sp,sp,-80
 5be:	ec06                	sd	ra,24(sp)
 5c0:	e822                	sd	s0,16(sp)
 5c2:	1000                	addi	s0,sp,32
 5c4:	e010                	sd	a2,0(s0)
 5c6:	e414                	sd	a3,8(s0)
 5c8:	e818                	sd	a4,16(s0)
 5ca:	ec1c                	sd	a5,24(s0)
 5cc:	03043023          	sd	a6,32(s0)
 5d0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 5d4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 5d8:	8622                	mv	a2,s0
 5da:	00000097          	auipc	ra,0x0
 5de:	e04080e7          	jalr	-508(ra) # 3de <vprintf>
}
 5e2:	60e2                	ld	ra,24(sp)
 5e4:	6442                	ld	s0,16(sp)
 5e6:	6161                	addi	sp,sp,80
 5e8:	8082                	ret

00000000000005ea <printf>:

void
printf(const char *fmt, ...)
{
 5ea:	711d                	addi	sp,sp,-96
 5ec:	ec06                	sd	ra,24(sp)
 5ee:	e822                	sd	s0,16(sp)
 5f0:	1000                	addi	s0,sp,32
 5f2:	e40c                	sd	a1,8(s0)
 5f4:	e810                	sd	a2,16(s0)
 5f6:	ec14                	sd	a3,24(s0)
 5f8:	f018                	sd	a4,32(s0)
 5fa:	f41c                	sd	a5,40(s0)
 5fc:	03043823          	sd	a6,48(s0)
 600:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 604:	00840613          	addi	a2,s0,8
 608:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 60c:	85aa                	mv	a1,a0
 60e:	4505                	li	a0,1
 610:	00000097          	auipc	ra,0x0
 614:	dce080e7          	jalr	-562(ra) # 3de <vprintf>
}
 618:	60e2                	ld	ra,24(sp)
 61a:	6442                	ld	s0,16(sp)
 61c:	6125                	addi	sp,sp,96
 61e:	8082                	ret

0000000000000620 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 620:	1141                	addi	sp,sp,-16
 622:	e422                	sd	s0,8(sp)
 624:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 626:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62a:	00000797          	auipc	a5,0x0
 62e:	19e7b783          	ld	a5,414(a5) # 7c8 <freep>
 632:	a805                	j	662 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 634:	4618                	lw	a4,8(a2)
 636:	9db9                	addw	a1,a1,a4
 638:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 63c:	6398                	ld	a4,0(a5)
 63e:	6318                	ld	a4,0(a4)
 640:	fee53823          	sd	a4,-16(a0)
 644:	a091                	j	688 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 646:	ff852703          	lw	a4,-8(a0)
 64a:	9e39                	addw	a2,a2,a4
 64c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 64e:	ff053703          	ld	a4,-16(a0)
 652:	e398                	sd	a4,0(a5)
 654:	a099                	j	69a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 656:	6398                	ld	a4,0(a5)
 658:	00e7e463          	bltu	a5,a4,660 <free+0x40>
 65c:	00e6ea63          	bltu	a3,a4,670 <free+0x50>
{
 660:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 662:	fed7fae3          	bgeu	a5,a3,656 <free+0x36>
 666:	6398                	ld	a4,0(a5)
 668:	00e6e463          	bltu	a3,a4,670 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 66c:	fee7eae3          	bltu	a5,a4,660 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 670:	ff852583          	lw	a1,-8(a0)
 674:	6390                	ld	a2,0(a5)
 676:	02059813          	slli	a6,a1,0x20
 67a:	01c85713          	srli	a4,a6,0x1c
 67e:	9736                	add	a4,a4,a3
 680:	fae60ae3          	beq	a2,a4,634 <free+0x14>
    bp->s.ptr = p->s.ptr;
 684:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 688:	4790                	lw	a2,8(a5)
 68a:	02061593          	slli	a1,a2,0x20
 68e:	01c5d713          	srli	a4,a1,0x1c
 692:	973e                	add	a4,a4,a5
 694:	fae689e3          	beq	a3,a4,646 <free+0x26>
  } else
    p->s.ptr = bp;
 698:	e394                	sd	a3,0(a5)
  freep = p;
 69a:	00000717          	auipc	a4,0x0
 69e:	12f73723          	sd	a5,302(a4) # 7c8 <freep>
}
 6a2:	6422                	ld	s0,8(sp)
 6a4:	0141                	addi	sp,sp,16
 6a6:	8082                	ret

00000000000006a8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6a8:	7139                	addi	sp,sp,-64
 6aa:	fc06                	sd	ra,56(sp)
 6ac:	f822                	sd	s0,48(sp)
 6ae:	f426                	sd	s1,40(sp)
 6b0:	f04a                	sd	s2,32(sp)
 6b2:	ec4e                	sd	s3,24(sp)
 6b4:	e852                	sd	s4,16(sp)
 6b6:	e456                	sd	s5,8(sp)
 6b8:	e05a                	sd	s6,0(sp)
 6ba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6bc:	02051493          	slli	s1,a0,0x20
 6c0:	9081                	srli	s1,s1,0x20
 6c2:	04bd                	addi	s1,s1,15
 6c4:	8091                	srli	s1,s1,0x4
 6c6:	0014899b          	addiw	s3,s1,1
 6ca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6cc:	00000517          	auipc	a0,0x0
 6d0:	0fc53503          	ld	a0,252(a0) # 7c8 <freep>
 6d4:	c515                	beqz	a0,700 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6d8:	4798                	lw	a4,8(a5)
 6da:	02977f63          	bgeu	a4,s1,718 <malloc+0x70>
 6de:	8a4e                	mv	s4,s3
 6e0:	0009871b          	sext.w	a4,s3
 6e4:	6685                	lui	a3,0x1
 6e6:	00d77363          	bgeu	a4,a3,6ec <malloc+0x44>
 6ea:	6a05                	lui	s4,0x1
 6ec:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 6f0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 6f4:	00000917          	auipc	s2,0x0
 6f8:	0d490913          	addi	s2,s2,212 # 7c8 <freep>
  if(p == (char*)-1)
 6fc:	5afd                	li	s5,-1
 6fe:	a895                	j	772 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 700:	00000797          	auipc	a5,0x0
 704:	0d078793          	addi	a5,a5,208 # 7d0 <base>
 708:	00000717          	auipc	a4,0x0
 70c:	0cf73023          	sd	a5,192(a4) # 7c8 <freep>
 710:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 712:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 716:	b7e1                	j	6de <malloc+0x36>
      if(p->s.size == nunits)
 718:	02e48c63          	beq	s1,a4,750 <malloc+0xa8>
        p->s.size -= nunits;
 71c:	4137073b          	subw	a4,a4,s3
 720:	c798                	sw	a4,8(a5)
        p += p->s.size;
 722:	02071693          	slli	a3,a4,0x20
 726:	01c6d713          	srli	a4,a3,0x1c
 72a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 72c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 730:	00000717          	auipc	a4,0x0
 734:	08a73c23          	sd	a0,152(a4) # 7c8 <freep>
      return (void*)(p + 1);
 738:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 73c:	70e2                	ld	ra,56(sp)
 73e:	7442                	ld	s0,48(sp)
 740:	74a2                	ld	s1,40(sp)
 742:	7902                	ld	s2,32(sp)
 744:	69e2                	ld	s3,24(sp)
 746:	6a42                	ld	s4,16(sp)
 748:	6aa2                	ld	s5,8(sp)
 74a:	6b02                	ld	s6,0(sp)
 74c:	6121                	addi	sp,sp,64
 74e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 750:	6398                	ld	a4,0(a5)
 752:	e118                	sd	a4,0(a0)
 754:	bff1                	j	730 <malloc+0x88>
  hp->s.size = nu;
 756:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 75a:	0541                	addi	a0,a0,16
 75c:	00000097          	auipc	ra,0x0
 760:	ec4080e7          	jalr	-316(ra) # 620 <free>
  return freep;
 764:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 768:	d971                	beqz	a0,73c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76c:	4798                	lw	a4,8(a5)
 76e:	fa9775e3          	bgeu	a4,s1,718 <malloc+0x70>
    if(p == freep)
 772:	00093703          	ld	a4,0(s2)
 776:	853e                	mv	a0,a5
 778:	fef719e3          	bne	a4,a5,76a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 77c:	8552                	mv	a0,s4
 77e:	00000097          	auipc	ra,0x0
 782:	b5c080e7          	jalr	-1188(ra) # 2da <sbrk>
  if(p == (char*)-1)
 786:	fd5518e3          	bne	a0,s5,756 <malloc+0xae>
        return 0;
 78a:	4501                	li	a0,0
 78c:	bf45                	j	73c <malloc+0x94>
