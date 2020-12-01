// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"
#define NBUCKRTS 13
struct {
  struct spinlock locks[NBUCKRTS];
  struct spinlock lock; 
  struct buf buf[NBUF];
  struct buf hashbucket[NBUCKRTS];
  
  // Linked list of all buffers, through prev/next.
  // head.next is most recently used.
  //struct buf head;
} bcache;

int bhash(int blockno){
  return blockno%NBUCKRTS;
}
void
binit(void)
{
  struct buf *b;

  for (int i=0;i<NBUCKRTS;i++){
      initlock(&bcache.locks[i],"bcache.bucket");
      b=&bcache.hashbucket[i];
      b->prev=b;
      b->next=b;
  }
  for(b=bcache.buf;b<bcache.buf+NBUF;b++){
      b->next = bcache.hashbucket[0].next;
      b->prev = &bcache.hashbucket[0];
      initsleeplock(&b->lock, "buffer");
      bcache.hashbucket[0].next->prev = b;
      bcache.hashbucket[0].next = b;
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;
  int h=bhash(blockno);
  acquire(&bcache.locks[h]);
 
  // 首先在blockno对应的bucket中找，refcnt可能为0，也可能不为0
  for(b = bcache.hashbucket[h].next; b != &bcache.hashbucket[h]; b = b->next){
    if(b->dev == dev && b->blockno == blockno){
      b->refcnt++;
      release(&bcache.locks[h]);
      acquiresleep(&b->lock);
      return b;
    }
  }
 
  // 如果在h对应的bucket中没有找到，那么需要到其他bucket中找，这种情况不会少见，因为
  // binit中，我们就把所有的buffer都插入到了第一个bucket中（当时blockno都是0
  // 此时原来bucket的锁还没有释放，因为我们在其他bucket中找到buffer后，还要将其插入到原bucket中
  int nh=(h+1)%NBUCKRTS; // nh表示下一个要探索的bucket，当它重新变成h，说明所有的buffer都bussy（refcnt不为0），此时
              // 如之前设计的，panic
  while(nh!=h){
    acquire(&bcache.locks[nh]);// 获取当前bocket的锁
    for(b = bcache.hashbucket[nh].prev; b != &bcache.hashbucket[nh]; b = b->prev){
      if(b->refcnt == 0) {
        b->dev = dev;
        b->blockno = blockno;
        b->valid = 0;
        b->refcnt = 1;
        // 从原来bucket的链表中断开
        b->next->prev=b->prev;
        b->prev->next=b->next;
        release(&bcache.locks[nh]);
        // 插入到blockno对应的bucket中去
        // 👇就是有头节点的头插法
        b->next=bcache.hashbucket[h].next;
        b->prev=&bcache.hashbucket[h];
        bcache.hashbucket[h].next->prev=b;
        bcache.hashbucket[h].next=b;
        release(&bcache.locks[h]);
        acquiresleep(&b->lock);
        return b;
      }
    }
    // 如果当前bucket里没有找到，在转到下一个bucket之前，记得释放当前bucket的锁
    release(&bcache.locks[nh]);
    nh=(nh+1)%NBUCKRTS;
  }

    
  
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
}

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);
  int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    // 下面做的就是把b从原来的位置取下来 放在链表开头（头插法）
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.hashbucket[h].next;
    b->prev = &bcache.hashbucket[h];
    bcache.hashbucket[h].next->prev = b;
    bcache.hashbucket[h].next = b;
  }
  
  release(&bcache.locks[h]);
  
}

void
bpin(struct buf *b) {
  int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
  b->refcnt++;
  release(&bcache.locks[h]);
}

void
bunpin(struct buf *b) {
   int h=bhash(b->blockno);
  acquire(&bcache.locks[h]);
  b->refcnt--;
  release(&bcache.locks[h]);
}


