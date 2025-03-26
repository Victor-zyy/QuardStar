#ifndef TIMER_H
#define TIMER_H


#include <sbi/sbi_ecall_interface.h>
#include <sbi/riscv_encoding.h>
#include <sbi/riscv_asm.h>
#include "../sbi_ecall_macro.h"


void reset_timer();
void timer_irq_process();

#endif


