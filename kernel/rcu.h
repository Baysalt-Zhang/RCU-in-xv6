#ifndef _RCU_H_
#define _RCU_H_

struct rcu_head {
  void (*func)(struct rcu_head *head);
  struct rcu_head *next;
};

void rcu_init(void);
void rcu_read_lock(void);
void rcu_read_unlock(void);
void synchronize_rcu(void);
void call_rcu(struct rcu_head *head, void (*func)(struct rcu_head *head));

#endif
