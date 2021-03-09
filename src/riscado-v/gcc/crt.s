.global _boot
.section .boot

_boot:
  nop
  nop
  lui		x2,	%hi(_sstack)
  addi	x2, x2, %lo(_sstack)
  j			main

