#!/usr/bin/bash 
MODE=$1
echo $MODE
#necessary compile options
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
CROSS_PREFIX=riscv64-linux-gnu

#compile opensbi-0.9
if [ ! -d "$SHELL_FOLDER/output/opensbi" ]; then
mkdir $SHELL_FOLDER/output/opensbi
fi

if [ "$MODE" = "all" ]; then
    cd $SHELL_FOLDER/opensbi-0.9
    make distclean
    make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star
fi
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/*.bin $SHELL_FOLDER/output/opensbi/
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/*.elf $SHELL_FOLDER/output/opensbi/
#compile u-boot
if [ ! -d "$SHELL_FOLDER/output/uboot" ]; then
mkdir $SHELL_FOLDER/output/uboot
fi

if [ "$MODE" = "all" ]; then
    cd $SHELL_FOLDER/u-boot-2021.07
    make distclean
    make CROSS_COMPILE=$CROSS_PREFIX- qemu-riscv64_smode_defconfig
    make CROSS_COMPILE=$CROSS_PREFIX- -j4
fi
cp $SHELL_FOLDER/u-boot-2021.07/u-boot $SHELL_FOLDER/output/uboot/u-boot.elf
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.map $SHELL_FOLDER/output/uboot/u-boot.map
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.bin $SHELL_FOLDER/output/uboot/u-boot.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/uboot/u-boot.elf > $SHELL_FOLDER/output/uboot/u-boot.lst
#compile device-tree

cd $SHELL_FOLDER/dts/scratch
dtc -I dts -O dtb -o $SHELL_FOLDER/output/uboot/qemu_board_uboot.dtb qemu_board_uboot.dts

cd $SHELL_FOLDER/dts/scratch
dtc -I dts -O dtb -o $SHELL_FOLDER/output/opensbi/qemu_board_sbi.dtb qemu_board_sbi.dts

#compile busybox-1.33.1 
if [ ! -d "$SHELL_FOLDER/output/busybox" ]; then
mkdir $SHELL_FOLDER/output/busybox
fi
#if [ "$MODE" = "all" ]; then
    #cd $SHELL_FOLDER/busybox-1.33.1
    #make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- quard_star_defconfig
    #make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j4
    #make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- install
#fi

#compile lowlevelboot
if [ ! -d "$SHELL_FOLDER/output/lowlevelboot" ]; then
mkdir $SHELL_FOLDER/output/lowlevelboot
fi
cd $SHELL_FOLDER/lowlevelboot/scratch
$CROSS_PREFIX-gcc -fno-asynchronous-unwind-tables -fno-pic -fno-builtin -fdata-sections -ffunction-sections -static -ggdb -x assembler-with-cpp -c crt0.S -o $SHELL_FOLDER/output/lowlevelboot/crt0.o
$CROSS_PREFIX-ld -T./boot.ld -Map=crt0.map --gc-sections $SHELL_FOLDER/output/lowlevelboot/crt0.o -o $SHELL_FOLDER/output/lowlevelboot/crt0.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/lowlevelboot/crt0.elf $SHELL_FOLDER/output/lowlevelboot/crt0.bin


if [ ! -d "$SHELL_FOLDER/output/linux_kernel" ]; then
mkdir $SHELL_FOLDER/output/linux_kernel
fi
if [ "$MODE" = "all" ]; then
    cd $SHELL_FOLDER/linux-5.15.175
    make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- defconfig
    make ARCH=riscv CROSS_COMPILE=$CROSS_PREFIX- -j4
fi
cp $SHELL_FOLDER/linux-5.15.175/arch/riscv/boot/Image $SHELL_FOLDER/output/linux_kernel/Image

#consturct the fw.bin file in the pflash
cd $SHELL_FOLDER/output/fw
rm -rf fw.bin
dd of=fw.bin bs=1k count=32k if=/dev/zero
dd of=fw.bin bs=1k conv=notrunc seek=0 if=$SHELL_FOLDER/output/lowlevelboot/crt0.bin
dd of=fw.bin bs=1k conv=notrunc seek=512 if=$SHELL_FOLDER/output/uboot/qemu_board_uboot.dtb
dd of=fw.bin bs=1k conv=notrunc seek=1k if=$SHELL_FOLDER/output/opensbi/fw_jump.bin
dd of=fw.bin bs=1k conv=notrunc seek=2K if=$SHELL_FOLDER/output/uboot/u-boot.bin
dd of=fw.bin bs=1k conv=notrunc seek=4K if=$SHELL_FOLDER/output/linux_kernel/Image
dd of=fw.bin bs=1k conv=notrunc seek=16K if=$SHELL_FOLDER/output/jffs2.img
