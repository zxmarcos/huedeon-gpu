/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module RegisterFile (
  input               clk,
  input [4:0]         ia,           // Re\gistrador de entrada A
  input [4:0]         ib,           // Registrador de entrada B
  input [4:0]         dst,          // Registrador de destino para escrita
  input wire [31:0]   dataIn,       // Dados para escrever no registrador
  input               writeEnable,  // Habilita escrita no registrador
  output wire [31:0]  oa,           // Saída de dados do registrador A
  output wire [31:0]  ob            // Saída de dados do registrador B
);
  reg [31:0] registers[0:31];
  integer i;
  
  initial begin
    for (i = 0; i < 32; i = i + 1)
      registers[i] = 0;
  end
  
  always @(posedge clk)
  begin
    if (writeEnable && dst != 0)
      registers[dst] <= dataIn;
  end
  
  assign oa = ia == 0 ? 32'b0 : registers[ia];
  assign ob = ib == 0 ? 32'b0 : registers[ib];
endmodule
