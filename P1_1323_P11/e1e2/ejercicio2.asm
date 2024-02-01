.data
numbers:
  .word 5, 9, 2, 1, 8, 6, 4, 7, 3, 10
n: .word 10

.text
.globl _start

_start:
  # Cargar la dirección del arreglo de números
  la a0, numbers
  # Cargar el número de elementos (10) en a1
  lw a1, n
  li t0, 1  # Inicializar t0 con 1 para indicar si se realizaron intercambios

outer_loop:
  li t1, 0  # Inicializar t1 con 0 para el índice del bucle interno

inner_loop:
  lw t2, 0(a0)    # Cargar el elemento actual del arreglo
  lw t3, 4(a0)    # Cargar el elemento siguiente del arreglo
  bge t2, t3, no_swap  # Salta si el elemento actual no es mayor que el siguiente

  # Intercambiar elementos en el arreglo
  sw t2, 4(a0)
  sw t3, 0(a0)
  li t0, 1  # Indicar que se realizó un intercambio

no_swap:
  addi t1, t1, 1  # Incrementar el índice del bucle interno
  addi a0, a0, 4  # Avanzar al siguiente par de elementos
  blt t1, a1, inner_loop  # Volver al bucle interno si no hemos terminado

  beqz t0, sorted  # Si no se realizaron intercambios, la lista está ordenada

  # Reiniciar el indicador de intercambios y volver al inicio del arreglo
  li t0, 0
  la a0, numbers
  j outer_loop

sorted:
  # Terminar el programa
  li a7, 10      # Llamada al sistema para salir del programa (en RISC-V)
  ecall
