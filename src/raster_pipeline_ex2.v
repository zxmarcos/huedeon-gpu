/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

// Vertex-color calculator
module RasterPipelineEX2(
  input                   i_clk,
  input                   i_write_enable,
  input signed [15:0]     i_x_pos,
  input signed [15:0]     i_y_pos,
  input `FIXPT            i_w1,
  input `FIXPT            i_w2,
  input `FIXPT            i_w3,

  input `FIXPT            i_v1_u,
  input `FIXPT            i_v1_v,
  input `FIXPT            i_v2_u,
  input `FIXPT            i_v2_v,
  input `FIXPT            i_v3_u,
  input `FIXPT            i_v3_v,

  input [7:0]             i_v1_r,
  input [7:0]             i_v1_g,
  input [7:0]             i_v1_b,
  input [7:0]             i_v2_r,
  input [7:0]             i_v2_g,
  input [7:0]             i_v2_b,
  input [7:0]             i_v3_r,
  input [7:0]             i_v3_g,
  input [7:0]             i_v3_b,

  output reg              o_write_pixel,
  output reg signed[15:0] o_x,
  output reg signed[15:0] o_y,
  output reg [7:0]        o_r,
  output reg [7:0]        o_g,
  output reg [7:0]        o_b,

  output reg `FIXPT       o_w1,
  output reg `FIXPT       o_w2,
  output reg `FIXPT       o_w3,
  output reg `FIXPT       o_v1_u,
  output reg `FIXPT       o_v1_v,
  output reg `FIXPT       o_v2_u,
  output reg `FIXPT       o_v2_v,
  output reg `FIXPT       o_v3_u,
  output reg `FIXPT       o_v3_v
);

  wire `FIXPT r_v1_value_fixpt;
  wire `FIXPT r_v2_value_fixpt;
  wire `FIXPT r_v3_value_fixpt;
  wire `FIXPT g_v1_value_fixpt;
  wire `FIXPT g_v2_value_fixpt;
  wire `FIXPT g_v3_value_fixpt;
  wire `FIXPT b_v1_value_fixpt;
  wire `FIXPT b_v2_value_fixpt;
  wire `FIXPT b_v3_value_fixpt;

  Interpolator r_interp_v1(.i_a(`FIXPT_INT({ 14'b0, i_v1_r })), .i_w(i_w1), .o_res(r_v1_value_fixpt));
  Interpolator r_interp_v2(.i_a(`FIXPT_INT({ 14'b0, i_v2_r })), .i_w(i_w2), .o_res(r_v2_value_fixpt));
  Interpolator r_interp_v3(.i_a(`FIXPT_INT({ 14'b0, i_v3_r })), .i_w(i_w3), .o_res(r_v3_value_fixpt));
  Interpolator g_interp_v1(.i_a(`FIXPT_INT({ 14'b0, i_v1_g })), .i_w(i_w1), .o_res(g_v1_value_fixpt));
  Interpolator g_interp_v2(.i_a(`FIXPT_INT({ 14'b0, i_v2_g })), .i_w(i_w2), .o_res(g_v2_value_fixpt));
  Interpolator g_interp_v3(.i_a(`FIXPT_INT({ 14'b0, i_v3_g })), .i_w(i_w3), .o_res(g_v3_value_fixpt));
  Interpolator b_interp_v1(.i_a(`FIXPT_INT({ 14'b0, i_v1_b })), .i_w(i_w1), .o_res(b_v1_value_fixpt));
  Interpolator b_interp_v2(.i_a(`FIXPT_INT({ 14'b0, i_v2_b })), .i_w(i_w2), .o_res(b_v2_value_fixpt));
  Interpolator b_interp_v3(.i_a(`FIXPT_INT({ 14'b0, i_v3_b })), .i_w(i_w3), .o_res(b_v3_value_fixpt));

  wire `FIXPT r_interp_fp = r_v1_value_fixpt + r_v2_value_fixpt + r_v3_value_fixpt;
  wire `FIXPT g_interp_fp = g_v1_value_fixpt + g_v2_value_fixpt + g_v3_value_fixpt;
  wire `FIXPT b_interp_fp = b_v1_value_fixpt + b_v2_value_fixpt + b_v3_value_fixpt;

  always @(posedge i_clk)
  begin
    if (i_write_enable)
    begin
      o_write_pixel <= 1;
      o_x           <= i_x_pos;
      o_y           <= i_y_pos;
      o_r           <= `SATURATE(8'd0, 8'd255, `FIXPT_TO_INT(r_interp_fp));
      o_g           <= `SATURATE(8'd0, 8'd255, `FIXPT_TO_INT(g_interp_fp));
      o_b           <= `SATURATE(8'd0, 8'd255, `FIXPT_TO_INT(b_interp_fp));
      o_w1          <= i_w1;
      o_w2          <= i_w2;
      o_w3          <= i_w3;
      o_v1_u        <= i_v1_u;
      o_v1_v        <= i_v1_v;
      o_v2_u        <= i_v2_u;
      o_v2_v        <= i_v2_v;
      o_v3_u        <= i_v3_u;
      o_v3_v        <= i_v3_v;
    end
    else begin
      o_write_pixel <= 0;
      o_x <= 32'bx;   
      o_y <= 32'bx;   
      o_r <= 32'bx;   
      o_g <= 32'bx;   
      o_b <= 32'bx;   
      o_w1 <= 32'bx;  
      o_w2 <= 32'bx;  
      o_w3 <= 32'bx;  
      o_v1_u <= 32'bx;
      o_v1_v <= 32'bx;
      o_v2_u <= 32'bx;
      o_v2_v <= 32'bx;
      o_v3_u <= 32'bx;
      o_v3_v <= 32'bx;
    end
  end

endmodule


module Interpolator(
  input  `FIXPT   i_a,
  input  `FIXPT   i_w,
  output `FIXPT   o_res
);
  assign o_res = `FIXPT_MUL(i_a, i_w);
endmodule