; === prologue ====
@t6 = constant [28 x i8] c"a = %d, b = %d, and c = %d\0A\00"
declare dso_local i32 @printf(i8*, ...)

define dso_local i32 @main() #0{
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
store i32 1, i32* %t2, align 4
%t3 = load i32, i32* %t2, align 4
%t4 = add nsw i32 %t3, 2
store i32 %t4, i32* %t1, align 4
%t5 = alloca i32, align 4
store i32 100, i32* %t5, align 4
%t7 = load i32, i32* %t2, align 4
%t8 = load i32, i32* %t1, align 4
%t9 = load i32, i32* %t5, align 4
%t10 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([28 x i8], [28 x i8]* @t6, i64 0, i64 0), i32 %t7, i32 %t8, i32 %t9)

; === epilogue ===
ret i32 0
}
