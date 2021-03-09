/* Thanks https://github.com/darklife/darkriscv */

__heap_size     = 0x200;    /* required amount of heap  */
__stack_size    = 0x2000;    /* required amount of stack */

MEMORY
{
    ROM         (rwx) : ORIGIN = 0x00000000, LENGTH = 0x100000
    RAM         (rwx) : ORIGIN = 0x00100000, LENGTH = 0x100000
    VRAM        (rw)  : ORIGIN = 0x00200000, LENGTH = 0x100000
    IO          (rw)  : ORIGIN = 0x80000000, LENGTH = 0x001000
}
SECTIONS
{
    .text :
    {
        *(.boot)
        *(.text)
        *(.text)
        *(.rodata*)
        *(.srodata*)
    } > ROM
    .data :
    {
        *(.sbss)
        *(.data)
        *(.bss)
        *(.rela*)
        *(COMMON)
    } > RAM

    .heap :
    {
        . = ALIGN(4);
        PROVIDE ( end = . );
        _sheap = .;
        . = . + __heap_size;
        . = ALIGN(4);
        _eheap = .;
    } >RAM


    .stack :
    {
        . = ALIGN(32);
        _estack = .;
        . = . + __stack_size;
        . = ALIGN(4);
        _sstack = .;
    } >RAM

}
