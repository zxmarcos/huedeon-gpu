/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
 
module BoundingBoxIterator #(parameter XLEN=15)
(
  input                       i_clk,
  input                       i_enable,
  input                       i_reset,
  input                       i_write,
  input signed [XLEN:0]       i_bbx0,
  input signed [XLEN:0]       i_bbx1,
  input signed [XLEN:0]       i_bby0,
  input signed [XLEN:0]       i_bby1,
  output reg                  o_done,
  output reg signed [XLEN:0]  o_x,
  output reg signed [XLEN:0]  o_y
);
  reg [XLEN:0] bbx0 = 0;
  reg [XLEN:0] bbx1 = 0;
  reg [XLEN:0] bby0 = 0;
  reg [XLEN:0] bby1 = 0;

  wire x_maxxed = (o_x >= bbx1);
  wire y_maxxed = (o_y >= bby1);

  initial begin
    o_x <= 0;
    o_y <= 0;
    o_done <= 0;
  end

  always @(posedge i_clk)
  begin
    if (i_reset)
    begin
      bbx0  <= 0;
      bbx1  <= 0;
      bby0  <= 0;
      bby1  <= 0;
      o_x   <= 0;
      o_y   <= 0;
    end
    else
    if (i_write)
    begin
      bbx0  <= i_bbx0;
      bbx1  <= i_bbx1;
      bby0  <= i_bby0;
      bby1  <= i_bby1;
      o_x   <= i_bbx0;
      o_y   <= i_bby0;
    end
    else if (i_enable)
    begin
      o_x     <= x_maxxed ? bbx0 : o_x + 1;
      o_y     <= x_maxxed ? (y_maxxed ? bby0 : o_y + 1) : o_y;
      o_done  <= x_maxxed && y_maxxed;
    end
  end
endmodule
