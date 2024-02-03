
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include "minero.h"

void handler1(int sig)
{
    return;
}

void registrador(int *fd_pipe, pid_t padre)
{
    FILE *fp;
    int bytes_leidos;
    char filename[MAX_CHAR];
    Bloque bloque;
    int i = 0, j=0;
    struct sigaction act1;

    /*MÁSCARA PARA QUE CORTE SOLO CUANDO EL MINERO HAYA CERRADO EL PIPE*/
    act1.sa_handler = handler1;
    sigemptyset(&(act1.sa_mask));
    act1.sa_flags = 0;

    if (sigaction(SIGINT, &act1, NULL) < 0)
    {
        perror("sigaction");
        exit(EXIT_FAILURE);
    }
    /*CERRAMOS PIPE DE ESCRITURA*/
    close(fd_pipe[1]);

    /*CREAMOS EL NOMBRE DEL ARCHIVO CON EL PID DEL PADRE Y LO ABRIMOS*/
    sprintf(filename, "%d.txt", padre);

    fp = fopen(filename, "a");
    if (!fp)
        return;

    /*BUCLE DE LECTURA DEL PIPE Y ESCRITURA EN FICHERO*/
    while((bytes_leidos = read(fd_pipe[0], &bloque, sizeof(Bloque)))>0)
    {
       
        if (dprintf(fileno(fp), "Id:\t%d\n", bloque.id_bloque) == -1)
        {
            perror("read");
            close(fd_pipe[0]);
            return;
        }
        if (dprintf(fileno(fp), "Winner:\t%d\n", bloque.winner_pid) == -1)
        {
            perror("read");
            close(fd_pipe[0]);
            return;
        }
        if (dprintf(fileno(fp), "Target:\t%ld\n", bloque.target) == -1)
        {
            perror("read");
            close(fd_pipe[0]);
            return;
        }
        if (dprintf(fileno(fp), "Solution:\t%ld\n", bloque.sol) == -1)
        {
            perror("read");
            close(fd_pipe[0]);
            return;
        }
        if (dprintf(fileno(fp), "Votes:\t%d/%d\n", bloque.vot_pos + 1, bloque.vot_tot + 1) == -1)
        {
            perror("read");
            close(fd_pipe[0]);
            return;
        }
        dprintf(fileno(fp),"Wallets:\t");
        /*BUSCAMOS DE ESTÁ FORMA PARA PREVENIR QUE NO IMPRIMA CARTERAS VACÍAS DE PROCESOS QUE SE HAN CORTADO ANTES*/
        j=0;
        for(i = 0; j < bloque.vot_tot + 1 ;i++)
        {
            if(bloque.carteras[i].pid != 0)
            {
                dprintf(fileno(fp),"%d: %d  ",bloque.carteras[i].pid, bloque.carteras[i].money);
                j++;
            }
        }

        dprintf(fileno(fp),"\n\n");
    }
    close(fd_pipe[0]);
    exit(EXIT_SUCCESS);
}