


SOURCES := hook.asm dosmay22.asm dosblok3.asm dosblok5.asm


all: discdos.tap

dosblok.bin: $(SOURCES)
	z88dk-z80asm -b -m dosblok.asm

booter.bin: dosblok.bin
	z88dk-z80asm -b booter.asm


discdos.tap: booter.bin
	z88dk-appmake +zx --org 32768 -b booter.bin


clean:
	$(RM) booter.bin dosblok.bin discdos.tap *.o *.sym *.map booter.tap
