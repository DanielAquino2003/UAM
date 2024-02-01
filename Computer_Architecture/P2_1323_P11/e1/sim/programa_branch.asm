.data 
num0:  .word 1  # posic 0
num1:  .word 2  # posic 4
num2:  .word 4  # posic 8 
num3:  .word 8  # posic 12 
num4:  .word 16 # posic 16 
num5:  .word 32 # posic 20
num6:  .word 0  # posic 24
num7:  .word 0  # posic 28
num8:  .word 0  # posic 32
num9:  .word 0  # posic 36
num10: .word 0  # posic 40
num11: .word 0  # posic 44

.text 
main:

  lw t1, 0
  lw t2, 4
  lw t3, 8 
  lw t4, 12 
  lw t5, 16
  lw t6, 20
  
  # vamos a jugar con los riesgos de datos (beq)
  
  funciona:
  add t2, t1, t3
  add t1, t2, t3 
  sub t2, t2, t3  
  add t4, t5, t6 
  sub t4, t4, t5  
  sub t5, t4, t1 
  beq t4, t1, etiqueta      
  add t3, t1, t2  
  add t1, t3, t2  
  add t3, t1, t2 
  add t1, t1, t2  
  beq t1, t3, etiqueta
  add t2, t4, t3  
  add s0, t1, t2  
  add s0, s0, s0  
  add s1, s0, s0  
  add t3, t1, t2  
  
  etiqueta:
  sw t3, 24
  lw t2, 24
  beq t2, t1, funciona
  add t4, t1, t2  
  nop      
  sw t4, 28
