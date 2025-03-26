#!/usr/bin/bash
## $1 -S augument can run in qemu-debug mode to gdb debug
SHELL_FOLDER=/home/zyy/repo/QuardStar_Tutorial
DEFAULT_VC="1280x720"

$SHELL_FOLDER/output/qemu/bin/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 2 \
-gdb tcp::26000 -D qemu.log \
-drive if=pflash,bus=0,unit=0,format=raw,file=fw.bin \
--serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --monitor vc:$DEFAULT_VC -display gtk,show-cursor=on,window-close=on \
--parallel none $1
