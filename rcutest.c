#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "memlayout.h"
#include "param.h"
#include "proc.h"
#include "rcu.h"

struct test_data
{
    int value;
    struct rcu_head rcu;
};

static struct test_data *global_test_ptr = 0;
// Helper: get struct test_data* from rcu_head* (like container_of).
static struct test_data *
rcu_to_test_data(struct rcu_head *head)
{
    return (struct test_data *)((char *)head - (uint64)(&((struct test_data *)0)->rcu));
}

// Callback executed after the grace period.
static void
rcu_free_callback(struct rcu_head *head)
{
    struct test_data *d = rcu_to_test_data(head);
    // printf("[callback] free old value=%d\n", d->value);
    kfree((char *)d);
}

void test_rcu(void)
{
    printf("=== RCU test start ===\n");

    struct test_data *d1 = (struct test_data *)kalloc();
    if (!d1)
    {
        printf("kalloc failed\n");
        return;
    }
    d1->value = 100;

    rcu_assign_pointer(global_test_ptr, d1);
    printf("[init] global=%d\n", global_test_ptr->value);

    // reader
    rcu_read_lock();
    struct test_data *local = rcu_dereference(global_test_ptr);
    printf("[reader] read value=%d\n", local->value);
    rcu_read_unlock();

    struct test_data *d2 = (struct test_data *)kalloc();
    d2->value = 200;

    struct test_data *old = global_test_ptr;
    rcu_assign_pointer(global_test_ptr, d2);

    printf("[writer] updated global to %d\n", global_test_ptr->value);

    call_rcu(&old->rcu, rcu_free_callback);

    printf("=== RCU test done ===\n");
}

void rcu_read_only(void)
{
    printf("=== RCU read-only test ===\n");

    for (int i = 0; i < 1000; i++)
    {
        rcu_read_lock();
        struct test_data *p = rcu_dereference(global_test_ptr);
        if (p)
        {
            int v = p->value;
            (void)v;
        }
        rcu_read_unlock();
    }

    printf("read-only test done\n");
}

void rcu_read_heavy(void)
{
    printf("=== RCU read-heavy test ===\n");

    for (int i = 0; i < 500000; i++)
    {

        // reader
        rcu_read_lock();
        struct test_data *p = rcu_dereference(global_test_ptr);
        if (p)
        {
            int v = p->value;
            (void)v;
        }
        rcu_read_unlock();

        // writer occasionally
        if (i % 5000 == 0)
        {
            struct test_data *d = kalloc();
            d->value = i;
            struct test_data *old = global_test_ptr;
            rcu_assign_pointer(global_test_ptr, d);
            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
            }
        }
    }

    printf("read-heavy test done\n");
}

static struct test_data *mix_test_ptr = 0;

void rcu_read_write_mix(void)
{
    printf("=== RCU read-write mix ===\n");

    for (int i = 0; i < 200000; i++)
    {
        if (i % 3 == 0)
        {
            // writer
            struct test_data *d = kalloc();
            d->value = i;
            struct test_data *old = mix_test_ptr;
            rcu_assign_pointer(mix_test_ptr, d);
            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
            }
        }
        else
        {
            // reader
            rcu_read_lock();
            struct test_data *p = rcu_dereference(global_test_ptr);
            if (p)
            {
                (void)p->value;
            }
            rcu_read_unlock();
        }
    }

    printf("mix test done\n");
}

void rcu_read_stress(void)
{
    printf("=== RCU stress test ===\n");

    for (int i = 0; i < 800000; i++)
    {
        int op = i % 7;

        if (op == 0)
        {
            // writer
            struct test_data *d = kalloc();
            d->value = i;
            struct test_data *old = global_test_ptr;
            rcu_assign_pointer(global_test_ptr, d);
            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
            }
        }
        else
        {
            // reader
            rcu_read_lock();
            struct test_data *p = rcu_dereference(global_test_ptr);
            if (p)
            {
                int v = p->value;
                (void)v;
            }
            rcu_read_unlock();
        }

        if (i % 50000 == 0)
            printf("progress %d\n", i);
    }

    printf("stress test done\n");
}
