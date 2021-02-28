/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module ColorLutRAM(
  input             i_clk,
  input [7:0]       i_entry,
  input [7:0]       i_data,
  input             i_write_enable,
  output [7:0]      o_r,
  output [7:0]      o_g,
  output [7:0]      o_b
);
  parameter LEN = 256;
  parameter filePath = "data/doom-clut.mem";

  reg [23:0] memory[0:LEN-1];
  reg [23:0] data;

  initial begin
    $readmemh(filePath, memory);
  end

  assign o_r = data[ 7: 0];
  assign o_g = data[15: 8];
  assign o_b = data[23:16];
  
  // Acesso a memória.
  always @(posedge i_clk)
  begin
    if (i_write_enable)
    begin
      memory[i_entry] <= i_data;
    end
    else
    begin
      data <= memory[i_entry];
    end
  end
endmodule
  