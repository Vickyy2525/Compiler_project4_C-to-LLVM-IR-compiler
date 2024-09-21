	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 14, 0
	.globl	_main                           ## -- Begin function main
	.p2align	4, 0x90
_main:                                  ## @main
	.cfi_startproc
## %bb.0:
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	$1, 16(%rsp)
	movl	16(%rsp), %eax
	addl	$2, %eax
	movl	%eax, 20(%rsp)
	movl	$100, 12(%rsp)
	movl	16(%rsp), %esi
	movl	20(%rsp), %edx
	movl	12(%rsp), %ecx
	leaq	_t6(%rip), %rdi
	movb	$0, %al
	callq	_printf
	xorl	%eax, %eax
	addq	$24, %rsp
	retq
	.cfi_endproc
                                        ## -- End function
	.section	__TEXT,__const
	.globl	_t6                             ## @t6
	.p2align	4, 0x0
_t6:
	.asciz	"a = %d, b = %d, and c = %d\n"

.subsections_via_symbols
