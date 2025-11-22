// rcu.h
#ifndef _RCU_H_
#define _RCU_H_

#include "param.h"
#include "types.h"

// Header for deferred RCU callbacks.
struct rcu_head {
  void (*func)(struct rcu_head *head);
  struct rcu_head *next;
};

void rcu_init(void);
void rcu_read_lock(void);
void rcu_read_unlock(void);
void synchronize_rcu(void);

void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *head));
void rcu_poll(void);

// Publish a new pointer value with a full memory barrier.
#define rcu_assign_pointer(p, v)       \
  do {                                 \
    __sync_synchronize();              \
    (p) = (v);                         \
  } while (0)

// Read a pointer safely inside an RCU read-side critical section.
#define rcu_dereference(p)             \
  ({                                   \
    __sync_synchronize();              \
    (p);                               \
  })

#endif // _RCU_H_
