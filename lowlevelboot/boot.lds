OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY
{
	flash (rxai!w) : ORIGIN = 0x20000000, LENGTH = 512K
}


SECTIONS
{
	.text :
	{
		KEEP(*(.text))
	} > flash

}
