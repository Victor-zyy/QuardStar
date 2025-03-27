// define loop count	
.macro loop,count
        li		t1,	0xffff
        li		t2,	\count
1:
	nop
	addi    t1, t1, -1
	bne		t1, x0, 1b
        li		t1,	0xffff
	addi    t2, t2, -1
	bne		t2, x0, 1b
.endm

// load data from src_start to [dst_start - dst_end]
.macro load_data,_src_start,_dst_start,_dst_end
	bgeu	\_dst_start, \_dst_end, 2f
1:
	lw      t0, (\_src_start)
	sw      t0, (\_dst_start)
	addi    \_src_start, \_src_start, 4
	addi    \_dst_start, \_dst_start, 4
	bltu    \_dst_start, \_dst_end, 1b
2:
.endm

// crt0.S startup
	
	.section .text
	.globl _start
	.type _start,@function
_start:	
	// mhartid
	csrr	a0, 	mhartid
	bnez	a0, 	_wait_copy_done
	
        // relocate .data section
        la      a0,     _sidata         //a0 = _sidata source data address FLASH
        la      a1,     _sdata          //a1 = dst relocate address
        la      a2,     _edata          //a2 = end relocate address data VMA

        load_data       a0,     a1,     a2 

	// opensbi 
	// 0x20200000  [0x80000000-0x80200000] 2MBytes
	li 	a0, 	0x202
	slli 	a0, 	a0, 	20
	li 	a1, 	0x800
	slli 	a1, 	a1, 	20
	li 	a2, 	0x802
	slli 	a2, 	a2, 	20

	load_data a0,	a1,	a2

	// load device tree
	// 0x20080000  [0x82200000-0x82280000]
	li 	a0, 	0x2008
	slli 	a0, 	a0, 	16
	li 	a1, 	0x822
	slli 	a1, 	a1, 	20
	li 	a2, 	0x8228
	slli 	a2, 	a2, 	16

	load_data a0,	a1,	a2

	// load uboot 0x9a47e ~ 1MB
	// 0x20800000  [0x80200000-0x80400000]
	li 	a0, 	0x208
	slli 	a0, 	a0, 	20
	li 	a1, 	0x802
	slli 	a1, 	a1, 	20
	li 	a2, 	0x804
	slli 	a2, 	a2, 	20

	load_data a0,	a1,	a2



	la	t0, _copy_done
	li	t1,	1
	sd	t1,	0(t0)
	j	_no_wait


_wait_copy_done:
	loop 0x2000
1:	
	la	t0, _copy_done
	ld	t0,	0(t0)
	beqz	t0,	1b
	
	
_no_wait:	
	// we just have one core 
	csrr 	a0, 	mhartid
	
	// a0 = mhartid
	// a1 = device_tree address 0x82200000
	// 
	li	a1,	0x822
	slli	a1,	a1,	20
	li	t0,	0x800
	slli	t0,	t0,	20

	jr 	t0

	.align 3

	.section .data
	.globl _copy_done
        .type  _copy_done, %object
_copy_done: //64-bit
	.dword	0


	.end
