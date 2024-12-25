	.macro loop,cunt
        li		t1,	0xffff
        li		t2,	\cunt
1:
	nop
	addi    t1, t1, -1
	bne		t1, x0, 1b
        li		t1,	0xffff
	addi    t2, t2, -1
	bne		t2, x0, 1b
	.endm

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

        .section .data
        .global _pen
        .type   _pen, %object
_pen:
        .word   1


	.section .text
	.globl _start
	.type _start,@function

_start:
        csrr    a0,     mhartid
        bne     a0,     zero,     _copy_ddr_memory_wait
        
        // relocate .data section
        la      a0,     _sidata         //a0 = _sidata source data address FLASH
        la      a1,     _sdata          //a1 = dst relocate address
        la      a2,     _edata          //a2 = end relocate address data VMA
        load_data       a0,     a1,     a2 

        // only CPU 0 copy necesarry bin file to DDR memory
        // use flag bit to let other CPUS(SMP) to wait 
        la      t0,     _pen
        la      t1,     1
        sw      t1,     0(t0) 

	//load opensbi_fw.bin 
	//[0x20200000:0x20400000] --> [0xBFF80000:0xC0000000] 512K 0x80000
        li      a0,     0x202
	slli	a0,	a0,     20      //a0 = 0x20200000
        li		a1,	0xbff
	slli	a1,	a1,     20      //a1 = 0xBFF80000
        li              a2,     0x800
	slli	a2,	a2,     8      
        add     a1,     a1,     a2
        li		a2,	0xC00
	slli	a2,	a2,     20      //a2 = 0xC0000000
	load_data   a0,     a1,     a2

	//load qemu_sbi.dtb
	//[0x20080000:0x20100000] --> [0xBFF00000:0xBFF80000]
        li		a0,	0x2008
	slli	a0,	a0,     16       //a0 = 0x20080000
        li		a1,	0xBFF
	slli	a1,	a1,     20       //a1 = 0xBFF00000
        li      a2,     0x800
        slli    a2,     a2,     8
        add     a2,     a1,     a2   //a2 = 0xBFF80000
	load_data       a0,     a1,     a2

	//load trusted_fw.bin
	//[0x20400000:0x20800000] --> [0xBF800000:0xBFC00000]
        li		a0,	0x204
	slli	a0,	a0,     20      //a0 = 0x20400000
        li		a1,	0xbf8
	slli	a1,	a1, 20      //a1 = 0xbf800000
        li		a2,	0xbfc
	slli	a2,	a2, 20      //a2 = 0xbfc00000
	load_data       a0,     a1,     a2

	//load qemu_uboot.dtb
	//[0x20100000:0x20180000] --> [0xB0000000:0xB0080000]
        li		a0,	0x201
	slli	a0,	a0,     20       //a0 = 0x20100000
	li		a1,	0xB00
	slli	a1,	a1,     20       //a1 = 0xB0000000
        li		a2,	0x800
	slli	a2,	a2,     8       
        add     a2,     a1,     a2       //a2 = 0xB0080000
	load_data       a0,     a1,     a2

	//load u-boot.bin
	//[0x20800000:0x20C00000] --> [0xB0200000:0xB0600000]
        li		a0,	0x208
	slli	a0,	a0, 20      //a0 = 0x20800000
        li		a1,	0xB02
	slli	a1,	a1, 20      //a1 = 0x80200000
        li		a2,	0xB06
	slli	a2,	a2, 20      //a2 = 0x80600000
	load_data       a0,     a1,     a2
        j       _no_wait

_copy_ddr_memory_wait:
        loop    0x2000
        la      t0,     _pen
        lw      t0,     0(t0)
        beq     t0,     zero,   _no_wait
        j       _copy_ddr_memory_wait

        // boot CPU 0
        // others CPU1~7 a0 = mhartid loop finished jump opensbi firmware
        // a0 bootid 
        // a1 device tree addr
        // a2 ....
_no_wait:
        csrr    a0,     mhartid
        li      a1,     0xbff           // set a1 device tree address
        slli    a1,     a1,     20      // set a2 device tree end address
        li      t0,     0x800
        slli    t0,     t0,     8
        add     t0,     a1,     t0      // to = 0xbff80000
        la      t1,     _pen
        sw      zero,   0(t1)           // clear flag bit
        jr      t0                      // jump t0 = 0xbff80000
    
        .end

