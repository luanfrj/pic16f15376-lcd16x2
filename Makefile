
ASM := gpasm

all: lcd16x2.hex

lcd16x2.hex: lcd16x2.asm
	$(ASM) -p16f15376 $^

clean:
	rm *.hex *.cod *.lst
