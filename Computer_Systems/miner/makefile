CC=gcc 
CFLAGS=-Wall -ggdb -pedantic
SHM_C = /dev/shm/shm_comprobador
SHM_M = /dev/shm/shm_minero
all: monitor minero

minero: minero.o registrador.o pow.o 
	$(CC) -o $@ $^	

monitor: comprobador.o monitor.o pow.o 
	$(CC) -o $@ $^

monitor.o: monitor.c comprobador.h pow.h 
	$(CC) -c -o $@ $< $(CFLAGS) 

comprobador.o: comprobador.c comprobador.h minero.h pow.h mq.h
	$(CC) -c -o $@ $< $(CFLAGS)

minero.o: minero.c minero.h pow.h mq.h
	$(CC) -c -o $@ $< $(CFLAGS)

pow.o: pow.c pow.h
	$(CC) -c -o $@ $< $(CFLAGS)	

registrador.o: registrador.c minero.h 
	$(CC) -c -o $@ $< $(CFLAGS)



clean:
	rm *.o *.txt minero monitor $(SHM_C) $(SHM_M)

run_monitor:
	./monitor

runv_monitor:
	valgrind ./monitor 

run_minero:
	./minero 5 3

runv_minero:
	valgrind ./minero 25 100

rm_shm:
	rm $(SHM_C) $(SHM_M)

