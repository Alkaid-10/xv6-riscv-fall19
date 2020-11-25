
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getLastElem>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"
 
 
// 返回path中最后一个斜杠之后的元素
char *getLastElem(char *p){
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    char *t=p;
    char *last=0;
    while(*t!='\0'){
   6:	00054703          	lbu	a4,0(a0)
   a:	c30d                	beqz	a4,2c <getLastElem+0x2c>
    char *t=p;
   c:	87aa                	mv	a5,a0
    char *last=0;
   e:	4601                	li	a2,0
        if(*t=='/'){
  10:	02f00693          	li	a3,47
  14:	a029                	j	1e <getLastElem+0x1e>
            last=t;
        }
        t++;
  16:	0785                	addi	a5,a5,1
    while(*t!='\0'){
  18:	0007c703          	lbu	a4,0(a5)
  1c:	c709                	beqz	a4,26 <getLastElem+0x26>
        if(*t=='/'){
  1e:	fed71ce3          	bne	a4,a3,16 <getLastElem+0x16>
  22:	863e                	mv	a2,a5
  24:	bfcd                	j	16 <getLastElem+0x16>
    }
    // 也可能没有/，那么p指向的文件名
    if(last==0){
  26:	c219                	beqz	a2,2c <getLastElem+0x2c>
        return p;
    }
    return last+1;
  28:	00160513          	addi	a0,a2,1
}
  2c:	6422                	ld	s0,8(sp)
  2e:	0141                	addi	sp,sp,16
  30:	8082                	ret

0000000000000032 <find>:

void find(char* path,char *name){
  32:	d8010113          	addi	sp,sp,-640
  36:	26113c23          	sd	ra,632(sp)
  3a:	26813823          	sd	s0,624(sp)
  3e:	26913423          	sd	s1,616(sp)
  42:	27213023          	sd	s2,608(sp)
  46:	25313c23          	sd	s3,600(sp)
  4a:	25413823          	sd	s4,592(sp)
  4e:	25513423          	sd	s5,584(sp)
  52:	25613023          	sd	s6,576(sp)
  56:	23713c23          	sd	s7,568(sp)
  5a:	23813823          	sd	s8,560(sp)
  5e:	0500                	addi	s0,sp,640
  60:	892a                	mv	s2,a0
  62:	89ae                	mv	s3,a1
    char buf[512], *p=0;
    int fd;
    struct dirent de;
    struct stat st;
 
    if((fd = open(path, O_RDONLY)) < 0){
  64:	4581                	li	a1,0
  66:	00000097          	auipc	ra,0x0
  6a:	440080e7          	jalr	1088(ra) # 4a6 <open>
  6e:	06054c63          	bltz	a0,e6 <find+0xb4>
  72:	84aa                	mv	s1,a0
        fprintf(2, "ls: cannot open %s\n", path);
        return;
    }
 
    if(fstat(fd, &st) < 0){
  74:	d8840593          	addi	a1,s0,-632
  78:	00000097          	auipc	ra,0x0
  7c:	446080e7          	jalr	1094(ra) # 4be <fstat>
  80:	06054e63          	bltz	a0,fc <find+0xca>
        fprintf(2, "ls: cannot stat %s\n", path);
        close(fd);
        return;
    }
    switch(st.type){
  84:	d9041783          	lh	a5,-624(s0)
  88:	0007869b          	sext.w	a3,a5
  8c:	4705                	li	a4,1
  8e:	0ae68163          	beq	a3,a4,130 <find+0xfe>
  92:	4709                	li	a4,2
  94:	00e69d63          	bne	a3,a4,ae <find+0x7c>
    case T_FILE:
        p=getLastElem(path);
  98:	854a                	mv	a0,s2
  9a:	00000097          	auipc	ra,0x0
  9e:	f66080e7          	jalr	-154(ra) # 0 <getLastElem>
        if(strcmp(p,name)==0)
  a2:	85ce                	mv	a1,s3
  a4:	00000097          	auipc	ra,0x0
  a8:	1f0080e7          	jalr	496(ra) # 294 <strcmp>
  ac:	c925                	beqz	a0,11c <find+0xea>
            }
            find(buf,name);
        }
        break;
    }
    close(fd);
  ae:	8526                	mv	a0,s1
  b0:	00000097          	auipc	ra,0x0
  b4:	3de080e7          	jalr	990(ra) # 48e <close>
 
}
  b8:	27813083          	ld	ra,632(sp)
  bc:	27013403          	ld	s0,624(sp)
  c0:	26813483          	ld	s1,616(sp)
  c4:	26013903          	ld	s2,608(sp)
  c8:	25813983          	ld	s3,600(sp)
  cc:	25013a03          	ld	s4,592(sp)
  d0:	24813a83          	ld	s5,584(sp)
  d4:	24013b03          	ld	s6,576(sp)
  d8:	23813b83          	ld	s7,568(sp)
  dc:	23013c03          	ld	s8,560(sp)
  e0:	28010113          	addi	sp,sp,640
  e4:	8082                	ret
        fprintf(2, "ls: cannot open %s\n", path);
  e6:	864a                	mv	a2,s2
  e8:	00001597          	auipc	a1,0x1
  ec:	8c058593          	addi	a1,a1,-1856 # 9a8 <malloc+0xec>
  f0:	4509                	li	a0,2
  f2:	00000097          	auipc	ra,0x0
  f6:	6de080e7          	jalr	1758(ra) # 7d0 <fprintf>
        return;
  fa:	bf7d                	j	b8 <find+0x86>
        fprintf(2, "ls: cannot stat %s\n", path);
  fc:	864a                	mv	a2,s2
  fe:	00001597          	auipc	a1,0x1
 102:	8c258593          	addi	a1,a1,-1854 # 9c0 <malloc+0x104>
 106:	4509                	li	a0,2
 108:	00000097          	auipc	ra,0x0
 10c:	6c8080e7          	jalr	1736(ra) # 7d0 <fprintf>
        close(fd);
 110:	8526                	mv	a0,s1
 112:	00000097          	auipc	ra,0x0
 116:	37c080e7          	jalr	892(ra) # 48e <close>
        return;
 11a:	bf79                	j	b8 <find+0x86>
            printf("%s\n",path);
 11c:	85ca                	mv	a1,s2
 11e:	00001517          	auipc	a0,0x1
 122:	89a50513          	addi	a0,a0,-1894 # 9b8 <malloc+0xfc>
 126:	00000097          	auipc	ra,0x0
 12a:	6d8080e7          	jalr	1752(ra) # 7fe <printf>
 12e:	b741                	j	ae <find+0x7c>
        if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 130:	854a                	mv	a0,s2
 132:	00000097          	auipc	ra,0x0
 136:	18e080e7          	jalr	398(ra) # 2c0 <strlen>
 13a:	2541                	addiw	a0,a0,16
 13c:	20000793          	li	a5,512
 140:	00a7fb63          	bgeu	a5,a0,156 <find+0x124>
        printf("ls: path too long\n");
 144:	00001517          	auipc	a0,0x1
 148:	89450513          	addi	a0,a0,-1900 # 9d8 <malloc+0x11c>
 14c:	00000097          	auipc	ra,0x0
 150:	6b2080e7          	jalr	1714(ra) # 7fe <printf>
        break;
 154:	bfa9                	j	ae <find+0x7c>
        strcpy(buf, path);
 156:	85ca                	mv	a1,s2
 158:	db040513          	addi	a0,s0,-592
 15c:	00000097          	auipc	ra,0x0
 160:	11c080e7          	jalr	284(ra) # 278 <strcpy>
        p = buf+strlen(buf);
 164:	db040513          	addi	a0,s0,-592
 168:	00000097          	auipc	ra,0x0
 16c:	158080e7          	jalr	344(ra) # 2c0 <strlen>
 170:	1502                	slli	a0,a0,0x20
 172:	9101                	srli	a0,a0,0x20
 174:	db040793          	addi	a5,s0,-592
 178:	953e                	add	a0,a0,a5
        *p++ = '/';
 17a:	00150a93          	addi	s5,a0,1
 17e:	02f00793          	li	a5,47
 182:	00f50023          	sb	a5,0(a0)
            int t=strlen(de.name)>DIRSIZ?DIRSIZ:strlen(de.name);
 186:	4a39                	li	s4,14
            if(strcmp(de.name,".")==0||strcmp(de.name,"..")==0){
 188:	00001b17          	auipc	s6,0x1
 18c:	868b0b13          	addi	s6,s6,-1944 # 9f0 <malloc+0x134>
 190:	00001b97          	auipc	s7,0x1
 194:	868b8b93          	addi	s7,s7,-1944 # 9f8 <malloc+0x13c>
                printf("ls: cannot stat %s\n", buf);
 198:	00001c17          	auipc	s8,0x1
 19c:	828c0c13          	addi	s8,s8,-2008 # 9c0 <malloc+0x104>
        while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1a0:	4641                	li	a2,16
 1a2:	da040593          	addi	a1,s0,-608
 1a6:	8526                	mv	a0,s1
 1a8:	00000097          	auipc	ra,0x0
 1ac:	2d6080e7          	jalr	726(ra) # 47e <read>
 1b0:	47c1                	li	a5,16
 1b2:	eef51ee3          	bne	a0,a5,ae <find+0x7c>
            if(de.inum == 0)
 1b6:	da045783          	lhu	a5,-608(s0)
 1ba:	d3fd                	beqz	a5,1a0 <find+0x16e>
            int t=strlen(de.name)>DIRSIZ?DIRSIZ:strlen(de.name);
 1bc:	da240513          	addi	a0,s0,-606
 1c0:	00000097          	auipc	ra,0x0
 1c4:	100080e7          	jalr	256(ra) # 2c0 <strlen>
 1c8:	2501                	sext.w	a0,a0
 1ca:	8952                	mv	s2,s4
 1cc:	04aa7f63          	bgeu	s4,a0,22a <find+0x1f8>
            memmove(p, de.name, t);
 1d0:	864a                	mv	a2,s2
 1d2:	da240593          	addi	a1,s0,-606
 1d6:	8556                	mv	a0,s5
 1d8:	00000097          	auipc	ra,0x0
 1dc:	25c080e7          	jalr	604(ra) # 434 <memmove>
            p[t] = 0;
 1e0:	9956                	add	s2,s2,s5
 1e2:	00090023          	sb	zero,0(s2)
            if(stat(buf, &st) < 0){
 1e6:	d8840593          	addi	a1,s0,-632
 1ea:	db040513          	addi	a0,s0,-592
 1ee:	00000097          	auipc	ra,0x0
 1f2:	1b6080e7          	jalr	438(ra) # 3a4 <stat>
 1f6:	04054363          	bltz	a0,23c <find+0x20a>
            if(strcmp(de.name,".")==0||strcmp(de.name,"..")==0){
 1fa:	85da                	mv	a1,s6
 1fc:	da240513          	addi	a0,s0,-606
 200:	00000097          	auipc	ra,0x0
 204:	094080e7          	jalr	148(ra) # 294 <strcmp>
 208:	dd41                	beqz	a0,1a0 <find+0x16e>
 20a:	85de                	mv	a1,s7
 20c:	da240513          	addi	a0,s0,-606
 210:	00000097          	auipc	ra,0x0
 214:	084080e7          	jalr	132(ra) # 294 <strcmp>
 218:	d541                	beqz	a0,1a0 <find+0x16e>
            find(buf,name);
 21a:	85ce                	mv	a1,s3
 21c:	db040513          	addi	a0,s0,-592
 220:	00000097          	auipc	ra,0x0
 224:	e12080e7          	jalr	-494(ra) # 32 <find>
 228:	bfa5                	j	1a0 <find+0x16e>
            int t=strlen(de.name)>DIRSIZ?DIRSIZ:strlen(de.name);
 22a:	da240513          	addi	a0,s0,-606
 22e:	00000097          	auipc	ra,0x0
 232:	092080e7          	jalr	146(ra) # 2c0 <strlen>
 236:	0005091b          	sext.w	s2,a0
 23a:	bf59                	j	1d0 <find+0x19e>
                printf("ls: cannot stat %s\n", buf);
 23c:	db040593          	addi	a1,s0,-592
 240:	8562                	mv	a0,s8
 242:	00000097          	auipc	ra,0x0
 246:	5bc080e7          	jalr	1468(ra) # 7fe <printf>
                continue;
 24a:	bf99                	j	1a0 <find+0x16e>

000000000000024c <main>:
int main(int argc,char* argv[]){
 24c:	1141                	addi	sp,sp,-16
 24e:	e406                	sd	ra,8(sp)
 250:	e022                	sd	s0,0(sp)
 252:	0800                	addi	s0,sp,16
    
    if(argc<3){
 254:	4709                	li	a4,2
 256:	00a74663          	blt	a4,a0,262 <main+0x16>
        exit();
 25a:	00000097          	auipc	ra,0x0
 25e:	20c080e7          	jalr	524(ra) # 466 <exit>
 262:	87ae                	mv	a5,a1
    }
    find(argv[1],argv[2]);
 264:	698c                	ld	a1,16(a1)
 266:	6788                	ld	a0,8(a5)
 268:	00000097          	auipc	ra,0x0
 26c:	dca080e7          	jalr	-566(ra) # 32 <find>
    exit();
 270:	00000097          	auipc	ra,0x0
 274:	1f6080e7          	jalr	502(ra) # 466 <exit>

0000000000000278 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1c>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x12>
  }
  return dst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strchr>:

char*
strchr(const char *s, char c)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cb99                	beqz	a5,32c <strchr+0x20>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1a>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xc>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strchr+0x1a>

0000000000000330 <gets>:

char*
gets(char *buf, int max)
{
 330:	711d                	addi	sp,sp,-96
 332:	ec86                	sd	ra,88(sp)
 334:	e8a2                	sd	s0,80(sp)
 336:	e4a6                	sd	s1,72(sp)
 338:	e0ca                	sd	s2,64(sp)
 33a:	fc4e                	sd	s3,56(sp)
 33c:	f852                	sd	s4,48(sp)
 33e:	f456                	sd	s5,40(sp)
 340:	f05a                	sd	s6,32(sp)
 342:	ec5e                	sd	s7,24(sp)
 344:	1080                	addi	s0,sp,96
 346:	8baa                	mv	s7,a0
 348:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34a:	892a                	mv	s2,a0
 34c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34e:	4aa9                	li	s5,10
 350:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 352:	89a6                	mv	s3,s1
 354:	2485                	addiw	s1,s1,1
 356:	0344d863          	bge	s1,s4,386 <gets+0x56>
    cc = read(0, &c, 1);
 35a:	4605                	li	a2,1
 35c:	faf40593          	addi	a1,s0,-81
 360:	4501                	li	a0,0
 362:	00000097          	auipc	ra,0x0
 366:	11c080e7          	jalr	284(ra) # 47e <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x56>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x54>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679be3          	bne	a5,s6,352 <gets+0x22>
  for(i=0; i+1 < max; ){
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x56>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e426                	sd	s1,8(sp)
 3ac:	e04a                	sd	s2,0(sp)
 3ae:	1000                	addi	s0,sp,32
 3b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b2:	4581                	li	a1,0
 3b4:	00000097          	auipc	ra,0x0
 3b8:	0f2080e7          	jalr	242(ra) # 4a6 <open>
  if(fd < 0)
 3bc:	02054563          	bltz	a0,3e6 <stat+0x42>
 3c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c2:	85ca                	mv	a1,s2
 3c4:	00000097          	auipc	ra,0x0
 3c8:	0fa080e7          	jalr	250(ra) # 4be <fstat>
 3cc:	892a                	mv	s2,a0
  close(fd);
 3ce:	8526                	mv	a0,s1
 3d0:	00000097          	auipc	ra,0x0
 3d4:	0be080e7          	jalr	190(ra) # 48e <close>
  return r;
}
 3d8:	854a                	mv	a0,s2
 3da:	60e2                	ld	ra,24(sp)
 3dc:	6442                	ld	s0,16(sp)
 3de:	64a2                	ld	s1,8(sp)
 3e0:	6902                	ld	s2,0(sp)
 3e2:	6105                	addi	sp,sp,32
 3e4:	8082                	ret
    return -1;
 3e6:	597d                	li	s2,-1
 3e8:	bfc5                	j	3d8 <stat+0x34>

00000000000003ea <atoi>:

int
atoi(const char *s)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f0:	00054603          	lbu	a2,0(a0)
 3f4:	fd06079b          	addiw	a5,a2,-48
 3f8:	0ff7f793          	andi	a5,a5,255
 3fc:	4725                	li	a4,9
 3fe:	02f76963          	bltu	a4,a5,430 <atoi+0x46>
 402:	86aa                	mv	a3,a0
  n = 0;
 404:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 406:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 408:	0685                	addi	a3,a3,1
 40a:	0025179b          	slliw	a5,a0,0x2
 40e:	9fa9                	addw	a5,a5,a0
 410:	0017979b          	slliw	a5,a5,0x1
 414:	9fb1                	addw	a5,a5,a2
 416:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 41a:	0006c603          	lbu	a2,0(a3)
 41e:	fd06071b          	addiw	a4,a2,-48
 422:	0ff77713          	andi	a4,a4,255
 426:	fee5f1e3          	bgeu	a1,a4,408 <atoi+0x1e>
  return n;
}
 42a:	6422                	ld	s0,8(sp)
 42c:	0141                	addi	sp,sp,16
 42e:	8082                	ret
  n = 0;
 430:	4501                	li	a0,0
 432:	bfe5                	j	42a <atoi+0x40>

0000000000000434 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 434:	1141                	addi	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 43a:	00c05f63          	blez	a2,458 <memmove+0x24>
 43e:	1602                	slli	a2,a2,0x20
 440:	9201                	srli	a2,a2,0x20
 442:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 446:	87aa                	mv	a5,a0
    *dst++ = *src++;
 448:	0585                	addi	a1,a1,1
 44a:	0785                	addi	a5,a5,1
 44c:	fff5c703          	lbu	a4,-1(a1)
 450:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 454:	fed79ae3          	bne	a5,a3,448 <memmove+0x14>
  return vdst;
}
 458:	6422                	ld	s0,8(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45e:	4885                	li	a7,1
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exit>:
.global exit
exit:
 li a7, SYS_exit
 466:	4889                	li	a7,2
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <wait>:
.global wait
wait:
 li a7, SYS_wait
 46e:	488d                	li	a7,3
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 476:	4891                	li	a7,4
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <read>:
.global read
read:
 li a7, SYS_read
 47e:	4895                	li	a7,5
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <write>:
.global write
write:
 li a7, SYS_write
 486:	48c1                	li	a7,16
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <close>:
.global close
close:
 li a7, SYS_close
 48e:	48d5                	li	a7,21
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <kill>:
.global kill
kill:
 li a7, SYS_kill
 496:	4899                	li	a7,6
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exec>:
.global exec
exec:
 li a7, SYS_exec
 49e:	489d                	li	a7,7
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <open>:
.global open
open:
 li a7, SYS_open
 4a6:	48bd                	li	a7,15
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ae:	48c5                	li	a7,17
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b6:	48c9                	li	a7,18
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4be:	48a1                	li	a7,8
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <link>:
.global link
link:
 li a7, SYS_link
 4c6:	48cd                	li	a7,19
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ce:	48d1                	li	a7,20
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d6:	48a5                	li	a7,9
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <dup>:
.global dup
dup:
 li a7, SYS_dup
 4de:	48a9                	li	a7,10
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e6:	48ad                	li	a7,11
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ee:	48b1                	li	a7,12
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f6:	48b5                	li	a7,13
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fe:	48b9                	li	a7,14
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 506:	48d9                	li	a7,22
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <crash>:
.global crash
crash:
 li a7, SYS_crash
 50e:	48dd                	li	a7,23
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <mount>:
.global mount
mount:
 li a7, SYS_mount
 516:	48e1                	li	a7,24
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <umount>:
.global umount
umount:
 li a7, SYS_umount
 51e:	48e5                	li	a7,25
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 526:	1101                	addi	sp,sp,-32
 528:	ec06                	sd	ra,24(sp)
 52a:	e822                	sd	s0,16(sp)
 52c:	1000                	addi	s0,sp,32
 52e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 532:	4605                	li	a2,1
 534:	fef40593          	addi	a1,s0,-17
 538:	00000097          	auipc	ra,0x0
 53c:	f4e080e7          	jalr	-178(ra) # 486 <write>
}
 540:	60e2                	ld	ra,24(sp)
 542:	6442                	ld	s0,16(sp)
 544:	6105                	addi	sp,sp,32
 546:	8082                	ret

0000000000000548 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 548:	7139                	addi	sp,sp,-64
 54a:	fc06                	sd	ra,56(sp)
 54c:	f822                	sd	s0,48(sp)
 54e:	f426                	sd	s1,40(sp)
 550:	f04a                	sd	s2,32(sp)
 552:	ec4e                	sd	s3,24(sp)
 554:	0080                	addi	s0,sp,64
 556:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 558:	c299                	beqz	a3,55e <printint+0x16>
 55a:	0805c863          	bltz	a1,5ea <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 55e:	2581                	sext.w	a1,a1
  neg = 0;
 560:	4881                	li	a7,0
 562:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 566:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 568:	2601                	sext.w	a2,a2
 56a:	00000517          	auipc	a0,0x0
 56e:	49e50513          	addi	a0,a0,1182 # a08 <digits>
 572:	883a                	mv	a6,a4
 574:	2705                	addiw	a4,a4,1
 576:	02c5f7bb          	remuw	a5,a1,a2
 57a:	1782                	slli	a5,a5,0x20
 57c:	9381                	srli	a5,a5,0x20
 57e:	97aa                	add	a5,a5,a0
 580:	0007c783          	lbu	a5,0(a5)
 584:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 588:	0005879b          	sext.w	a5,a1
 58c:	02c5d5bb          	divuw	a1,a1,a2
 590:	0685                	addi	a3,a3,1
 592:	fec7f0e3          	bgeu	a5,a2,572 <printint+0x2a>
  if(neg)
 596:	00088b63          	beqz	a7,5ac <printint+0x64>
    buf[i++] = '-';
 59a:	fd040793          	addi	a5,s0,-48
 59e:	973e                	add	a4,a4,a5
 5a0:	02d00793          	li	a5,45
 5a4:	fef70823          	sb	a5,-16(a4)
 5a8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ac:	02e05863          	blez	a4,5dc <printint+0x94>
 5b0:	fc040793          	addi	a5,s0,-64
 5b4:	00e78933          	add	s2,a5,a4
 5b8:	fff78993          	addi	s3,a5,-1
 5bc:	99ba                	add	s3,s3,a4
 5be:	377d                	addiw	a4,a4,-1
 5c0:	1702                	slli	a4,a4,0x20
 5c2:	9301                	srli	a4,a4,0x20
 5c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c8:	fff94583          	lbu	a1,-1(s2)
 5cc:	8526                	mv	a0,s1
 5ce:	00000097          	auipc	ra,0x0
 5d2:	f58080e7          	jalr	-168(ra) # 526 <putc>
  while(--i >= 0)
 5d6:	197d                	addi	s2,s2,-1
 5d8:	ff3918e3          	bne	s2,s3,5c8 <printint+0x80>
}
 5dc:	70e2                	ld	ra,56(sp)
 5de:	7442                	ld	s0,48(sp)
 5e0:	74a2                	ld	s1,40(sp)
 5e2:	7902                	ld	s2,32(sp)
 5e4:	69e2                	ld	s3,24(sp)
 5e6:	6121                	addi	sp,sp,64
 5e8:	8082                	ret
    x = -xx;
 5ea:	40b005bb          	negw	a1,a1
    neg = 1;
 5ee:	4885                	li	a7,1
    x = -xx;
 5f0:	bf8d                	j	562 <printint+0x1a>

00000000000005f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f2:	7119                	addi	sp,sp,-128
 5f4:	fc86                	sd	ra,120(sp)
 5f6:	f8a2                	sd	s0,112(sp)
 5f8:	f4a6                	sd	s1,104(sp)
 5fa:	f0ca                	sd	s2,96(sp)
 5fc:	ecce                	sd	s3,88(sp)
 5fe:	e8d2                	sd	s4,80(sp)
 600:	e4d6                	sd	s5,72(sp)
 602:	e0da                	sd	s6,64(sp)
 604:	fc5e                	sd	s7,56(sp)
 606:	f862                	sd	s8,48(sp)
 608:	f466                	sd	s9,40(sp)
 60a:	f06a                	sd	s10,32(sp)
 60c:	ec6e                	sd	s11,24(sp)
 60e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 610:	0005c903          	lbu	s2,0(a1)
 614:	18090f63          	beqz	s2,7b2 <vprintf+0x1c0>
 618:	8aaa                	mv	s5,a0
 61a:	8b32                	mv	s6,a2
 61c:	00158493          	addi	s1,a1,1
  state = 0;
 620:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 622:	02500a13          	li	s4,37
      if(c == 'd'){
 626:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 62a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 62e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 632:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 636:	00000b97          	auipc	s7,0x0
 63a:	3d2b8b93          	addi	s7,s7,978 # a08 <digits>
 63e:	a839                	j	65c <vprintf+0x6a>
        putc(fd, c);
 640:	85ca                	mv	a1,s2
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	ee2080e7          	jalr	-286(ra) # 526 <putc>
 64c:	a019                	j	652 <vprintf+0x60>
    } else if(state == '%'){
 64e:	01498f63          	beq	s3,s4,66c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 652:	0485                	addi	s1,s1,1
 654:	fff4c903          	lbu	s2,-1(s1)
 658:	14090d63          	beqz	s2,7b2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 65c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 660:	fe0997e3          	bnez	s3,64e <vprintf+0x5c>
      if(c == '%'){
 664:	fd479ee3          	bne	a5,s4,640 <vprintf+0x4e>
        state = '%';
 668:	89be                	mv	s3,a5
 66a:	b7e5                	j	652 <vprintf+0x60>
      if(c == 'd'){
 66c:	05878063          	beq	a5,s8,6ac <vprintf+0xba>
      } else if(c == 'l') {
 670:	05978c63          	beq	a5,s9,6c8 <vprintf+0xd6>
      } else if(c == 'x') {
 674:	07a78863          	beq	a5,s10,6e4 <vprintf+0xf2>
      } else if(c == 'p') {
 678:	09b78463          	beq	a5,s11,700 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 67c:	07300713          	li	a4,115
 680:	0ce78663          	beq	a5,a4,74c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 684:	06300713          	li	a4,99
 688:	0ee78e63          	beq	a5,a4,784 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 68c:	11478863          	beq	a5,s4,79c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 690:	85d2                	mv	a1,s4
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e92080e7          	jalr	-366(ra) # 526 <putc>
        putc(fd, c);
 69c:	85ca                	mv	a1,s2
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e86080e7          	jalr	-378(ra) # 526 <putc>
      }
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b765                	j	652 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6ac:	008b0913          	addi	s2,s6,8
 6b0:	4685                	li	a3,1
 6b2:	4629                	li	a2,10
 6b4:	000b2583          	lw	a1,0(s6)
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	e8e080e7          	jalr	-370(ra) # 548 <printint>
 6c2:	8b4a                	mv	s6,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b771                	j	652 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c8:	008b0913          	addi	s2,s6,8
 6cc:	4681                	li	a3,0
 6ce:	4629                	li	a2,10
 6d0:	000b2583          	lw	a1,0(s6)
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e72080e7          	jalr	-398(ra) # 548 <printint>
 6de:	8b4a                	mv	s6,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bf85                	j	652 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	4681                	li	a3,0
 6ea:	4641                	li	a2,16
 6ec:	000b2583          	lw	a1,0(s6)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e56080e7          	jalr	-426(ra) # 548 <printint>
 6fa:	8b4a                	mv	s6,s2
      state = 0;
 6fc:	4981                	li	s3,0
 6fe:	bf91                	j	652 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 700:	008b0793          	addi	a5,s6,8
 704:	f8f43423          	sd	a5,-120(s0)
 708:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 70c:	03000593          	li	a1,48
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	e14080e7          	jalr	-492(ra) # 526 <putc>
  putc(fd, 'x');
 71a:	85ea                	mv	a1,s10
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	e08080e7          	jalr	-504(ra) # 526 <putc>
 726:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 728:	03c9d793          	srli	a5,s3,0x3c
 72c:	97de                	add	a5,a5,s7
 72e:	0007c583          	lbu	a1,0(a5)
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	df2080e7          	jalr	-526(ra) # 526 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 73c:	0992                	slli	s3,s3,0x4
 73e:	397d                	addiw	s2,s2,-1
 740:	fe0914e3          	bnez	s2,728 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 744:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 748:	4981                	li	s3,0
 74a:	b721                	j	652 <vprintf+0x60>
        s = va_arg(ap, char*);
 74c:	008b0993          	addi	s3,s6,8
 750:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 754:	02090163          	beqz	s2,776 <vprintf+0x184>
        while(*s != 0){
 758:	00094583          	lbu	a1,0(s2)
 75c:	c9a1                	beqz	a1,7ac <vprintf+0x1ba>
          putc(fd, *s);
 75e:	8556                	mv	a0,s5
 760:	00000097          	auipc	ra,0x0
 764:	dc6080e7          	jalr	-570(ra) # 526 <putc>
          s++;
 768:	0905                	addi	s2,s2,1
        while(*s != 0){
 76a:	00094583          	lbu	a1,0(s2)
 76e:	f9e5                	bnez	a1,75e <vprintf+0x16c>
        s = va_arg(ap, char*);
 770:	8b4e                	mv	s6,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	bdf9                	j	652 <vprintf+0x60>
          s = "(null)";
 776:	00000917          	auipc	s2,0x0
 77a:	28a90913          	addi	s2,s2,650 # a00 <malloc+0x144>
        while(*s != 0){
 77e:	02800593          	li	a1,40
 782:	bff1                	j	75e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 784:	008b0913          	addi	s2,s6,8
 788:	000b4583          	lbu	a1,0(s6)
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	d98080e7          	jalr	-616(ra) # 526 <putc>
 796:	8b4a                	mv	s6,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	bd65                	j	652 <vprintf+0x60>
        putc(fd, c);
 79c:	85d2                	mv	a1,s4
 79e:	8556                	mv	a0,s5
 7a0:	00000097          	auipc	ra,0x0
 7a4:	d86080e7          	jalr	-634(ra) # 526 <putc>
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b565                	j	652 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ac:	8b4e                	mv	s6,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b54d                	j	652 <vprintf+0x60>
    }
  }
}
 7b2:	70e6                	ld	ra,120(sp)
 7b4:	7446                	ld	s0,112(sp)
 7b6:	74a6                	ld	s1,104(sp)
 7b8:	7906                	ld	s2,96(sp)
 7ba:	69e6                	ld	s3,88(sp)
 7bc:	6a46                	ld	s4,80(sp)
 7be:	6aa6                	ld	s5,72(sp)
 7c0:	6b06                	ld	s6,64(sp)
 7c2:	7be2                	ld	s7,56(sp)
 7c4:	7c42                	ld	s8,48(sp)
 7c6:	7ca2                	ld	s9,40(sp)
 7c8:	7d02                	ld	s10,32(sp)
 7ca:	6de2                	ld	s11,24(sp)
 7cc:	6109                	addi	sp,sp,128
 7ce:	8082                	ret

00000000000007d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d0:	715d                	addi	sp,sp,-80
 7d2:	ec06                	sd	ra,24(sp)
 7d4:	e822                	sd	s0,16(sp)
 7d6:	1000                	addi	s0,sp,32
 7d8:	e010                	sd	a2,0(s0)
 7da:	e414                	sd	a3,8(s0)
 7dc:	e818                	sd	a4,16(s0)
 7de:	ec1c                	sd	a5,24(s0)
 7e0:	03043023          	sd	a6,32(s0)
 7e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ec:	8622                	mv	a2,s0
 7ee:	00000097          	auipc	ra,0x0
 7f2:	e04080e7          	jalr	-508(ra) # 5f2 <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6161                	addi	sp,sp,80
 7fc:	8082                	ret

00000000000007fe <printf>:

void
printf(const char *fmt, ...)
{
 7fe:	711d                	addi	sp,sp,-96
 800:	ec06                	sd	ra,24(sp)
 802:	e822                	sd	s0,16(sp)
 804:	1000                	addi	s0,sp,32
 806:	e40c                	sd	a1,8(s0)
 808:	e810                	sd	a2,16(s0)
 80a:	ec14                	sd	a3,24(s0)
 80c:	f018                	sd	a4,32(s0)
 80e:	f41c                	sd	a5,40(s0)
 810:	03043823          	sd	a6,48(s0)
 814:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 818:	00840613          	addi	a2,s0,8
 81c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 820:	85aa                	mv	a1,a0
 822:	4505                	li	a0,1
 824:	00000097          	auipc	ra,0x0
 828:	dce080e7          	jalr	-562(ra) # 5f2 <vprintf>
}
 82c:	60e2                	ld	ra,24(sp)
 82e:	6442                	ld	s0,16(sp)
 830:	6125                	addi	sp,sp,96
 832:	8082                	ret

0000000000000834 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	00000797          	auipc	a5,0x0
 842:	1e27b783          	ld	a5,482(a5) # a20 <freep>
 846:	a805                	j	876 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 848:	4618                	lw	a4,8(a2)
 84a:	9db9                	addw	a1,a1,a4
 84c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	6398                	ld	a4,0(a5)
 852:	6318                	ld	a4,0(a4)
 854:	fee53823          	sd	a4,-16(a0)
 858:	a091                	j	89c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85a:	ff852703          	lw	a4,-8(a0)
 85e:	9e39                	addw	a2,a2,a4
 860:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 862:	ff053703          	ld	a4,-16(a0)
 866:	e398                	sd	a4,0(a5)
 868:	a099                	j	8ae <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	6398                	ld	a4,0(a5)
 86c:	00e7e463          	bltu	a5,a4,874 <free+0x40>
 870:	00e6ea63          	bltu	a3,a4,884 <free+0x50>
{
 874:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 876:	fed7fae3          	bgeu	a5,a3,86a <free+0x36>
 87a:	6398                	ld	a4,0(a5)
 87c:	00e6e463          	bltu	a3,a4,884 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 880:	fee7eae3          	bltu	a5,a4,874 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 884:	ff852583          	lw	a1,-8(a0)
 888:	6390                	ld	a2,0(a5)
 88a:	02059813          	slli	a6,a1,0x20
 88e:	01c85713          	srli	a4,a6,0x1c
 892:	9736                	add	a4,a4,a3
 894:	fae60ae3          	beq	a2,a4,848 <free+0x14>
    bp->s.ptr = p->s.ptr;
 898:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89c:	4790                	lw	a2,8(a5)
 89e:	02061593          	slli	a1,a2,0x20
 8a2:	01c5d713          	srli	a4,a1,0x1c
 8a6:	973e                	add	a4,a4,a5
 8a8:	fae689e3          	beq	a3,a4,85a <free+0x26>
  } else
    p->s.ptr = bp;
 8ac:	e394                	sd	a3,0(a5)
  freep = p;
 8ae:	00000717          	auipc	a4,0x0
 8b2:	16f73923          	sd	a5,370(a4) # a20 <freep>
}
 8b6:	6422                	ld	s0,8(sp)
 8b8:	0141                	addi	sp,sp,16
 8ba:	8082                	ret

00000000000008bc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8bc:	7139                	addi	sp,sp,-64
 8be:	fc06                	sd	ra,56(sp)
 8c0:	f822                	sd	s0,48(sp)
 8c2:	f426                	sd	s1,40(sp)
 8c4:	f04a                	sd	s2,32(sp)
 8c6:	ec4e                	sd	s3,24(sp)
 8c8:	e852                	sd	s4,16(sp)
 8ca:	e456                	sd	s5,8(sp)
 8cc:	e05a                	sd	s6,0(sp)
 8ce:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d0:	02051493          	slli	s1,a0,0x20
 8d4:	9081                	srli	s1,s1,0x20
 8d6:	04bd                	addi	s1,s1,15
 8d8:	8091                	srli	s1,s1,0x4
 8da:	0014899b          	addiw	s3,s1,1
 8de:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e0:	00000517          	auipc	a0,0x0
 8e4:	14053503          	ld	a0,320(a0) # a20 <freep>
 8e8:	c515                	beqz	a0,914 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ec:	4798                	lw	a4,8(a5)
 8ee:	02977f63          	bgeu	a4,s1,92c <malloc+0x70>
 8f2:	8a4e                	mv	s4,s3
 8f4:	0009871b          	sext.w	a4,s3
 8f8:	6685                	lui	a3,0x1
 8fa:	00d77363          	bgeu	a4,a3,900 <malloc+0x44>
 8fe:	6a05                	lui	s4,0x1
 900:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 904:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 908:	00000917          	auipc	s2,0x0
 90c:	11890913          	addi	s2,s2,280 # a20 <freep>
  if(p == (char*)-1)
 910:	5afd                	li	s5,-1
 912:	a895                	j	986 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 914:	00000797          	auipc	a5,0x0
 918:	11478793          	addi	a5,a5,276 # a28 <base>
 91c:	00000717          	auipc	a4,0x0
 920:	10f73223          	sd	a5,260(a4) # a20 <freep>
 924:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 926:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92a:	b7e1                	j	8f2 <malloc+0x36>
      if(p->s.size == nunits)
 92c:	02e48c63          	beq	s1,a4,964 <malloc+0xa8>
        p->s.size -= nunits;
 930:	4137073b          	subw	a4,a4,s3
 934:	c798                	sw	a4,8(a5)
        p += p->s.size;
 936:	02071693          	slli	a3,a4,0x20
 93a:	01c6d713          	srli	a4,a3,0x1c
 93e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 940:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 944:	00000717          	auipc	a4,0x0
 948:	0ca73e23          	sd	a0,220(a4) # a20 <freep>
      return (void*)(p + 1);
 94c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 950:	70e2                	ld	ra,56(sp)
 952:	7442                	ld	s0,48(sp)
 954:	74a2                	ld	s1,40(sp)
 956:	7902                	ld	s2,32(sp)
 958:	69e2                	ld	s3,24(sp)
 95a:	6a42                	ld	s4,16(sp)
 95c:	6aa2                	ld	s5,8(sp)
 95e:	6b02                	ld	s6,0(sp)
 960:	6121                	addi	sp,sp,64
 962:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 964:	6398                	ld	a4,0(a5)
 966:	e118                	sd	a4,0(a0)
 968:	bff1                	j	944 <malloc+0x88>
  hp->s.size = nu;
 96a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 96e:	0541                	addi	a0,a0,16
 970:	00000097          	auipc	ra,0x0
 974:	ec4080e7          	jalr	-316(ra) # 834 <free>
  return freep;
 978:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 97c:	d971                	beqz	a0,950 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 97e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 980:	4798                	lw	a4,8(a5)
 982:	fa9775e3          	bgeu	a4,s1,92c <malloc+0x70>
    if(p == freep)
 986:	00093703          	ld	a4,0(s2)
 98a:	853e                	mv	a0,a5
 98c:	fef719e3          	bne	a4,a5,97e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 990:	8552                	mv	a0,s4
 992:	00000097          	auipc	ra,0x0
 996:	b5c080e7          	jalr	-1188(ra) # 4ee <sbrk>
  if(p == (char*)-1)
 99a:	fd5518e3          	bne	a0,s5,96a <malloc+0xae>
        return 0;
 99e:	4501                	li	a0,0
 9a0:	bf45                	j	950 <malloc+0x94>
