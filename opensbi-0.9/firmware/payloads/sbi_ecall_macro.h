#ifndef SBI_ECALL_MACRO_H
#define SBI_ECALL_MACRO_H


#define SBI_ECALL(__extid, __funcid, __a0, __a1, __a2)		        	\
  ({                                                                            \
		register unsigned long a0 asm("a0") = (unsigned long)(__a0);    \
		register unsigned long a1 asm("a1") = (unsigned long)(__a1);    \
		register unsigned long a2 asm("a2") = (unsigned long)(__a2);    \
		register unsigned long a6 asm("a6") = (unsigned long)(__funcid); \
		register unsigned long a7 asm("a7") = (unsigned long)(__extid); \
		asm volatile("ecall"                                            \
			     : "+r"(a0)                                       \
			     : "r"(a1), "r"(a2), "r"(a7), "r"(a6)             \
			     : "memory");                                     \
		a0;                                                           \
	})

#define SBI_ECALL_0(__num) SBI_ECALL(__num, 0, 0, 0, 0)
#define SBI_ECALL_1(__num, __a0) SBI_ECALL(__num, 0, __a0, 0, 0)
#define SBI_ECALL_2(__num, __a0, __a1) SBI_ECALL(__num, 0, __a0, __a1, 0)

#define wfi()                                             \
	do {                                              \
		__asm__ __volatile__("wfi" ::: "memory"); \
	} while (0)


#endif
