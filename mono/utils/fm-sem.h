#ifndef _FM_SEM_H
#define _FM_SEM_H

#ifdef USE_FM_SEMAPHORE

#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif

#include <stdatomic.h>


/// Semaphore structure
struct fm_sem_t {
    /// Value of semaphore
    _Atomic int value;
};

int fm_sem_init(struct fm_sem_t *sem, int initval);

int fm_sem_wait(struct fm_sem_t *sem);

int fm_sem_trywait(struct fm_sem_t *sem);

int fm_sem_post(struct fm_sem_t *sem);

int fm_sem_timedwait(struct fm_sem_t *sem, const struct timespec* timeout);


#endif

#endif
