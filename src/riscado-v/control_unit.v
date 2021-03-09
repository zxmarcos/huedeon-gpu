/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "riscvdefs.vh"

module ControlUnit(
  input             clk,
  input             reset,
  input [31:0]      dataIn,
  input [31:0]      ir,
  input             aluFlag,
  output reg        writeEnable,
  output reg        irWriteEnable,
  output reg        addressIsPc,
  output reg        incrementPc,
  output reg [1:0]  regDataSrc,
  output reg        regWriteEnable,
  output reg        pcWriteEnable,
  output reg [1:0]  aluSrcA,
  output reg [2:0]  aluSrcB,
  output reg [3:0]  aluOperation,
  output reg [1:0]  readLen,
  output reg [1:0]  writeLen,
  output reg        readSignExtend
);
  parameter [2:0] FETCH0  = 0;
  parameter [2:0] FETCH1  = 1;
  parameter [2:0] DECODE  = 2;
  parameter [2:0] EX1     = 3;
  parameter [2:0] EX2     = 4;
  parameter [2:0] EX3     = 5;
  parameter [2:0] EX4     = 6;

  
  reg [2:0] state;
  wire [2:0] funct3 = ir[14:12];
  wire [6:0] funct7 = ir[31:25];
  wire [6:0] opcode = ir[6:0];
  
  reg branchTestTrue = 0;
  
  always @(posedge clk)
  begin
    if (reset)
    begin
      state           <= FETCH0;
      writeEnable     <= 0;
      regWriteEnable  <= 0;
      incrementPc     <= 0;
      addressIsPc     <= 1;
      aluSrcA         <= `ALU_SRC_A_REG;
      aluSrcB         <= `ALU_SRC_B_REG;
      pcWriteEnable   <= 0;
      readLen         <= `LOAD_STORE_WORD;
      writeLen        <= `LOAD_STORE_WORD;
      readSignExtend  <= 0;
    end
    else
    begin
      if (state == FETCH0) 
      begin
        $display("FETCH0");
        writeEnable     <= 0;
        state           <= FETCH1;
        irWriteEnable   <= 1;
        addressIsPc     <= 1;
        incrementPc     <= 1;
        regWriteEnable  <= 0;
        regDataSrc      <= `REG_DATA_SRC_ALU;
        aluSrcA         <= `ALU_SRC_A_REG;
        aluSrcB         <= `ALU_SRC_B_REG;
        aluOperation    <= `ALU_A;
        pcWriteEnable   <= 0;
        branchTestTrue  <= 0;
        writeLen        <= `LOAD_STORE_WORD;
        readLen         <= `LOAD_STORE_WORD;
        readSignExtend  <= 0;
      end
      else
      if (state == FETCH1)
      begin
        $display("FETCH1");
        state         <= DECODE;
        irWriteEnable <= 0;
        incrementPc   <= 0;
      end
      else
      begin
        $display("Execute %x", ir);
        // LUI
        if (opcode == 7'b0110111)
        begin
          $display("LUI");
          aluSrcB         <= `ALU_SRC_B_IMM_U_TYPE;
          aluOperation    <= `ALU_B;
          regWriteEnable  <= 1;
          state           <= FETCH0;
        end
        else
        // AUIPC
        if (opcode == 7'b0010111)
        begin
          $display("AUIPC");
          aluSrcA         <= `ALU_SRC_A_PREV_PC;
          aluSrcB         <= `ALU_SRC_B_IMM_U_TYPE;
          aluOperation    <= `ALU_ADD;
          regWriteEnable  <= 1;
          pcWriteEnable   <= 1;
          state           <= FETCH0;
        end
        else
        // I-TYPE
        if (opcode == 7'b0010011)
        begin
          $display("I-TYPE");
          case (funct3)
          3'b000: aluOperation <= `ALU_ADD; 
          3'b001: aluOperation <= `ALU_SLL; 
          3'b010: aluOperation <= `ALU_SLT; 
          3'b011: aluOperation <= `ALU_SLTU; 
          3'b100: aluOperation <= `ALU_XOR; 
          3'b101: aluOperation <= (funct7 == 7'h20) ? `ALU_SRA : `ALU_SRL; 
          3'b110: aluOperation <= `ALU_OR; 
          3'b111: aluOperation <= `ALU_AND;
          endcase
          regWriteEnable  <= 1;
          aluSrcB         <= `ALU_SRC_B_IMM_I_TYPE;
          state           <= FETCH0;
        end
        else
        // R-TYPE
        if (opcode == 7'b0110011)
        begin
          $display("R-TYPE"); 
          case (funct3)
          3'b000: aluOperation <= (funct7 == 7'h20) ? `ALU_SUB : `ALU_ADD;
          3'b001: aluOperation <= `ALU_SLL;
          3'b010: aluOperation <= `ALU_SLT;
          3'b011: aluOperation <= `ALU_SLTU;
          3'b100: aluOperation <= `ALU_XOR;
          3'b101: aluOperation <= (funct7 == 7'h20) ? `ALU_SRA : `ALU_SRL;
          3'b110: aluOperation <= `ALU_OR;
          3'b111: aluOperation <= `ALU_AND;
          endcase
          regWriteEnable  <= 1;
          aluSrcB         <= `ALU_SRC_B_REG;
          state           <= FETCH0;
        end
        else
        // B-TYPE
        if (opcode == 7'b1100011)
        begin
          $display("B-TYPE");
          if (state == DECODE)
          begin
            case (funct3)
            3'b000: begin aluOperation <= `ALU_EQ;    branchTestTrue <= 1;  end // BEQ
            3'b001: begin aluOperation <= `ALU_EQ;                          end // BNE
            3'b100: begin aluOperation <= `ALU_SLT;   branchTestTrue <= 1;  end // BLT
            3'b101: begin aluOperation <= `ALU_SLT;                         end // BGE
            3'b110: begin aluOperation <= `ALU_SLTU;  branchTestTrue <= 1;  end // BLTU
            3'b111: begin aluOperation <= `ALU_SLTU;                        end // BGEU
            default:      aluOperation <= `ALU_EQ; 
            endcase
            state <= EX1;
          end
          else
          if (state == EX1)
          begin
            aluSrcA       <= `ALU_SRC_A_PREV_PC;
            aluSrcB       <= `ALU_SRC_B_IMM_B_TYPE;
            aluOperation  <= `ALU_ADD;
            
            if ((branchTestTrue & aluFlag) | (~branchTestTrue & ~aluFlag))
            begin
              pcWriteEnable <= 1;
              state         <= EX2;
            end
            else
            begin
              state         <= FETCH0;
            end
            
          end
          else
          if (state == EX2)
          begin
            // Delay?
            pcWriteEnable <= 0;
            state         <= FETCH0;
          end
        end
        else
        // JAL
        if (opcode == 7'b1101111)
        begin
          $display("JAL");
          if (state == DECODE)
          begin
            aluSrcA         <= `ALU_SRC_A_PREV_PC;
            aluSrcB         <= `ALU_SRC_B_IMM_J_TYPE;
            aluOperation    <= `ALU_ADD;
            regDataSrc      <= `REG_DATA_SRC_PC;
            pcWriteEnable   <= 1;
            regWriteEnable  <= 1;
            state           <= EX1;
          end
          else
          begin
            // Delay?
            pcWriteEnable   <= 0;
            regWriteEnable  <= 0;
            state           <= FETCH0;
          end
        end
        else
        // JALR
        if (opcode == 7'b1100111)
        begin
          $display("JALR");
          if (state == DECODE)
          begin
            aluSrcA         <= `ALU_SRC_A_REG;
            aluSrcB         <= `ALU_SRC_B_IMM_I_TYPE;
            aluOperation    <= `ALU_ADD;
            regDataSrc      <= `REG_DATA_SRC_PC;
            pcWriteEnable   <= 1;
            regWriteEnable  <= 1;
            state           <= EX1;
          end
          else
          begin
            // Delay?
            pcWriteEnable   <= 0;
            regWriteEnable  <= 0;
            state           <= FETCH0;
          end
        end
        else
        // Loads
        if (opcode == 7'b0000011)
        begin
          if (state == DECODE)
          begin
            aluSrcA       <= `ALU_SRC_A_REG;
            aluSrcB       <= `ALU_SRC_B_IMM_I_TYPE;
            aluOperation  <= `ALU_ADD;
            regDataSrc    <= `REG_DATA_SRC_MEM;
            addressIsPc   <= 0;
            state         <= EX1;
          end
          else
          if (state == EX1)
          begin
            case (funct3)
            3'b000: begin readLen <= `LOAD_STORE_BYTE; readSignExtend <= 1; end
            3'b001: begin readLen <= `LOAD_STORE_HALF; readSignExtend <= 1; end
            3'b010: begin readLen <= `LOAD_STORE_WORD; end
            3'b100: begin readLen <= `LOAD_STORE_BYTE; end
            3'b101: begin readLen <= `LOAD_STORE_HALF; end
            endcase
            regWriteEnable  <= 1;
            state           <= EX2;
          end
          else
          if (state == EX2)
          begin
            regWriteEnable  <= 0;
            addressIsPc     <= 1;
            state           <= FETCH0;
          end
        end
        else
        // Stores
        if (opcode == 7'b0100011)
        begin
          if (state == DECODE)
          begin
            aluSrcA         <= `ALU_SRC_A_REG;
            aluSrcB         <= `ALU_SRC_B_IMM_S_TYPE;
            aluOperation    <= `ALU_ADD;
            regDataSrc      <= `REG_DATA_SRC_MEM;
            readLen         <= `LOAD_STORE_WORD;
            readSignExtend  <= 0;
            addressIsPc     <= 0;
            state           <= EX1;
          end
          else
          if (state == EX1)
          begin
            // Delay?
            state       <= EX2;
          end
          else
          if (state == EX2)
          begin
            case (funct3)
            3'b000: writeLen  <= `LOAD_STORE_BYTE;
            3'b001: writeLen  <= `LOAD_STORE_HALF;
            3'b010: writeLen  <= `LOAD_STORE_WORD;
            endcase
            writeEnable     <= 1;
            state           <= EX3;
          end
          else
          if (state == EX3)
          begin
            addressIsPc <= 1;
            writeEnable <= 0;
            state       <= FETCH0;
          end
        end
        
        else
        begin
          $display("Error %x [%x]", ir, opcode);
          state       <= FETCH0;
        end
      end
      
    end
  end
  
  
endmodule
