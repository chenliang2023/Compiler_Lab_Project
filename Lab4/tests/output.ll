; ModuleID = 'module'
source_filename = "module"

@globalVar = global i32 100
@GLOBAL_CONST = global i32 1024

define i32 @complexFunction(i32 %0, i32 %1) {
complexFunctionEntry:
  %param1 = alloca i32, align 4
  store i32 %0, i32* %param1, align 4
  %param2 = alloca i32, align 4
  store i32 %1, i32* %param2, align 4
  %localResult = alloca i32, align 4
  store i32 0, i32* %localResult, align 4
  %param1_lload = load i32, i32* %param1, align 4
  %param2_lload = load i32, i32* %param2, align 4
  %tmp_gt = icmp sgt i32 %param1_lload, %param2_lload
  br i1 %tmp_gt, label %if_true, label %if_false

if_true:                                          ; preds = %complexFunctionEntry
  %param1_lload1 = load i32, i32* %param1, align 4
  %param2_lload2 = load i32, i32* %param2, align 4
  %tmp_ = sub i32 %param1_lload1, %param2_lload2
  store i32 %tmp_, i32* %localResult, align 4
  br label %if_next

if_false:                                         ; preds = %complexFunctionEntry
  %param1_lload6 = load i32, i32* %param1, align 4
  %param2_lload7 = load i32, i32* %param2, align 4
  %tmp_lt = icmp slt i32 %param1_lload6, %param2_lload7
  br i1 %tmp_lt, label %if_true3, label %if_false4

if_next:                                          ; preds = %if_next5, %if_true
  %localResult_lload21 = load i32, i32* %localResult, align 4
  ret i32 %localResult_lload21
  ret i32 0

if_true3:                                         ; preds = %if_false
  %param2_lload8 = load i32, i32* %param2, align 4
  %param1_lload9 = load i32, i32* %param1, align 4
  %tmp_10 = sub i32 %param2_lload8, %param1_lload9
  store i32 %tmp_10, i32* %localResult, align 4
  br label %while_condition

if_false4:                                        ; preds = %if_false
  %param1_lload18 = load i32, i32* %param1, align 4
  %param2_lload19 = load i32, i32* %param2, align 4
  %tmp_20 = mul i32 %param1_lload18, %param2_lload19
  store i32 %tmp_20, i32* %localResult, align 4
  br label %if_next5

if_next5:                                         ; preds = %if_false4, %after_while
  br label %if_next

while_condition:                                  ; preds = %if_next15, %if_true3
  %localResult_lload = load i32, i32* %localResult, align 4
  %GLOBAL_CONST_gload = load i32, i32* @GLOBAL_CONST, align 4
  %tmp_lt11 = icmp slt i32 %localResult_lload, %GLOBAL_CONST_gload
  br i1 %tmp_lt11, label %while_body, label %after_while

while_body:                                       ; preds = %while_condition
  %localResult_lload12 = load i32, i32* %localResult, align 4
  %tmp_13 = mul i32 %localResult_lload12, 2
  store i32 %tmp_13, i32* %localResult, align 4
  %localResult_lload16 = load i32, i32* %localResult, align 4
  %globalVar_gload = load i32, i32* @globalVar, align 4
  %tmp_gt17 = icmp sgt i32 %localResult_lload16, %globalVar_gload
  br i1 %tmp_gt17, label %if_true14, label %if_next15

after_while:                                      ; preds = %if_true14, %while_condition
  br label %if_next5

if_true14:                                        ; preds = %while_body
  br label %after_while

if_next15:                                        ; preds = %while_body
  br label %while_condition
}

define void @nestedBlocks() {
nestedBlocksEntry:
  %x = alloca i32, align 4
  store i32 5, i32* %x, align 4
  %x_lload = load i32, i32* %x, align 4
  %tmp_ = add i32 %x_lload, 3
  %y = alloca i32, align 4
  store i32 %tmp_, i32* %y, align 4
  %y_lload = load i32, i32* %y, align 4
  %tmp_1 = mul i32 %y_lload, 2
  %z = alloca i32, align 4
  store i32 %tmp_1, i32* %z, align 4
  %z_lload = load i32, i32* %z, align 4
  %tmp_gt = icmp sgt i32 %z_lload, 10
  br i1 %tmp_gt, label %if_true, label %if_next

if_true:                                          ; preds = %nestedBlocksEntry
  %z_lload2 = load i32, i32* %z, align 4
  %tmp_3 = sub i32 %z_lload2, 1
  store i32 %tmp_3, i32* %z, align 4
  br label %if_next

if_next:                                          ; preds = %if_true, %nestedBlocksEntry
  ret void
}

define i32 @factorial(i32 %0) {
factorialEntry:
  %n = alloca i32, align 4
  store i32 %0, i32* %n, align 4
  %n_lload = load i32, i32* %n, align 4
  %tmp_le = icmp sle i32 %n_lload, 1
  br i1 %tmp_le, label %if_true, label %if_next

if_true:                                          ; preds = %factorialEntry
  ret i32 1

if_next:                                          ; preds = %factorialEntry
  %n_lload1 = load i32, i32* %n, align 4
  %n_lload2 = load i32, i32* %n, align 4
  %tmp_ = sub i32 %n_lload2, 1
  %returnValue = call i32 @factorial(i32 %tmp_)
  %tmp_3 = mul i32 %n_lload1, %returnValue
  ret i32 %tmp_3
  ret i32 0
}

define i32 @mixedOperations(i32 %0, i32 %1) {
mixedOperationsEntry:
  %a = alloca i32, align 4
  store i32 %0, i32* %a, align 4
  %b = alloca i32, align 4
  store i32 %1, i32* %b, align 4
  %a_lload = load i32, i32* %a, align 4
  %b_lload = load i32, i32* %b, align 4
  %tmp_ = add i32 %a_lload, %b_lload
  %a_lload1 = load i32, i32* %a, align 4
  %b_lload2 = load i32, i32* %b, align 4
  %tmp_3 = sub i32 %a_lload1, %b_lload2
  %tmp_4 = mul i32 %tmp_, %tmp_3
  %temp = alloca i32, align 4
  store i32 %tmp_4, i32* %temp, align 4
  %temp_lload = load i32, i32* %temp, align 4
  %GLOBAL_CONST_gload = load i32, i32* @GLOBAL_CONST, align 4
  %tmp_5 = srem i32 %temp_lload, %GLOBAL_CONST_gload
  store i32 %tmp_5, i32* %temp, align 4
  %temp_lload6 = load i32, i32* %temp, align 4
  %b_lload7 = load i32, i32* %b, align 4
  %tmp_8 = add i32 %b_lload7, 1
  %tmp_9 = sdiv i32 %temp_lload6, %tmp_8
  store i32 %tmp_9, i32* %temp, align 4
  %temp_lload10 = load i32, i32* %temp, align 4
  ret i32 %temp_lload10
  ret i32 0
}

define i32 @main() {
mainEntry:
  %localConst = alloca i32, align 4
  store i32 42, i32* %localConst, align 4
  %result1 = alloca i32, align 4
  store i32 0, i32* %result1, align 4
  %result2 = alloca i32, align 4
  store i32 0, i32* %result2, align 4
  %counter = alloca i32, align 4
  store i32 0, i32* %counter, align 4
  %globalVar_gload = load i32, i32* @globalVar, align 4
  %localConst_lload = load i32, i32* %localConst, align 4
  %returnValue = call i32 @complexFunction(i32 %globalVar_gload, i32 %localConst_lload)
  store i32 %returnValue, i32* %result1, align 4
  br label %while_condition

while_condition:                                  ; preds = %if_next7, %if_true, %mainEntry
  %counter_lload = load i32, i32* %counter, align 4
  %tmp_lt = icmp slt i32 %counter_lload, 5
  br i1 %tmp_lt, label %while_body, label %after_while

while_body:                                       ; preds = %while_condition
  %result2_lload = load i32, i32* %result2, align 4
  %result1_lload = load i32, i32* %result1, align 4
  %counter_lload1 = load i32, i32* %counter, align 4
  %returnValue2 = call i32 @mixedOperations(i32 %result1_lload, i32 %counter_lload1)
  %tmp_ = add i32 %result2_lload, %returnValue2
  store i32 %tmp_, i32* %result2, align 4
  %counter_lload3 = load i32, i32* %counter, align 4
  %tmp_4 = add i32 %counter_lload3, 1
  store i32 %tmp_4, i32* %counter, align 4
  %counter_lload5 = load i32, i32* %counter, align 4
  %tmp_eq = icmp eq i32 %counter_lload5, 3
  br i1 %tmp_eq, label %if_true, label %if_next

after_while:                                      ; preds = %if_true6, %while_condition
  call void @nestedBlocks()
  %result2_lload9 = load i32, i32* %result2, align 4
  %tmp_10 = srem i32 %result2_lload9, 6
  %returnValue11 = call i32 @factorial(i32 %tmp_10)
  %finalResult = alloca i32, align 4
  store i32 %returnValue11, i32* %finalResult, align 4
  %finalResult_lload = load i32, i32* %finalResult, align 4
  %tmp_gt14 = icmp sgt i32 %finalResult_lload, 10
  br i1 %tmp_gt14, label %if_and, label %if_or

if_true:                                          ; preds = %while_body
  br label %while_condition

if_next:                                          ; preds = %while_body
  %result2_lload8 = load i32, i32* %result2, align 4
  %tmp_gt = icmp sgt i32 %result2_lload8, 1000
  br i1 %tmp_gt, label %if_true6, label %if_next7

if_true6:                                         ; preds = %if_next
  br label %after_while

if_next7:                                         ; preds = %if_next
  br label %while_condition

if_true12:                                        ; preds = %if_or, %if_and
  %finalResult_lload19 = load i32, i32* %finalResult, align 4
  %globalVar_gload20 = load i32, i32* @globalVar, align 4
  %tmp_21 = add i32 %finalResult_lload19, %globalVar_gload20
  store i32 %tmp_21, i32* %finalResult, align 4
  br label %if_next13

if_false:                                         ; preds = %if_or
  %finalResult_lload22 = load i32, i32* %finalResult, align 4
  %GLOBAL_CONST_gload = load i32, i32* @GLOBAL_CONST, align 4
  %tmp_23 = sub i32 %finalResult_lload22, %GLOBAL_CONST_gload
  store i32 %tmp_23, i32* %finalResult, align 4
  br label %if_next13

if_next13:                                        ; preds = %if_false, %if_true12
  %finalResult_lload24 = load i32, i32* %finalResult, align 4
  ret i32 %finalResult_lload24
  ret i32 0

if_or:                                            ; preds = %if_and, %after_while
  %result2_lload17 = load i32, i32* %result2, align 4
  %tmp_eq18 = icmp eq i32 %result2_lload17, 0
  br i1 %tmp_eq18, label %if_true12, label %if_false

if_and:                                           ; preds = %after_while
  %result1_lload15 = load i32, i32* %result1, align 4
  %tmp_lt16 = icmp slt i32 %result1_lload15, 200
  br i1 %tmp_lt16, label %if_true12, label %if_or
}
