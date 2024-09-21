; === prologue ====
@t19 = constant [25 x i8] c"z = %d is less than 150\0A\00"
@t16 = constant [24 x i8] c"z = %d is equal to 150\0A\00"
@t11 = constant [28 x i8] c"z = %d is greater than 150\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main() #0{
%t1 = alloca i32, align 4
store i32 0, i32* %t1, align 4
%t2 = alloca i32, align 4
store i32 15, i32* %t2, align 4
%t3 = alloca i32, align 4
store i32 20, i32* %t3, align 4
%t4 = load i32, i32* %t3, align 4
%t5 = load i32, i32* %t2, align 4
%t6 = sub nsw i32 100, %t5
%t7 = mul nsw i32 2, %t6
%t8 = add nsw i32 %t4, %t7
store i32 %t8, i32* %t1, align 4
%t9 = load i32, i32* %t1, align 4
%t10 = icmp sgt i32 %t9, 150
br i1 %t10, label %L1, label %L2
L1:
%t12 = load i32, i32* %t1, align 4
%t13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @t11, i64 0, i64 0), i32 %t12)
br label %L3
L2:
%t14 = load i32, i32* %t1, align 4
%t15 = icmp eq i32 %t14, 150
br i1 %t15, label %L4, label %L5
L4:
%t17 = load i32, i32* %t1, align 4
%t18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([24 x i8], [24 x i8]* @t16, i64 0, i64 0), i32 %t17)
br label %L3
L5:
%t20 = load i32, i32* %t1, align 4
%t21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([25 x i8], [25 x i8]* @t19, i64 0, i64 0), i32 %t20)
br label %L3
L3:

; === epilogue ===
ret i32 0
}
