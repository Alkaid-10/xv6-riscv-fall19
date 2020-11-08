#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(){
    int pFaWriteSonRead[2];//父进程写子进程读
    int pFaReadSonWrite[2];//子进程写父进程读
    //待读取的字符
    char buffer[]={'X'};
    long length=sizeof(buffer);
    //创建管道
    pipe(pFaWriteSonRead);//父写子读
    pipe(pFaReadSonWrite);//子写父读
    if(fork()==0)//进入子进程
    {
        //关闭无用的端口
        close(pFaWriteSonRead[1]);
        close(pFaReadSonWrite[0]);
        //异常处理
        if(read(pFaWriteSonRead[0],buffer,length)!=length){
            printf("son:fa to son error!\n");
            exit();
        }
        //输出获取到的字符
        printf("%d: received ping\n",getpid());
        //将待写入的字符写入pipe的写入端
        if(write(pFaReadSonWrite[1],buffer,length)!=length){
            printf("son:son to fa error!\n");
            exit();
        }
        exit();
    }
    //关闭无用的端口
    close(pFaWriteSonRead[0]);
    close(pFaReadSonWrite[1]);
    //父进程向写入端写入字符
    if(write(pFaWriteSonRead[1],buffer,length)!=length){
        printf("fa:fa to son error!\n");
        exit();
    }
    //父进程从读入端读入字符
    if(read(pFaReadSonWrite[0],buffer,length)!=length){
        printf("fa:son to fa erroe!\n");
        exit();
    }
    //打印读出的字符
    printf("%d: received pong\n",getpid());
    //等待子进程退出
    wait();
    exit();

}