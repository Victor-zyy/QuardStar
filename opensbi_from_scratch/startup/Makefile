.PNONY: clean dts all
# configure the qemu-board sbi dts
dts: qemu_board_sbi.dtb qemu_board_smp.dtb
qemu_board_sbi.dtb : qemu_board_sbi.dts
	dtc -I dts -O dtb -o $@ $<

qemu_board_smp.dtb : qemu_board_smp.dts
	dtc -I dts -O dtb -o $@ $<

CROSS_COMPILE=riscv64-linux-gnu-
# Setup compilation commands
ifdef CROSS_COMPILE
CC		=	$(CROSS_COMPILE)gcc
CPP		=	$(CROSS_COMPILE)cpp
AR		=	$(CROSS_COMPILE)ar
LD		=	$(CROSS_COMPILE)ld
OBJCOPY		=	$(CROSS_COMPILE)objcopy
else
CC		?=	gcc
CPP		?=	cpp
AR		?=	ar
LD		?=	ld
OBJCOPY		?=	objcopy
endif
AS		=	$(CC)
DTC		=	dtc
# configure the start_up file
crt0.o: crt0.S
	$(CC) -fno-asynchronous-unwind-tables -fno-pic -fno-builtin -fdata-sections -ffunction-sections -static -ggdb -x assembler-with-cpp -c crt0.S -o $@
crt0.elf: crt0.o
	$(LD) -T./boot.ld -Map=crt0.map --gc-sections crt0.o -o crt0.elf
crt0.bin: crt0.elf
	$(OBJCOPY) -O binary -S crt0.elf crt0.bin

fw.bin: crt0.bin qemu_board_sbi.dtb fw_jump.bin test.bin qemu_board_smp.dtb
	$(sleep 1)
	$(shell dd of=fw.bin bs=1k count=32k if=/dev/zero)
	$(shell dd of=fw.bin bs=1k conv=notrunc seek=0 if=crt0.bin)
	$(shell dd of=fw.bin bs=1k conv=notrunc seek=512 if=qemu_board_smp.dtb)
	$(shell dd of=fw.bin bs=1k conv=notrunc seek=1024 if=test.bin)
	$(shell dd of=fw.bin bs=1k conv=notrunc seek=2k if=fw_jump.bin)

#$(shell dd of=fw.bin bs=1k conv=notrunc seek=512 if=qemu_board_sbi.dtb)
fw_jump.bin:
	$(shell make -C /home/zyy/repo/QuardStar_Tutorial/opensbi-0.9 CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=quard_star)
	$(shell cp /home/zyy/repo/QuardStar_Tutorial/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.bin .)
	$(shell cp /home/zyy/repo/QuardStar_Tutorial/opensbi-0.9/build/platform/quard_star/firmware/fw_jump.elf .)

test.bin:
	$(shell cp /home/zyy/repo/QuardStar_Tutorial/opensbi-0.9/build/platform/quard_star/firmware/payloads/test.bin .)
	$(shell cp /home/zyy/repo/QuardStar_Tutorial/opensbi-0.9/build/platform/quard_star/firmware/payloads/test.elf .)

all: fw.bin

clean:
	rm -rf *.dtb *.o *.bin
