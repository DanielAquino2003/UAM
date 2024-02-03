#include "comprobador.h"
#include "pow.h"

void monitor(Struct *shm_struct)
{
    int j = 0,i = 0;
    while (1)
    {
        // semaforos
        sem_wait(&shm_struct->sem_fill);
        sem_wait(&shm_struct->sem_mutex);

        if (shm_struct->operacion[shm_struct->front].fin == 1)
            break;

        fprintf(stdout, "Id:       %d\n", shm_struct->operacion[shm_struct->front].id_bloque);
        fprintf(stdout, "Winner:   %d\n", shm_struct->operacion[shm_struct->front].winner_pid);
        fprintf(stdout, "Target:   %ld\n", shm_struct->operacion[shm_struct->front].target);
        if (shm_struct->operacion[shm_struct->rear].status == 0)
        {
            fprintf(stdout, "Solution: %ld (validated)\n", shm_struct->operacion[shm_struct->front].sol);
        }
        else if(shm_struct->operacion[shm_struct->rear].status == 1)
        {
            fprintf(stdout, "Solution: %ld (rejected)\n", shm_struct->operacion[shm_struct->front].sol);
        }
        fprintf(stdout, "Votes:    %d/%d\n", shm_struct->operacion[shm_struct->front].vot_pos + 1, shm_struct->operacion[shm_struct->front].vot_tot + 1);
        fprintf(stdout, "Wallets:  ");
        for (j = 0, i = 0; j < shm_struct->operacion[shm_struct->front].vot_tot + 1; i++)
        {
            if (shm_struct->operacion[shm_struct->front].pockets[i].pid != 0)
            {
                fprintf(stdout, "%d: %d  ", shm_struct->operacion[shm_struct->front].pockets[i].pid, shm_struct->operacion[shm_struct->front].pockets[i].money);
                j++;
            }
        }
        fprintf(stdout, "\n\n");
        shm_struct->front = (shm_struct->front + 1) % 5;

        if (shm_struct->operacion[shm_struct->front].fin == 1)
        {
            break;
        }
        sem_post(&shm_struct->sem_mutex);
        sem_post(&shm_struct->sem_empty);
    }
    return;
}