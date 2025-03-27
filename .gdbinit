target remote localhost:26000
add-symbol-file ./output/opensbi/fw_jump.elf
add-symbol-file ./output/uboot/u-boot.elf
add-symbol-file ./output/lowlevelboot/crt0.elf
add-symbol-file ./output/uboot/u-boot.elf
