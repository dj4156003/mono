#ifndef _FM_SEM_H
#define _FM_SEM_H

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif

#ifdef USE_FM_SEMAPHORE
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include <sys/syscall.h>
#include <linux/futex.h>
#include <stdatomic.h>

/// Semaphore structure
struct fm_sem_t {
    /// Value of semaphore
    int value;
};

/**
 * @brief Fast user-space locking
 * @param[in] uaddr Pointer to futex word
 * @param[in] futex_op Operation to be performed
 * @param[in] val Expected value of the futex word
 * @return 0 on success; -1 on error
 */
static inline int futex(int *uaddr, int futex_op, int val) {
    return syscall(__NR_futex, uaddr, futex_op, val, NULL, NULL, 0);
}

/**
 * @brief Initialise the semaphore
 * @param[in,out] sem Pointer to semaphore
 * @param[in,out] initval Value to be initialised to
 * @return On success, returns 0
 */
static inline int fm_sem_init(fm_sem_t *sem, uint32_t initval) {
    g_assert(sem);
    atomic_init(&sem->value, initval);
    return 0;
}

/**
 * @brief Decrements (locks) the semaphore
 * @param[in,out] sem Pointer to semaphore
 * @note If the semaphore currently has the value zero, then the
 * call blocks  until it becomes possible to perform the decrement
 * @return On success, returns 0
 */
int fm_sem_wait(fm_sem_t *sem) {
    g_assert(sem);
    uint32_t value = 1;

    while(!atomic_compare_exchange_weak_explicit(&sem->value,
                                                    &value, value - 1,
                                                    memory_order_acquire,
                                                    memory_order_relaxed)) {
        if(value == 0) {
            futex(&sem->value, FUTEX_WAIT_PRIVATE, 0);
            value = 1;
        }
    }

    return 0;
}

/**
 * @brief Tries to decrement (lock) the semaphore without blocking
 * @param[in,out] sem Pointer to semaphore
 * @return On success, returns 0; On failure, returns -1
 */
int fm_sem_trywait(fm_sem_t *sem) {
    g_assert(sem);
    uint32_t value = atomic_load_explicit(&sem->value, memory_order_acquire);

    while (value > 0) {
        if (atomic_compare_exchange_weak_explicit(&sem->value,
                                                  &value, value - 1,
                                                  memory_order_acquire,
                                                  memory_order_relaxed)) {
            return 0; // Successfully decremented the semaphore
        }
    }
    errno = EAGAIN;
    return -1; // Failed to decrement the semaphore (value was 0)
}


/**
 * @brief Increments (unlocks) the semaphore
 * @param[in,out] sem Pointer to semaphore
 * @return On success, returns 0
 */
int fm_sem_post(fm_sem_t *sem) {
    g_assert(sem);
    atomic_fetch_add_explicit(&sem->value, 1, memory_order_release);
    futex(&sem->value, FUTEX_WAKE_PRIVATE, 1);
    return 0;
}

/**
 * @brief Decrements (locks) the semaphore with a timeout
 * @param[in,out] sem Pointer to semaphore
 * @param[in] timeout Timeout value in milliseconds
 * @note If the semaphore currently has the value zero, then the
 * call blocks until it becomes possible to perform the decrement or the timeout expires
 * @return On success, returns 0; on timeout, returns -1
 */
int fm_sem_timedwait(fm_sem_t *sem, uint32_t timeout_ms) {
    g_assert(sem);
    uint32_t value = 1;

    struct timespec timeout, now;
    clock_gettime(CLOCK_MONOTONIC, &now);
    timeout.tv_sec = now.tv_sec + timeout_ms / 1000;
    timeout.tv_nsec = now.tv_nsec + (timeout_ms % 1000) * 1000000;
    while (timeout.tv_nsec >= MONO_NSEC_PER_SEC) {
        timeout.tv_nsec -= MONO_NSEC_PER_SEC;
        timeout.tv_sec++;
    }

    while (!atomic_compare_exchange_weak_explicit(&sem->value,
                                                  &value, value - 1,
                                                  memory_order_acquire,
                                                  memory_order_relaxed)) {
        if (value == 0) {
            int res = futex(&sem->value, FUTEX_WAIT_BITSET_PRIVATE, 0, &timeout, NULL, 0);
            if (res == -1 && (errno == ETIMEDOUT || error = EINTR) {
                return -1;
            }
            value = 1;
        }
    }

    return 0;
}


#endif

#endif
