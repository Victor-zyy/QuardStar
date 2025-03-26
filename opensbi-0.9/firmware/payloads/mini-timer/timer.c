#include "timer.h"

#define sbi_ecall_set_time(t) SBI_ECALL_1(SBI_EXT_0_1_SET_TIMER, (t))
#define CLINT_TIMEBASE_FREQ 10000000  //100ns
#define TIME_SECOND_TICKS 10000000

/* read mtime register to get curent time cycles */
extern int jtime;
static unsigned long get_ticks()
{
	unsigned long n;

	__asm__ __volatile__("rdtime %0" : "=r"(n));
	return n;
}
void reset_timer()
{
  
  /* set mtimecmp for about 1s + mtime */
  sbi_ecall_set_time(get_ticks() + TIME_SECOND_TICKS);
  /* enable interrupt */
  csr_set(CSR_SIE, MIP_STIP);
  /* enable global interrupt */
  csr_set(CSR_SSTATUS, SSTATUS_SIE);

}


void timer_irq_process(){
  csr_clear(CSR_SIE, MIP_STIP);
  jtime++;
  reset_timer();
}
