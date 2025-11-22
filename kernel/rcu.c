#include "types.h"
#include "param.h"
#include "riscv.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "rcu.h"

// Per-CPU reader counters.
static int rcu_readers[NCPU];

// Protects defer_list.
static struct spinlock rcu_lock;

// List of pending callbacks.
static struct rcu_head *defer_list = 0;

// Wait until all CPUs have no active readers.
static void
wait_for_readers(void)
{
  for (;;) {
    int busy = 0;
    for (int i = 0; i < NCPU; i++) {
      if (__sync_fetch_and_add(&rcu_readers[i], 0) > 0) {
        busy = 1;
        break;
      }
    }
    if (!busy)
      break;
  }
}

void
rcu_init(void)
{
  initlock(&rcu_lock, "rcu");
  defer_list = 0;
  for (int i = 0; i < NCPU; i++)
    rcu_readers[i] = 0;
}

void
rcu_read_lock(void)
{
  int id = cpuid();
  __sync_add_and_fetch(&rcu_readers[id], 1);
  __sync_synchronize();
}

void
rcu_read_unlock(void)
{
  __sync_synchronize();
  int id = cpuid();
  __sync_sub_and_fetch(&rcu_readers[id], 1);
}

void
call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *))
{
  head->func = func;

  acquire(&rcu_lock);
  head->next = defer_list;
  defer_list = head;
  release(&rcu_lock);
}

void
synchronize_rcu(void)
{
  // Wait for a grace period.
  wait_for_readers();

  // Detach the callback list under the lock.
  acquire(&rcu_lock);
  struct rcu_head *h = defer_list;
  defer_list = 0;
  release(&rcu_lock);

  // Run callbacks without holding rcu_lock.
  while (h) {
    struct rcu_head *next = h->next;
    h->func(h);
    h = next;
  }
}

void
rcu_poll(void)
{
  // Fast check: if there is nothing to reclaim, return immediately.
  acquire(&rcu_lock);
  int empty = (defer_list == 0);
  release(&rcu_lock);

  if (!empty) {
    // Wait for a grace period and run all pending callbacks.
    synchronize_rcu();
  }
}