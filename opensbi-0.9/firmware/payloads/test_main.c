/*
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2019 Western Digital Corporation or its affiliates.
 *
 * Authors:
 *   Anup Patel <anup.patel@wdc.com>
 */
#include <sbi/sbi_ecall_interface.h>
#include "mini-libc/mini_printf.h"
#include "mini-timer/timer.h"
#include "sbi_ecall_macro.h"


int jtime = 0;

char src_str[64] = "hello, this is core0\n";
void test_main(unsigned long a0, unsigned long a1)
{
	mini_printf("\nTest payload mini_printf!\n");
	reset_timer();

	while (1){

	  wfi();
	  if(jtime < 20){
	    mini_printf("\nTest timer interrupt : %d!\n", jtime);
	  }

	  if(jtime == 10){ // 10s hsm wake the core 1 up
	    // SBI_EXT_HSM
	    // regs->a0 hartid
	    // rges->a1 saddr
	    // rges->a2 priv
	    SBI_ECALL(SBI_EXT_HSM, SBI_EXT_HSM_HART_START, 1, 0x80400000, 1); 
	  }

	  if(jtime == 20){
	    // regs->a0 hmask
	    // reg->a1 hbase
	    SBI_ECALL(SBI_EXT_IPI, SBI_EXT_IPI_SEND_MSG_IPI, 2, 0, (unsigned long)src_str);
	  }
	}
}
