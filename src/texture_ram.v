/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module TextureRAM(
  input             i_clk,
  input [13:0]      i_address,
  input [7:0]       i_data,
  input             i_write_enable,
  output reg [7:0]  o_data
);
  parameter LEN = 128*128;
  parameter filePath = "data/doom-pixmap.mem";

  reg [7:0] memory[0:LEN-1];
  initial begin
    $readmemh(filePath, memory);
  end

  
  // Acesso a memória.
  always @(posedge i_clk)
  begin
    if (i_write_enable)
    begin
      memory[i_address] <= i_data;
    end
    else
    begin
      o_data <= memory[i_address];
    end
  end
endmodule
  