main:
	fasm main.asm
	ld main.o -lc -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o main

clean:
	rm -f main.o main