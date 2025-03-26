target remote localhost:26000
add-symbol-file ./crt0.elf
add-symbol-file ./fw_jump.elf
add-symbol-file ./test.elf
