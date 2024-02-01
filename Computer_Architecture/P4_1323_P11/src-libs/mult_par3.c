#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "arqo4.h"
#include "omp.h"

int main(int argc, char *argv[]){
	int n, i, j, k, nproc;
	float **a = NULL, **b = NULL, **c = NULL;
	struct timeval fin, ini;

	printf("Word size: %ld bits\n", 8*sizeof(float));

	if(argc != 3){
		printf("Error: ./%s <matrix size><number cores>\n", argv[0]);
		return -1;
	}

	n = atoi(argv[1]);
	a = generateMatrix(n);
	b = generateMatrix(n);
	c = generateEmptyMatrix(n);
    nproc = atoi(argv[2]);
    omp_set_num_threads(nproc);

	gettimeofday(&ini, NULL);
#pragma omp parallel for private(j, k)
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			for(k = 0; k < n; k++){
				c[i][j] += a[i][k] * b[k][j];
			}
		}
	}

	gettimeofday(&fin, NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	freeMatrix(a);
	freeMatrix(b);
	freeMatrix(c);
	return 0;
}