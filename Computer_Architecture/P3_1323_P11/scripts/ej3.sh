#!/bin/bash

#Variables generales
P=4

#Variables ej 3
N1=$((128 + 16 * P))
N2=$((2176 + 16 * P))
N=0
Nstep=256
Ndata=mult.dat

rm -f $Ndata $Nplot
touch $Ndata

for ((N = N1 ; N <= N2 ; N += Nstep)); do
	if ((i=="0")); then
		times_norm[$i]=0
		times_trasp[$i]=0
		normD1mr[$i]=0
		normD1mw[$i]=0
		traspD1mr[$i]=0
		traspD1mw[$i]=0
	fi;
	for((i = 0; i < 10; i++)); do
		echo "N: $N / $N2..."
		normTime_t=$(./mult_matrix "$N" | grep 'time' | awk '{print $3}')
		traspTime_t=$(./mult_trasp "$N" | grep 'time' | awk '{print $3}')

		
		times_norm[$i]=$(echo "${times_norm[$i]}" "$normTime_t" | awk '{print $1 + $2}')
		times_trasp[$i]=$(echo "${times_trasp[$i]}" "$traspTime_t" | awk '{print $1 + $2}')
	done
done

length=${#times_norm[@]}

for ((N = 0; N < length; N += 1 )); do
    Nsize=$((N1 + Nstep * N))
    echo "$N"

    normTime=$(echo "${times_norm[$N]}" | awk '{print $1/5}')
    traspTime=$(echo "${times_trasp[$N]}" | awk '{print $1/5}')

    valgrind --tool=cachegrind --cachegrind-out-file=norm.out ./mult_matrix $Nsize
    valgrind --tool=cachegrind --cachegrind-out-file=trasp.out ./mult_trasp $Nsize 

    normD1mr=$(cg_annotate norm.out | grep 'PROGRAM' | awk '{print $9}' | tr -d ',')
    normD1mw=$(cg_annotate norm.out | grep 'PROGRAM' | awk '{print $15}' | tr -d ',')
    traspD1mr=$(cg_annotate trasp.out | grep 'PROGRAM' | awk '{print $9}' | tr -d ',')
    traspD1mw=$(cg_annotate trasp.out | grep 'PROGRAM' | awk '{print $15}' | tr -d ',')

    echo "$Nsize $normTime $normD1mr $normD1mw $traspTime $traspD1mr $traspD1mw" >> "$Ndata"
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Data Cache Read Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key left bottom
set grid
set term png
set output "mult_cache_read.png"
plot "mult.dat" using 1:3 with linespoints lw 2 title "read normal", \
     "mult.dat" using 1:6 with linespoints lw 2 title "read trasp"
replot
set title "Data Cache Write Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key left bottom
set grid
set term png
set output "mult_cache_write.png"
plot "mult.dat" using 1:4 with linespoints lw 2 title "write normal", \
     "mult.dat" using 1:7 with linespoints lw 2 title "write trasp"
replot
set title "Matrix Product Times"
set ylabel "Time (s)"
set output "mult_time.png"
plot "mult.dat" using 1:2 with linespoints lw 2 title "normal", \
     "mult.dat" using 1:5 with linespoints lw 2 title "trasp"
replot
quit
END_GNUPLOT

     
