#
# SPDX-License-Identifier: BSD-2-Clause
#

platform-cppflags-y =
platform-cflags-y =
platform-asflags-y =
platform-ldflags-y =

FW_JUMP=y
FW_TEXT_START=0x80000000
FW_JUMP_ADDR=0x80200000 #uboot _start address
# arg is set to what
FW_JUMP_FDT_ADDR=0x82000000 #uboot device tree
#FW_JUMP=y
#FW_TEXT_START=0xBFF80000
#FW_JUMP_ADDR=0x0
#FW_JUMP_ADDR=0x80040000

#FW_PAYLOAD=y
#FW_PAYLOAD_OFFSET=0x00400000
