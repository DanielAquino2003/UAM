#ifndef _COMPROBADOR_H
#define _COMPROBADOR_H

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <time.h>
#include <string.h>
#include <semaphore.h>
#include <errno.h>
#include <sys/mman.h>
#include <string.h>




#define MAX_LINE 30
#define MAX_PIDS 100
#define BLOCKS 6
#define SHM_NAME "/shm_candidato"

typedef struct _Pocket
{
    pid_t pid;
    int money;
} Pocket;

typedef struct _Opera
{
    int id_bloque;
    long int target;
    long int sol;
    pid_t winner_pid;
    Pocket pockets[MAX_PIDS];
    int votes_status;
    int vot_tot;
    int vot_pos;
    int fin;
    int status;
    int num_pids;
} Opera;

typedef struct _Struct
{
    Opera operacion[6];
    int front;
    int rear;
    sem_t sem_mutex;
    sem_t sem_empty;
    sem_t sem_fill;
} Struct;

void monitor(Struct *shm_struct);
#endif