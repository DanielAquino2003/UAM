.data 
num0:  .word 1  # posic 0
num1:  .word 2  # posic 4
num2:  .word 4  # posic 8 
num3:  .word 8  # posic 12 
num4:  .word 16 # posic 16 
num5:  .word 32 # posic 20

.text 
main:

  lw t1, 0 
  lw t2, 4 
  lw t3, 8   
  lw t4, 12 
  lw t5, 16 
  lw t6, 20 
  
  # vamos a jugar con los riesgos de datos
  
  add t2, t1, t3  
  add t1, t2, t3  
  sub t2, t2, t3  
  add t4, t5, t6  
  sub t4, t4, t5  
  sub t5, t4, t1  
  nop
  nop
  add t3, t1, t2  
  add t1, t3, t2   
  add t3, t1, t2  
  nop
  nop
  add t3, t1, t2 
