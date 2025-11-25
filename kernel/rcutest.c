#include "types.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"
#include "memlayout.h"
#include "param.h"
#include "proc.h"
#include "rcu.h"

struct rwlock {
  struct spinlock lock;
  int readers;
  int writer;   // 0 = no writer, 1 = writer holds the lock
};

void
rwlock_init(struct rwlock *lk, char *name)
{
  initlock(&lk->lock, name);
  lk->readers = 0;
  lk->writer = 0;
}

void
rlock(struct rwlock *lk)
{
  for (;;) {
    acquire(&lk->lock);
    if (lk->writer == 0) {
      lk->readers++;
      release(&lk->lock);
      break;
    }
    release(&lk->lock);
    // busy-wait; good enough for a microbenchmark
  }
}

void
runlock(struct rwlock *lk)
{
  acquire(&lk->lock);
  lk->readers--;
  release(&lk->lock);
}

void
wlock(struct rwlock *lk)
{
  for (;;) {
    acquire(&lk->lock);
    if (lk->writer == 0 && lk->readers == 0) {
      lk->writer = 1;
      release(&lk->lock);
      break;
    }
    release(&lk->lock);
  }
}

void
wunlock(struct rwlock *lk)
{
  acquire(&lk->lock);
  lk->writer = 0;
  release(&lk->lock);
}
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
    printf("[callback] free old value=%d\n", d->value);
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

void
rcu_read_heavy(void)
{
  // -------------------------------
  // Part 1: RCU read-heavy test
  // -------------------------------
  printf("=== RCU read-heavy test ===\n");

  // reset global pointer for the test
  global_test_ptr = 0;

  uint64 read_count = 0;
  uint64 write_count = 0;
  uint64 callback_before = rcu_callback_counter;
  uint64 start = ticks;
  uint64 now = start;

  // run the test for at least 10 ticks
  while (now - start < 10) {
    // RCU reader: lock, dereference, unlock
    rcu_read_lock();
    struct test_data *p = rcu_dereference(global_test_ptr);
    if (p) {
      int v = p->value;
      (void)v;
    }
    rcu_read_unlock();
    read_count++;

    // occasional writer: publish a new object
    if (read_count % 5000 == 0) {
      struct test_data *d = (struct test_data *)kalloc();
      if (d) {
        d->value = (int)read_count;
        struct test_data *old = global_test_ptr;
        rcu_assign_pointer(global_test_ptr, d);
        if (old != 0) {
          call_rcu(&old->rcu, rcu_free_callback);
          write_count++;
        }
      }
    }

    // let scheduler/idle path run RCU callbacks
    rcu_poll();

    now = ticks;
  }

  uint64 duration = now - start;
  uint64 callback_after = rcu_callback_counter;
  uint64 callbacks_executed = callback_after - callback_before;

  printf("[RCU] duration ticks: %d\n", (int)duration);
  printf("[RCU] total reads : %d\n", (int)read_count);
  printf("[RCU] total writes: %d\n", (int)write_count);
  printf("[RCU] callbacks executed: %d\n", (int)callbacks_executed);

  if (duration > 0) {
    printf("[RCU] reads per tick : %d\n",
           (int)(read_count / duration));
    printf("[RCU] writes per tick: %d\n",
           (int)(write_count / duration));
  }

  // -------------------------------
  // Part 2: RW-lock read-heavy test
  // -------------------------------
  printf("=== RW-lock read-heavy test ===\n");

  // test pointer protected by rwlock
  static struct test_data *rw_ptr = 0;
  static struct rwlock rw;

  rwlock_init(&rw, "rwbench");
  rw_ptr = 0;

  uint64 rw_read_count = 0;
  uint64 rw_write_count = 0;
  uint64 start2 = ticks;
  uint64 now2 = start2;

  while (now2 - start2 < 10) {
    // reader: shared lock
    rlock(&rw);
    struct test_data *p2 = rw_ptr;
    if (p2) {
      int v2 = p2->value;
      (void)v2;
    }
    runlock(&rw);
    rw_read_count++;

    // occasional writer: exclusive lock
    if (rw_read_count % 5000 == 0) {
      wlock(&rw);
      struct test_data *d2 = (struct test_data *)kalloc();
      if (d2) {
        d2->value = (int)rw_read_count;
        struct test_data *old2 = rw_ptr;
        rw_ptr = d2;
        if (old2) {
          kfree((char *)old2);  // no RCU, safe after exclusive lock
          rw_write_count++;
        }
      }
      wunlock(&rw);
    }

    now2 = ticks;
  }

  uint64 duration2 = now2 - start2;

  printf("[RW ] duration ticks: %d\n", (int)duration2);
  printf("[RW ] total reads : %d\n", (int)rw_read_count);
  printf("[RW ] total writes: %d\n", (int)rw_write_count);

  if (duration2 > 0) {
    printf("[RW ] reads per tick : %d\n",
           (int)(rw_read_count / duration2));
    printf("[RW ] writes per tick: %d\n",
           (int)(rw_write_count / duration2));
  }

  printf("=== read-heavy comparison done ===\n");
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
