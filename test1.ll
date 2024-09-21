; === prologue ====
@t33 = constant [27 x i8] c"You are the lowest grade.\0A\00"
@t30 = constant [47 x i8] c"You are %d points away from the lowest grade.\0A\00"
@t21 = constant [48 x i8] c"You are %d points away from the highest grade.\0A\00"
@t11 = constant [7 x i8] c"Fail.\0A\00"
@t9 = constant [7 x i8] c"Good.\0A\00"
@t5 = constant [8 x i8] c"Great.\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main() #0{
%t1 = alloca i32, align 4
store i32 96, i32* %t1, align 4
%t2 = alloca i32, align 4
store i32 85, i32* %t2, align 4
%t3 = load i32, i32* %t2, align 4
%t4 = icmp sge i32 %t3, 80
br i1 %t4, label %L1, label %L2
L1:
%t6 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @t5, i64 0, i64 0))
br label %L3
L2:
%t7 = load i32, i32* %t2, align 4
%t8 = icmp sge i32 %t7, 60
br i1 %t8, label %L4, label %L5
L4:
%t10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @t9, i64 0, i64 0))
br label %L3
L5:
%t12 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @t11, i64 0, i64 0))
br label %L3
L3:
%t13 = alloca i32, align 4
store i32 1, i32* %t13, align 4
%t14 = alloca i32, align 4
store i32 50, i32* %t14, align 4
%t15 = load i32, i32* %t1, align 4
%t16 = load i32, i32* %t2, align 4
%t17 = icmp sgt i32 %t15, %t16
br i1 %t17, label %L6, label %L7
L6:
%t18 = load i32, i32* %t1, align 4
%t19 = load i32, i32* %t2, align 4
%t20 = sub nsw i32 %t18, %t19
store i32 %t20, i32* %t13, align 4
%t22 = load i32, i32* %t13, align 4
%t23 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([48 x i8], [48 x i8]* @t21, i64 0, i64 0), i32 %t22)
%t24 = load i32, i32* %t2, align 4
%t25 = load i32, i32* %t14, align 4
%t26 = icmp sgt i32 %t24, %t25
br i1 %t26, label %L8, label %L9
L8:
%t27 = load i32, i32* %t2, align 4
%t28 = load i32, i32* %t14, align 4
%t29 = sub nsw i32 %t27, %t28
store i32 %t29, i32* %t13, align 4
%t31 = load i32, i32* %t13, align 4
%t32 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([47 x i8], [47 x i8]* @t30, i64 0, i64 0), i32 %t31)
br label %L10
L9:
%t34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([27 x i8], [27 x i8]* @t33, i64 0, i64 0))
br label %L10
L10:
br label %L11
L7:
br label %L11
L11:

; === epilogue ===
ret i32 0
}
