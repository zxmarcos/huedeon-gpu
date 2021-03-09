/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

module HuedeonGPU(
  input                 i_clk,
  input                 i_reset,
  input                 i_enable,
  input                 i_chip_select,
  input [31:0]          i_wr_address,
  input [31:0]          i_wr_data,
  input                 i_wr_enable,
  output [31:0]         o_status,
  output wire           o_wr_enable,
  output wire [17:0]    o_wr_address,
  output wire [7:0]     o_r,
  output wire [7:0]     o_g,
  output wire [7:0]     o_b,
  output [17:0]         o_display_offset
);
  // GPU Registers
  parameter REG_RESET       = 0;
  parameter REG_CONTROL     = 1;
  parameter REG_DRAW        = 2;
  parameter REG_V1_X        = 3;
  parameter REG_V1_Y        = 4;
  parameter REG_V1_Z        = 5;
  parameter REG_V1_COLOR    = 6;
  parameter REG_V1_UV       = 7;
  parameter REG_V2_X        = 8;
  parameter REG_V2_Y        = 9;
  parameter REG_V2_Z        = 10;
  parameter REG_V2_COLOR    = 11;
  parameter REG_V2_UV       = 12;
  parameter REG_V3_X        = 13;
  parameter REG_V3_Y        = 14;
  parameter REG_V3_Z        = 15;
  parameter REG_V3_COLOR    = 16;
  parameter REG_V3_UV       = 17;
  parameter REG_DRAW_OFFSET = 18;
  parameter REG_DISP_OFFSET = 19;

  // Vertex (X,Y,Z,U,V,R,G,B,A)
  reg `FIXPT  v1_x, v1_y, v1_z;
  reg [15:0]  v1_u, v1_v;
  reg [7:0]   v1_r, v1_g, v1_b, v1_a;

  reg `FIXPT  v2_x, v2_y, v2_z;
  reg [15:0]  v2_u, v2_v;
  reg [7:0]   v2_r, v2_g, v2_b, v2_a;

  reg `FIXPT  v3_x, v3_y, v3_z;
  reg [15:0]  v3_u, v3_v;
  reg [7:0]   v3_r, v3_g, v3_b, v3_a;

  reg draw;
  reg [17:0] draw_offset = 0;
  reg [17:0] display_offset = 0;
  reg control;
  wire reset = i_reset || (i_wr_address == REG_RESET && i_wr_data[0]);

  assign o_display_offset = display_offset;

  always @(posedge i_clk)
  begin
    if (i_enable && i_wr_enable && i_chip_select)
    begin
      case (i_wr_address)
      REG_CONTROL       : control                     <= i_wr_data;
      REG_DRAW          : draw                        <= i_wr_data[0];
      REG_V1_X          : v1_x                        <= i_wr_data;
      REG_V1_Y          : v1_y                        <= i_wr_data;
      REG_V1_Z          : v1_z                        <= i_wr_data;
      REG_V1_UV         : { v1_u, v1_v }              <= i_wr_data;
      REG_V1_COLOR      : { v1_a, v1_r, v1_g, v1_b }  <= i_wr_data;
      REG_V2_X          : v2_x                        <= i_wr_data;
      REG_V2_Y          : v2_y                        <= i_wr_data;
      REG_V2_Z          : v2_z                        <= i_wr_data;
      REG_V2_UV         : { v2_u, v2_v }              <= i_wr_data;
      REG_V2_COLOR      : { v2_a, v2_r, v2_g, v2_b }  <= i_wr_data;
      REG_V3_X          : v3_x                        <= i_wr_data;
      REG_V3_Y          : v3_y                        <= i_wr_data;
      REG_V3_Z          : v3_z                        <= i_wr_data;
      REG_V3_UV         : { v3_u, v3_v }              <= i_wr_data;
      REG_V3_COLOR      : { v3_a, v3_r, v3_g, v3_b }  <= i_wr_data;
      REG_DRAW_OFFSET   : draw_offset                 <= i_wr_data;
      REG_DISP_OFFSET   : display_offset              <= i_wr_data;
      endcase
    end
    else
    begin
      // Reset state write.
      draw <= 0;
    end
  end

  wire enable_vertex_color = control;
  wire tre_busy;
  wire tre_done;
  wire signed [15:0] wr_x_addr;
  wire signed [15:0] wr_y_addr;
  assign o_wr_address = draw_offset + (wr_y_addr * 320) + wr_x_addr;
  assign o_status = { 29'b0, tre_done, tre_busy };
  
  TriRasterEngine tre(
    .i_clk          (i_clk),
    .i_reset        (reset),
    .i_draw         (draw),
    
    .i_v1_x         (v1_x),
    .i_v1_y         (v1_y),
    .i_v1_z         (v1_z),
    .i_v1_r         (enable_vertex_color ? v1_r : 0),
    .i_v1_g         (enable_vertex_color ? v1_g : 0),
    .i_v1_b         (enable_vertex_color ? v1_b : 0),
    .i_v1_u         (v1_u),
    .i_v1_v         (v1_v),

    .i_v2_x         (v2_x),
    .i_v2_y         (v2_y),
    .i_v2_z         (v2_z),
    .i_v2_r         (enable_vertex_color ? v2_r : 0),
    .i_v2_g         (enable_vertex_color ? v2_g : 0),
    .i_v2_b         (enable_vertex_color ? v2_b : 0),
    .i_v2_u         (v2_u),
    .i_v2_v         (v2_v),


    .i_v3_x         (v3_x),
    .i_v3_y         (v3_y),
    .i_v3_z         (v3_z),
    .i_v3_r         (enable_vertex_color ? v3_r : 0),
    .i_v3_g         (enable_vertex_color ? v3_g : 0),
    .i_v3_b         (enable_vertex_color ? v3_b : 0),
    .i_v3_u         (v3_u),
    .i_v3_v         (v3_v),

    .o_color_r      (o_r),
    .o_color_g      (o_g),
    .o_color_b      (o_b),
    .o_x            (wr_x_addr),
    .o_y            (wr_y_addr),
    .o_write_pixel  (o_wr_enable),
    .o_busy         (tre_busy),
    .o_done         (tre_done)
  );
  
endmodule