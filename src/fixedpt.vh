/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
// Aritmética de ponto fixo
`ifndef __FIXPT
`define __FIXPT
`define FIXPT_REAL_BITS         22
`define FIXPT_FRACTION_BITS     10
`define FIXPT_SIZE              32
`define FIXPT_SIZE_L            64
`define FIXPT_INT(n)            {n,`FIXPT_FRACTION_BITS'b0}
`define FIXPT_TO_INT(n)         (n[`FIXPT_SIZE-1:`FIXPT_FRACTION_BITS])
`define FIXPT_FRAC(n)           (n[`FIXPT_FRACTION_BITS-1:0])
`define FIXPT_MUL(a,b)          ($signed(({ {`FIXPT_SIZE{a[`FIXPT_SIZE-1]}}, (a)}) * (b)) >>> `FIXPT_FRACTION_BITS)
`define FIXPT                   signed [`FIXPT_SIZE  -1:0]
`define FIXPT_L                 signed [`FIXPT_SIZE_L-1:0]

`define MIN(a,b)                (((a)<(b))?(a):(b))
`define MAX(a,b)                (((a)>(b))?(a):(b))
`define SATURATE(min,max,a)     `MIN((max),`MAX((min),(a)))

`endif