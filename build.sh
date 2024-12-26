SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

# compile qemu
cd qemu-6.0.0
if [ ! -d "$SHELL_FOLDER/output/qemu" ]; then
./configure --prefix=$SHELL_FOLDER/output/qemu --target-list=riscv64-softmmu --enable-gtk --enable-virtfs --disable-gio
fi

#make -j16
#make install

cd ..


CROSS_PREFIX=riscv64-linux-gnu
#CROSS_PREFIX=riscv64-unknown-elf

if [ ! -d "$SHELL_FOLDER/output/lowlevelboot" ]; then
mkdir $SHELL_FOLDER/output/lowlevelboot
fi

cd lowlevelboot
$CROSS_PREFIX-gcc -fno-asynchronous-unwind-tables -fno-pic -fno-builtin -fdata-sections -ffunction-sections -static -ggdb -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/output/lowlevelboot/startup.o
$CROSS_PREFIX-ld -T./boot.ld -Map=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.map --gc-sections $SHELL_FOLDER/output/lowlevelboot/startup.o -o $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf > $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.lst

# compile opensbi
if [ ! -d "$SHELL_FOLDER/output/opensbi" ]; then
mkdir $SHELL_FOLDER/output/opensbi
fi

cd $SHELL_FOLDER/opensbi-0.9
#make distclean
make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/*.bin $SHELL_FOLDER/output/opensbi/
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/*.elf $SHELL_FOLDER/output/opensbi/

# generate dtb
cd $SHELL_FOLDER/dts
#dtc -I dts -O dtb -o $SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb quard_star_sbi.dts

# compile trusted_domain
if [ ! -d "$SHELL_FOLDER/output/trusted_domain" ]; then  
mkdir $SHELL_FOLDER/output/trusted_domain
fi 

cd $SHELL_FOLDER/trusted_domain
$CROSS_PREFIX-gcc -fno-asynchronous-unwind-tables -fno-pic -fno-builtin -fdata-sections -ffunction-sections -static -ggdb -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/output/trusted_domain/startup.o
$CROSS_PREFIX-ld -T./link.ld -Map=$SHELL_FOLDER/output/trusted_domain/trusted_fw.map --gc-sections $SHELL_FOLDER/output/trusted_domain/startup.o -o $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf $SHELL_FOLDER/output/trusted_domain/trusted_fw.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/trusted_domain/trusted_fw.elf > $SHELL_FOLDER/output/trusted_domain/trusted_fw.lst

# compile u-boot
if [ ! -d "$SHELL_FOLDER/output/uboot" ]; then
mkdir $SHELL_FOLDER/output/uboot
fi
cd $SHELL_FOLDER/u-boot-2021.07
#make CROSS_COMPILE=$CROSS_PREFIX- qemu-quard-star_defconfig
#make CROSS_COMPILE=$CROSS_PREFIX- -j4
cp $SHELL_FOLDER/u-boot-2021.07/u-boot $SHELL_FOLDER/output/uboot/u-boot.elf
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.map $SHELL_FOLDER/output/uboot/u-boot.map
cp $SHELL_FOLDER/u-boot-2021.07/u-boot.bin $SHELL_FOLDER/output/uboot/u-boot.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/uboot/u-boot.elf > $SHELL_FOLDER/output/uboot/u-boot.lst

# generate uboot.dtb
cd $SHELL_FOLDER/dts
#dtc -I dts -O dtb -o $SHELL_FOLDER/output/uboot/quard_star_uboot.dtb quard_star_uboot.dts


# composite firmware
if [ ! -d "$SHELL_FOLDER/output/fw" ]; then
mkdir $SHELL_FOLDER/output/fw
fi

cd $SHELL_FOLDER/output/fw
rm -rf fw.bin
dd of=fw.bin bs=1k count=32k if=/dev/zero
dd of=fw.bin bs=1k conv=notrunc seek=0 if=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
dd of=fw.bin bs=1k conv=notrunc seek=512 if=$SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb
dd of=fw.bin bs=1k conv=notrunc seek=1K if=$SHELL_FOLDER/output/uboot/quard_star_uboot.dtb
dd of=fw.bin bs=1k conv=notrunc seek=2k if=$SHELL_FOLDER/output/opensbi/fw_jump.bin
dd of=fw.bin bs=1k conv=notrunc seek=4k if=$SHELL_FOLDER/output/trusted_domain/trusted_fw.bin
dd of=fw.bin bs=1k conv=notrunc seek=8K if=$SHELL_FOLDER/output/uboot/u-boot.bin

cd $SHELL_FOLDER
