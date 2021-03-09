/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "riscvdefs.vh"

module ALU(
    input [31:0]        a,
    input [31:0]        b,
    input [3:0]         operation,
    output wire [31:0]  result
);
    
    reg [31:0] res;
    
    always @(*)
    begin
        case (operation)
        `ALU_ADD:   res = a + b;                                        // ADD
        `ALU_SLL:   res = a << b[4:0];                                  // SLL
        `ALU_SLT:   res = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;    // SLT
        `ALU_SLTU:  res = (a < b) ? 32'b1 : 32'b0;                      // SLTU
        `ALU_XOR:   res = a ^ b;                                        // XOR
        `ALU_SRL:   res = a >> b[4:0];                                  // SRL
        `ALU_OR:    res = a | b;                                        // OR
        `ALU_AND:   res = a & b;                                        // AND
        `ALU_SUB:   res = a - b;                                        // SUB
        `ALU_SRA:   res = $signed(a) >>> b[4:0];                        // SRA
        `ALU_A:     res = a;                                            // A
        `ALU_B:     res = b;                                            // B
        `ALU_EQ:    res = (a == b) ? 32'b1 : 32'b0;                     // EQ
        default:    res = a;
        endcase
    end
    
    assign result = res;
    
endmodule
    