ASM_SOURCES   := crt.s
SOURCES       := main.c stdio.c fb.c fb_console.c fb_font_vga8x16.c printk.c 
OBJECTS       := main.o stdio.o fb.o fb_console.o fb_font_vga8x16.o printk.o
ASM_OBJECTS   := crt.s.o

CFLAGS=-mabi=ilp32 -march=rv32i -Os -nostdlib -fdata-sections -ffreestanding
LDFLAGS=-T riscado.ld -m elf32lriscv -O binary

OC=riscv64-unknown-elf-objcopy
CC=riscv64-unknown-elf-gcc
LD=riscv64-unknown-elf-ld
AS=riscv64-unknown-elf-as
DUMP=riscv64-unknown-elf-objdump

TOOLCHAIN=D:/SysGCC/risc-v
TOOLCHAIN_GCC=$(TOOLCHAIN)/lib/gcc/riscv64-unknown-elf/10.1.0/rv32i/ilp32
TOOLCHAIN_LIB=$(TOOLCHAIN)/riscv64-unknown-elf/lib/rv32i/ilp32

all: prog.elf rom.mem

%.o: %.c
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

%.s.o: %.s
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

prog.elf: $(OBJECTS) $(ASM_OBJECTS)
	@echo "Linking prog.elf $(OBJECTS) $(ASM_OBJECTS)"
	@$(LD) $(LDFLAGS) $(OBJECTS) $(ASM_OBJECTS) -o prog.elf
#	@$(LD) $(LDFLAGS) $(OBJECTS) $(ASM_OBJECTS) $(TOOLCHAIN_LIB)/libm.a $(TOOLCHAIN_GCC)/libgcc.a $(TOOLCHAIN_LIB)/libc.a -o prog.elf

rom.mem: prog.elf
	@echo "Building $< -> $@"
	@$(OC) -O binary prog.elf rom.bin --only-section .text\*
#	@hxdump rom.bin  rom.mem mem4
	@hxdump rom.bin  rom.mif mif4

prog.txt: prog.elf
	@echo "Dumping $@..."
	@$(DUMP) $< -D > $@

prog.headers.txt: prog.elf
	@echo "Dumping $@..."
	@$(DUMP) $< -x > $@

clean:
	del prog.elf
	del prog.txt
	del prog.headers.txt
	del crt.s.o
	del main.o
	del stdio.o
	del fb.o
	del fb_console.o
	del fb_font_vga8x16.o
	del printk.o
