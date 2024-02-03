#include "comprobador.h"
#include "minero.h"
#include "mq.h"
#include "pow.h"

static volatile sig_atomic_t got_signal = 0;

void handler_2(int sig)
{
    if (sig == SIGINT)
    {
        got_signal = 1;
    }
    return;
}

int main()
{
    sem_t *sem = NULL;
    Struct *shm_struct;
    Bloque bloque;
    int fd_shm = 0;
    pid_t pid = 0;
    int i = 0, j = 0;
    long int result;
    struct sigaction act1;

    mqd_t queue;

    queue = mq_open(
        MQ_NAME,
        O_CREAT | O_RDONLY,
        S_IRUSR | S_IWUSR,
        &attributes);

    if (queue == (mqd_t)-1)
    {
        fprintf(stderr, "Error opening the queue\n");
        mq_close(queue);
        mq_unlink(MQ_NAME);
        exit(EXIT_FAILURE);
    }

    // INICIALIZAMOS LAS MASCARAS DE MENSAJES.
    act1.sa_handler = handler_2;
    sigemptyset(&(act1.sa_mask));
    act1.sa_flags = 0;

    if (sigaction(SIGINT, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    // Abrimos la memoria compartida
    fd_shm = shm_open(SHM_NAME, O_CREAT | O_EXCL | O_RDWR, S_IRUSR | S_IWUSR);
    if (fd_shm == -1)
    {
        if (errno == EEXIST)
            perror(" Shared memory already created\n");
        fprintf(stdout, "Error en el comprobador\n");
        exit(EXIT_FAILURE);
    }

    if (ftruncate(fd_shm, sizeof(Struct)) == -1)
    {
        perror("ftruncate");
        fprintf(stdout, "Error en el monitor\n");
        shm_unlink(SHM_NAME);
        exit(EXIT_FAILURE);
    }

    /* Mapping of the memory segment. */
    shm_struct = mmap(NULL, sizeof(Struct), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);
    close(fd_shm);
    if (shm_struct == MAP_FAILED)
    {
        perror("mmap");
        fprintf(stdout, "Error en el comprobador\n");
        shm_unlink(SHM_NAME);
        exit(EXIT_FAILURE);
    }

    memset(shm_struct, 0, sizeof(Struct));

    // innicializacion de los semaforos
    if (sem_init(&shm_struct->sem_mutex, 1, 1) == -1)
    {
        fprintf(stdout, "Error en el comprobador\n");
        munmap(shm_struct, sizeof(Struct));
        shm_unlink(SHM_NAME);
        perror("sem_mutex");
        exit(EXIT_FAILURE);
    }
    if (sem_init(&shm_struct->sem_fill, 1, 0) == -1)
    {
        fprintf(stdout, "Error en el comprobador\n");
        munmap(shm_struct, sizeof(Struct));
        shm_unlink(SHM_NAME);
        sem_destroy(&shm_struct->sem_mutex);
        perror("sem_fill");
        exit(EXIT_FAILURE);
    }
    if (sem_init(&shm_struct->sem_empty, 1, 6) == -1)
    {
        fprintf(stdout, "Error en el comprobador\n");
        munmap(shm_struct, sizeof(Struct));
        shm_unlink(SHM_NAME);
        sem_destroy(&shm_struct->sem_mutex);
        sem_destroy(&shm_struct->sem_fill);
        perror("sem_empty");
        exit(EXIT_FAILURE);
    }


    pid = fork();
    if (pid < 0)
    {
        perror("fork");
        fprintf(stdout, "Error en el comprobador\n");
        munmap(shm_struct, sizeof(shm_struct));
        sem_destroy(&shm_struct->sem_mutex);
        sem_destroy(&shm_struct->sem_fill);
        sem_destroy(&shm_struct->sem_empty);
        shm_unlink(SHM_NAME);

        exit(EXIT_SUCCESS);
    }
    if (pid == 0)
    {
        monitor(shm_struct);
        exit(EXIT_SUCCESS);
    }
    else
    {
        if ((sem = sem_open(SEM_NAME, O_CREAT, S_IRUSR | S_IWUSR, 0)) == SEM_FAILED)
        {
            perror(" sem_open ");
            fprintf(stdout, "Error en el comprobador\n");
            munmap(shm_struct, sizeof(shm_struct));
            sem_destroy(&shm_struct->sem_mutex);
            sem_destroy(&shm_struct->sem_fill);
            sem_destroy(&shm_struct->sem_empty);
            shm_unlink(SHM_NAME);
            exit(EXIT_FAILURE);
        }

        while (1)
        {
            sem_wait(&shm_struct->sem_empty);
            if (mq_receive(queue, (char *)&bloque, sizeof(Bloque), NULL) == -1)
            {
                perror("sem_empty");
                shm_unlink(SHM_NAME);
                sem_destroy(&shm_struct->sem_mutex);
                sem_destroy(&shm_struct->sem_fill);
                sem_destroy(&shm_struct->sem_empty);
                mq_close(queue);
                unlink(MQ_NAME);
                exit(EXIT_FAILURE);
            }

            sem_wait(&shm_struct->sem_mutex);

            shm_struct->operacion[shm_struct->rear].sol = bloque.sol;

            shm_struct->operacion[shm_struct->rear].target = bloque.target;

            shm_struct->operacion[shm_struct->rear].id_bloque = bloque.id_bloque;

            shm_struct->operacion[shm_struct->rear].vot_pos = bloque.vot_pos;

            shm_struct->operacion[shm_struct->rear].vot_tot = bloque.vot_tot;

            shm_struct->operacion[shm_struct->rear].winner_pid = bloque.winner_pid;

            shm_struct->operacion[shm_struct->rear].fin = bloque.fin;

            shm_struct->operacion[shm_struct->rear].id_bloque = bloque.id_bloque;

            shm_struct->operacion[shm_struct->rear].num_pids = bloque.num_pids;

            /*  for (i = 0; i < shm_struct->operacion[shm_struct->rear].num_pids; i++)
             {
                 shm_struct->operacion[shm_struct->rear].pockets[i].money = bloque.carteras[i].money;
                 shm_struct->operacion[shm_struct->rear].pockets[i].pid = bloque.carteras[i].pid;
             } */

            for (i = 0, j = 0; j < bloque.vot_tot + 1; i++)
            {
                if (bloque.carteras[i].pid != 0)
                {
                    shm_struct->operacion[shm_struct->rear].pockets[j].money = bloque.carteras[i].money;
                    shm_struct->operacion[shm_struct->rear].pockets[j].pid = bloque.carteras[i].pid;
                    j++;
                }
            }

            result = pow_hash(bloque.sol);

            if (result == bloque.target)
            {
                shm_struct->operacion[shm_struct->rear].status = 0;
            }
            else
            {
                shm_struct->operacion[shm_struct->rear].status = 1;
            }

            if (shm_struct->operacion[shm_struct->rear].fin == 1)
            {
                break;
            }

            if (got_signal == 1)
            {
                shm_struct->operacion[shm_struct->rear].fin = 1;
            }

            shm_struct->rear = (shm_struct->rear + 1) % 5;

            sem_post(&shm_struct->sem_mutex);
            sem_post(&shm_struct->sem_fill);

            usleep(1000);

            if (shm_struct->operacion[shm_struct->rear].fin == 1)
                break;
        }

        usleep(10000);
        mq_close(queue);
        mq_unlink(MQ_NAME);
        munmap(shm_struct, sizeof(shm_struct));
        sem_destroy(&shm_struct->sem_mutex);
        sem_destroy(&shm_struct->sem_fill);
        sem_destroy(&shm_struct->sem_empty);
        shm_unlink(SHM_NAME);
        sem_close(sem);
        sem_unlink(SEM_NAME);
    }
    exit(EXIT_SUCCESS);
}