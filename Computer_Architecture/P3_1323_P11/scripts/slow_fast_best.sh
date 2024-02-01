#!/bin/bash

# Inicializar variables
Ninicio=1024
Npaso=1024
Nfinal=5120
P=4
LINEA=64
CACHE_SIZE=8192 # Tamaños de caché en Bytes
ASSOCIATIVITY=16
CACHE_SIZE_UPPER=8388608  # 8 MBytes
POSICION_D1MR=9
POSICION_D1MW=15

# Bucle para N desde P hasta Q
for ((N = Ninicio + 128 * P; N <= Nfinal + 128 * P; N += Npaso)); do
	OUTPUT_FILE="cache_best.dat"
	# Escribir el valor de N en el archivo
	echo -n "$N " >> $OUTPUT_FILE

	for PROGRAM in "slow" "fast"; do
		# Ejecutar Valgrind con cachegrind y guardar la salida en un archivo temporal
		valgrind --tool=cachegrind --I1=$CACHE_SIZE,$ASSOCIATIVITY,$LINEA --D1=$CACHE_SIZE,$ASSOCIATIVITY,$LINEA --LL=$CACHE_SIZE_UPPER,$ASSOCIATIVITY,$LINEA --cachegrind-out-file=pr_out.dat ./$PROGRAM $N

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

echo "Generating plot..."
# Llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT

# Configuración del terminal y salida de las gráficas
set terminal pngcairo enhanced font 'arial,10' size 800, 600
set output 'cache_lectura_BEST.png'

# Configuración de la primera gráfica (lectura de datos)
set title 'Fallos de Lectura de Datos'
set xlabel 'Tamaño de la Matriz (N)'
set ylabel 'Número de Fallos'
plot "cache_best.dat" using 1:2 with linespoints title 'D1mr slow', \
     "cache_best.dat" using 1:4 with linespoints title 'D1mr fast'


# Cambiar el nombre de salida para la segunda gráfica
set output 'cache_escritura_BEST.png'

# Configuración de la segunda gráfica (escritura de datos)
set title 'Fallos de Escritura de Datos'
set ylabel 'Número de Fallos'
plot "cache_best.dat" using 1:3 with linespoints title 'D1mw slow', \
     "cache_best.dat" using 1:5 with linespoints title 'D1mw fast'

quit
END_GNUPLOT
echo "Plots generated successfully."




