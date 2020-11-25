
user/_nsh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
#define MAXARGS 10
#define MAXWORD 30
#define MAXLINE 100
 
int getcmd(char *buf, int nbuf)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
    fprintf(2, "@ ");
  10:	00001597          	auipc	a1,0x1
  14:	ab858593          	addi	a1,a1,-1352 # ac8 <malloc+0xec>
  18:	4509                	li	a0,2
  1a:	00001097          	auipc	ra,0x1
  1e:	8d6080e7          	jalr	-1834(ra) # 8f0 <fprintf>
    memset(buf, 0, nbuf);
  22:	864a                	mv	a2,s2
  24:	4581                	li	a1,0
  26:	8526                	mv	a0,s1
  28:	00000097          	auipc	ra,0x0
  2c:	3e2080e7          	jalr	994(ra) # 40a <memset>
    gets(buf, nbuf);
  30:	85ca                	mv	a1,s2
  32:	8526                	mv	a0,s1
  34:	00000097          	auipc	ra,0x0
  38:	41c080e7          	jalr	1052(ra) # 450 <gets>
    if (buf[0] == 0) // EOF
  3c:	0004c503          	lbu	a0,0(s1)
  40:	00153513          	seqz	a0,a0
        return -1;
    return 0;
}
  44:	40a00533          	neg	a0,a0
  48:	60e2                	ld	ra,24(sp)
  4a:	6442                	ld	s0,16(sp)
  4c:	64a2                	ld	s1,8(sp)
  4e:	6902                	ld	s2,0(sp)
  50:	6105                	addi	sp,sp,32
  52:	8082                	ret

0000000000000054 <setargs>:
char whitespace[] = " \t\r\n\v";
char args[MAXARGS][MAXWORD];
 
//引用自sh.c
void setargs(char *cmd, char* argv[],int* argc)
{
  54:	7119                	addi	sp,sp,-128
  56:	fc86                	sd	ra,120(sp)
  58:	f8a2                	sd	s0,112(sp)
  5a:	f4a6                	sd	s1,104(sp)
  5c:	f0ca                	sd	s2,96(sp)
  5e:	ecce                	sd	s3,88(sp)
  60:	e8d2                	sd	s4,80(sp)
  62:	e4d6                	sd	s5,72(sp)
  64:	e0da                	sd	s6,64(sp)
  66:	fc5e                	sd	s7,56(sp)
  68:	f862                	sd	s8,48(sp)
  6a:	f466                	sd	s9,40(sp)
  6c:	f06a                	sd	s10,32(sp)
  6e:	ec6e                	sd	s11,24(sp)
  70:	0100                	addi	s0,sp,128
  72:	8baa                	mv	s7,a0
  74:	8dae                	mv	s11,a1
  76:	f8c43423          	sd	a2,-120(s0)
    // 让argv的每一个元素都指向args的每一行
    for(int i=0;i<MAXARGS;i++){
  7a:	00001797          	auipc	a5,0x1
  7e:	a9e78793          	addi	a5,a5,-1378 # b18 <args>
  82:	8c2e                	mv	s8,a1
  84:	00001697          	auipc	a3,0x1
  88:	bc068693          	addi	a3,a3,-1088 # c44 <args+0x12c>
{
  8c:	872e                	mv	a4,a1
        argv[i]=&args[i][0];
  8e:	e31c                	sd	a5,0(a4)
    for(int i=0;i<MAXARGS;i++){
  90:	07f9                	addi	a5,a5,30
  92:	0721                	addi	a4,a4,8
  94:	fed79de3          	bne	a5,a3,8e <setargs+0x3a>
    }
    int i = 0; // 表示第i个word
    // int k = 0; // 表示word中第k个char
    int j = 0;
    for (; cmd[j] != '\n' && cmd[j] != '\0'; j++)
  98:	000bc783          	lbu	a5,0(s7)
  9c:	4729                	li	a4,10
    int j = 0;
  9e:	4981                	li	s3,0
    int i = 0; // 表示第i个word
  a0:	4c81                	li	s9,0
    {
        // 每一轮循环都是找到输入的命令中的一个word，比如 echo hi ,就是先找到echo，再找到hi
        // 让argv[i]分别指向他们的开头，并且将echo，hi后面的空格设为\0
        // 跳过之前的空格
        while (strchr(whitespace,cmd[j])){
  a2:	00001a17          	auipc	s4,0x1
  a6:	a66a0a13          	addi	s4,s4,-1434 # b08 <whitespace>
    for (; cmd[j] != '\n' && cmd[j] != '\0'; j++)
  aa:	4d29                	li	s10,10
  ac:	06e78463          	beq	a5,a4,114 <setargs+0xc0>
  b0:	c3b5                	beqz	a5,114 <setargs+0xc0>
  b2:	013b87b3          	add	a5,s7,s3
  b6:	893e                	mv	s2,a5
  b8:	40f989bb          	subw	s3,s3,a5
  bc:	012984bb          	addw	s1,s3,s2
  c0:	00048a9b          	sext.w	s5,s1
        while (strchr(whitespace,cmd[j])){
  c4:	8b4a                	mv	s6,s2
  c6:	00094583          	lbu	a1,0(s2)
  ca:	8552                	mv	a0,s4
  cc:	00000097          	auipc	ra,0x0
  d0:	360080e7          	jalr	864(ra) # 42c <strchr>
  d4:	0905                	addi	s2,s2,1
  d6:	f17d                	bnez	a0,bc <setargs+0x68>
            j++;
        }
        argv[i++]=cmd+j;
  d8:	2c85                	addiw	s9,s9,1
  da:	016c3023          	sd	s6,0(s8)
        // 只要不是空格，就j++,找到下一个空格
        while (strchr(whitespace,cmd[j])==0){
  de:	015b84b3          	add	s1,s7,s5
  e2:	8926                	mv	s2,s1
  e4:	409a8abb          	subw	s5,s5,s1
  e8:	012a89bb          	addw	s3,s5,s2
  ec:	84ca                	mv	s1,s2
  ee:	00094583          	lbu	a1,0(s2)
  f2:	8552                	mv	a0,s4
  f4:	00000097          	auipc	ra,0x0
  f8:	338080e7          	jalr	824(ra) # 42c <strchr>
  fc:	0905                	addi	s2,s2,1
  fe:	d56d                	beqz	a0,e8 <setargs+0x94>
            j++;
        }
        cmd[j]='\0';
 100:	00048023          	sb	zero,0(s1)
    for (; cmd[j] != '\n' && cmd[j] != '\0'; j++)
 104:	2985                	addiw	s3,s3,1
 106:	013b87b3          	add	a5,s7,s3
 10a:	0007c783          	lbu	a5,0(a5)
 10e:	0c21                	addi	s8,s8,8
 110:	fba790e3          	bne	a5,s10,b0 <setargs+0x5c>
    }
    argv[i]=0;
 114:	003c9793          	slli	a5,s9,0x3
 118:	9dbe                	add	s11,s11,a5
 11a:	000db023          	sd	zero,0(s11)
    *argc=i;
 11e:	f8843783          	ld	a5,-120(s0)
 122:	0197a023          	sw	s9,0(a5)
}
 126:	70e6                	ld	ra,120(sp)
 128:	7446                	ld	s0,112(sp)
 12a:	74a6                	ld	s1,104(sp)
 12c:	7906                	ld	s2,96(sp)
 12e:	69e6                	ld	s3,88(sp)
 130:	6a46                	ld	s4,80(sp)
 132:	6aa6                	ld	s5,72(sp)
 134:	6b06                	ld	s6,64(sp)
 136:	7be2                	ld	s7,56(sp)
 138:	7c42                	ld	s8,48(sp)
 13a:	7ca2                	ld	s9,40(sp)
 13c:	7d02                	ld	s10,32(sp)
 13e:	6de2                	ld	s11,24(sp)
 140:	6109                	addi	sp,sp,128
 142:	8082                	ret

0000000000000144 <execPipe>:
        }
    }
    exec(argv[0], argv);
}
 
void execPipe(char*argv[],int argc){
 144:	715d                	addi	sp,sp,-80
 146:	e486                	sd	ra,72(sp)
 148:	e0a2                	sd	s0,64(sp)
 14a:	fc26                	sd	s1,56(sp)
 14c:	f84a                	sd	s2,48(sp)
 14e:	f44e                	sd	s3,40(sp)
 150:	f052                	sd	s4,32(sp)
 152:	ec56                	sd	s5,24(sp)
 154:	e85a                	sd	s6,16(sp)
 156:	0880                	addi	s0,sp,80
 158:	8b2a                	mv	s6,a0
 15a:	89ae                	mv	s3,a1
    int i=0;
    // 首先找到命令中的"|",然后把他换成'\0'
    // 从前到后，找到第一个就停止，后面都递归调用
    for(;i<argc;i++){
 15c:	08b05863          	blez	a1,1ec <execPipe+0xa8>
 160:	84aa                	mv	s1,a0
    int i=0;
 162:	4901                	li	s2,0
        if(!strcmp(argv[i],"|")){
 164:	00001a17          	auipc	s4,0x1
 168:	96ca0a13          	addi	s4,s4,-1684 # ad0 <malloc+0xf4>
 16c:	85d2                	mv	a1,s4
 16e:	6088                	ld	a0,0(s1)
 170:	00000097          	auipc	ra,0x0
 174:	244080e7          	jalr	580(ra) # 3b4 <strcmp>
 178:	c511                	beqz	a0,184 <execPipe+0x40>
    for(;i<argc;i++){
 17a:	2905                	addiw	s2,s2,1
 17c:	04a1                	addi	s1,s1,8
 17e:	ff2997e3          	bne	s3,s2,16c <execPipe+0x28>
 182:	a019                	j	188 <execPipe+0x44>
            argv[i]=0;
 184:	0004b023          	sd	zero,0(s1)
            break;
        }
    }
    // 管道
    int fd[2];
    pipe(fd);
 188:	fb840513          	addi	a0,s0,-72
 18c:	00000097          	auipc	ra,0x0
 190:	40a080e7          	jalr	1034(ra) # 596 <pipe>
    if(fork()==0){
 194:	00000097          	auipc	ra,0x0
 198:	3ea080e7          	jalr	1002(ra) # 57e <fork>
 19c:	e931                	bnez	a0,1f0 <execPipe+0xac>
        // 子进程 执行左边的命令 把自己的标准输出关闭,将左侧文件作为标准输出(利用重定向)
        close(1);
 19e:	4505                	li	a0,1
 1a0:	00000097          	auipc	ra,0x0
 1a4:	40e080e7          	jalr	1038(ra) # 5ae <close>
        dup(fd[1]);
 1a8:	fbc42503          	lw	a0,-68(s0)
 1ac:	00000097          	auipc	ra,0x0
 1b0:	452080e7          	jalr	1106(ra) # 5fe <dup>
        close(fd[0]);
 1b4:	fb842503          	lw	a0,-72(s0)
 1b8:	00000097          	auipc	ra,0x0
 1bc:	3f6080e7          	jalr	1014(ra) # 5ae <close>
        close(fd[1]);
 1c0:	fbc42503          	lw	a0,-68(s0)
 1c4:	00000097          	auipc	ra,0x0
 1c8:	3ea080e7          	jalr	1002(ra) # 5ae <close>
        runcmd(argv,i);
 1cc:	85ca                	mv	a1,s2
 1ce:	855a                	mv	a0,s6
 1d0:	00000097          	auipc	ra,0x0
 1d4:	066080e7          	jalr	102(ra) # 236 <runcmd>
        dup(fd[0]);
        close(fd[0]);
        close(fd[1]);
        runcmd(argv+i+1,argc-i-1);
    }
}
 1d8:	60a6                	ld	ra,72(sp)
 1da:	6406                	ld	s0,64(sp)
 1dc:	74e2                	ld	s1,56(sp)
 1de:	7942                	ld	s2,48(sp)
 1e0:	79a2                	ld	s3,40(sp)
 1e2:	7a02                	ld	s4,32(sp)
 1e4:	6ae2                	ld	s5,24(sp)
 1e6:	6b42                	ld	s6,16(sp)
 1e8:	6161                	addi	sp,sp,80
 1ea:	8082                	ret
    int i=0;
 1ec:	4901                	li	s2,0
 1ee:	bf69                	j	188 <execPipe+0x44>
        close(0);
 1f0:	4501                	li	a0,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	3bc080e7          	jalr	956(ra) # 5ae <close>
        dup(fd[0]);
 1fa:	fb842503          	lw	a0,-72(s0)
 1fe:	00000097          	auipc	ra,0x0
 202:	400080e7          	jalr	1024(ra) # 5fe <dup>
        close(fd[0]);
 206:	fb842503          	lw	a0,-72(s0)
 20a:	00000097          	auipc	ra,0x0
 20e:	3a4080e7          	jalr	932(ra) # 5ae <close>
        close(fd[1]);
 212:	fbc42503          	lw	a0,-68(s0)
 216:	00000097          	auipc	ra,0x0
 21a:	398080e7          	jalr	920(ra) # 5ae <close>
        runcmd(argv+i+1,argc-i-1);
 21e:	412985bb          	subw	a1,s3,s2
 222:	0905                	addi	s2,s2,1
 224:	090e                	slli	s2,s2,0x3
 226:	35fd                	addiw	a1,a1,-1
 228:	012b0533          	add	a0,s6,s2
 22c:	00000097          	auipc	ra,0x0
 230:	00a080e7          	jalr	10(ra) # 236 <runcmd>
}
 234:	b755                	j	1d8 <execPipe+0x94>

0000000000000236 <runcmd>:
{
 236:	7139                	addi	sp,sp,-64
 238:	fc06                	sd	ra,56(sp)
 23a:	f822                	sd	s0,48(sp)
 23c:	f426                	sd	s1,40(sp)
 23e:	f04a                	sd	s2,32(sp)
 240:	ec4e                	sd	s3,24(sp)
 242:	e852                	sd	s4,16(sp)
 244:	e456                	sd	s5,8(sp)
 246:	e05a                	sd	s6,0(sp)
 248:	0080                	addi	s0,sp,64
 24a:	8a2a                	mv	s4,a0
    for(int i=1;i<argc;i++){
 24c:	4785                	li	a5,1
 24e:	0ab7df63          	bge	a5,a1,30c <runcmd+0xd6>
 252:	8b2e                	mv	s6,a1
 254:	00850493          	addi	s1,a0,8
 258:	ffe5899b          	addiw	s3,a1,-2
 25c:	02099793          	slli	a5,s3,0x20
 260:	01d7d993          	srli	s3,a5,0x1d
 264:	01050793          	addi	a5,a0,16
 268:	99be                	add	s3,s3,a5
 26a:	8926                	mv	s2,s1
        if(!strcmp(argv[i],"|")){
 26c:	00001a97          	auipc	s5,0x1
 270:	864a8a93          	addi	s5,s5,-1948 # ad0 <malloc+0xf4>
 274:	a021                	j	27c <runcmd+0x46>
    for(int i=1;i<argc;i++){
 276:	0921                	addi	s2,s2,8
 278:	03390163          	beq	s2,s3,29a <runcmd+0x64>
        if(!strcmp(argv[i],"|")){
 27c:	85d6                	mv	a1,s5
 27e:	00093503          	ld	a0,0(s2)
 282:	00000097          	auipc	ra,0x0
 286:	132080e7          	jalr	306(ra) # 3b4 <strcmp>
 28a:	f575                	bnez	a0,276 <runcmd+0x40>
            execPipe(argv,argc);
 28c:	85da                	mv	a1,s6
 28e:	8552                	mv	a0,s4
 290:	00000097          	auipc	ra,0x0
 294:	eb4080e7          	jalr	-332(ra) # 144 <execPipe>
 298:	bff9                	j	276 <runcmd+0x40>
        if(!strcmp(argv[i],">")){
 29a:	00001b17          	auipc	s6,0x1
 29e:	83eb0b13          	addi	s6,s6,-1986 # ad8 <malloc+0xfc>
        if(!strcmp(argv[i],"<")){
 2a2:	00001a97          	auipc	s5,0x1
 2a6:	83ea8a93          	addi	s5,s5,-1986 # ae0 <malloc+0x104>
 2aa:	a01d                	j	2d0 <runcmd+0x9a>
            close(1);
 2ac:	4505                	li	a0,1
 2ae:	00000097          	auipc	ra,0x0
 2b2:	300080e7          	jalr	768(ra) # 5ae <close>
            open(argv[i+1],O_CREATE|O_WRONLY);
 2b6:	20100593          	li	a1,513
 2ba:	6488                	ld	a0,8(s1)
 2bc:	00000097          	auipc	ra,0x0
 2c0:	30a080e7          	jalr	778(ra) # 5c6 <open>
            argv[i]=0;
 2c4:	0004b023          	sd	zero,0(s1)
 2c8:	a821                	j	2e0 <runcmd+0xaa>
    for(int i=1;i<argc;i++){
 2ca:	04a1                	addi	s1,s1,8
 2cc:	05348063          	beq	s1,s3,30c <runcmd+0xd6>
        if(!strcmp(argv[i],">")){
 2d0:	8926                	mv	s2,s1
 2d2:	85da                	mv	a1,s6
 2d4:	6088                	ld	a0,0(s1)
 2d6:	00000097          	auipc	ra,0x0
 2da:	0de080e7          	jalr	222(ra) # 3b4 <strcmp>
 2de:	d579                	beqz	a0,2ac <runcmd+0x76>
        if(!strcmp(argv[i],"<")){
 2e0:	85d6                	mv	a1,s5
 2e2:	00093503          	ld	a0,0(s2)
 2e6:	00000097          	auipc	ra,0x0
 2ea:	0ce080e7          	jalr	206(ra) # 3b4 <strcmp>
 2ee:	fd71                	bnez	a0,2ca <runcmd+0x94>
            close(0);
 2f0:	00000097          	auipc	ra,0x0
 2f4:	2be080e7          	jalr	702(ra) # 5ae <close>
            open(argv[i+1],O_RDONLY);
 2f8:	4581                	li	a1,0
 2fa:	00893503          	ld	a0,8(s2)
 2fe:	00000097          	auipc	ra,0x0
 302:	2c8080e7          	jalr	712(ra) # 5c6 <open>
            argv[i]=0;
 306:	00093023          	sd	zero,0(s2)
 30a:	b7c1                	j	2ca <runcmd+0x94>
    exec(argv[0], argv);
 30c:	85d2                	mv	a1,s4
 30e:	000a3503          	ld	a0,0(s4)
 312:	00000097          	auipc	ra,0x0
 316:	2ac080e7          	jalr	684(ra) # 5be <exec>
}
 31a:	70e2                	ld	ra,56(sp)
 31c:	7442                	ld	s0,48(sp)
 31e:	74a2                	ld	s1,40(sp)
 320:	7902                	ld	s2,32(sp)
 322:	69e2                	ld	s3,24(sp)
 324:	6a42                	ld	s4,16(sp)
 326:	6aa2                	ld	s5,8(sp)
 328:	6b02                	ld	s6,0(sp)
 32a:	6121                	addi	sp,sp,64
 32c:	8082                	ret

000000000000032e <main>:
int main()
{
 32e:	7115                	addi	sp,sp,-224
 330:	ed86                	sd	ra,216(sp)
 332:	e9a2                	sd	s0,208(sp)
 334:	e5a6                	sd	s1,200(sp)
 336:	1180                	addi	s0,sp,224
    {
 
        if (fork() == 0)
        {
            char* argv[MAXARGS];
            int argc=-1;
 338:	54fd                	li	s1,-1
    while (getcmd(buf, sizeof(buf)) >= 0)
 33a:	a031                	j	346 <main+0x18>
            setargs(buf, argv,&argc);
            runcmd(argv,argc);
        }
        wait(0);
 33c:	4501                	li	a0,0
 33e:	00000097          	auipc	ra,0x0
 342:	250080e7          	jalr	592(ra) # 58e <wait>
    while (getcmd(buf, sizeof(buf)) >= 0)
 346:	06400593          	li	a1,100
 34a:	f7840513          	addi	a0,s0,-136
 34e:	00000097          	auipc	ra,0x0
 352:	cb2080e7          	jalr	-846(ra) # 0 <getcmd>
 356:	02054c63          	bltz	a0,38e <main+0x60>
        if (fork() == 0)
 35a:	00000097          	auipc	ra,0x0
 35e:	224080e7          	jalr	548(ra) # 57e <fork>
 362:	fd69                	bnez	a0,33c <main+0xe>
            int argc=-1;
 364:	f2942223          	sw	s1,-220(s0)
            setargs(buf, argv,&argc);
 368:	f2440613          	addi	a2,s0,-220
 36c:	f2840593          	addi	a1,s0,-216
 370:	f7840513          	addi	a0,s0,-136
 374:	00000097          	auipc	ra,0x0
 378:	ce0080e7          	jalr	-800(ra) # 54 <setargs>
            runcmd(argv,argc);
 37c:	f2442583          	lw	a1,-220(s0)
 380:	f2840513          	addi	a0,s0,-216
 384:	00000097          	auipc	ra,0x0
 388:	eb2080e7          	jalr	-334(ra) # 236 <runcmd>
 38c:	bf45                	j	33c <main+0xe>
    }
 
    exit(0);
 38e:	4501                	li	a0,0
 390:	00000097          	auipc	ra,0x0
 394:	1f6080e7          	jalr	502(ra) # 586 <exit>

0000000000000398 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 39e:	87aa                	mv	a5,a0
 3a0:	0585                	addi	a1,a1,1
 3a2:	0785                	addi	a5,a5,1
 3a4:	fff5c703          	lbu	a4,-1(a1)
 3a8:	fee78fa3          	sb	a4,-1(a5)
 3ac:	fb75                	bnez	a4,3a0 <strcpy+0x8>
    ;
  return os;
}
 3ae:	6422                	ld	s0,8(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 3ba:	00054783          	lbu	a5,0(a0)
 3be:	cb91                	beqz	a5,3d2 <strcmp+0x1e>
 3c0:	0005c703          	lbu	a4,0(a1)
 3c4:	00f71763          	bne	a4,a5,3d2 <strcmp+0x1e>
    p++, q++;
 3c8:	0505                	addi	a0,a0,1
 3ca:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	fbe5                	bnez	a5,3c0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3d2:	0005c503          	lbu	a0,0(a1)
}
 3d6:	40a7853b          	subw	a0,a5,a0
 3da:	6422                	ld	s0,8(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <strlen>:

uint
strlen(const char *s)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3e6:	00054783          	lbu	a5,0(a0)
 3ea:	cf91                	beqz	a5,406 <strlen+0x26>
 3ec:	0505                	addi	a0,a0,1
 3ee:	87aa                	mv	a5,a0
 3f0:	4685                	li	a3,1
 3f2:	9e89                	subw	a3,a3,a0
 3f4:	00f6853b          	addw	a0,a3,a5
 3f8:	0785                	addi	a5,a5,1
 3fa:	fff7c703          	lbu	a4,-1(a5)
 3fe:	fb7d                	bnez	a4,3f4 <strlen+0x14>
    ;
  return n;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret
  for(n = 0; s[n]; n++)
 406:	4501                	li	a0,0
 408:	bfe5                	j	400 <strlen+0x20>

000000000000040a <memset>:

void*
memset(void *dst, int c, uint n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 410:	ca19                	beqz	a2,426 <memset+0x1c>
 412:	87aa                	mv	a5,a0
 414:	1602                	slli	a2,a2,0x20
 416:	9201                	srli	a2,a2,0x20
 418:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 41c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 420:	0785                	addi	a5,a5,1
 422:	fee79de3          	bne	a5,a4,41c <memset+0x12>
  }
  return dst;
}
 426:	6422                	ld	s0,8(sp)
 428:	0141                	addi	sp,sp,16
 42a:	8082                	ret

000000000000042c <strchr>:

char*
strchr(const char *s, char c)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e422                	sd	s0,8(sp)
 430:	0800                	addi	s0,sp,16
  for(; *s; s++)
 432:	00054783          	lbu	a5,0(a0)
 436:	cb99                	beqz	a5,44c <strchr+0x20>
    if(*s == c)
 438:	00f58763          	beq	a1,a5,446 <strchr+0x1a>
  for(; *s; s++)
 43c:	0505                	addi	a0,a0,1
 43e:	00054783          	lbu	a5,0(a0)
 442:	fbfd                	bnez	a5,438 <strchr+0xc>
      return (char*)s;
  return 0;
 444:	4501                	li	a0,0
}
 446:	6422                	ld	s0,8(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret
  return 0;
 44c:	4501                	li	a0,0
 44e:	bfe5                	j	446 <strchr+0x1a>

0000000000000450 <gets>:

char*
gets(char *buf, int max)
{
 450:	711d                	addi	sp,sp,-96
 452:	ec86                	sd	ra,88(sp)
 454:	e8a2                	sd	s0,80(sp)
 456:	e4a6                	sd	s1,72(sp)
 458:	e0ca                	sd	s2,64(sp)
 45a:	fc4e                	sd	s3,56(sp)
 45c:	f852                	sd	s4,48(sp)
 45e:	f456                	sd	s5,40(sp)
 460:	f05a                	sd	s6,32(sp)
 462:	ec5e                	sd	s7,24(sp)
 464:	1080                	addi	s0,sp,96
 466:	8baa                	mv	s7,a0
 468:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 46a:	892a                	mv	s2,a0
 46c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 46e:	4aa9                	li	s5,10
 470:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 472:	89a6                	mv	s3,s1
 474:	2485                	addiw	s1,s1,1
 476:	0344d863          	bge	s1,s4,4a6 <gets+0x56>
    cc = read(0, &c, 1);
 47a:	4605                	li	a2,1
 47c:	faf40593          	addi	a1,s0,-81
 480:	4501                	li	a0,0
 482:	00000097          	auipc	ra,0x0
 486:	11c080e7          	jalr	284(ra) # 59e <read>
    if(cc < 1)
 48a:	00a05e63          	blez	a0,4a6 <gets+0x56>
    buf[i++] = c;
 48e:	faf44783          	lbu	a5,-81(s0)
 492:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 496:	01578763          	beq	a5,s5,4a4 <gets+0x54>
 49a:	0905                	addi	s2,s2,1
 49c:	fd679be3          	bne	a5,s6,472 <gets+0x22>
  for(i=0; i+1 < max; ){
 4a0:	89a6                	mv	s3,s1
 4a2:	a011                	j	4a6 <gets+0x56>
 4a4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 4a6:	99de                	add	s3,s3,s7
 4a8:	00098023          	sb	zero,0(s3)
  return buf;
}
 4ac:	855e                	mv	a0,s7
 4ae:	60e6                	ld	ra,88(sp)
 4b0:	6446                	ld	s0,80(sp)
 4b2:	64a6                	ld	s1,72(sp)
 4b4:	6906                	ld	s2,64(sp)
 4b6:	79e2                	ld	s3,56(sp)
 4b8:	7a42                	ld	s4,48(sp)
 4ba:	7aa2                	ld	s5,40(sp)
 4bc:	7b02                	ld	s6,32(sp)
 4be:	6be2                	ld	s7,24(sp)
 4c0:	6125                	addi	sp,sp,96
 4c2:	8082                	ret

00000000000004c4 <stat>:

int
stat(const char *n, struct stat *st)
{
 4c4:	1101                	addi	sp,sp,-32
 4c6:	ec06                	sd	ra,24(sp)
 4c8:	e822                	sd	s0,16(sp)
 4ca:	e426                	sd	s1,8(sp)
 4cc:	e04a                	sd	s2,0(sp)
 4ce:	1000                	addi	s0,sp,32
 4d0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4d2:	4581                	li	a1,0
 4d4:	00000097          	auipc	ra,0x0
 4d8:	0f2080e7          	jalr	242(ra) # 5c6 <open>
  if(fd < 0)
 4dc:	02054563          	bltz	a0,506 <stat+0x42>
 4e0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4e2:	85ca                	mv	a1,s2
 4e4:	00000097          	auipc	ra,0x0
 4e8:	0fa080e7          	jalr	250(ra) # 5de <fstat>
 4ec:	892a                	mv	s2,a0
  close(fd);
 4ee:	8526                	mv	a0,s1
 4f0:	00000097          	auipc	ra,0x0
 4f4:	0be080e7          	jalr	190(ra) # 5ae <close>
  return r;
}
 4f8:	854a                	mv	a0,s2
 4fa:	60e2                	ld	ra,24(sp)
 4fc:	6442                	ld	s0,16(sp)
 4fe:	64a2                	ld	s1,8(sp)
 500:	6902                	ld	s2,0(sp)
 502:	6105                	addi	sp,sp,32
 504:	8082                	ret
    return -1;
 506:	597d                	li	s2,-1
 508:	bfc5                	j	4f8 <stat+0x34>

000000000000050a <atoi>:

int
atoi(const char *s)
{
 50a:	1141                	addi	sp,sp,-16
 50c:	e422                	sd	s0,8(sp)
 50e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 510:	00054603          	lbu	a2,0(a0)
 514:	fd06079b          	addiw	a5,a2,-48
 518:	0ff7f793          	andi	a5,a5,255
 51c:	4725                	li	a4,9
 51e:	02f76963          	bltu	a4,a5,550 <atoi+0x46>
 522:	86aa                	mv	a3,a0
  n = 0;
 524:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 526:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 528:	0685                	addi	a3,a3,1
 52a:	0025179b          	slliw	a5,a0,0x2
 52e:	9fa9                	addw	a5,a5,a0
 530:	0017979b          	slliw	a5,a5,0x1
 534:	9fb1                	addw	a5,a5,a2
 536:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 53a:	0006c603          	lbu	a2,0(a3)
 53e:	fd06071b          	addiw	a4,a2,-48
 542:	0ff77713          	andi	a4,a4,255
 546:	fee5f1e3          	bgeu	a1,a4,528 <atoi+0x1e>
  return n;
}
 54a:	6422                	ld	s0,8(sp)
 54c:	0141                	addi	sp,sp,16
 54e:	8082                	ret
  n = 0;
 550:	4501                	li	a0,0
 552:	bfe5                	j	54a <atoi+0x40>

0000000000000554 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 554:	1141                	addi	sp,sp,-16
 556:	e422                	sd	s0,8(sp)
 558:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 55a:	00c05f63          	blez	a2,578 <memmove+0x24>
 55e:	1602                	slli	a2,a2,0x20
 560:	9201                	srli	a2,a2,0x20
 562:	00c506b3          	add	a3,a0,a2
  dst = vdst;
 566:	87aa                	mv	a5,a0
    *dst++ = *src++;
 568:	0585                	addi	a1,a1,1
 56a:	0785                	addi	a5,a5,1
 56c:	fff5c703          	lbu	a4,-1(a1)
 570:	fee78fa3          	sb	a4,-1(a5)
  while(n-- > 0)
 574:	fed79ae3          	bne	a5,a3,568 <memmove+0x14>
  return vdst;
}
 578:	6422                	ld	s0,8(sp)
 57a:	0141                	addi	sp,sp,16
 57c:	8082                	ret

000000000000057e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 57e:	4885                	li	a7,1
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <exit>:
.global exit
exit:
 li a7, SYS_exit
 586:	4889                	li	a7,2
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <wait>:
.global wait
wait:
 li a7, SYS_wait
 58e:	488d                	li	a7,3
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 596:	4891                	li	a7,4
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <read>:
.global read
read:
 li a7, SYS_read
 59e:	4895                	li	a7,5
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <write>:
.global write
write:
 li a7, SYS_write
 5a6:	48c1                	li	a7,16
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <close>:
.global close
close:
 li a7, SYS_close
 5ae:	48d5                	li	a7,21
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5b6:	4899                	li	a7,6
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <exec>:
.global exec
exec:
 li a7, SYS_exec
 5be:	489d                	li	a7,7
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <open>:
.global open
open:
 li a7, SYS_open
 5c6:	48bd                	li	a7,15
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5ce:	48c5                	li	a7,17
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5d6:	48c9                	li	a7,18
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5de:	48a1                	li	a7,8
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <link>:
.global link
link:
 li a7, SYS_link
 5e6:	48cd                	li	a7,19
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ee:	48d1                	li	a7,20
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5f6:	48a5                	li	a7,9
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 5fe:	48a9                	li	a7,10
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 606:	48ad                	li	a7,11
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 60e:	48b1                	li	a7,12
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 616:	48b5                	li	a7,13
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 61e:	48b9                	li	a7,14
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <ntas>:
.global ntas
ntas:
 li a7, SYS_ntas
 626:	48d9                	li	a7,22
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <crash>:
.global crash
crash:
 li a7, SYS_crash
 62e:	48dd                	li	a7,23
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <mount>:
.global mount
mount:
 li a7, SYS_mount
 636:	48e1                	li	a7,24
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <umount>:
.global umount
umount:
 li a7, SYS_umount
 63e:	48e5                	li	a7,25
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 646:	1101                	addi	sp,sp,-32
 648:	ec06                	sd	ra,24(sp)
 64a:	e822                	sd	s0,16(sp)
 64c:	1000                	addi	s0,sp,32
 64e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 652:	4605                	li	a2,1
 654:	fef40593          	addi	a1,s0,-17
 658:	00000097          	auipc	ra,0x0
 65c:	f4e080e7          	jalr	-178(ra) # 5a6 <write>
}
 660:	60e2                	ld	ra,24(sp)
 662:	6442                	ld	s0,16(sp)
 664:	6105                	addi	sp,sp,32
 666:	8082                	ret

0000000000000668 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 668:	7139                	addi	sp,sp,-64
 66a:	fc06                	sd	ra,56(sp)
 66c:	f822                	sd	s0,48(sp)
 66e:	f426                	sd	s1,40(sp)
 670:	f04a                	sd	s2,32(sp)
 672:	ec4e                	sd	s3,24(sp)
 674:	0080                	addi	s0,sp,64
 676:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 678:	c299                	beqz	a3,67e <printint+0x16>
 67a:	0805c863          	bltz	a1,70a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 67e:	2581                	sext.w	a1,a1
  neg = 0;
 680:	4881                	li	a7,0
 682:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 686:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 688:	2601                	sext.w	a2,a2
 68a:	00000517          	auipc	a0,0x0
 68e:	46650513          	addi	a0,a0,1126 # af0 <digits>
 692:	883a                	mv	a6,a4
 694:	2705                	addiw	a4,a4,1
 696:	02c5f7bb          	remuw	a5,a1,a2
 69a:	1782                	slli	a5,a5,0x20
 69c:	9381                	srli	a5,a5,0x20
 69e:	97aa                	add	a5,a5,a0
 6a0:	0007c783          	lbu	a5,0(a5)
 6a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6a8:	0005879b          	sext.w	a5,a1
 6ac:	02c5d5bb          	divuw	a1,a1,a2
 6b0:	0685                	addi	a3,a3,1
 6b2:	fec7f0e3          	bgeu	a5,a2,692 <printint+0x2a>
  if(neg)
 6b6:	00088b63          	beqz	a7,6cc <printint+0x64>
    buf[i++] = '-';
 6ba:	fd040793          	addi	a5,s0,-48
 6be:	973e                	add	a4,a4,a5
 6c0:	02d00793          	li	a5,45
 6c4:	fef70823          	sb	a5,-16(a4)
 6c8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6cc:	02e05863          	blez	a4,6fc <printint+0x94>
 6d0:	fc040793          	addi	a5,s0,-64
 6d4:	00e78933          	add	s2,a5,a4
 6d8:	fff78993          	addi	s3,a5,-1
 6dc:	99ba                	add	s3,s3,a4
 6de:	377d                	addiw	a4,a4,-1
 6e0:	1702                	slli	a4,a4,0x20
 6e2:	9301                	srli	a4,a4,0x20
 6e4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6e8:	fff94583          	lbu	a1,-1(s2)
 6ec:	8526                	mv	a0,s1
 6ee:	00000097          	auipc	ra,0x0
 6f2:	f58080e7          	jalr	-168(ra) # 646 <putc>
  while(--i >= 0)
 6f6:	197d                	addi	s2,s2,-1
 6f8:	ff3918e3          	bne	s2,s3,6e8 <printint+0x80>
}
 6fc:	70e2                	ld	ra,56(sp)
 6fe:	7442                	ld	s0,48(sp)
 700:	74a2                	ld	s1,40(sp)
 702:	7902                	ld	s2,32(sp)
 704:	69e2                	ld	s3,24(sp)
 706:	6121                	addi	sp,sp,64
 708:	8082                	ret
    x = -xx;
 70a:	40b005bb          	negw	a1,a1
    neg = 1;
 70e:	4885                	li	a7,1
    x = -xx;
 710:	bf8d                	j	682 <printint+0x1a>

0000000000000712 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 712:	7119                	addi	sp,sp,-128
 714:	fc86                	sd	ra,120(sp)
 716:	f8a2                	sd	s0,112(sp)
 718:	f4a6                	sd	s1,104(sp)
 71a:	f0ca                	sd	s2,96(sp)
 71c:	ecce                	sd	s3,88(sp)
 71e:	e8d2                	sd	s4,80(sp)
 720:	e4d6                	sd	s5,72(sp)
 722:	e0da                	sd	s6,64(sp)
 724:	fc5e                	sd	s7,56(sp)
 726:	f862                	sd	s8,48(sp)
 728:	f466                	sd	s9,40(sp)
 72a:	f06a                	sd	s10,32(sp)
 72c:	ec6e                	sd	s11,24(sp)
 72e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 730:	0005c903          	lbu	s2,0(a1)
 734:	18090f63          	beqz	s2,8d2 <vprintf+0x1c0>
 738:	8aaa                	mv	s5,a0
 73a:	8b32                	mv	s6,a2
 73c:	00158493          	addi	s1,a1,1
  state = 0;
 740:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 742:	02500a13          	li	s4,37
      if(c == 'd'){
 746:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 74a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 74e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 752:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 756:	00000b97          	auipc	s7,0x0
 75a:	39ab8b93          	addi	s7,s7,922 # af0 <digits>
 75e:	a839                	j	77c <vprintf+0x6a>
        putc(fd, c);
 760:	85ca                	mv	a1,s2
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	ee2080e7          	jalr	-286(ra) # 646 <putc>
 76c:	a019                	j	772 <vprintf+0x60>
    } else if(state == '%'){
 76e:	01498f63          	beq	s3,s4,78c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 772:	0485                	addi	s1,s1,1
 774:	fff4c903          	lbu	s2,-1(s1)
 778:	14090d63          	beqz	s2,8d2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 77c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 780:	fe0997e3          	bnez	s3,76e <vprintf+0x5c>
      if(c == '%'){
 784:	fd479ee3          	bne	a5,s4,760 <vprintf+0x4e>
        state = '%';
 788:	89be                	mv	s3,a5
 78a:	b7e5                	j	772 <vprintf+0x60>
      if(c == 'd'){
 78c:	05878063          	beq	a5,s8,7cc <vprintf+0xba>
      } else if(c == 'l') {
 790:	05978c63          	beq	a5,s9,7e8 <vprintf+0xd6>
      } else if(c == 'x') {
 794:	07a78863          	beq	a5,s10,804 <vprintf+0xf2>
      } else if(c == 'p') {
 798:	09b78463          	beq	a5,s11,820 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 79c:	07300713          	li	a4,115
 7a0:	0ce78663          	beq	a5,a4,86c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7a4:	06300713          	li	a4,99
 7a8:	0ee78e63          	beq	a5,a4,8a4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7ac:	11478863          	beq	a5,s4,8bc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7b0:	85d2                	mv	a1,s4
 7b2:	8556                	mv	a0,s5
 7b4:	00000097          	auipc	ra,0x0
 7b8:	e92080e7          	jalr	-366(ra) # 646 <putc>
        putc(fd, c);
 7bc:	85ca                	mv	a1,s2
 7be:	8556                	mv	a0,s5
 7c0:	00000097          	auipc	ra,0x0
 7c4:	e86080e7          	jalr	-378(ra) # 646 <putc>
      }
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	b765                	j	772 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7cc:	008b0913          	addi	s2,s6,8
 7d0:	4685                	li	a3,1
 7d2:	4629                	li	a2,10
 7d4:	000b2583          	lw	a1,0(s6)
 7d8:	8556                	mv	a0,s5
 7da:	00000097          	auipc	ra,0x0
 7de:	e8e080e7          	jalr	-370(ra) # 668 <printint>
 7e2:	8b4a                	mv	s6,s2
      state = 0;
 7e4:	4981                	li	s3,0
 7e6:	b771                	j	772 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e8:	008b0913          	addi	s2,s6,8
 7ec:	4681                	li	a3,0
 7ee:	4629                	li	a2,10
 7f0:	000b2583          	lw	a1,0(s6)
 7f4:	8556                	mv	a0,s5
 7f6:	00000097          	auipc	ra,0x0
 7fa:	e72080e7          	jalr	-398(ra) # 668 <printint>
 7fe:	8b4a                	mv	s6,s2
      state = 0;
 800:	4981                	li	s3,0
 802:	bf85                	j	772 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 804:	008b0913          	addi	s2,s6,8
 808:	4681                	li	a3,0
 80a:	4641                	li	a2,16
 80c:	000b2583          	lw	a1,0(s6)
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	e56080e7          	jalr	-426(ra) # 668 <printint>
 81a:	8b4a                	mv	s6,s2
      state = 0;
 81c:	4981                	li	s3,0
 81e:	bf91                	j	772 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 820:	008b0793          	addi	a5,s6,8
 824:	f8f43423          	sd	a5,-120(s0)
 828:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 82c:	03000593          	li	a1,48
 830:	8556                	mv	a0,s5
 832:	00000097          	auipc	ra,0x0
 836:	e14080e7          	jalr	-492(ra) # 646 <putc>
  putc(fd, 'x');
 83a:	85ea                	mv	a1,s10
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	e08080e7          	jalr	-504(ra) # 646 <putc>
 846:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 848:	03c9d793          	srli	a5,s3,0x3c
 84c:	97de                	add	a5,a5,s7
 84e:	0007c583          	lbu	a1,0(a5)
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	df2080e7          	jalr	-526(ra) # 646 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 85c:	0992                	slli	s3,s3,0x4
 85e:	397d                	addiw	s2,s2,-1
 860:	fe0914e3          	bnez	s2,848 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 864:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 868:	4981                	li	s3,0
 86a:	b721                	j	772 <vprintf+0x60>
        s = va_arg(ap, char*);
 86c:	008b0993          	addi	s3,s6,8
 870:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 874:	02090163          	beqz	s2,896 <vprintf+0x184>
        while(*s != 0){
 878:	00094583          	lbu	a1,0(s2)
 87c:	c9a1                	beqz	a1,8cc <vprintf+0x1ba>
          putc(fd, *s);
 87e:	8556                	mv	a0,s5
 880:	00000097          	auipc	ra,0x0
 884:	dc6080e7          	jalr	-570(ra) # 646 <putc>
          s++;
 888:	0905                	addi	s2,s2,1
        while(*s != 0){
 88a:	00094583          	lbu	a1,0(s2)
 88e:	f9e5                	bnez	a1,87e <vprintf+0x16c>
        s = va_arg(ap, char*);
 890:	8b4e                	mv	s6,s3
      state = 0;
 892:	4981                	li	s3,0
 894:	bdf9                	j	772 <vprintf+0x60>
          s = "(null)";
 896:	00000917          	auipc	s2,0x0
 89a:	25290913          	addi	s2,s2,594 # ae8 <malloc+0x10c>
        while(*s != 0){
 89e:	02800593          	li	a1,40
 8a2:	bff1                	j	87e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8a4:	008b0913          	addi	s2,s6,8
 8a8:	000b4583          	lbu	a1,0(s6)
 8ac:	8556                	mv	a0,s5
 8ae:	00000097          	auipc	ra,0x0
 8b2:	d98080e7          	jalr	-616(ra) # 646 <putc>
 8b6:	8b4a                	mv	s6,s2
      state = 0;
 8b8:	4981                	li	s3,0
 8ba:	bd65                	j	772 <vprintf+0x60>
        putc(fd, c);
 8bc:	85d2                	mv	a1,s4
 8be:	8556                	mv	a0,s5
 8c0:	00000097          	auipc	ra,0x0
 8c4:	d86080e7          	jalr	-634(ra) # 646 <putc>
      state = 0;
 8c8:	4981                	li	s3,0
 8ca:	b565                	j	772 <vprintf+0x60>
        s = va_arg(ap, char*);
 8cc:	8b4e                	mv	s6,s3
      state = 0;
 8ce:	4981                	li	s3,0
 8d0:	b54d                	j	772 <vprintf+0x60>
    }
  }
}
 8d2:	70e6                	ld	ra,120(sp)
 8d4:	7446                	ld	s0,112(sp)
 8d6:	74a6                	ld	s1,104(sp)
 8d8:	7906                	ld	s2,96(sp)
 8da:	69e6                	ld	s3,88(sp)
 8dc:	6a46                	ld	s4,80(sp)
 8de:	6aa6                	ld	s5,72(sp)
 8e0:	6b06                	ld	s6,64(sp)
 8e2:	7be2                	ld	s7,56(sp)
 8e4:	7c42                	ld	s8,48(sp)
 8e6:	7ca2                	ld	s9,40(sp)
 8e8:	7d02                	ld	s10,32(sp)
 8ea:	6de2                	ld	s11,24(sp)
 8ec:	6109                	addi	sp,sp,128
 8ee:	8082                	ret

00000000000008f0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8f0:	715d                	addi	sp,sp,-80
 8f2:	ec06                	sd	ra,24(sp)
 8f4:	e822                	sd	s0,16(sp)
 8f6:	1000                	addi	s0,sp,32
 8f8:	e010                	sd	a2,0(s0)
 8fa:	e414                	sd	a3,8(s0)
 8fc:	e818                	sd	a4,16(s0)
 8fe:	ec1c                	sd	a5,24(s0)
 900:	03043023          	sd	a6,32(s0)
 904:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 908:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 90c:	8622                	mv	a2,s0
 90e:	00000097          	auipc	ra,0x0
 912:	e04080e7          	jalr	-508(ra) # 712 <vprintf>
}
 916:	60e2                	ld	ra,24(sp)
 918:	6442                	ld	s0,16(sp)
 91a:	6161                	addi	sp,sp,80
 91c:	8082                	ret

000000000000091e <printf>:

void
printf(const char *fmt, ...)
{
 91e:	711d                	addi	sp,sp,-96
 920:	ec06                	sd	ra,24(sp)
 922:	e822                	sd	s0,16(sp)
 924:	1000                	addi	s0,sp,32
 926:	e40c                	sd	a1,8(s0)
 928:	e810                	sd	a2,16(s0)
 92a:	ec14                	sd	a3,24(s0)
 92c:	f018                	sd	a4,32(s0)
 92e:	f41c                	sd	a5,40(s0)
 930:	03043823          	sd	a6,48(s0)
 934:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 938:	00840613          	addi	a2,s0,8
 93c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 940:	85aa                	mv	a1,a0
 942:	4505                	li	a0,1
 944:	00000097          	auipc	ra,0x0
 948:	dce080e7          	jalr	-562(ra) # 712 <vprintf>
}
 94c:	60e2                	ld	ra,24(sp)
 94e:	6442                	ld	s0,16(sp)
 950:	6125                	addi	sp,sp,96
 952:	8082                	ret

0000000000000954 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 954:	1141                	addi	sp,sp,-16
 956:	e422                	sd	s0,8(sp)
 958:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 95a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 95e:	00000797          	auipc	a5,0x0
 962:	1b27b783          	ld	a5,434(a5) # b10 <freep>
 966:	a805                	j	996 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 968:	4618                	lw	a4,8(a2)
 96a:	9db9                	addw	a1,a1,a4
 96c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 970:	6398                	ld	a4,0(a5)
 972:	6318                	ld	a4,0(a4)
 974:	fee53823          	sd	a4,-16(a0)
 978:	a091                	j	9bc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 97a:	ff852703          	lw	a4,-8(a0)
 97e:	9e39                	addw	a2,a2,a4
 980:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 982:	ff053703          	ld	a4,-16(a0)
 986:	e398                	sd	a4,0(a5)
 988:	a099                	j	9ce <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 98a:	6398                	ld	a4,0(a5)
 98c:	00e7e463          	bltu	a5,a4,994 <free+0x40>
 990:	00e6ea63          	bltu	a3,a4,9a4 <free+0x50>
{
 994:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 996:	fed7fae3          	bgeu	a5,a3,98a <free+0x36>
 99a:	6398                	ld	a4,0(a5)
 99c:	00e6e463          	bltu	a3,a4,9a4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a0:	fee7eae3          	bltu	a5,a4,994 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9a4:	ff852583          	lw	a1,-8(a0)
 9a8:	6390                	ld	a2,0(a5)
 9aa:	02059813          	slli	a6,a1,0x20
 9ae:	01c85713          	srli	a4,a6,0x1c
 9b2:	9736                	add	a4,a4,a3
 9b4:	fae60ae3          	beq	a2,a4,968 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9b8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9bc:	4790                	lw	a2,8(a5)
 9be:	02061593          	slli	a1,a2,0x20
 9c2:	01c5d713          	srli	a4,a1,0x1c
 9c6:	973e                	add	a4,a4,a5
 9c8:	fae689e3          	beq	a3,a4,97a <free+0x26>
  } else
    p->s.ptr = bp;
 9cc:	e394                	sd	a3,0(a5)
  freep = p;
 9ce:	00000717          	auipc	a4,0x0
 9d2:	14f73123          	sd	a5,322(a4) # b10 <freep>
}
 9d6:	6422                	ld	s0,8(sp)
 9d8:	0141                	addi	sp,sp,16
 9da:	8082                	ret

00000000000009dc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9dc:	7139                	addi	sp,sp,-64
 9de:	fc06                	sd	ra,56(sp)
 9e0:	f822                	sd	s0,48(sp)
 9e2:	f426                	sd	s1,40(sp)
 9e4:	f04a                	sd	s2,32(sp)
 9e6:	ec4e                	sd	s3,24(sp)
 9e8:	e852                	sd	s4,16(sp)
 9ea:	e456                	sd	s5,8(sp)
 9ec:	e05a                	sd	s6,0(sp)
 9ee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9f0:	02051493          	slli	s1,a0,0x20
 9f4:	9081                	srli	s1,s1,0x20
 9f6:	04bd                	addi	s1,s1,15
 9f8:	8091                	srli	s1,s1,0x4
 9fa:	0014899b          	addiw	s3,s1,1
 9fe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a00:	00000517          	auipc	a0,0x0
 a04:	11053503          	ld	a0,272(a0) # b10 <freep>
 a08:	c515                	beqz	a0,a34 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a0c:	4798                	lw	a4,8(a5)
 a0e:	02977f63          	bgeu	a4,s1,a4c <malloc+0x70>
 a12:	8a4e                	mv	s4,s3
 a14:	0009871b          	sext.w	a4,s3
 a18:	6685                	lui	a3,0x1
 a1a:	00d77363          	bgeu	a4,a3,a20 <malloc+0x44>
 a1e:	6a05                	lui	s4,0x1
 a20:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a24:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a28:	00000917          	auipc	s2,0x0
 a2c:	0e890913          	addi	s2,s2,232 # b10 <freep>
  if(p == (char*)-1)
 a30:	5afd                	li	s5,-1
 a32:	a895                	j	aa6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a34:	00000797          	auipc	a5,0x0
 a38:	21478793          	addi	a5,a5,532 # c48 <base>
 a3c:	00000717          	auipc	a4,0x0
 a40:	0cf73a23          	sd	a5,212(a4) # b10 <freep>
 a44:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a46:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a4a:	b7e1                	j	a12 <malloc+0x36>
      if(p->s.size == nunits)
 a4c:	02e48c63          	beq	s1,a4,a84 <malloc+0xa8>
        p->s.size -= nunits;
 a50:	4137073b          	subw	a4,a4,s3
 a54:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a56:	02071693          	slli	a3,a4,0x20
 a5a:	01c6d713          	srli	a4,a3,0x1c
 a5e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a60:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a64:	00000717          	auipc	a4,0x0
 a68:	0aa73623          	sd	a0,172(a4) # b10 <freep>
      return (void*)(p + 1);
 a6c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a70:	70e2                	ld	ra,56(sp)
 a72:	7442                	ld	s0,48(sp)
 a74:	74a2                	ld	s1,40(sp)
 a76:	7902                	ld	s2,32(sp)
 a78:	69e2                	ld	s3,24(sp)
 a7a:	6a42                	ld	s4,16(sp)
 a7c:	6aa2                	ld	s5,8(sp)
 a7e:	6b02                	ld	s6,0(sp)
 a80:	6121                	addi	sp,sp,64
 a82:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a84:	6398                	ld	a4,0(a5)
 a86:	e118                	sd	a4,0(a0)
 a88:	bff1                	j	a64 <malloc+0x88>
  hp->s.size = nu;
 a8a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a8e:	0541                	addi	a0,a0,16
 a90:	00000097          	auipc	ra,0x0
 a94:	ec4080e7          	jalr	-316(ra) # 954 <free>
  return freep;
 a98:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a9c:	d971                	beqz	a0,a70 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a9e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aa0:	4798                	lw	a4,8(a5)
 aa2:	fa9775e3          	bgeu	a4,s1,a4c <malloc+0x70>
    if(p == freep)
 aa6:	00093703          	ld	a4,0(s2)
 aaa:	853e                	mv	a0,a5
 aac:	fef719e3          	bne	a4,a5,a9e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ab0:	8552                	mv	a0,s4
 ab2:	00000097          	auipc	ra,0x0
 ab6:	b5c080e7          	jalr	-1188(ra) # 60e <sbrk>
  if(p == (char*)-1)
 aba:	fd5518e3          	bne	a0,s5,a8a <malloc+0xae>
        return 0;
 abe:	4501                	li	a0,0
 ac0:	bf45                	j	a70 <malloc+0x94>
