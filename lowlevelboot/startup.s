	.section .text			// define .text
	.global _start			// global symbol
	.type _start, @function // _start is function

_start:
	csrr a0, mhartid		// read hart id start from M-machine mode
	li	t0, 0x0
	beq  a0, t0, _core0
_loop:
	j _loop

_core0:
	li t0, 0x100
	slli t0, t0, 20		// t0 = 0x10000000
	li t1, 'H'
	sb t1, 0(t0)
	li t1, 'e'
	sb t1, 0(t0)
	li t1, 'l'
	sb t1, 0(t0)
	li t1, 'l'
	sb t1, 0(t0)
	li t1, 'o'
	sb t1, 0(t0)
	li t1, ','
	sb t1, 0(t0)
	li t1, 'W'
	sb t1, 0(t0)
	li t1, 'o'
	sb t1, 0(t0)
	li t1, 'r'
	sb t1, 0(t0)
	li t1, 'l'
	sb t1, 0(t0)
	li t1, 'd'
	sb t1, 0(t0)
	li t1, '!'
	sb t1, 0(t0)

	j _loop

.end
