


SOURCES := hook.asm dosmay22.asm dosblok3.asm dosblok5.asm dosblok.asm


all: discdos.tap discdos.dsk

dosblok.bin: $(SOURCES)
	z88dk-z80asm -b -m dosblok.asm

discdos.bin: dosblok.bin
	z88dk-z80asm -b booter.asm -o$@


discdos.tap: discdos.bin
	z88dk-appmake +zx --org 32768 -b $^ -o $@

discdos.dsk: discdos.bin
	z88dk-appmake +zx --plus3 --org 32768 -b $^  -o $@


clean:
	$(RM) discdos.bin dosblok.bin *.o *.sym *.map discdos.tap discdos.dsk
