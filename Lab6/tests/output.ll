  .text
  .globl main
main:
  addi sp, sp, -16
mainEntry:
#1:   %i = alloca i32, align 4
#------------------------
#2:   store i32 0, i32* %i, align 4
  li t0, 0
  sw t0, 8(sp)
#------------------------
#3:   %max = alloca i32, align 4
#------------------------
#4:   store i32 5, i32* %max, align 4
  li t0, 5
  mv a2, t0
#------------------------
#5:   %count = alloca i32, align 4
#------------------------
#6:   store i32 0, i32* %count, align 4
  li t0, 0
  sw t0, 12(sp)
#------------------------
#7:   br label %while_condition
  j while_condition
#------------------------
while_condition:
#8:   %i_lload = load i32, i32* %i, align 4
  lw t0, 8(sp)
  mv a3, t0
#------------------------
#9:   %max_lload = load i32, i32* %max, align 4
  mv t2, a2
  mv a1, t2
#------------------------
#10:   %tmp_lt = icmp slt i32 %i_lload, %max_lload
  mv t0, a3
  mv t1, a1
  slt t2, t0, t1
  mv a2, t2
#------------------------
#11:   br i1 %tmp_lt, label %while_body, label %after_while
  mv t0, a2
  bne t0, x0, while_body
  j after_while
#------------------------
while_body:
#12:   %x1 = alloca i32, align 4
#------------------------
#13:   store i32 1, i32* %x1, align 4
  li t0, 1
  mv a3, t0
#------------------------
#14:   %x2 = alloca i32, align 4
#------------------------
#15:   store i32 2, i32* %x2, align 4
  li t0, 2
  sw t0, 0(sp)
#------------------------
#16:   %x3 = alloca i32, align 4
#------------------------
#17:   store i32 3, i32* %x3, align 4
  li t0, 3
  sw t0, 4(sp)
#------------------------
#18:   %count_lload = load i32, i32* %count, align 4
  lw t0, 12(sp)
  mv a2, t0
#------------------------
#19:   %x1_lload = load i32, i32* %x1, align 4
  mv t2, a3
  mv a1, t2
#------------------------
#20:   %tmp_ = add i32 %count_lload, %x1_lload
  mv t0, a2
  mv t1, a1
  add t0, t0, t1
  mv a3, t0
#------------------------
#21:   %x2_lload = load i32, i32* %x2, align 4
  lw t0, 0(sp)
  mv a2, t0
#------------------------
#22:   %tmp_1 = add i32 %tmp_, %x2_lload
  mv t0, a3
  mv t1, a2
  add t0, t0, t1
  mv a1, t0
#------------------------
#23:   %x3_lload = load i32, i32* %x3, align 4
  lw t0, 4(sp)
  mv a3, t0
#------------------------
#24:   %tmp_2 = add i32 %tmp_1, %x3_lload
  mv t0, a1
  mv t1, a3
  add t0, t0, t1
  mv a2, t0
#------------------------
#25:   store i32 %tmp_2, i32* %count, align 4
  mv t0, a2
  sw t0, 12(sp)
#------------------------
#26:   %i_lload3 = load i32, i32* %i, align 4
  lw t0, 8(sp)
  mv a1, t0
#------------------------
#27:   %tmp_4 = add i32 %i_lload3, 1
  mv t0, a1
  li t1, 1
  add t0, t0, t1
  mv a3, t0
#------------------------
#28:   store i32 %tmp_4, i32* %i, align 4
  mv t0, a3
  sw t0, 8(sp)
#------------------------
#29:   br label %while_condition
  j while_condition
#------------------------
after_while:
#30:   %count_lload5 = load i32, i32* %count, align 4
  lw t0, 12(sp)
  mv a2, t0
#------------------------
#31:   ret i32 %count_lload5
  mv a0, a2
  addi sp, sp, 16
  li a7, 93
  ecall
#------------------------
