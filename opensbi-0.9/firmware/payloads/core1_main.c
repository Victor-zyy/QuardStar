#include <sbi/sbi_ecall_interface.h>
#include <sbi/riscv_encoding.h>
#include <sbi/riscv_asm.h>

#include "mini-libc/mini_printf.h"
#include "sbi_ecall_macro.h"

int core1_main(){
  // enable ipi interrupt
  csr_set(CSR_SIE, MIP_SSIP);
  // global status for interrupt
  csr_set(CSR_SSTATUS, SSTATUS_SIE);
  char dst[64];
  while(1){
    wfi();
    SBI_ECALL(SBI_EXT_BASE, SBI_EXT_BASE_GET_MSG, 0, 0, (unsigned long)dst);
    mini_printf("recv from core0: %s\n", dst);
  }
  return 0;
}
