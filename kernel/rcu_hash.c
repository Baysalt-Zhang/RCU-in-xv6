// rcu_hash.c
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "rcu.h"
#include "rcu_hash.h"

// Simple container_of to get struct pointer from member pointer.
#define container_of(ptr, type, member) \
  ((type *)((char *)(ptr) - (uint64)(&((type *)0)->member)))

static inline int
hash_key(uint64 key)
{
  return key % RCU_HT_NBUCKET;
}

void
rcu_hash_init(struct rcu_hash_table *ht)
{
  // allocate an array of spinlocks for all buckets
  ht->lock = (struct spinlock *)kalloc();
  if (ht->lock == 0) {
    panic("rcu_hash_init: no memory for locks");
  }

  for (int i = 0; i < RCU_HT_NBUCKET; i++) {
    initlock(&ht->lock[i], "rcu_ht");
    ht->bucket[i] = 0;
  }
}

// RCU callback to free a node after a grace period.
static void
rcu_hnode_free_cb(struct rcu_head *head)
{
  struct rcu_hnode *node = container_of(head, struct rcu_hnode, rcu);
  kfree((void *)node);
}

// Insert a new (key, value) if key is not present.
int
rcu_hash_insert(struct rcu_hash_table *ht, uint64 key, uint64 value)
{
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);

  // Reject duplicate keys for simplicity.
  struct rcu_hnode *p = ht->bucket[idx];
  while (p) {
    if (p->key == key) {
      release(&ht->lock[idx]);
      return -1;
    }
    p = p->next;
  }

  struct rcu_hnode *node = (struct rcu_hnode *)kalloc();
  if (node == 0) {
    release(&ht->lock[idx]);
    return -1;
  }

  node->key = key;
  node->value = value;

  // Insert at bucket head.
  node->next = ht->bucket[idx];
  rcu_assign_pointer(ht->bucket[idx], node);

  release(&ht->lock[idx]);
  return 0;
}

// Lookup must be called inside an RCU read-side critical section.
int
rcu_hash_lookup(struct rcu_hash_table *ht, uint64 key, uint64 *valuep)
{
  int idx = hash_key(key);
  int found = 0;

  rcu_read_lock();

  struct rcu_hnode *p = rcu_dereference(ht->bucket[idx]);
  while (p) {
    if (p->key == key) {
      if (valuep)
        *valuep = p->value;
      found = 1;
      break;
    }
    p = p->next;
  }

  rcu_read_unlock();
  return found;
}

// Remove a key and defer freeing its node via RCU.
int
rcu_hash_remove(struct rcu_hash_table *ht, uint64 key)
{
  int idx = hash_key(key);
  acquire(&ht->lock[idx]);

  struct rcu_hnode *prev = 0;
  struct rcu_hnode *p = ht->bucket[idx];

  while (p) {
    if (p->key == key)
      break;
    prev = p;
    p = p->next;
  }

  if (p == 0) {
    release(&ht->lock[idx]);
    return 0;
  }

  // Unlink from the bucket list.
  if (prev)
    prev->next = p->next;
  else
    rcu_assign_pointer(ht->bucket[idx], p->next);

  release(&ht->lock[idx]);

  // Actual free happens after a grace period.
  call_rcu(&p->rcu, rcu_hnode_free_cb);
  return 1;
}
