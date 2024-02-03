#include "minero.h"
#include "mq.h"
#include "pow.h"

int flag;                                        /*!< Bandera de proceso para que indicar solución encontrada */
int res;                                         /*!< Valor del resultado encontrado */
static volatile sig_atomic_t got_signal = 0;     /*!< Señal para indicar cuál ha sido recibida */
static volatile sig_atomic_t got_signal_fin = 0; /*!< Señal para indicar que el proceso debe terminar*/

#define MAX_INTENTOS 40 /*!< Numero de intentos máximos realizados de espera a votación */

struct _Space_t
{
    int s_ini;  /*!< Valor de inicio del espacio */
    int s_fin;  /*!< Valor de final del espacio */
    int target; /*!< Resultado a obtener */
};

/*HANDLER*/
void handler(int sig)
{
    /*SI ES SIGINT O SIGALARM ACTIVAMOS FLAG DE FINALIZACIÓN*/
    if(sig == SIGINT)
    {
        fprintf(stdout, "Finising by signal");
    }
    if (sig == SIGALRM || sig == SIGINT)
    {
        got_signal_fin = 1;
    }
    got_signal = sig;
    return;
}

/*call the function pow_hash in range Space_t to find solution.*/
void *solve(void *t)
{
    int i = 0;
    int num = 0;
    Space_t *space = t;
    for (i = space->s_ini; i < space->s_fin; i++)
    {
        num = pow_hash(i);
        if (got_signal == SIGUSR2 || got_signal_fin == 1)
        {
            return NULL;
        }
        if (num == space->target)
        {
            flag = 1;
            res = i;
        }
        if (flag == 1)
            return NULL;
    }
    return NULL;
}

int main(int argc, char *argv[])
{
    sem_t *sem = NULL;
    int errorf = 0;
    int fd_shm = 0;
    int error = 0;
    pthread_t *threads;
    int num_hilos = 0;
    Space_t spaces[num_hilos];
    pid_t pid;
    struct stat filestat;
    System *system;
    struct sigaction act1;
    sigset_t set1, set5;
    int secs = 0;
    int perdedor = 0, intentos = 0;
    int fd_pipe[2], pipe_status = 0, nbytes = 0, sem_value = -1;
    int i = 0, j = 0;
    mqd_t queue;

    flag = 0;
    res = 0;


    if (argc != 3)
    {
        perror("./miner <N_SECONDS> <N_THREADS>");
        return 1;
    }
    if (!argv)
        return 1;

    secs = atoi(argv[1]);
    if (secs < 0)
    {
        return 1;
    }

    num_hilos = atoi(argv[2]);
    if (num_hilos < 0 || num_hilos > MAX_THREAD)
    {
        return 1;
    }

    pipe_status = pipe(fd_pipe);
    if (pipe_status == -1)
    {
        perror("pipe");
        exit(EXIT_FAILURE);
    }

    // CREAMOS PROCESO REGISTRADOR
    pid = fork();
    if (pid < 0)
    {
        close(fd_pipe[0]);
        close(fd_pipe[1]);
        perror("fork");
        exit(EXIT_FAILURE);
    }
    if (pid == 0)
    {
        registrador(fd_pipe, getppid());
        exit(EXIT_SUCCESS);
    }

    // INICIALIZAMOS LAS MASCARAS DE MENSAJES.
    act1.sa_handler = handler;
    sigemptyset(&(act1.sa_mask));
    act1.sa_flags = 0;

    if (sigaction(SIGALRM, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }
    if (sigaction(SIGINT, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    if (sigaction(SIGUSR1, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    if (sigaction(SIGUSR2, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }

    sigfillset(&set1);
    sigdelset(&set1, SIGUSR1);
    sigdelset(&set1, SIGALRM);
    sigdelset(&set1, SIGINT);
    if (sigprocmask(SIG_BLOCK, &set1, NULL) < 0)
    {
        perror("sigprocmask");
        exit(EXIT_FAILURE);
    }

    sigfillset(&set5);
    sigdelset(&set5, SIGUSR2);
    sigdelset(&set5, SIGALRM);
    sigdelset(&set5, SIGINT);
    if (sigprocmask(SIG_BLOCK, &set5, NULL) < 0)
    {
        perror("sigprocmask");
        exit(EXIT_FAILURE);
    }

    // ACTIVAMOS LA ALARMA
    alarm(secs);

    // CERRAMOS PIPE DE LECTURA
    close(fd_pipe[0]);

    queue = mq_open(
        MQ_NAME,
        O_CREAT | O_WRONLY,
        S_IRUSR | S_IWUSR,
        &attributes);

    if (queue == (mqd_t)-1)
    {
        fprintf(stderr, "Error opening the queue\n");
        exit(EXIT_FAILURE);
    }

    // Abrimos la memoria compartida
    fd_shm = shm_open(SHM_NAME_MINERO, O_RDWR | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR);
    if (fd_shm == -1)
    {
        if (errno == EEXIST)
        {
            // NO ES EL PRIMER PROCESO
            /* ABRIR EL SEGMENTO Y ENLAZARLO, GARANTIZANDO QUE SE HAYA INICIALIZADO ANTES, COMPROBANDO QUE EL SEGMENTO DE MEMORIA YA TIENE TAMAÑO Y QUE EL ULTIMO SEMAFORO QUE SE VAYA A CREAR YA ESTA DISPONIBLE */
            /*  */
            fd_shm = shm_open(SHM_NAME_MINERO, O_RDWR, 0);
            if (fd_shm == -1)
            {
                perror(" Error opening the shared memory segment ");
                mq_close(queue);
                mq_unlink(MQ_NAME);
                exit(EXIT_FAILURE);
            }
            /*SE COMPRUEBA QUE EL PRIMER PROCESO(MINERO) HA ACABADO DE CREAR TODO*/
            while (1)
            {
                if (fstat(fd_shm, &filestat) == -1)
                {
                    perror("fstat");
                    exit(EXIT_FAILURE);
                }
                if (filestat.st_size == sizeof(System))
                {
                    break;
                }
                usleep(10000);
            }

            /* Mapping of the memory segment. */
            system = mmap(NULL, sizeof(System), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);
            close(fd_shm);
            if (system == MAP_FAILED)
            {
                perror("mmap");
                shm_unlink(SHM_NAME_MINERO);
                mq_close(queue);
                mq_unlink(MQ_NAME);
                exit(EXIT_FAILURE);
            }

            while (1)
            {
                if (sem_getvalue(&system->sem_empty, &sem_value) != -1)
                {
                    break;
                }
                usleep(10000);
            }

            /*INTRODUCIR EL PID EN EL ARRAY DE PIDS*/
            sem_wait(&system->sem_empty);
            sem_post(&system->sem_empty);
            sem_wait(&system->sem_mutex);
            if (system->num_pids < MAX_PIDS)
            {
                i = 0;
                while (system->pids[i] != 0)
                {
                    i++;
                }
                system->pids[i] = getpid();
                system->num_pids++;
                system->new_bloque.num_pids++;
                system->new_bloque.carteras[i].pid = getpid();
                system->new_bloque.carteras[i].money = 0;
            }
            else
            {
                sem_post(&system->sem_mutex);
                munmap(system, sizeof(System));
                exit(EXIT_SUCCESS);
            }
            sem_post(&system->sem_mutex);

            /*ESPERA SIGUSR1*/

            sigsuspend(&set1);
            if (got_signal_fin == 1)
            {

                sem_wait(&system->sem_mutex);
                if (system->num_pids == 1)
                {
                    sem_post(&system->sem_mutex);
                    sem_destroy(&system->sem_mutex);
                    sem_destroy(&system->sem_mutex);
                    sem_destroy(&system->sem_mutex);
                    munmap(system, sizeof(System));
                    close(fd_shm);
                    shm_unlink(SHM_NAME_MINERO);
                    close(fd_pipe[1]);
                }
                else
                {
                    i = 0;
                    while (system->pids[i] != getpid())
                    {
                        i++;
                    }
                    system->pids[i] = 0;
                    system->num_pids--;
                    sem_post(&system->sem_mutex);
                    munmap(system, sizeof(System));
                    close(fd_shm);
                    close(fd_pipe[1]);
                }

                exit(EXIT_SUCCESS);
            }

        }
        else
        {
            perror(" Error creating the shared memory segment \n ");
            exit(EXIT_FAILURE);
        }
    }
    // SI LA MEMORIA NO ESTABA CREADA ES QUE VA A SER EL PRIMER MINERO
    else
    {
        /*INICIALIZAR SISTEMA */
        /*DAR TAMAÑO A SEGMENTO Y ENLAZARLO AL ESPACIO DE MEMORIA*/
        if (ftruncate(fd_shm, sizeof(System)) == -1)
        {
            perror("ftruncate");
            shm_unlink(SHM_NAME_MINERO);
            exit(EXIT_FAILURE);
        }

        /* Mapping of the memory segment. */
        system = mmap(NULL, sizeof(System), PROT_READ | PROT_WRITE, MAP_SHARED, fd_shm, 0);
        close(fd_shm);
        if (system == MAP_FAILED)
        {
            perror("mmap");
            shm_unlink(SHM_NAME_MINERO);
            exit(EXIT_FAILURE);
        }
        /*CREAR SEMÁFOROS*/
        if (sem_init(&system->sem_mutex, 1, 1) == -1)
        {
            munmap(system, sizeof(System));
            shm_unlink(SHM_NAME_MINERO);
            perror("sem_mutex");
            mq_close(queue);
            mq_unlink(MQ_NAME);
            exit(EXIT_FAILURE);
        }
        if (sem_init(&system->sem_fill, 1, 0) == -1)
        {
            munmap(system, sizeof(System));
            shm_unlink(SHM_NAME_MINERO);
            sem_destroy(&system->sem_mutex);
            perror("sem_fill");
            mq_close(queue);
            mq_unlink(MQ_NAME);
            exit(EXIT_FAILURE);
        }
        if (sem_init(&system->sem_empty, 1, 0) == -1)
        {
            munmap(system, sizeof(System));
            shm_unlink(SHM_NAME_MINERO);
            sem_destroy(&system->sem_mutex);
            sem_destroy(&system->sem_fill);
            perror("sem_empty");
            mq_close(queue);
            mq_unlink(MQ_NAME);
            exit(EXIT_FAILURE);
        }

        /*ESTABLECER EL VALOR POR DEFECTO DE LOS CAMPOS*/
        sem_wait(&system->sem_mutex);
        system->num_pids = 0;
        system->new_bloque.num_pids = 0;
        while (i < MAX_PIDS)
        {
            system->pids[i] = 0;
            i++;
        }
        /* INTRODUCIR SU PID EN EL ARRAY DE PIDS Y EN EL BLOQUE*/
        system->pids[0] = getpid();
        system->num_pids += 1;
        system->new_bloque.num_pids += 1;
        system->new_bloque.id_bloque = 0;
        system->new_bloque.target = 0;
        system->new_bloque.carteras[0].pid = getpid();
        system->new_bloque.carteras[0].money = 0;
        system->new_bloque.sol = -1;
        system->new_bloque.fin = 0;
        sem_post(&system->sem_mutex);
        sem_post(&system->sem_empty);

        /*ENVÍA SIGUSR1*/
        for (i = 0; i < system->num_pids; i++)
        {
            if (system->pids[i] != getpid())
            {
                kill(system->pids[i], SIGUSR1);
            }
        }
        //sem_post(&system->sem_mutex);
    }

    /*MINEROS COMIENZAN A MINAR*/
    while (1)
    {
        threads = (pthread_t *)malloc(sizeof(pthread_t) * num_hilos);
        if (!threads)
            return -1;

        for (i = 0; i < num_hilos; i++)
        {

            spaces[i].target = system->new_bloque.target;
            spaces[i].s_ini = ((i * (POW_LIMIT - 1)) / num_hilos);
            spaces[i].s_fin = (((i + 1) * (POW_LIMIT - 1)) / num_hilos);

            error = pthread_create(&threads[i], NULL, solve, &spaces[i]);
            if (error != 0)
            {
                fprintf(stderr, "pthread_create: %s\n", strerror(error));
                free(threads);
                errorf = 1;
                break;
            }
        }
        if (errorf == 1)
        {
            break;
        }

        for (i = 0; i < num_hilos; i++)
        {
            error = pthread_join(threads[i], NULL);
            if (error != 0)
            {
                fprintf(stderr, "pthread_join: %s\n", strerror(error));
                free(threads);
                errorf = 1;
                break;
            }
        }
        if (errorf == 1)
        {
            break;
        }

        // SI RECIBE SIGINT O SIGALARM MIENTRAS MINABA SE ACABA
        if (got_signal_fin == 1)
        {
            free(threads);
            break;
        }

        /*SI ES EL PRIMERO, PONE LA SOLUCIÓN OBTENIDA Y SU PID Y ENVIA SIGUSR2 PARA QUE TODOS PAREN DE MINAR*/
        sem_wait(&system->sem_mutex);
        if (flag == 1 && system->new_bloque.sol == -1)
        {
            if (system->new_bloque.sol == -1)
            {
                j = 0;
                for (i = 0; j < system->num_pids - 1; i++)
                {
                    if (system->pids[i] != getpid() && system->pids[i] != 0)
                    {
                        kill(system->pids[i], SIGUSR2);
                        j++;
                    }
                }
                system->new_bloque.sol = res;
                system->new_bloque.winner_pid = getpid();
            }
        }
        else
        {
            perdedor = 1;
        }
        sem_post(&system->sem_mutex);

        /*SI ES PERDEDOR ESPERA SIGUSR2 PARA EMPEZAR VOTACIÓN, SI ES GANADOR ENVÍA SIGUSR2 PARA EMPEZAR VOTACIÓN*/
        if (perdedor == 1)
        {
            /*ESPERA SIGUSR2*/
            sigsuspend(&set5);
            // SI RECIBE SIGINT O SIGALARM SE ACABA
            if (got_signal_fin == 1)
            {
                free(threads);
                break;
            }

            /*VOTA*/
            sem_wait(&system->sem_mutex);
            if (pow_hash(system->new_bloque.sol) == system->new_bloque.target)
            {
                system->new_bloque.vot_pos++;
            }
            system->new_bloque.vot_tot++;
            sem_post(&system->sem_mutex);
            /*ESPERA SIGUSR1*/
            sigsuspend(&set1);
            // SI RECIBE SIGINT O SIGALARM SE ACABA
            if (got_signal_fin == 1)
            {
                free(threads);
                break;
            }
        }
        else
        {
            j = 0;
            for (i = 0; j < system->num_pids - 1; i++)
            {
                if (system->pids[i] != getpid() && system->pids[i] != 0)
                {
                    kill(system->pids[i], SIGUSR2);
                    j++;
                }
            }
            /*GANADOR HACE ESPERAS NO ACTIVAS HASTA QUE TODOS ACTUALICEN O PASEN VARIOS INTENTOS*/

            intentos = 0;
            while (intentos < MAX_INTENTOS)
            {
                if (system->new_bloque.vot_tot == system->num_pids - 1)
                {
                    break;
                }
                intentos++;
                usleep(10000);
            }
            /*COMPROBAMOS SI ESTA APROBADO Y SUMAMOS MONEDA*/
            if (system->new_bloque.vot_pos >= system->new_bloque.vot_tot / 2)
            {
                j = 0;
                for (i = 0; j < 1; i++)
                {
                    if (system->new_bloque.carteras[i].pid == getpid())
                    {
                        system->new_bloque.carteras[i].money++;
                        j++;
                    }
                }
            }

            /*ENVIA BLOQUE POR COLA DE MENSAJE A MONITOR */
            if ((sem = sem_open(SEM_NAME, O_CREAT | O_EXCL, S_IRUSR | S_IWUSR, 0)) == SEM_FAILED)
            {
                if (mq_send(queue, (char *)&system->new_bloque, sizeof(Bloque), 1) == -1)
                {
                    fprintf(stderr, "Error sending message\n");
                    exit(EXIT_FAILURE);
                }
                sem_close(sem);
            }
            else{
                sem_close(sem);
                sem_unlink(SEM_NAME);
            }

            /*PREPARACIÓN SIGUIENTE RONDA*/
            sem_wait(&system->sem_mutex);
            system->last_bloque = system->new_bloque;
            system->new_bloque.sol = -1;
            system->new_bloque.vot_pos = 0;
            system->new_bloque.vot_tot = 0;
            system->new_bloque.target = res;
            system->new_bloque.winner_pid = 0;
            system->new_bloque.fin = 0;
            system->new_bloque.id_bloque++;
            sem_post(&system->sem_mutex);

            /*ENVIO SIGUSR1 PARA VOLVER A EMPEZAR*/
            j = 0;
            for (i = 0; j < system->num_pids - 1; i++)
            {
                if (system->pids[i] != getpid() && system->pids[i] != 0)
                {
                    kill(system->pids[i], SIGUSR1);
                    j++;
                    sem_post(&system->sem_fill);
                }
            }
        }

        if (got_signal_fin == 1)
        {
            free(threads);
            break;
        }

        /*TODOS ENVÍAN POR PIPES EL BLOQUE A SU PROCESO REGISTRADOR*/
        if (perdedor == 1)
        {
            sem_wait(&system->sem_fill);
        }
        sem_wait(&system->sem_mutex);
        nbytes = write(fd_pipe[1], &system->last_bloque, sizeof(Bloque));
        if (nbytes == -1)
        {
            perror("write");
            free(threads);
            errorf = 1;
            break;
        }
        sem_post(&system->sem_mutex);

        free(threads);

        res = 0;
        flag = 0;
        perdedor = 0;
        got_signal = 0;

        /*FINALIZACIÓN*/
        if (got_signal_fin == 1)
        {
            break;
        }
        /*CIERRE DE BUCLE*/
    }

    sem_wait(&system->sem_mutex);
    /*SI ES EL ÚLTIMO, BORRA LOS SEMÁFOROS Y LA MEMORIA Y CIERRA PIPE PARA QUE TERMINE REGISTRADOR*/
    if (system->num_pids == 1)
    {
        system->new_bloque.fin = 1;
        if ((sem = sem_open(SEM_NAME, O_CREAT | O_EXCL, S_IRUSR | S_IWUSR, 0)) == SEM_FAILED)
        {
            if (mq_send(queue, (char *)&system->new_bloque, sizeof(Bloque), 1) == -1)
            {
                fprintf(stderr, "Error sending message\n");
                exit(EXIT_FAILURE);
            }
            sem_close(sem);
        }
        else
        {
            sem_close(sem);
            sem_unlink(SEM_NAME);
        }
        mq_close(queue);
        mq_unlink(MQ_NAME);
        sem_post(&system->sem_mutex);
        sem_destroy(&system->sem_mutex);
        sem_destroy(&system->sem_empty);
        sem_destroy(&system->sem_fill);
        munmap(system, sizeof(System));
        shm_unlink(SHM_NAME_MINERO);
        close(fd_pipe[1]);
    }
    else
    {
        /*SI NO ES EL ÚLTIMO SE BORRA DE PONIENDO SU PID A 0 Y CIERRA PIPE PARA QUE TERMINE REGISTRADOR*/
        i = 0;
        while (system->pids[i] != getpid())
        {
            i++;
        }
        system->pids[i] = 0;
        system->new_bloque.carteras[i].pid = 0;
        system->new_bloque.carteras[i].money = 0;
        system->num_pids--;
        system->new_bloque.num_pids--;
        sem_post(&system->sem_mutex);
        munmap(system, sizeof(System));
        mq_close(queue);
        close(fd_pipe[1]);
    }

    if (errorf == 1)
    {
        exit(EXIT_FAILURE);
    }

    exit(EXIT_SUCCESS);
}