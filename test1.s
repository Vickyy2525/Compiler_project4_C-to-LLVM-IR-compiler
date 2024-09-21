	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 14, 0
	.globl	_main                           ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$32, %rsp
	movl	$96, -4(%rbp)
	movl	$85, -8(%rbp)
	cmpl	$80, -8(%rbp)
	jl	LBB0_2
## %bb.1:                               ## %L1
	leaq	_t5(%rip), %rdi
	movb	$0, %al
	callq	_printf
	jmp	LBB0_5
LBB0_2:                                 ## %L2
	cmpl	$60, -8(%rbp)
	jl	LBB0_4
## %bb.3:                               ## %L4
	leaq	_t9(%rip), %rdi
	movb	$0, %al
	callq	_printf
	jmp	LBB0_5
LBB0_4:                                 ## %L5
	leaq	_t11(%rip), %rdi
	movb	$0, %al
	callq	_printf
LBB0_5:                                 ## %L3
	movq	%rsp, %rax
	movq	%rax, %rcx
	addq	$-16, %rcx
	movq	%rcx, -24(%rbp)                 ## 8-byte Spill
	movq	%rcx, %rsp
	movl	$1, -16(%rax)
	movq	%rsp, %rax
	addq	$-16, %rax
	movq	%rax, -16(%rbp)                 ## 8-byte Spill
	movq	%rax, %rsp
	movl	$50, (%rax)
	movl	-4(%rbp), %eax
	cmpl	-8(%rbp), %eax
	jle	LBB0_10
## %bb.6:                               ## %L6
	movq	-24(%rbp), %rax                 ## 8-byte Reload
	movl	-4(%rbp), %ecx
	subl	-8(%rbp), %ecx
	movl	%ecx, (%rax)
	movl	(%rax), %esi
	leaq	_t21(%rip), %rdi
	movb	$0, %al
	callq	_printf
	movq	-16(%rbp), %rcx                 ## 8-byte Reload
	movl	-8(%rbp), %eax
	cmpl	(%rcx), %eax
	jle	LBB0_8
## %bb.7:                               ## %L8
	movq	-24(%rbp), %rax                 ## 8-byte Reload
	movq	-16(%rbp), %rdx                 ## 8-byte Reload
	movl	-8(%rbp), %ecx
	subl	(%rdx), %ecx
	movl	%ecx, (%rax)
	movl	(%rax), %esi
	leaq	_t30(%rip), %rdi
	movb	$0, %al
	callq	_printf
	jmp	LBB0_9
LBB0_8:                                 ## %L9
	leaq	_t33(%rip), %rdi
	movb	$0, %al
	callq	_printf
LBB0_9:                                 ## %L10
	jmp	LBB0_11
LBB0_10:                                ## %L7
	jmp	LBB0_11
LBB0_11:                                ## %L11
	xorl	%eax, %eax
	movq	%rbp, %rsp
	popq	%rbp
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__const
	.globl	_t33                            ## @t33
	.p2align	4, 0x0
_t33:
	.asciz	"You are the lowest grade.\n"

	.globl	_t30                            ## @t30
	.p2align	4, 0x0
_t30:
	.asciz	"You are %d points away from the lowest grade.\n"

	.globl	_t21                            ## @t21
	.p2align	4, 0x0
_t21:
	.asciz	"You are %d points away from the highest grade.\n"

	.globl	_t11                            ## @t11
_t11:
	.asciz	"Fail.\n"

	.globl	_t9                             ## @t9
_t9:
	.asciz	"Good.\n"

	.globl	_t5                             ## @t5
_t5:
	.asciz	"Great.\n"

.subsections_via_symbols
