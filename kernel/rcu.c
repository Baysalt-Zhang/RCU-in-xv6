#include "types.h"
#include "param.h"
#include "riscv.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "rcu.h"


static int rcu_readers = 0;
static struct spinlock rcu_lock;
static struct rcu_head *defer_list = 0;

void
rcu_init(void)
{
  initlock(&rcu_lock, "rcu");
  rcu_readers = 0;
  defer_list = 0;
}

// Enter RCU read section
void
rcu_read_lock(void)
{
  __sync_add_and_fetch(&rcu_readers, 1);
  __sync_synchronize();
}

// Exit RCU read section
void
rcu_read_unlock(void)
{
  __sync_synchronize();
  __sync_sub_and_fetch(&rcu_readers, 1);
}

// Register a deferred callback
void
call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *))
{
  head->func = func;
  acquire(&rcu_lock);
  head->next = defer_list;
  defer_list = head;
  release(&rcu_lock);
}

// Wait until all readers finish, then run callbacks
void
synchronize_rcu(void)
{
  while (__sync_fetch_and_add(&rcu_readers, 0) > 0)
    ; // wait for readers

  acquire(&rcu_lock);
  struct rcu_head *h = defer_list;
  while (h) {
    struct rcu_head *next = h->next;
    h->func(h);
    h = next;
  }
  defer_list = 0;
  release(&rcu_lock);
}
