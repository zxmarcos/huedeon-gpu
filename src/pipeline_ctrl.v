/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module pipeline_ctrl(
  input   i_clk,
  input   i_enable,
  output  o_ack
);
  parameter WIDTH = 4;
  reg [0:WIDTH] valid = 0;

  assign o_ack = valid[WIDTH];

  integer i;
  initial begin
    valid = 0;
  end
  
  always @(posedge i_clk)
  begin
    valid[0] <= i_enable;

    for (i = 1; i <= WIDTH; i = i+1)
      valid[i] <= valid[i - 1];
  
  end

endmodule

