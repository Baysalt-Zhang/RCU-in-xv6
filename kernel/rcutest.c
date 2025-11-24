#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "memlayout.h"
#include "param.h"
#include "proc.h"
#include "rcu.h"

uint64 rcu_callback_counter = 0;
double read_only_avg_latency = 0; // 来自 rcu_read_only()

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
    rcu_callback_counter++;
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

    uint64 read_count = 0;
    uint64 start = ticks; // start time in ticks

    int iter = 10 * 1000 * 1000; // run more to get meaningful data
    for (int i = 0; i < iter; i++)
    {
        rcu_read_lock();
        struct test_data *p = rcu_dereference(global_test_ptr);
        if (p)
        {
            int v = p->value;
            (void)v;
        }
        rcu_read_unlock();
        read_count++;
    }

    uint64 end = ticks; // end time
    uint64 duration = end - start;

    printf("read-only test done\n");
    printf("Total read operations: %u\n", read_count);
    printf("Total time: %u ticks\n", duration);

    if (duration > 0)
    {
        printf("Reads per tick: %u\n", read_count / duration);
    }
    else
    {
        printf("Duration < 1 tick, measurement too small.\n");
    }
}

void rcu_read_heavy(void)
{
    printf("=== RCU read-heavy test ===\n");

    // evaluation
    uint64 read_count = 0;
    uint64 write_count = 0;
    uint64 callback_count_before = rcu_callback_counter;
    uint64 start = ticks;

    // run test for at least 10 ticks (~100ms) to get meaningful data
    uint64 now = start;
    while (now - start < 10)
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
        read_count++;

        // writer occasionally
        if (read_count % 5000 == 0)
        {
            struct test_data *d = kalloc();
            d->value = read_count;
            struct test_data *old = global_test_ptr;
            rcu_assign_pointer(global_test_ptr, d);
            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
                write_count++;
            }
        }
        now = ticks;
    }

    uint64 duration = now - start;
    uint64 callback_count_after = rcu_callback_counter;
    uint64 callbacks_executed = callback_count_after - callback_count_before;

    printf("read-heavy test done\n");
    printf("Duration: %u ticks\n", duration);
    printf("Total reads: %u\n", read_count);
    printf("Total writes: %u\n", write_count);
    printf("Callbacks executed: %u\n", callbacks_executed);

    printf("Reads per tick: %u\n", read_count / duration);
    printf("Writes per tick: %u\n", write_count / duration);

    printf("Average ticks per read: %f\n",
           (double)duration / (double)read_count);

    if (write_count > 0)
    {
        printf("Average callbacks per write: %f\n",
               (double)callbacks_executed / (double)write_count);
    }
}

static struct test_data *mix_test_ptr = 0;

void rcu_read_write_mix(void)
{
    printf("=== RCU read-write mix ===\n");

    // --- initialization ---
    if (mix_test_ptr == 0)
    {
        struct test_data *init = kalloc();
        init->value = -1;
        rcu_assign_pointer(mix_test_ptr, init);
    }

    uint64 read_count = 0;
    uint64 write_count = 0;
    uint64 callback_before = rcu_callback_counter;

    uint64 start = ticks;
    uint64 now = start;

    // run at least 10 ticks (~100ms) for stable measurement
    while (now - start < 10)
    {
        // writer every 3 iterations
        if ((read_count % 3) == 0)
        {
            struct test_data *d = kalloc();
            d->value = read_count;

            struct test_data *old = mix_test_ptr;
            rcu_assign_pointer(mix_test_ptr, d);

            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
                write_count++;
            }
        }
        else
        {
            // reader
            rcu_read_lock();
            struct test_data *p = rcu_dereference(mix_test_ptr);
            if (p)
            {
                (void)p->value;
            }
            rcu_read_unlock();
            read_count++;
        }

        now = ticks;
    }

    uint64 duration = now - start;
    uint64 callback_after = rcu_callback_counter;
    uint64 callbacks = callback_after - callback_before;

    // --- results ---
    printf("mix test done\n");
    printf("Duration: %u ticks\n", duration);
    printf("Reads: %u\n", read_count);
    printf("Writes: %u\n", write_count);
    printf("Callbacks executed: %u\n", callbacks);

    printf("Reads per tick: %u\n", read_count / duration);
    printf("Writes per tick: %u\n", write_count / duration);

    double avg_latency = (double)duration / (double)(read_count + write_count);
    printf("Average ticks per operation: %f\n", avg_latency);

    // if (read_only_avg_latency > 0)
    // {
    //     double interference =
    //         (avg_latency - read_only_avg_latency) / read_only_avg_latency;
    //     printf("Interference ratio (writer impact): %f\n", interference);
    // }
}

void rcu_read_stress(void)
{
    printf("=== RCU stress test ===\n");

    // ---- initialize pointer once ----
    if (global_test_ptr == 0)
    {
        struct test_data *init = kalloc();
        init->value = -1;
        rcu_assign_pointer(global_test_ptr, init);
    }

    // ---- quantitative counters ----
    uint64 read_count = 0;
    uint64 write_count = 0;
    uint64 callback_before = rcu_callback_counter;

    // measure at least 20 ticks (~200ms) to show stress behavior
    uint64 start = ticks;
    uint64 now = start;

    while (now - start < 20)
    {
        int op = write_count % 7; // change frequency of writer

        if (op == 0)
        {
            // ---- writer ----
            struct test_data *d = kalloc();
            if (!d)
                panic("kalloc failed");
            d->value = write_count;

            struct test_data *old = global_test_ptr;
            rcu_assign_pointer(global_test_ptr, d);

            if (old != 0)
            {
                call_rcu(&old->rcu, rcu_free_callback);
                write_count++;
            }
        }
        else
        {
            // ---- reader ----
            rcu_read_lock();
            struct test_data *p = rcu_dereference(global_test_ptr);

            if (p)
            {
                int v = p->value;
                (void)v;
            }

            rcu_read_unlock();
            read_count++;
        }

        // occasionally flush RCU callbacks
        if ((read_count & 0xFFF) == 0)
            rcu_poll();

        now = ticks;
    }

    uint64 duration = now - start;
    uint64 callback_after = rcu_callback_counter;
    uint64 callbacks = callback_after - callback_before;

    // ---- Results ----
    printf("stress test done\n");
    printf("Duration: %u ticks\n", duration);
    printf("Total reads: %u\n", read_count);
    printf("Total writes: %u\n", write_count);
    printf("Callbacks executed: %u\n", callbacks);
    printf("Reads per tick: %u\n", read_count / duration);
    printf("Writes per tick: %u\n", write_count / duration);

    double avg_latency = (double)duration / (double)(read_count + write_count);
    printf("Average ticks per operation: %f\n", avg_latency);

    if (read_only_avg_latency > 0)
    {
        double interference =
            (avg_latency - read_only_avg_latency) / read_only_avg_latency;
        printf("Interference ratio (writer impact): %f\n", interference);
    }

    if (callbacks != write_count)
    {
        printf("WARNING: callback mismatch (Possible memory leak or RCU bug!)\n");
    }
}
