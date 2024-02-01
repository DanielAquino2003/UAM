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
  
  # vamos a jugar con los riesgos de datos sobre lw
  
  add t2, t1, t3  
  add t1, t2, t3  
  sub t2, t2, t3  
  lw t3, 0
  add t4, t2, t3  
  lw t3, 4
  nop
  add t4, t2, t3  
  nop
  nop
  lw t3, 8   
  nop
  nop
  add t4, t2, t3  
  lw t4, 0	 
  sw t3, 0(t4)	 
  lw t4, 16
  addi t4, t3, 20  
  nop  
  nop
  add t2, t3, t4  
  lw t2, 16
