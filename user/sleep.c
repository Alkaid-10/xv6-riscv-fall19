#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void usage(){
    printf("Usage: sleep <NUM> \n");
    printf("NUM must be non-negative\n");
    exit();
}
 
 
int main(int argc,char* argv[]){
    if(argc<2){
        usage();
    }
    //检测输入合法性
    char c=argv[1][0];
    if(c<'0'||c>'9'){
        usage();
    }
    //转换为int
    int num=atoi(argv[1]);
    printf("sleep %d ticks\n",num);
    sleep(num);
    exit();
}


