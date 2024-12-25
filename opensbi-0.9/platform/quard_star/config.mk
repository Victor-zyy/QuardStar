#
# SPDX-License-Identifier: BSD-2-Clause
#

platform-cppflags-y =
platform-cflags-y =
platform-asflags-y =
platform-ldflags-y =

FW_JUMP=y
FW_TEXT_START=0x80000000
#FW_JUMP_ADDR=0x0
FW_JUMP_ADDR=0x80040000

FW_PAYLOAD=y
FW_PAYLOAD_OFFSET=0x00040000
