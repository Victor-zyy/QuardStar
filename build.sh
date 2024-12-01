SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)

cd qemu-6.0.0
if [ ! -d "$SHELL_FOLDER/output/qemu" ]; then
./configure --prefix=$SHELL_FOLDER/output/qemu --target-list=riscv64-softmmu --enable-gtk --enable-virtfs --disable-gio
fi

make -j16
make install

cd ..


CROSS_PREFIX=riscv64-linux-gnu

if [ ! -d "$SHELL_FOLDER/output/lowlevelboot" ]; then
mkdir $SHELL_FOLDER/output/lowlevelboot
fi

cd lowlevelboot
$CROSS_PREFIX-gcc -ggdb -x assembler-with-cpp -c startup.s -o $SHELL_FOLDER/output/lowlevelboot/startup.o
$CROSS_PREFIX-gcc -nostartfiles -T./boot.lds -Wl,-Map=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.map -Wl,--gc-sections $SHELL_FOLDER/output/lowlevelboot/startup.o -o $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf
$CROSS_PREFIX-objcopy -O binary -S $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
$CROSS_PREFIX-objdump --source --demangle --disassemble --reloc --wide $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.elf > $SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.lst

# compile opensbi
if [ ! -d "$SHELL_FOLDER/output/opensbi" ]; then
mkdir $SHELL_FOLDER/output/opensbi
fi

cd $SHELL_FOLDER/opensbi-0.9
make CROSS_COMPILE=$CROSS_PREFIX- PLATFORM=quard_star
cp -r $SHELL_FOLDER/opensbi-0.9/build/platform/quard_star/firmware/*.bin $SHELL_FOLDER/output/opensbi/

# generate dtb
cd $SHELL_FOLDER/dts
dtc -I dts -O dtb -o $SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb quard_star_sbi.dts

# composite firmware
if [ ! -d "$SHELL_FOLDER/output/fw" ]; then
mkdir $SHELL_FOLDER/output/fw
fi

cd $SHELL_FOLDER/output/fw
rm -rf fw.bin
dd of=fw.bin bs=1k count=32k if=/dev/zero
dd of=fw.bin bs=1k conv=notrunc seek=0 if=$SHELL_FOLDER/output/lowlevelboot/lowlevel_fw.bin
dd of=fw.bin bs=1k conv=notrunc seek=512 if=$SHELL_FOLDER/output/opensbi/quard_star_sbi.dtb
dd of=fw.bin bs=1k conv=notrunc seek=2k if=$SHELL_FOLDER/output/opensbi/fw_jump.bin

cd $SHELL_FOLDER
