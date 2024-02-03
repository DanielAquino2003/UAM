#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <math.h>
#include <sys/types.h>
#include <mqueue.h>
#include <sys/wait.h>
#include <signal.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <semaphore.h>
#include <errno.h>
#include <sys/mman.h>
#include <string.h>


#ifndef _MINER_H
#define _MINER_H
#define MAX_THREAD 3    /*!< numero máximo de hilos por proceso */
#define MAX_PIDS 100     /*!< Numero máximo de procesos en el sistema */
#define SHM_NAME_MINERO "/shm_minero"    /*!< Nombre de la memoria compartida del sistema */
#define MAX_CHAR 128     /*!< Máximo de carácteres */



typedef struct _Space_t Space_t;

/*!< (RECURSOS DE LA RED) */

/*!<CARTERA*/
typedef struct _Cartera
{
    pid_t pid;  /*!< Pid del proceso propietario de la cartera */
    int money;  /*!< Numero de monedas obtenidas*/
} Cartera;

/*!<BLOQUE*/
typedef struct _Bloque
{
    int id_bloque;              /*!< Id del bloque */
    int num_pids;
    long int target;            /*!< Target */
    long int sol;               /*!< Solucion del target */
    pid_t winner_pid;           /*!< Pid del proceso ganador */
    Cartera carteras[MAX_PIDS]; /*!< Array de carteras de todos los procesos */
    int vot_tot;                /*!< Numero de votos totales*/
    int vot_pos;                /*!< Numero de votos positivos */
    int fin;                    /*!< Flag de finalización */
} Bloque;

/*!<SEGMENTO DE MEMORIA DEL SISTEMA*/
typedef struct _System
{
    pid_t pids[MAX_PIDS];   /*!< Array con todos los pids del sistema */
    int num_pids;           /*!< Numero de pids en el sistema */
    int voting[MAX_PIDS];   /*!< Valor de inicio del espacio */
    int money[MAX_PIDS];    /*!< Monedas de los procesos */
    Bloque last_bloque;     /*!< Ultimo bloque solucionado*/
    Bloque new_bloque;      /*!< Bloque actual */
    sem_t sem_mutex;        /*!< Semaforo que controla la escritura y lectura de la memoria */
    sem_t sem_empty;        /*!< Semáforo de control */
    sem_t sem_fill;         /*!< Semáforo de control */
}System;


/**
 * @brief call the function pow_hash in range Space_t
 * to find solution.
 *
 *
 * @param void *t with a struct Space_t
 * @return Return NULL
 */
void *solve(void *t);

/**
 * @brief Create num_hilos threads and allocates memory for them.
 * Call with each thread the function solve with a diferent space.
 *
 * @param int num_hilos number of threads to create. int target (result t search)
 * @return -1 in case of error, and resultado (res) in case is all ok.

 */
int mining(int num_hilos, int target);

/**
 * @brief Proceso hijo del minero que crea un txt con el pid del minero como nombre
 * y registra los bloques en cada ronda.
 *
 * @param int *fd_pipe pipe por el que se recibirá el bloque.
 * @param pid_t padre para crear el nombre del archivo.txt

 */
void registrador(int *fd_pipe, pid_t padre);



#endif