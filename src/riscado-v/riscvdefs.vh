/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`define LOAD_STORE_BYTE         2'b00
`define LOAD_STORE_HALF         2'b01
`define LOAD_STORE_WORD         2'b10

`define ALU_SRC_A_REG           2'b00
`define ALU_SRC_A_PC            2'b01
`define ALU_SRC_A_PREV_PC       2'b10

`define ALU_SRC_B_REG           3'b000
`define ALU_SRC_B_IMM_I_TYPE    3'b001
`define ALU_SRC_B_IMM_S_TYPE    3'b010
`define ALU_SRC_B_IMM_B_TYPE    3'b011
`define ALU_SRC_B_IMM_U_TYPE    3'b100
`define ALU_SRC_B_IMM_J_TYPE    3'b101

`define ALU_ADD                 4'b0000
`define ALU_SLL                 4'b0001
`define ALU_SLT                 4'b0010
`define ALU_SLTU                4'b0011
`define ALU_XOR                 4'b0100
`define ALU_SRL                 4'b0101
`define ALU_OR                  4'b0110
`define ALU_AND                 4'b0111
`define ALU_SUB                 4'b1000
`define ALU_SRA                 4'b1101
`define ALU_A                   4'b1001
`define ALU_B                   4'b1010
`define ALU_EQ                  4'b1100

`define REG_DATA_SRC_ALU        2'b00
`define REG_DATA_SRC_MEM        2'b01
`define REG_DATA_SRC_PC         2'b10
