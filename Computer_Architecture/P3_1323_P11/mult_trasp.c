#include <stdio.h>
#include "arqo3.h"

int main(int argc, char *argv[]){
	int n, i, j, k;
	tipo **a = NULL, **b = NULL, **bt = NULL, **c = NULL;
	struct timeval fin, ini;

	printf("Word size: %ld bits\n", 8*sizeof(tipo));

	if(argc != 2){
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}

	n = atoi(argv[1]);
	a = generateMatrix(n);
	b = generateMatrix(n);
    bt = generateEmptyMatrix(n);
	c = generateEmptyMatrix(n);

	gettimeofday(&ini, NULL);

    for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			bt[i][j] = b[j][i];
		}
	}

	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			for(k = 0; k < n; k++){
				c[i][j] += a[i][k] * bt[j][k];
			}
		}
	}

	gettimeofday(&fin, NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

	freeMatrix(a);
	freeMatrix(b);
    freeMatrix(bt);
	freeMatrix(c);
	return 0;
}