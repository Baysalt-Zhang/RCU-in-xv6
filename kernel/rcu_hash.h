// rcu_hash.h
#ifndef _RCU_HASH_H_
#define _RCU_HASH_H_

#include "types.h"
#include "rcu.h"

// Forward declaration; real definition is in spinlock.h
struct spinlock;

#define RCU_HT_NBUCKET 64

// Hash table node protected by RCU.
struct rcu_hnode {
  struct rcu_head rcu;      // For RCU callback.
  struct rcu_hnode *next;   // Next node in bucket list.
  uint64 key;
  uint64 value;
};

struct rcu_hash_table {
  struct spinlock *lock;          // pointer to array of locks
  struct rcu_hnode *bucket[RCU_HT_NBUCKET];
};

void rcu_hash_init(struct rcu_hash_table *ht);
int rcu_hash_insert(struct rcu_hash_table *ht, uint64 key, uint64 value);
int rcu_hash_lookup(struct rcu_hash_table *ht, uint64 key, uint64 *valuep);
int rcu_hash_remove(struct rcu_hash_table *ht, uint64 key);

#endif // _RCU_HASH_H_
