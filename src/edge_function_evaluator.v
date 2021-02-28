/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

module EdgeFunctionEvaluator(
  input                     i_clk,
  input                     i_write_enable,

  input signed[15:0]        i_x_pos,
  input signed[15:0]        i_y_pos,

  input `FIXPT              i_vp_x,
  input `FIXPT              i_vp_y,
  input `FIXPT              i_v1_x,
  input `FIXPT              i_v1_y,
  input `FIXPT              i_v2_x,
  input `FIXPT              i_v2_y,
  input `FIXPT              i_v3_x,
  input `FIXPT              i_v3_y,

  output reg signed[15:0]   o_x_pos,
  output reg signed[15:0]   o_y_pos,
  output reg `FIXPT         o_area,
  output reg `FIXPT         o_e1,
  output reg `FIXPT         o_e2,
  output reg `FIXPT         o_e3,
  output reg                o_write_pixel
);
  parameter PIPELINE_WIDTH = 2;

  reg [15:0] x_pos[0:PIPELINE_WIDTH];
  reg [15:0] y_pos[0:PIPELINE_WIDTH];

  wire valid;

  pipeline_ctrl #(PIPELINE_WIDTH) pc(
    .i_clk      (i_clk),
    .i_enable   (i_write_enable),
    .o_ack      (valid)
  );


  integer i;
  always @(posedge i_clk)
  begin
    if (i_write_enable)
    begin
      x_pos[0] <= i_x_pos;
      y_pos[0] <= i_y_pos;
    end
    
    for (i = 1; i <= PIPELINE_WIDTH; i = i+1)
    begin
      x_pos[i] <= x_pos[i - 1];
      y_pos[i] <= y_pos[i - 1];
    end
  end

  wire `FIXPT area;
  wire `FIXPT e1;
  wire `FIXPT e2;
  wire `FIXPT e3;
  wire e1_inside;
  wire e2_inside;
  wire e3_inside;

  wire wr_pixel_enable = (e1_inside && e2_inside && e3_inside);
  // Do not render pixels when area is 0
  wire area_is_valid = area != 0;

  always @(posedge i_clk)
  begin
    if (valid && wr_pixel_enable && area_is_valid)
    begin
      o_area      <= area;
      o_e1        <= e1;
      o_e2        <= e2;
      o_e3        <= e3;
      o_x_pos     <= x_pos[PIPELINE_WIDTH];
      o_y_pos     <= y_pos[PIPELINE_WIDTH];
      o_write_pixel <= 1;
    end
    else
    begin
      o_write_pixel <= 0;
    end
  end

  EdgeFunctionTestP area_test(
    .i_clk      (i_clk),
    .i_px       (i_v1_x),
    .i_py       (i_v1_y),
    .i_x1       (i_v2_x),
    .i_y1       (i_v2_y),
    .i_x2       (i_v3_x),
    .i_y2       (i_v3_y),
    .o_function (area)
  );


  EdgeFunctionTestP e1_test(
    .i_clk      (i_clk),
    .i_px       (i_vp_x),
    .i_py       (i_vp_y),
    .i_x1       (i_v1_x),
    .i_y1       (i_v1_y),
    .i_x2       (i_v2_x),
    .i_y2       (i_v2_y),
    .o_function (e1),
    .o_inside   (e1_inside)
  );

  EdgeFunctionTestP e2_test(
    .i_clk      (i_clk),
    .i_px       (i_vp_x),
    .i_py       (i_vp_y),
    .i_x1       (i_v2_x),
    .i_y1       (i_v2_y),
    .i_x2       (i_v3_x),
    .i_y2       (i_v3_y),
    .o_function (e2),
    .o_inside   (e2_inside)
  );

  EdgeFunctionTestP e3_test(
    .i_clk      (i_clk),
    .i_px       (i_vp_x),
    .i_py       (i_vp_y),
    .i_x1       (i_v3_x),
    .i_y1       (i_v3_y),
    .i_x2       (i_v1_x),
    .i_y2       (i_v1_y),
    .o_function (e3),
    .o_inside   (e3_inside)
  );


endmodule
