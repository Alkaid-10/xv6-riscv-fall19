
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
 
#define R 0
#define W 1
 
int
main(int argc, char *argv[])
{
  int numbers[100], cnt = 0, i;
  int fd[2];
  for (i = 2; i <= 35; i++) {
    numbers[cnt++] = i;
  }
  
  while (cnt > 0) {
    pipe(fd);

    //子进程
    if (fork() == 0) {
      int prime, this_prime = 0;
      // 关闭写
      close(fd[W]);
      cnt = -1;
      // 读的时候，如果父亲还没写，就会block
      while (read(fd[R], &prime, sizeof(prime)) != 0) {
          // 设置当前进程代表的素数，用于筛掉能被当前素数整除的数
        if (cnt == -1) {
          this_prime = prime;
          cnt = 0;
        } 
        else {
            // 把筛出来的接着放在numbers数组里 这里cnt是重新从0开始计数的
          if (prime % this_prime != 0) numbers[cnt++] = prime;
        }
      }
      printf("prime %d\n",this_prime);
      // 关闭读
      close(fd[R]);
      
    } 
    

    // 父进程里
    else {
        
      close(fd[R]);
      
      for (i = 0; i < cnt; i++) {//将上一个子进程（这一次的父进程）筛选出来的素数写入pipe
        write(fd[W], &numbers[i], sizeof(numbers[0]));
      }
      close(fd[W]);
      wait();
      // 这个break，让父进程直接退出循环，从而结束了
      // 即父进程只是起了往第一个子进程传原始数据的作用
 
      break;
    }
  }
  exit();
}