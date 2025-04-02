#!/usr/bin/bash
SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
DEFAULT_VC="1280x720"

$SHELL_FOLDER/output/qemu/bin/qemu-system-riscv64 \
-M quard-star \
-m 1G \
-smp 1 \
-nographic \
-serial mon:stdio \
-drive if=pflash,bus=0,unit=0,format=raw,file=$SHELL_FOLDER/output/fw/fw.bin \
-gdb tcp::26000 -D qemu.log \
$1 \
#-drive if=mtd,format=raw,file=$SHELL_FOLDER/output/fw/fw.bin \
#-drive file=$SHELL_FOLDER/output/rootfs/rootfs.img,format=raw,id=hd0 \
#-device virtio-blk-device,drive=hd0 \
#-fw_cfg name="opt/qemu_cmdline",string="qemu_vc="$DEFAULT_V"" \
#--serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --serial vc:$DEFAULT_VC --monitor vc:$DEFAULT_VC -display gtk,show-cursor=on,window-close=on  \
