#
# SPDX-License-Identifier: BSD-2-Clause
#
# Copyright (c) 2019 Western Digital Corporation or its affiliates.
#
# Authors:
#   Anup Patel <anup.patel@wdc.com>
#

firmware-bins-$(FW_PAYLOAD) += payloads/test.bin

test-y += test_head.o
test-y += mini-libc/mini_printf.o
test-y += mini-timer/timer.o
test-y += mini-strap/mini-strap.o
test-y += mini-ipi/mini-ipi.o
test-y += core1_main.o
test-y += test_main.o

%/test.o: $(foreach obj,$(test-y),%/$(obj))
	$(call merge_objs,$@,$^)

%/test.dep: $(foreach dep,$(test-y:.o=.dep),%/$(dep))
	$(call merge_deps,$@,$^)
