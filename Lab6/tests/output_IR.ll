; ModuleID = 'module'
source_filename = "module"

@global_var = global i32 1

define i32 @main() {
mainEntry:
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %while_condition

while_condition:                                  ; preds = %while_body, %mainEntry
  %i_lload = load i32, i32* %i, align 4
  %tmp_lt = icmp slt i32 %i_lload, 1
  br i1 %tmp_lt, label %while_body, label %after_while

while_body:                                       ; preds = %while_condition
  %i_lload1 = load i32, i32* %i, align 4
  %tmp_ = add i32 %i_lload1, 1
  store i32 %tmp_, i32* %i, align 4
  br label %while_condition

after_while:                                      ; preds = %while_condition
  %i_lload2 = load i32, i32* %i, align 4
  ret i32 %i_lload2
}
