/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module CLKDivider(clk, clkdiv2, clkdiv4, clkdiv8, clkdiv16);
  input clk;
  output clkdiv2, clkdiv4, clkdiv8, clkdiv16;
  
  reg [3:0] counter = 1'b0;
  
  always @(posedge clk)
    counter <= counter + 1;
    
  assign clkdiv2 = counter[0];
  assign clkdiv4 = counter[1];
  assign clkdiv8 = counter[2];
  assign clkdiv16 = counter[3];

endmodule
