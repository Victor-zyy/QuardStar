#ifndef MINI_PRINTF_H
#define MINI_PRINTF_H


#include <sbi/sbi_ecall_interface.h>
#include <sbi/sbi_types.h>
#include "../sbi_ecall_macro.h"


#define PAD_RIGHT 1
#define PAD_ZERO 2
#define PAD_ALTERNATE 4
#define PRINT_BUF_LEN 64

#define va_start(v, l) __builtin_va_start((v), l)
#define va_end __builtin_va_end
#define va_arg __builtin_va_arg
typedef __builtin_va_list va_list;

int mini_printf(const char *format, ...);

void mini_puts(const char *str);
void mini_putc(char ch);
#endif
