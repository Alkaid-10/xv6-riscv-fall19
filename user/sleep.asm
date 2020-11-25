
user/_sleep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <usage>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void usage(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Usage: sleep <NUM> \n");
   8:	00000517          	auipc	a0,0x0
   c:	7b850513          	addi	a0,a0,1976 # 7c0 <malloc+0xea>
  10:	00000097          	auipc	ra,0x0
  14:	608080e7          	jalr	1544(ra) # 618 <printf>
    printf("NUM must be non-negative\n");
  18:	00000517          	auipc	a0,0x0
  1c:	7c050513          	addi	a0,a0,1984 # 7d8 <malloc+0x102>
  20:	00000097          	auipc	ra,0x0
  24:	5f8080e7          	jalr	1528(ra) # 618 <printf>
    exit();
  28:	00000097          	auipc	ra,0x0
  2c:	258080e7          	jalr	600(ra) # 280 <exit>

0000000000000030 <main>:
}
 
 
int main(int argc,char* argv[]){
  30:	1101                	addi	sp,sp,-32
  32:	ec06                	sd	ra,24(sp)
  34:	e822                	sd	s0,16(sp)
  36:	e426                	sd	s1,8(sp)
  38:	1000                	addi	s0,sp,32
    if(argc<2){
  3a:	4785                	li	a5,1
  3c:	02a7d063          	bge	a5,a0,5c <main+0x2c>
        usage();
    }
    //检测输入合法性
    char c=argv[1][0];
  40:	6588                	ld	a0,8(a1)
    if(c<'0'||c>'9'){
  42:	00054783          	lbu	a5,0(a0)
  46:	fd07879b          	addiw	a5,a5,-48
  4a:	0ff7f793          	andi	a5,a5,255
  4e:	4725                	li	a4,9
  50:	00f77a63          	bgeu	a4,a5,64 <main+0x34>
        usage();
  54:	00000097          	auipc	ra,0x0
  58:	fac080e7          	jalr	-84(ra) # 0 <usage>
        usage();
  5c:	00000097          	auipc	ra,0x0
  60:	fa4080e7          	jalr	-92(ra) # 0 <usage>
    }
    //转换为int
    int num=atoi(argv[1]);
  64:	00000097          	auipc	ra,0x0
  68:	1a0080e7          	jalr	416(ra) # 204 <atoi>
  6c:	84aa                	mv	s1,a0
    printf("sleep %d ticks\n",num);
  6e:	85aa                	mv	a1,a0
  70:	00000517          	auipc	a0,0x0
  74:	78850513          	addi	a0,a0,1928 # 7f8 <malloc+0x122>
  78:	00000097          	auipc	ra,0x0
  7c:	5a0080e7          	jalr	1440(ra) # 618 <printf>
    sleep(num);
  80:	8526                	mv	a0,s1
  82:	00000097          	auipc	ra,0x0
  86:	28e080e7          	jalr	654(ra) # 310 <sleep>
    exit();
  8a:	00000097          	auipc	ra,0x0
  8e:	1f6080e7          	jalr	502(ra) # 280 <exit>

0000000000000092 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  98:	87aa                	mv	a5,a0
  9a:	0585                	addi	a1,a1,1
  9c:	0785                	addi	a5,a5,1
  9e:	fff5c703          	lbu	a4,-1(a1)
  a2:	fee78fa3          	sb	a4,-1(a5)
  a6:	fb75                	bnez	a4,9a <strcpy+0x8>
    ;
  return os;
}
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b4:	00054783          	lbu	a5,0(a0)
  b8:	cb91                	beqz	a5,cc <strcmp+0x1e>
  ba:	0005c703          	lbu	a4,0(a1)
  be:	00f71763          	bne	a4,a5,cc <strcmp+0x1e>
    p++, q++;
  c2:	0505                	addi	a0,a0,1
  c4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	fbe5                	bnez	a5,ba <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  cc:	0005c503          	lbu	a0,0(a1)
}
  d0:	40a7853b          	subw	a0,a5,a0
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strlen>:

uint
strlen(const char *s)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cf91                	beqz	a5,100 <strlen+0x26>
  e6:	0505                	addi	a0,a0,1
  e8:	87aa                	mv	a5,a0
  ea:	4685                	li	a3,1
  ec:	9e89                	subw	a3,a3,a0
  ee:	00f6853b          	addw	a0,a3,a5
  f2:	0785                	addi	a5,a5,1
  f4:	fff7c703          	lbu	a4,-1(a5)
  f8:	fb7d                	bnez	a4,ee <strlen+0x14>
    ;
  return n;
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret
  for(n = 0; s[n]; n++)
 100:	4501                	li	a0,0
 102:	bfe5                	j	fa <strlen+0x20>

0000000000000104 <memset>:

void*
memset(void *dst, int c, uint n)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 10a:	ca19                	beqz	a2,120 <memset+0x1c>
 10c:	87aa                	mv	a5,a0
 10e:	1602                	slli	a2,a2,0x20
 110:	9201                	srli	a2,a2,0x20
 112:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 116:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 11a:	0785                	addi	a5,a5,1
 11c:	fee79de3          	bne	a5,a4,116 <memset+0x12>
  }
  return dst;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strchr>:

char*
strchr(const char *s, char c)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cb99                	beqz	a5,146 <strchr+0x20>
    if(*s == c)
 132:	00f58763          	beq	a1,a5,140 <strchr+0x1a>
  for(; *s; s++)
 136:	0505                	addi	a0,a0,1
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbfd                	bnez	a5,132 <strchr+0xc>
      return (char*)s;
  return 0;
 13e:	4501                	li	a0,0
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret
  return 0;
 146:	4501                	li	a0,0
 148:	bfe5                	j	140 <strchr+0x1a>

000000000000014a <gets>:

char*
gets(char *buf, int max)
{
 14a:	711d                	addi	sp,sp,-96
 14c:	ec86                	sd	ra,88(sp)
 14e:	e8a2                	sd	s0,80(sp)
 150:	e4a6                	sd	s1,72(sp)
 152:	e0ca                	sd	s2,64(sp)
 154:	fc4e                	sd	s3,56(sp)
 156:	f852                	sd	s4,48(sp)
 158:	f456                	sd	s5,40(sp)
 15a:	f05a                	sd	s6,32(sp)
 15c:	ec5e                	sd	s7,24(sp)
 15e:	1080                	addi	s0,sp,96
 160:	8baa                	mv	s7,a0
 162:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 164:	892a                	mv	s2,a0
 166:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 168:	4aa9                	li	s5,10
 16a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 16c:	89a6                	mv	s3,s1
 16e:	2485                	addiw	s1,s1,1
 170:	0344d863          	bge	s1,s4,1a0 <gets+0x56>
    cc = read(0, &c, 1);
 174:	4605                	li	a2,1
 176:	faf40593          	addi	a1,s0,-81
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	11c080e7          	jalr	284(ra) # 298 <read>
    if(cc < 1)
 184:	00a05e63          	blez	a0,1a0 <gets+0x56>
    buf[i++] = c;
 188:	faf44783          	lbu	a5,-81(s0)
 18c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 190:	01578763          	beq	a5,s5,19e <gets+0x54>
 194:	0905                	addi	s2,s2,1
 196:	fd679be3          	bne	a5,s6,16c <gets+0x22>
  for(i=0; i+1 < max; ){
 19a:	89a6                	mv	s3,s1
 19c:	a011                	j	1a0 <gets+0x56>
 19e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a0:	99de                	add	s3,s3,s7
 1a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a6:	855e                	mv	a0,s7
 1a8:	60e6                	ld	ra,88(sp)
 1aa:	6446                	ld	s0,80(sp)
 1ac:	64a6                	ld	s1,72(sp)
 1ae:	6906                	ld	s2,64(sp)
 1b0:	79e2                	ld	s3,56(sp)
 1b2:	7a42                	ld	s4,48(sp)
 1b4:	7aa2                	ld	s5,40(sp)
 1b6:	7b02                	ld	s6,32(sp)
 1b8:	6be2                	ld	s7,24(sp)
 1ba:	6125                	addi	sp,sp,96
 1bc:	8082                	ret

00000000000001be <stat>:

int
stat(const char *n, struct stat *st)
{
 1be:	1101                	addi	sp,sp,-32
 1c0:	ec06                	sd	ra,24(sp)
 1c2:	e822                	sd	s0,16(sp)
 1c4:	e426                	sd	s1,8(sp)
 1c6:	e04a                	sd	s2,0(sp)
 1c8:	1000                	addi	s0,sp,32
 1ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cc:	4581                	li	a1,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	0f2080e7          	jalr	242(ra) # 2c0 <open>
  if(fd < 0)
 1d6:	02054563          	bltz	a0,200 <stat+0x42>
 1da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1dc:	85ca                	mv	a1,s2
 1de:	00000097          	auipc	ra,0x0
 1e2:	0fa080e7          	jalr	250(ra) # 2d8 <fstat>
 1e6:	892a                	mv	s2,a0
  close(fd);
 1e8:	8526                	mv	a0,s1
 1ea:	00000097          	auipc	ra,0x0
 1ee:	0be080e7          	jalr	190(ra) # 2a8 <close>
  return r;
}
 1f2:	854a                	mv	a0,s2
 1f4:	60e2                	ld	ra,24(sp)
 1f6:	6442                	ld	s0,16(sp)
 1f8:	64a2                	ld	s1,8(sp)
 1fa:	6902                	ld	s2,0(sp)
 1fc:	6105                	addi	sp,sp,32
 1fe:	8082                	ret
    return -1;
 200:	597d                	li	s2,-1
 202:	bfc5                	j	1f2 <stat+0x34>

0000000000000204 <atoi>:

int
atoi(const char *s)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 20a:	00054603          	lbu	a2,0(a0)
 20e:	fd06079b          	addiw	a5,a2,-48
 212:	0ff7f793          	andi	a5,a5,255
 216:	4725                	li	a4,9
 218:	02f76963          	bltu	a4,a5,24a <atoi+0x46>
 21c:	86aa                	mv	a3,a0
  n = 0;
 21e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 220:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 222:	0685                	addi	a3,a3,1
 224:	0025179b          	slliw	a5,a0,0x2
 228:	9fa9                	addw	a5,a5,a0
 22a:	0017979b          	slliw	a5,a5,0x1
 22e:	9fb1                	addw	a5,a5,a2
 230:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 234:	0006c603          	lbu	a2,0(a3)
 238:	fd06071b          	addiw	a4,a2,-48
 23c:	0ff77713          	andi	a4,a4,255
 240:	fee5f1e3          	bgeu	a1,a4,222 <atoi+0x1e>
  return n;
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
  n = 0;
 24a:	4501                	li	a0,0
 24c:	bfe5                	j	244 <atoi+0x40>

000000000000024e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 254:	00c05f63          	blez	a2,272 <memmove+0x24>
 258:	1602                	slli	a2,a2,0x20
 25a:	9201                	srli	a2,a2,0x20
 25c:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 260:	87aa                	mv	a5,a0
    *dst++ = *src++;
 262:	0585                	addi	a1,a1,1
 264:	0785                	addi	a5,a5,1
 266:	fff5c703          	lbu	a4,-1(a1)
 26a:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 26e:	fed79ae3          	bne	a5,a3,262 <memmove+0x14>
  return vdst;
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret

0000000000000278 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 278:	4885                	li	a7,1
 ecall
 27a:	00000073          	ecall
 ret
 27e:	8082                	ret

0000000000000280 <exit>:
.global exit
exit:
 li a7, SYS_exit
 280:	4889                	li	a7,2
 ecall
 282:	00000073          	ecall
 ret
 286:	8082                	ret

0000000000000288 <wait>:
.global wait
wait:
 li a7, SYS_wait
 288:	488d                	li	a7,3
 ecall
 28a:	00000073          	ecall
 ret
 28e:	8082                	ret

0000000000000290 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 290:	4891                	li	a7,4
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <read>:
.global read
read:
 li a7, SYS_read
 298:	4895                	li	a7,5
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <write>:
.global write
write:
 li a7, SYS_write
 2a0:	48c1                	li	a7,16
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <close>:
.global close
close:
 li a7, SYS_close
 2a8:	48d5                	li	a7,21
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2b0:	4899                	li	a7,6
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2b8:	489d                	li	a7,7
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <open>:
.global open
open:
 li a7, SYS_open
 2c0:	48bd                	li	a7,15
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2c8:	48c5                	li	a7,17
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2d0:	48c9                	li	a7,18
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2d8:	48a1                	li	a7,8
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <link>:
.global link
link:
 li a7, SYS_link
 2e0:	48cd                	li	a7,19
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2e8:	48d1                	li	a7,20
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 2f0:	48a5                	li	a7,9
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 2f8:	48a9                	li	a7,10
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 300:	48ad                	li	a7,11
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 308:	48b1                	li	a7,12
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 310:	48b5                	li	a7,13
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 318:	48b9                	li	a7,14
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 320:	48d9                	li	a7,22
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <crash>:
.global crash
crash:
 li a7, SYS_crash
 328:	48dd                	li	a7,23
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <mount>:
.global mount
mount:
 li a7, SYS_mount
 330:	48e1                	li	a7,24
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <umount>:
.global umount
umount:
 li a7, SYS_umount
 338:	48e5                	li	a7,25
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 340:	1101                	addi	sp,sp,-32
 342:	ec06                	sd	ra,24(sp)
 344:	e822                	sd	s0,16(sp)
 346:	1000                	addi	s0,sp,32
 348:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 34c:	4605                	li	a2,1
 34e:	fef40593          	addi	a1,s0,-17
 352:	00000097          	auipc	ra,0x0
 356:	f4e080e7          	jalr	-178(ra) # 2a0 <write>
}
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	6105                	addi	sp,sp,32
 360:	8082                	ret

0000000000000362 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 362:	7139                	addi	sp,sp,-64
 364:	fc06                	sd	ra,56(sp)
 366:	f822                	sd	s0,48(sp)
 368:	f426                	sd	s1,40(sp)
 36a:	f04a                	sd	s2,32(sp)
 36c:	ec4e                	sd	s3,24(sp)
 36e:	0080                	addi	s0,sp,64
 370:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 372:	c299                	beqz	a3,378 <printint+0x16>
 374:	0805c863          	bltz	a1,404 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 378:	2581                	sext.w	a1,a1
  neg = 0;
 37a:	4881                	li	a7,0
 37c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 380:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 382:	2601                	sext.w	a2,a2
 384:	00000517          	auipc	a0,0x0
 388:	48c50513          	addi	a0,a0,1164 # 810 <digits>
 38c:	883a                	mv	a6,a4
 38e:	2705                	addiw	a4,a4,1
 390:	02c5f7bb          	remuw	a5,a1,a2
 394:	1782                	slli	a5,a5,0x20
 396:	9381                	srli	a5,a5,0x20
 398:	97aa                	add	a5,a5,a0
 39a:	0007c783          	lbu	a5,0(a5)
 39e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a2:	0005879b          	sext.w	a5,a1
 3a6:	02c5d5bb          	divuw	a1,a1,a2
 3aa:	0685                	addi	a3,a3,1
 3ac:	fec7f0e3          	bgeu	a5,a2,38c <printint+0x2a>
  if(neg)
 3b0:	00088b63          	beqz	a7,3c6 <printint+0x64>
    buf[i++] = '-';
 3b4:	fd040793          	addi	a5,s0,-48
 3b8:	973e                	add	a4,a4,a5
 3ba:	02d00793          	li	a5,45
 3be:	fef70823          	sb	a5,-16(a4)
 3c2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c6:	02e05863          	blez	a4,3f6 <printint+0x94>
 3ca:	fc040793          	addi	a5,s0,-64
 3ce:	00e78933          	add	s2,a5,a4
 3d2:	fff78993          	addi	s3,a5,-1
 3d6:	99ba                	add	s3,s3,a4
 3d8:	377d                	addiw	a4,a4,-1
 3da:	1702                	slli	a4,a4,0x20
 3dc:	9301                	srli	a4,a4,0x20
 3de:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e2:	fff94583          	lbu	a1,-1(s2)
 3e6:	8526                	mv	a0,s1
 3e8:	00000097          	auipc	ra,0x0
 3ec:	f58080e7          	jalr	-168(ra) # 340 <putc>
  while(--i >= 0)
 3f0:	197d                	addi	s2,s2,-1
 3f2:	ff3918e3          	bne	s2,s3,3e2 <printint+0x80>
}
 3f6:	70e2                	ld	ra,56(sp)
 3f8:	7442                	ld	s0,48(sp)
 3fa:	74a2                	ld	s1,40(sp)
 3fc:	7902                	ld	s2,32(sp)
 3fe:	69e2                	ld	s3,24(sp)
 400:	6121                	addi	sp,sp,64
 402:	8082                	ret
    x = -xx;
 404:	40b005bb          	negw	a1,a1
    neg = 1;
 408:	4885                	li	a7,1
    x = -xx;
 40a:	bf8d                	j	37c <printint+0x1a>

000000000000040c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 40c:	7119                	addi	sp,sp,-128
 40e:	fc86                	sd	ra,120(sp)
 410:	f8a2                	sd	s0,112(sp)
 412:	f4a6                	sd	s1,104(sp)
 414:	f0ca                	sd	s2,96(sp)
 416:	ecce                	sd	s3,88(sp)
 418:	e8d2                	sd	s4,80(sp)
 41a:	e4d6                	sd	s5,72(sp)
 41c:	e0da                	sd	s6,64(sp)
 41e:	fc5e                	sd	s7,56(sp)
 420:	f862                	sd	s8,48(sp)
 422:	f466                	sd	s9,40(sp)
 424:	f06a                	sd	s10,32(sp)
 426:	ec6e                	sd	s11,24(sp)
 428:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 42a:	0005c903          	lbu	s2,0(a1)
 42e:	18090f63          	beqz	s2,5cc <vprintf+0x1c0>
 432:	8aaa                	mv	s5,a0
 434:	8b32                	mv	s6,a2
 436:	00158493          	addi	s1,a1,1
  state = 0;
 43a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 43c:	02500a13          	li	s4,37
      if(c == 'd'){
 440:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 444:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 448:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 44c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 450:	00000b97          	auipc	s7,0x0
 454:	3c0b8b93          	addi	s7,s7,960 # 810 <digits>
 458:	a839                	j	476 <vprintf+0x6a>
        putc(fd, c);
 45a:	85ca                	mv	a1,s2
 45c:	8556                	mv	a0,s5
 45e:	00000097          	auipc	ra,0x0
 462:	ee2080e7          	jalr	-286(ra) # 340 <putc>
 466:	a019                	j	46c <vprintf+0x60>
    } else if(state == '%'){
 468:	01498f63          	beq	s3,s4,486 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 46c:	0485                	addi	s1,s1,1
 46e:	fff4c903          	lbu	s2,-1(s1)
 472:	14090d63          	beqz	s2,5cc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 476:	0009079b          	sext.w	a5,s2
    if(state == 0){
 47a:	fe0997e3          	bnez	s3,468 <vprintf+0x5c>
      if(c == '%'){
 47e:	fd479ee3          	bne	a5,s4,45a <vprintf+0x4e>
        state = '%';
 482:	89be                	mv	s3,a5
 484:	b7e5                	j	46c <vprintf+0x60>
      if(c == 'd'){
 486:	05878063          	beq	a5,s8,4c6 <vprintf+0xba>
      } else if(c == 'l') {
 48a:	05978c63          	beq	a5,s9,4e2 <vprintf+0xd6>
      } else if(c == 'x') {
 48e:	07a78863          	beq	a5,s10,4fe <vprintf+0xf2>
      } else if(c == 'p') {
 492:	09b78463          	beq	a5,s11,51a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 496:	07300713          	li	a4,115
 49a:	0ce78663          	beq	a5,a4,566 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 49e:	06300713          	li	a4,99
 4a2:	0ee78e63          	beq	a5,a4,59e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4a6:	11478863          	beq	a5,s4,5b6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4aa:	85d2                	mv	a1,s4
 4ac:	8556                	mv	a0,s5
 4ae:	00000097          	auipc	ra,0x0
 4b2:	e92080e7          	jalr	-366(ra) # 340 <putc>
        putc(fd, c);
 4b6:	85ca                	mv	a1,s2
 4b8:	8556                	mv	a0,s5
 4ba:	00000097          	auipc	ra,0x0
 4be:	e86080e7          	jalr	-378(ra) # 340 <putc>
      }
      state = 0;
 4c2:	4981                	li	s3,0
 4c4:	b765                	j	46c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4c6:	008b0913          	addi	s2,s6,8
 4ca:	4685                	li	a3,1
 4cc:	4629                	li	a2,10
 4ce:	000b2583          	lw	a1,0(s6)
 4d2:	8556                	mv	a0,s5
 4d4:	00000097          	auipc	ra,0x0
 4d8:	e8e080e7          	jalr	-370(ra) # 362 <printint>
 4dc:	8b4a                	mv	s6,s2
      state = 0;
 4de:	4981                	li	s3,0
 4e0:	b771                	j	46c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4e2:	008b0913          	addi	s2,s6,8
 4e6:	4681                	li	a3,0
 4e8:	4629                	li	a2,10
 4ea:	000b2583          	lw	a1,0(s6)
 4ee:	8556                	mv	a0,s5
 4f0:	00000097          	auipc	ra,0x0
 4f4:	e72080e7          	jalr	-398(ra) # 362 <printint>
 4f8:	8b4a                	mv	s6,s2
      state = 0;
 4fa:	4981                	li	s3,0
 4fc:	bf85                	j	46c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4fe:	008b0913          	addi	s2,s6,8
 502:	4681                	li	a3,0
 504:	4641                	li	a2,16
 506:	000b2583          	lw	a1,0(s6)
 50a:	8556                	mv	a0,s5
 50c:	00000097          	auipc	ra,0x0
 510:	e56080e7          	jalr	-426(ra) # 362 <printint>
 514:	8b4a                	mv	s6,s2
      state = 0;
 516:	4981                	li	s3,0
 518:	bf91                	j	46c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 51a:	008b0793          	addi	a5,s6,8
 51e:	f8f43423          	sd	a5,-120(s0)
 522:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 526:	03000593          	li	a1,48
 52a:	8556                	mv	a0,s5
 52c:	00000097          	auipc	ra,0x0
 530:	e14080e7          	jalr	-492(ra) # 340 <putc>
  putc(fd, 'x');
 534:	85ea                	mv	a1,s10
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	e08080e7          	jalr	-504(ra) # 340 <putc>
 540:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 542:	03c9d793          	srli	a5,s3,0x3c
 546:	97de                	add	a5,a5,s7
 548:	0007c583          	lbu	a1,0(a5)
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	df2080e7          	jalr	-526(ra) # 340 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 556:	0992                	slli	s3,s3,0x4
 558:	397d                	addiw	s2,s2,-1
 55a:	fe0914e3          	bnez	s2,542 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 55e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 562:	4981                	li	s3,0
 564:	b721                	j	46c <vprintf+0x60>
        s = va_arg(ap, char*);
 566:	008b0993          	addi	s3,s6,8
 56a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 56e:	02090163          	beqz	s2,590 <vprintf+0x184>
        while(*s != 0){
 572:	00094583          	lbu	a1,0(s2)
 576:	c9a1                	beqz	a1,5c6 <vprintf+0x1ba>
          putc(fd, *s);
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	dc6080e7          	jalr	-570(ra) # 340 <putc>
          s++;
 582:	0905                	addi	s2,s2,1
        while(*s != 0){
 584:	00094583          	lbu	a1,0(s2)
 588:	f9e5                	bnez	a1,578 <vprintf+0x16c>
        s = va_arg(ap, char*);
 58a:	8b4e                	mv	s6,s3
      state = 0;
 58c:	4981                	li	s3,0
 58e:	bdf9                	j	46c <vprintf+0x60>
          s = "(null)";
 590:	00000917          	auipc	s2,0x0
 594:	27890913          	addi	s2,s2,632 # 808 <malloc+0x132>
        while(*s != 0){
 598:	02800593          	li	a1,40
 59c:	bff1                	j	578 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 59e:	008b0913          	addi	s2,s6,8
 5a2:	000b4583          	lbu	a1,0(s6)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	d98080e7          	jalr	-616(ra) # 340 <putc>
 5b0:	8b4a                	mv	s6,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bd65                	j	46c <vprintf+0x60>
        putc(fd, c);
 5b6:	85d2                	mv	a1,s4
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	d86080e7          	jalr	-634(ra) # 340 <putc>
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b565                	j	46c <vprintf+0x60>
        s = va_arg(ap, char*);
 5c6:	8b4e                	mv	s6,s3
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	b54d                	j	46c <vprintf+0x60>
    }
  }
}
 5cc:	70e6                	ld	ra,120(sp)
 5ce:	7446                	ld	s0,112(sp)
 5d0:	74a6                	ld	s1,104(sp)
 5d2:	7906                	ld	s2,96(sp)
 5d4:	69e6                	ld	s3,88(sp)
 5d6:	6a46                	ld	s4,80(sp)
 5d8:	6aa6                	ld	s5,72(sp)
 5da:	6b06                	ld	s6,64(sp)
 5dc:	7be2                	ld	s7,56(sp)
 5de:	7c42                	ld	s8,48(sp)
 5e0:	7ca2                	ld	s9,40(sp)
 5e2:	7d02                	ld	s10,32(sp)
 5e4:	6de2                	ld	s11,24(sp)
 5e6:	6109                	addi	sp,sp,128
 5e8:	8082                	ret

00000000000005ea <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5ea:	715d                	addi	sp,sp,-80
 5ec:	ec06                	sd	ra,24(sp)
 5ee:	e822                	sd	s0,16(sp)
 5f0:	1000                	addi	s0,sp,32
 5f2:	e010                	sd	a2,0(s0)
 5f4:	e414                	sd	a3,8(s0)
 5f6:	e818                	sd	a4,16(s0)
 5f8:	ec1c                	sd	a5,24(s0)
 5fa:	03043023          	sd	a6,32(s0)
 5fe:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 602:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 606:	8622                	mv	a2,s0
 608:	00000097          	auipc	ra,0x0
 60c:	e04080e7          	jalr	-508(ra) # 40c <vprintf>
}
 610:	60e2                	ld	ra,24(sp)
 612:	6442                	ld	s0,16(sp)
 614:	6161                	addi	sp,sp,80
 616:	8082                	ret

0000000000000618 <printf>:

void
printf(const char *fmt, ...)
{
 618:	711d                	addi	sp,sp,-96
 61a:	ec06                	sd	ra,24(sp)
 61c:	e822                	sd	s0,16(sp)
 61e:	1000                	addi	s0,sp,32
 620:	e40c                	sd	a1,8(s0)
 622:	e810                	sd	a2,16(s0)
 624:	ec14                	sd	a3,24(s0)
 626:	f018                	sd	a4,32(s0)
 628:	f41c                	sd	a5,40(s0)
 62a:	03043823          	sd	a6,48(s0)
 62e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 632:	00840613          	addi	a2,s0,8
 636:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 63a:	85aa                	mv	a1,a0
 63c:	4505                	li	a0,1
 63e:	00000097          	auipc	ra,0x0
 642:	dce080e7          	jalr	-562(ra) # 40c <vprintf>
}
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6125                	addi	sp,sp,96
 64c:	8082                	ret

000000000000064e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64e:	1141                	addi	sp,sp,-16
 650:	e422                	sd	s0,8(sp)
 652:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 654:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 658:	00000797          	auipc	a5,0x0
 65c:	1d07b783          	ld	a5,464(a5) # 828 <freep>
 660:	a805                	j	690 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 662:	4618                	lw	a4,8(a2)
 664:	9db9                	addw	a1,a1,a4
 666:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 66a:	6398                	ld	a4,0(a5)
 66c:	6318                	ld	a4,0(a4)
 66e:	fee53823          	sd	a4,-16(a0)
 672:	a091                	j	6b6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 674:	ff852703          	lw	a4,-8(a0)
 678:	9e39                	addw	a2,a2,a4
 67a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 67c:	ff053703          	ld	a4,-16(a0)
 680:	e398                	sd	a4,0(a5)
 682:	a099                	j	6c8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 684:	6398                	ld	a4,0(a5)
 686:	00e7e463          	bltu	a5,a4,68e <free+0x40>
 68a:	00e6ea63          	bltu	a3,a4,69e <free+0x50>
{
 68e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 690:	fed7fae3          	bgeu	a5,a3,684 <free+0x36>
 694:	6398                	ld	a4,0(a5)
 696:	00e6e463          	bltu	a3,a4,69e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69a:	fee7eae3          	bltu	a5,a4,68e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 69e:	ff852583          	lw	a1,-8(a0)
 6a2:	6390                	ld	a2,0(a5)
 6a4:	02059813          	slli	a6,a1,0x20
 6a8:	01c85713          	srli	a4,a6,0x1c
 6ac:	9736                	add	a4,a4,a3
 6ae:	fae60ae3          	beq	a2,a4,662 <free+0x14>
    bp->s.ptr = p->s.ptr;
 6b2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6b6:	4790                	lw	a2,8(a5)
 6b8:	02061593          	slli	a1,a2,0x20
 6bc:	01c5d713          	srli	a4,a1,0x1c
 6c0:	973e                	add	a4,a4,a5
 6c2:	fae689e3          	beq	a3,a4,674 <free+0x26>
  } else
    p->s.ptr = bp;
 6c6:	e394                	sd	a3,0(a5)
  freep = p;
 6c8:	00000717          	auipc	a4,0x0
 6cc:	16f73023          	sd	a5,352(a4) # 828 <freep>
}
 6d0:	6422                	ld	s0,8(sp)
 6d2:	0141                	addi	sp,sp,16
 6d4:	8082                	ret

00000000000006d6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6d6:	7139                	addi	sp,sp,-64
 6d8:	fc06                	sd	ra,56(sp)
 6da:	f822                	sd	s0,48(sp)
 6dc:	f426                	sd	s1,40(sp)
 6de:	f04a                	sd	s2,32(sp)
 6e0:	ec4e                	sd	s3,24(sp)
 6e2:	e852                	sd	s4,16(sp)
 6e4:	e456                	sd	s5,8(sp)
 6e6:	e05a                	sd	s6,0(sp)
 6e8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ea:	02051493          	slli	s1,a0,0x20
 6ee:	9081                	srli	s1,s1,0x20
 6f0:	04bd                	addi	s1,s1,15
 6f2:	8091                	srli	s1,s1,0x4
 6f4:	0014899b          	addiw	s3,s1,1
 6f8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6fa:	00000517          	auipc	a0,0x0
 6fe:	12e53503          	ld	a0,302(a0) # 828 <freep>
 702:	c515                	beqz	a0,72e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 704:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 706:	4798                	lw	a4,8(a5)
 708:	02977f63          	bgeu	a4,s1,746 <malloc+0x70>
 70c:	8a4e                	mv	s4,s3
 70e:	0009871b          	sext.w	a4,s3
 712:	6685                	lui	a3,0x1
 714:	00d77363          	bgeu	a4,a3,71a <malloc+0x44>
 718:	6a05                	lui	s4,0x1
 71a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 71e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 722:	00000917          	auipc	s2,0x0
 726:	10690913          	addi	s2,s2,262 # 828 <freep>
  if(p == (char*)-1)
 72a:	5afd                	li	s5,-1
 72c:	a895                	j	7a0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 72e:	00000797          	auipc	a5,0x0
 732:	10278793          	addi	a5,a5,258 # 830 <base>
 736:	00000717          	auipc	a4,0x0
 73a:	0ef73923          	sd	a5,242(a4) # 828 <freep>
 73e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 740:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 744:	b7e1                	j	70c <malloc+0x36>
      if(p->s.size == nunits)
 746:	02e48c63          	beq	s1,a4,77e <malloc+0xa8>
        p->s.size -= nunits;
 74a:	4137073b          	subw	a4,a4,s3
 74e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 750:	02071693          	slli	a3,a4,0x20
 754:	01c6d713          	srli	a4,a3,0x1c
 758:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 75a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 75e:	00000717          	auipc	a4,0x0
 762:	0ca73523          	sd	a0,202(a4) # 828 <freep>
      return (void*)(p + 1);
 766:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 76a:	70e2                	ld	ra,56(sp)
 76c:	7442                	ld	s0,48(sp)
 76e:	74a2                	ld	s1,40(sp)
 770:	7902                	ld	s2,32(sp)
 772:	69e2                	ld	s3,24(sp)
 774:	6a42                	ld	s4,16(sp)
 776:	6aa2                	ld	s5,8(sp)
 778:	6b02                	ld	s6,0(sp)
 77a:	6121                	addi	sp,sp,64
 77c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 77e:	6398                	ld	a4,0(a5)
 780:	e118                	sd	a4,0(a0)
 782:	bff1                	j	75e <malloc+0x88>
  hp->s.size = nu;
 784:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 788:	0541                	addi	a0,a0,16
 78a:	00000097          	auipc	ra,0x0
 78e:	ec4080e7          	jalr	-316(ra) # 64e <free>
  return freep;
 792:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 796:	d971                	beqz	a0,76a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 798:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79a:	4798                	lw	a4,8(a5)
 79c:	fa9775e3          	bgeu	a4,s1,746 <malloc+0x70>
    if(p == freep)
 7a0:	00093703          	ld	a4,0(s2)
 7a4:	853e                	mv	a0,a5
 7a6:	fef719e3          	bne	a4,a5,798 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7aa:	8552                	mv	a0,s4
 7ac:	00000097          	auipc	ra,0x0
 7b0:	b5c080e7          	jalr	-1188(ra) # 308 <sbrk>
  if(p == (char*)-1)
 7b4:	fd5518e3          	bne	a0,s5,784 <malloc+0xae>
        return 0;
 7b8:	4501                	li	a0,0
 7ba:	bf45                	j	76a <malloc+0x94>
