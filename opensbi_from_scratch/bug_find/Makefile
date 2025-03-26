all:
	riscv64-linux-gnu-gcc -g -Wall -nostdlib -mabi=lp64 -march=rv64imafdc -mcmodel=medany -fno-pie -no-pie  -fno-tree-loop-distribute-patterns test_main.c test_head.S  -Wl,-T./test.elf.ld -o test.elf
clean:
	rm -rf *.elf

        #riscv63-linux-gnu-gcc -g -Wall -nostdlib -fno-builtin-memset -fno-strict-aliasing -fno-omit-frame-pointer -fno-optimize-sibling-calls -mno-save-restore -mstrict-align -mabi=lp64 -march=rv64imafdc -mcmodel=medany -fno-pie -no-pie -Wl,--build-id=none -N  test_main.c test_head.S  -Wl,-T./test.elf.ld -o test.elf
