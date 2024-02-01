#!/bin/bash

# Inicializar variables
Ninicio=1024
Npaso=1024
Nfinal=5120
P=4
CACHE_SIZE=1024 # Tamaños de caché en Bytes
ASSOCIATIVITYS=(1 2 4 8 16)
CACHE_SIZE_UPPER=8388608  # 8 MBytes
POSICION_D1MR=9
POSICION_D1MW=15

# Bucle para N desde P hasta Q
for ((N = Ninicio + 128 * P; N <= Nfinal + 128 * P; N += Npaso)); do
    for ASSOCIATIVITY in "${ASSOCIATIVITYS[@]}"; do
        OUTPUT_FILE="cache_as_${ASSOCIATIVITY}.dat"
        # Escribir el valor de N en el archivo
        echo -n "$N " >> $OUTPUT_FILE

        for PROGRAM in "slow" "fast"; do
            # Ejecutar Valgrind con cachegrind y guardar la salida en un archivo temporal
            valgrind --tool=cachegrind --I1=$CACHE_SIZE,$ASSOCIATIVITY,64 --D1=$CACHE_SIZE,$ASSOCIATIVITY,64 --LL=$CACHE_SIZE_UPPER,$ASSOCIATIVITY,64 --cachegrind-out-file=pr_out.dat ./$PROGRAM $N

            echo ""
            echo "CG_ANNOTATE:"
            echo ""
            cg_annotate pr_out.dat | head -n 20

            LINE=$(cg_annotate pr_out.dat | head -n 20| awk 'NR==18 {print}')
            D1MR=$(echo "$LINE" | awk -v col="$POSICION_D1MR" '{print $col}')
            D1MW=$(echo "$LINE" | awk -v col="$POSICION_D1MW" '{print $col}')

            # Escribir los valores en el archivo
            echo -n "$D1MR $D1MW " >> $OUTPUT_FILE

            rm pr_out.dat
        done

        # Agregar un salto de línea al final de la línea después de escribir los resultados para cada conjunto de caché
        if [ "$((N + Npaso))" -le "$((Nfinal + 128 * P))" ]; then
            echo "" >> "$OUTPUT_FILE"
        fi
        
        sed -i 's/,//g' "$OUTPUT_FILE"
    done
done

echo "Generating plot..."
# Llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT

# Configuración del terminal y salida de las gráficas
set terminal pngcairo enhanced font 'arial,10' size 800, 600
set output 'cache_lectura_associativity.png'

# Configuración de la primera gráfica (lectura de datos)
set title 'Fallos de Lectura de Datos'
set xlabel 'Tamaño de la Matriz (N)'
set ylabel 'Número de Fallos'
plot "cache_as_1.dat" using 1:2 with linespoints title 'D1mr "1" slow', \
     "cache_as_1.dat" using 1:4 with linespoints title 'D1mr "1" fast', \
     "cache_as_2.dat" using 1:2 with linespoints title 'D1mr "2" slow', \
     "cache_as_2.dat" using 1:4 with linespoints title 'D1mr "2" fast', \
     "cache_as_4.dat" using 1:2 with linespoints title 'D1mr "4" slow', \
     "cache_as_4.dat" using 1:4 with linespoints title 'D1mr "4" fast', \
     "cache_as_8.dat" using 1:2 with linespoints title 'D1mr "8" slow', \
     "cache_as_8.dat" using 1:4 with linespoints title 'D1mr "8" fast', \
	 "cache_as_16.dat" using 1:2 with linespoints title 'D1mr "16" slow', \
     "cache_as_16.dat" using 1:4 with linespoints title 'D1mr "16" fast'

# Cambiar el nombre de salida para la segunda gráfica
set output 'cache_escritura_associativity.png'

# Configuración de la segunda gráfica (escritura de datos)
set title 'Fallos de Escritura de Datos'
set ylabel 'Número de Fallos'
plot "cache_as_1.dat" using 1:3 with linespoints title 'D1mw "1" slow', \
     "cache_as_1.dat" using 1:5 with linespoints title 'D1mw "1" fast', \
     "cache_as_2.dat" using 1:3 with linespoints title 'D1mw "2" slow', \
     "cache_as_2.dat" using 1:5 with linespoints title 'D1mw "2" fast', \
     "cache_as_4.dat" using 1:3 with linespoints title 'D1mw "4" slow', \
     "cache_as_4.dat" using 1:5 with linespoints title 'D1mw "4" fast', \
     "cache_as_8.dat" using 1:3 with linespoints title 'D1mw "8" slow', \
     "cache_as_8.dat" using 1:5 with linespoints title 'D1mw "8" fast', \
	 "cache_as_16.dat" using 1:3 with linespoints title 'D1mw "16" slow', \
     "cache_as_16.dat" using 1:5 with linespoints title 'D1mw "16" fast'

quit
END_GNUPLOT
echo "Plots generated successfully."




