#include <mqueue.h>
#include "minero.h"
#define SEM_NAME "/minero_comprobador"

#define MQ_NAME "/mq_messaje"
#define N 33
#define MAX_MSG 7

typedef struct _Miner
{
    long objYsol[3];
}Miner;



struct mq_attr attributes = {.mq_flags = 0,
                             .mq_maxmsg = MAX_MSG,
                             .mq_curmsgs = 0,
                             .mq_msgsize = sizeof(Bloque)};

