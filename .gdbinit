target remote localhost:26000
add-symbol-file ./output/opensbi/fw_jump.elf
add-symbol-file ./output/uboot/u-boot.elf
add-symbol-file ./output/opensbi/fw_payload.elf
add-symbol-file ./output/lowlevelboot/lowlevel_fw.elf
add-symbol-file ./output/trusted_domain/trusted_fw.elf
