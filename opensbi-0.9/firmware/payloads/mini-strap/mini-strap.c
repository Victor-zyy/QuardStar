#include "mini-strap.h"
#include "../mini-timer/timer.h"
#include "../mini-ipi/mini-ipi.h"

#define INTERRUPT_CAUSE_TIMER 5
#define INTERRUPT_CAUSE_IPI 1
#define INTERRUPT_MASK (0x8000000000000000)

void do_exception_s(struct exception_smode_regs *p_regs, unsigned long scause){
  // []
  if(scause & INTERRUPT_MASK){
    // interrupt
    switch(scause &~ INTERRUPT_MASK){
      case INTERRUPT_CAUSE_TIMER:
	timer_irq_process();
	break;
      case INTERRUPT_CAUSE_IPI:
	//ipi_process();
	break;
    }
  }
}
