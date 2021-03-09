/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "riscvdefs.vh"

module RISCV (
  input         clk,
  input         reset,
  input [31:0]  dataIn,
  output [31:0] dataOut,
  output [31:0] address,
  output        writeEnable
);

  reg [31:0]  ir = 0;
  wire        irWriteEnable;    // Registrador IR recebe os dados do BUS
  wire        addressIsPc;      // O endereço no BUS é do PC ou resultado da ALU?
  wire        incrementPc;      // Incrementa o PC com +4?
  wire [31:0] dataAddress;      // O endereço de dados é sempre a saída da ALU
  wire [1:0]  regDataSrc;       // O valor para escrever no registrador é da memória, resultado da ALU ou PC?
  wire        regWriteEnable;   // Habilita a escrita no registrador
  wire        pcWriteEnable;    // Habilita a escrita no PC
  wire [31:0] pcAddress;        // Endereço PC
  wire [31:0] pcPrevAddress;    // Endereço Anterior PC
  wire [1:0]  aluSrcA;          // Operando A da ALU (Registrador ou PC)
  wire [2:0]  aluSrcB;          // Operando B da ALU
  wire [3:0]  aluOperation;     // Operação da ALU
  wire [1:0]  readLen;          // Tamanho da leitura
  wire [1:0]  writeLen;         // Tamanho da escrita
  wire        readSignExtend;   // Extender o dado lido com sinal
  wire [31:0] lsReadDataOut;
           
  
  
  // O endereço de memória calculado é o PC ou a saída calculada na ALU?
  assign address = addressIsPc ? pcAddress : dataAddress;
  
  // Recebe a nova instrução.
  always @(posedge clk)
  begin
    if (irWriteEnable)
      ir <= lsReadDataOut;
  end
  
  wire [31:0] aluResult;
  
  ControlUnit ctrlUnit(
    .clk(clk),
    .reset(reset),
    .dataIn(lsReadDataOut),
    .readLen(readLen),
    .writeLen(writeLen),
    .aluFlag(aluResult[0]),
    .writeEnable(writeEnable),
    .irWriteEnable(irWriteEnable),
    .addressIsPc(addressIsPc),
    .incrementPc(incrementPc),
    .ir(ir),
    .regDataSrc(regDataSrc),
    .pcWriteEnable(pcWriteEnable),
    .regWriteEnable(regWriteEnable),
    .aluSrcA(aluSrcA),
    .aluSrcB(aluSrcB),
    .aluOperation(aluOperation),
    .readSignExtend(readSignExtend)
  );
  
  // ALU
  wire [4:0]  regRs1  = ir[19:15];
  wire [4:0]  regRs2  = ir[24:20];
  wire [4:0]  regRd   = ir[11:7];
  wire [31:0] rs1;
  wire [31:0] rs2;
  wire [31:0] regDataIn;
  
  // Escrever o resultado da ALU, memória ou PC no registrador?
  assign regDataIn = (regDataSrc == `REG_DATA_SRC_ALU) ? aluResult :
                     (regDataSrc == `REG_DATA_SRC_MEM) ? lsReadDataOut :
                     (regDataSrc == `REG_DATA_SRC_PC)  ? pcAddress :
                      0;
  
  
  LoadStore ls(
    .dataIn(dataIn),
    .offset(address[1:0]),
    
    .readLen(readLen),
    .readSignExtend(readSignExtend),
    .readDataOut(lsReadDataOut),
    
    .writeLen(writeLen),
    .writeDataIn(rs2),
    .writeDataOut(dataOut)
  );
  
  RegisterFile registerFile(
    .clk(clk),
    .ia(regRs1),
    .ib(regRs2),
    .dst(regRd),
    .oa(rs1),
    .ob(rs2),
    .dataIn(regDataIn),
    .writeEnable(regWriteEnable)
  );
    
  ProgramCounter pc(
    .clk(clk),
    .reset(reset),
    .dataIn(aluResult),
    .writeEnable(pcWriteEnable),
    .increment(incrementPc),
    .currentPc(pcAddress),
    .prevPc(pcPrevAddress)
  );

  
  // Seleciona a entrada B da ALU
  wire [31:0] aluInputA;
  assign aluInputA = (aluSrcA == `ALU_SRC_A_REG) ? rs1 :
                     (aluSrcA == `ALU_SRC_A_PC) ? pcAddress :
                     (aluSrcA == `ALU_SRC_A_PREV_PC) ? pcPrevAddress :
                     0;
  
  // Seleciona a entrada B da ALU
  wire [31:0] aluInputB;
  assign aluInputB = (aluSrcB == `ALU_SRC_B_REG) ? rs2 :
                     (aluSrcB == `ALU_SRC_B_IMM_U_TYPE) ? { ir[31:12], 12'b0 } :
                     (aluSrcB == `ALU_SRC_B_IMM_I_TYPE) ? { {20{ir[31]}}, ir[31:20] } :
                     (aluSrcB == `ALU_SRC_B_IMM_B_TYPE) ? { {19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0 } :
                     (aluSrcB == `ALU_SRC_B_IMM_J_TYPE) ? { {11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0 } :
                     (aluSrcB == `ALU_SRC_B_IMM_S_TYPE) ? { {20{ir[31]}}, ir[31:25], ir[11:7] } :
                     0;

  assign dataAddress = aluResult;
  ALU alu(
    .a(aluInputA),
    .b(aluInputB),
    .operation(aluOperation),
    .result(aluResult)
  );
  

endmodule
