#!/bin/bash

Ninicio=512+4
Npaso=64
Nfinal=$((Ninicio + 1024))

echo "Running mult_serie and mult_par1..."

for((N=Ninicio; N<= Nfinal; N+=Npaso)); do
    echo "Tamaño de matriz: $N"
    multserieTime=$(./../src-libs/mult_serie "$N" | grep 'time' | awk '{print $3}')
    multparTime=$(./../src-libs/mult_par1 "$N" 2 | grep 'time' | awk '{print $3}')

    echo "$N $multserieTime $multparTime" >> ../data/ej3.dat
done

fDAT="../data/ej3.dat"
fPNG="../img/ej3.png"

rm -f ../img/ej3.png

echo "Generating plot..."
# Llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Serie-Paralelo tiempo ejecucion"
set ylabel "Tiempo ejecucion (s)"
set xlabel "Tamaño matriz"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "serie", \
     "$fDAT" using 1:3 with lines lw 2 title "paralelo"
quit
END_GNUPLOT