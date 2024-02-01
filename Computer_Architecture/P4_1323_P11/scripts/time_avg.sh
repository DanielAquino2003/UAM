#!/bin/bash

# Número de ejecuciones
num_executions=15

# Ruta al programa
program_path="../src-libs/edgeDetector"

# Lista de imágenes
images=("../img/SD.jpg" "../img/HD.jpg" "../img/FHD.jpg" "../img/4k.jpg" "../img/8k.jpg")

# Asociar cada imagen con su tiempo total
declare -A image_times

# Iterar sobre cada imagen
for image in "${images[@]}"
do
    echo "Procesando imagen: $image"
    total_time=0

    # Ejecutar el programa 50 veces para cada imagen
    for ((i=1; i<=$num_executions; i++))
    do
        echo "  Ejecución $i:"
        execution_time=$($program_path "$image" | grep "Tiempo:" | awk '{print $2}')
        echo "  Tiempo: $execution_time segundos"
        total_time=$(echo "$total_time + $execution_time" | bc)
    done

    # Calcular la media de tiempo para la imagen actual
    average_time=$(echo "scale=6; $total_time / $num_executions" | bc)

    # Almacenar la media de tiempo en el arreglo asociativo
    image_times["$image"]=$average_time
done

# Mostrar la media de tiempos para todas las imágenes al final
echo "Medias de tiempo para todas las imágenes:"
for image in "${images[@]}"
do
    echo "$image: ${image_times[$image]} segundos"
done
