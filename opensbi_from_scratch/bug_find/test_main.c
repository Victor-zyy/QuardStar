
//char src_str[64] = "hello, this is core0\n";
void test_main(unsigned long a0, unsigned long a1)
{
	char src_str[64] = "hello, this is core0\n"; // error undefined memset
        __builtin_trap();
	while (1){
            mini_printf("%s", src_str);            
	}
}
