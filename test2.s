	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 14, 0
	.globl	_main                           ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$0, 20(%rsp)
	movl	$15, 16(%rsp)
	movl	$20, 12(%rsp)
	movl	12(%rsp), %eax
	movl	$100, %ecx
	subl	16(%rsp), %ecx
	shll	%ecx
	addl	%ecx, %eax
	movl	%eax, 20(%rsp)
	cmpl	$150, 20(%rsp)
	jle	LBB0_2
## %bb.1:                               ## %L1
	movl	20(%rsp), %esi
	leaq	_t11(%rip), %rdi
	movb	$0, %al
	callq	_printf
	jmp	LBB0_5
LBB0_2:                                 ## %L2
	cmpl	$150, 20(%rsp)
	jne	LBB0_4
## %bb.3:                               ## %L4
	movl	20(%rsp), %esi
	leaq	_t16(%rip), %rdi
	movb	$0, %al
	callq	_printf
	jmp	LBB0_5
LBB0_4:                                 ## %L5
	movl	20(%rsp), %esi
	leaq	_t19(%rip), %rdi
	movb	$0, %al
	callq	_printf
LBB0_5:                                 ## %L3
	xorl	%eax, %eax
	addq	$24, %rsp
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__const
	.globl	_t19                            ## @t19
	.p2align	4, 0x0
_t19:
	.asciz	"z = %d is less than 150\n"

	.globl	_t16                            ## @t16
	.p2align	4, 0x0
_t16:
	.asciz	"z = %d is equal to 150\n"

	.globl	_t11                            ## @t11
	.p2align	4, 0x0
_t11:
	.asciz	"z = %d is greater than 150\n"

.subsections_via_symbols
