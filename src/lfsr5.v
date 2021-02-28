/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module lfsr_5bit #(parameter seed=5'h43)(
  input             i_clk,
  input             i_reset,
  output reg [4:0]  o_data
);

  reg [4:0] next_data;
  initial begin
  	next_data <= seed;
  end
  
  always @(*)
  begin
    next_data[4] = o_data[4] ^ o_data[1];
    next_data[3] = o_data[3] ^ o_data[0];
    next_data[2] = o_data[2] ^ next_data[4];
    next_data[1] = o_data[1] ^ next_data[3];
    next_data[0] = o_data[0] ^ next_data[2];
  end
  
  always @(posedge i_clk or negedge i_reset)
  begin
    if (!i_reset)
    begin
      o_data <= seed;
    end
    else
    begin
      o_data <= next_data;
    end
  end

endmodule
