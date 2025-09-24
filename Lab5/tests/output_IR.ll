; ModuleID = 'module'
source_filename = "module"

define i32 @main() {
mainEntry:
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  %max = alloca i32, align 4
  store i32 5, i32* %max, align 4
  %count = alloca i32, align 4
  store i32 0, i32* %count, align 4
  br label %while_condition

while_condition:                                  ; preds = %while_body, %mainEntry
  %i_lload = load i32, i32* %i, align 4
  %max_lload = load i32, i32* %max, align 4
  %tmp_lt = icmp slt i32 %i_lload, %max_lload
  br i1 %tmp_lt, label %while_body, label %after_while

while_body:                                       ; preds = %while_condition
  %x1 = alloca i32, align 4
  store i32 1, i32* %x1, align 4
  %x2 = alloca i32, align 4
  store i32 2, i32* %x2, align 4
  %x3 = alloca i32, align 4
  store i32 3, i32* %x3, align 4
  %count_lload = load i32, i32* %count, align 4
  %x1_lload = load i32, i32* %x1, align 4
  %tmp_ = add i32 %count_lload, %x1_lload
  %x2_lload = load i32, i32* %x2, align 4
  %tmp_1 = add i32 %tmp_, %x2_lload
  %x3_lload = load i32, i32* %x3, align 4
  %tmp_2 = add i32 %tmp_1, %x3_lload
  store i32 %tmp_2, i32* %count, align 4
  %i_lload3 = load i32, i32* %i, align 4
  %tmp_4 = add i32 %i_lload3, 1
  store i32 %tmp_4, i32* %i, align 4
  br label %while_condition

after_while:                                      ; preds = %while_condition
  %count_lload5 = load i32, i32* %count, align 4
  ret i32 %count_lload5
}
