/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

module TriRasterEngine #(parameter XLEN=`FIXPT_REAL_BITS - 1)
(
  input                     i_clk,
  input                     i_reset,
  input                     i_draw,

  input signed [XLEN:0]     i_v1_x,
  input signed [XLEN:0]     i_v1_y,
  input signed [XLEN:0]     i_v1_z,
  input signed [8:0]        i_v1_u,
  input signed [8:0]        i_v1_v,
  input [7:0]               i_v1_r,
  input [7:0]               i_v1_g,
  input [7:0]               i_v1_b,

  input signed [XLEN:0]     i_v2_x,
  input signed [XLEN:0]     i_v2_y,
  input signed [XLEN:0]     i_v2_z,
  input signed [8:0]        i_v2_u,
  input signed [8:0]        i_v2_v,
  input [7:0]               i_v2_r,
  input [7:0]               i_v2_g,
  input [7:0]               i_v2_b,

  input signed [XLEN:0]     i_v3_x,
  input signed [XLEN:0]     i_v3_y,
  input signed [XLEN:0]     i_v3_z,
  input signed [8:0]        i_v3_u,
  input signed [8:0]        i_v3_v,
  input [7:0]               i_v3_r,
  input [7:0]               i_v3_g,
  input [7:0]               i_v3_b,

  output                    o_busy,
  output reg                o_done,
  output reg                o_write_pixel,
  output reg signed [15:0]  o_x,
  output reg signed [15:0]  o_y,
  output reg [7:0]          o_color_r,
  output reg [7:0]          o_color_g,
  output reg [7:0]          o_color_b
);


  localparam ST_IDLE    = 0;
  localparam ST_DRAWING = 1;
  localparam ST_CLIP_0  = 2;
  localparam ST_CLIP_1  = 3;
  localparam ST_CLIP_3  = 4;

  localparam TILE_X = 0;
  localparam TILE_Y = 0;
  localparam TILE_W = 320;
  localparam TILE_H = 240;

  reg `FIXPT          v1_x;
  reg `FIXPT          v1_y;
  reg `FIXPT          v1_z;
  reg `FIXPT          v1_u;
  reg `FIXPT          v1_v;
  reg signed [7:0]    v1_r;
  reg signed [7:0]    v1_g;
  reg signed [7:0]    v1_b;

  reg `FIXPT          v2_x;
  reg `FIXPT          v2_y;
  reg `FIXPT          v2_z;
  reg `FIXPT          v2_u;
  reg `FIXPT          v2_v;
  reg signed [7:0]    v2_r;
  reg signed [7:0]    v2_g;
  reg signed [7:0]    v2_b;

  reg `FIXPT          v3_x;
  reg `FIXPT          v3_y;
  reg `FIXPT          v3_z;
  reg `FIXPT          v3_u;
  reg `FIXPT          v3_v;
  reg signed [7:0]    v3_r;
  reg signed [7:0]    v3_g;
  reg signed [7:0]    v3_b;

  reg signed [15:0]   x_min;
  reg signed [15:0]   x_max;
  reg signed [15:0]   y_min;
  reg signed [15:0]   y_max;

  reg req_next_pixel;

  initial begin
    v1_x <= 0; v1_y <= 0; v1_z <= 0; v1_u <= 0; v1_v <= 0; v1_r <= 0; v1_g <= 0; v1_b <= 0;
    v2_x <= 0; v2_y <= 0; v2_z <= 0; v2_u <= 0; v2_v <= 0; v2_r <= 0; v2_g <= 0; v2_b <= 0;
    v3_x <= 0; v3_y <= 0; v3_z <= 0; v3_u <= 0; v3_v <= 0; v3_r <= 0; v3_g <= 0; v3_b <= 0;
    x_min <= 0; x_max <= 0;
    y_min <= 0; y_max <= 0;
  end

  reg [2:0] state = 0;

  assign o_busy = state != ST_IDLE; 

  wire bounding_box_end;
  wire signed [15:0] x_pos;
  wire signed [15:0] y_pos;
  
  reg signed [15:0] x_pixel;
  reg signed [15:0] y_pixel;


  wire `FIXPT vp_x = `FIXPT_INT(x_pixel);
  wire `FIXPT vp_y = `FIXPT_INT(y_pixel);

  reg wr_bounding_box = 0;

  BoundingBoxIterator bbox_iterator(
    .i_clk    (i_clk),
    .i_reset  (i_reset),
    .i_enable (req_next_pixel),
    .i_write  (wr_bounding_box),
    .i_bbx0   (x_min),
    .i_bbx1   (x_max),
    .i_bby0   (y_min),
    .i_bby1   (y_max),
    .o_done   (bounding_box_end),
    .o_x      (x_pos),
    .o_y      (y_pos)
  );

  always @(posedge i_clk)
  begin
    if (i_reset)
    begin
      v1_x <= 0; v1_y <= 0; v1_z <= 0;
      v1_u <= 0; v1_v <= 0;
      v1_r <= 0; v1_g <= 0; v1_b <= 0;

      v2_x <= 0; v2_y <= 0; v2_z <= 0;
      v2_u <= 0; v2_v <= 0;
      v2_r <= 0; v2_g <= 0; v2_b <= 0;

      v3_x <= 0; v3_y <= 0; v3_z <= 0;
      v3_u <= 0; v3_v <= 0;
      v3_r <= 0; v3_g <= 0; v3_b <= 0;

      state <= ST_IDLE;
    end
    else
    begin
      case (state)
      ST_IDLE: begin
        if (i_draw)
        begin
          // Latch inputs...
          v1_x <= `FIXPT_INT(i_v1_x); v1_y <= `FIXPT_INT(i_v1_y); v1_z <= `FIXPT_INT(i_v1_z);
          v1_u <= `FIXPT_INT(i_v1_u); v1_v <= `FIXPT_INT(i_v1_v);
          v1_r <= i_v1_r;             v1_g <= i_v1_g;             v1_b <= i_v1_b;

          v2_x <= `FIXPT_INT(i_v2_x); v2_y <= `FIXPT_INT(i_v2_y); v2_z <= `FIXPT_INT(i_v2_z);
          v2_u <= `FIXPT_INT(i_v2_u); v2_v <= `FIXPT_INT(i_v2_v);
          v2_r <= i_v2_r;             v2_g <= i_v2_g;             v2_b <= i_v2_b;

          v3_x <= `FIXPT_INT(i_v3_x); v3_y <= `FIXPT_INT(i_v3_y); v3_z <= `FIXPT_INT(i_v3_z);
          v3_u <= `FIXPT_INT(i_v3_u); v3_v <= `FIXPT_INT(i_v3_v);
          v3_r <= i_v3_r;             v3_g <= i_v3_g;             v3_b <= i_v3_b;

          state <= ST_CLIP_0;
        end
      end
      ST_CLIP_0: begin
        x_min <= `MIN(`MIN(`FIXPT_TO_INT(v1_x), `FIXPT_TO_INT(v2_x)), `FIXPT_TO_INT(v3_x));
        y_min <= `MIN(`MIN(`FIXPT_TO_INT(v1_y), `FIXPT_TO_INT(v2_y)), `FIXPT_TO_INT(v3_y));
        x_max <= `MAX(`MAX(`FIXPT_TO_INT(v1_x), `FIXPT_TO_INT(v2_x)), `FIXPT_TO_INT(v3_x));
        y_max <= `MAX(`MAX(`FIXPT_TO_INT(v1_y), `FIXPT_TO_INT(v2_y)), `FIXPT_TO_INT(v3_y));
        state <= ST_CLIP_1;
      end
      ST_CLIP_1: begin
        x_min <= `MAX(TILE_X, x_min);
        y_min <= `MAX(TILE_Y, y_min);
        x_max <= `MIN(TILE_W, x_max);
        y_max <= `MIN(TILE_H, y_max);
        wr_bounding_box <= 1;
        state <= ST_CLIP_3;
      end
      ST_CLIP_3: begin
        wr_bounding_box <= 0;
        state <= ST_DRAWING;
      end
      ST_DRAWING: begin
        if (bounding_box_end)
        begin
          state <= ST_IDLE;
          req_next_pixel <= 0;
        end
        else
        begin
          req_next_pixel <= 1;
          x_pixel <= x_pos;
          y_pixel <= y_pos;
        end
      end
      default: state <= ST_IDLE;
      endcase
    end
  end
  
  wire `FIXPT area;
  wire `FIXPT e1;
  wire `FIXPT e2;
  wire `FIXPT e3;
  wire e1_inside;
  wire e2_inside;
  wire e3_inside;
  wire signed [15:0] edge_x_pos;
  wire signed [15:0] edge_y_pos;
  wire edge_pixel_enable;

  EdgeFunctionEvaluator edge_evaluator(
    .i_clk          (i_clk),
    .i_write_enable (req_next_pixel),

    .i_x_pos        (x_pixel),
    .i_y_pos        (y_pixel),

    .i_vp_x         (vp_x),
    .i_vp_y         (vp_y),
    .i_v1_x         (v1_x),
    .i_v1_y         (v1_y),
    .i_v2_x         (v2_x),
    .i_v2_y         (v2_y),
    .i_v3_x         (v3_x),
    .i_v3_y         (v3_y),

    .o_x_pos        (edge_x_pos),
    .o_y_pos        (edge_y_pos),
    .o_area         (area),
    .o_e1           (e1),
    .o_e2           (e2),
    .o_e3           (e3),
    .o_write_pixel  (edge_pixel_enable)
  );
  
  wire ex1_write_enable;
  wire signed [15:0] ex1_x;
  wire signed [15:0] ex1_y;
  wire `FIXPT ex1_w1;
  wire `FIXPT ex1_w2;
  wire `FIXPT ex1_w3;

  wire `FIXPT ex1_v1_u;
  wire `FIXPT ex1_v1_v;
  wire `FIXPT ex1_v2_u;
  wire `FIXPT ex1_v2_v;
  wire `FIXPT ex1_v3_u;
  wire `FIXPT ex1_v3_v;

  wire [7:0] ex1_v1_r;
  wire [7:0] ex1_v1_g;
  wire [7:0] ex1_v1_b;
  wire [7:0] ex1_v2_r;
  wire [7:0] ex1_v2_g;
  wire [7:0] ex1_v2_b;
  wire [7:0] ex1_v3_r;
  wire [7:0] ex1_v3_g;
  wire [7:0] ex1_v3_b;


  RasterPipelineEX1 raster_pipe_ex1(
    .i_clk          (i_clk),
    .i_write_enable (edge_pixel_enable),
    .i_x_pos        (edge_x_pos),
    .i_y_pos        (edge_y_pos),
    .i_area         (area),
    .i_e1           (e1),
    .i_e2           (e2),
    .i_e3           (e3),

    .i_v1_r         (v1_r),
    .i_v1_g         (v1_g),
    .i_v1_b         (v1_b),
    .i_v1_u         (v1_u),
    .i_v1_v         (v1_v),

    .i_v2_r         (v2_r),
    .i_v2_g         (v2_g),
    .i_v2_b         (v2_b),
    .i_v2_u         (v2_u),
    .i_v2_v         (v2_v),

    .i_v3_r         (v3_r),
    .i_v3_g         (v3_g),
    .i_v3_b         (v3_b),
    .i_v3_u         (v3_u),
    .i_v3_v         (v3_v),

    .o_write_pixel  (ex1_write_enable),
    .o_x            (ex1_x),
    .o_y            (ex1_y),
    .o_w1           (ex1_w1),
    .o_w2           (ex1_w2),
    .o_w3           (ex1_w3),

    .o_v1_u         (ex1_v1_u),
    .o_v1_v         (ex1_v1_v),
    .o_v2_u         (ex1_v2_u),
    .o_v2_v         (ex1_v2_v),
    .o_v3_u         (ex1_v3_u),
    .o_v3_v         (ex1_v3_v),

    .o_v1_r         (ex1_v1_r),
    .o_v1_g         (ex1_v1_g),
    .o_v1_b         (ex1_v1_b),
    .o_v2_r         (ex1_v2_r),
    .o_v2_g         (ex1_v2_g),
    .o_v2_b         (ex1_v2_b),
    .o_v3_r         (ex1_v3_r),
    .o_v3_g         (ex1_v3_g),
    .o_v3_b         (ex1_v3_b)
  );


  wire ex2_write_pixel;
  wire [7:0] ex2_r;
  wire [7:0] ex2_g;
  wire [7:0] ex2_b;
  wire signed [15:0] ex2_x;
  wire signed [15:0] ex2_y;

  wire `FIXPT ex2_v1_u;
  wire `FIXPT ex2_v1_v;
  wire `FIXPT ex2_v2_u;
  wire `FIXPT ex2_v2_v;
  wire `FIXPT ex2_v3_u;
  wire `FIXPT ex2_v3_v;

  wire `FIXPT ex2_w1;
  wire `FIXPT ex2_w2;
  wire `FIXPT ex2_w3;


  RasterPipelineEX2 raster_pipe_ex2(
    .i_clk            (i_clk),
    .i_write_enable   (ex1_write_enable),
    .i_x_pos          (ex1_x),
    .i_y_pos          (ex1_y),
    .i_w1             (ex1_w1),
    .i_w2             (ex1_w2),
    .i_w3             (ex1_w3),
    
    .i_v1_u           (ex1_v1_u),
    .i_v1_v           (ex1_v1_v),
    .i_v2_u           (ex1_v2_u),
    .i_v2_v           (ex1_v2_v),
    .i_v3_u           (ex1_v3_u),
    .i_v3_v           (ex1_v3_v),

    .i_v1_r           (ex1_v1_r),
    .i_v1_g           (ex1_v1_g),
    .i_v1_b           (ex1_v1_b),
    .i_v2_r           (ex1_v2_r),
    .i_v2_g           (ex1_v2_g),
    .i_v2_b           (ex1_v2_b),
    .i_v3_r           (ex1_v3_r),
    .i_v3_g           (ex1_v3_g),
    .i_v3_b           (ex1_v3_b),

    .o_write_pixel    (ex2_write_pixel),
    .o_x              (ex2_x),
    .o_y              (ex2_y),
    .o_r              (ex2_r),
    .o_g              (ex2_g),
    .o_b              (ex2_b),

    .o_w1             (ex2_w1),
    .o_w2             (ex2_w2),
    .o_w3             (ex2_w3),

    .o_v1_u           (ex2_v1_u),
    .o_v1_v           (ex2_v1_v),
    .o_v2_u           (ex2_v2_u),
    .o_v2_v           (ex2_v2_v),
    .o_v3_u           (ex2_v3_u),
    .o_v3_v           (ex2_v3_v)
  );

  wire ex3_write_pixel;
  wire [7:0] ex3_r;
  wire [7:0] ex3_g;
  wire [7:0] ex3_b;
  wire signed [15:0] ex3_x;
  wire signed [15:0] ex3_y;

  always @(posedge i_clk)
  begin
    o_write_pixel <= ex3_write_pixel;
    if (ex3_write_pixel)
    begin
      o_color_r <= ex3_r;
      o_color_g <= ex3_g;
      o_color_b <= ex3_b;
      o_x       <= ex3_x;
      o_y       <= ex3_y;

      $display("%d,%d,%d,%d,%d", ex3_y,ex3_x,ex3_r,ex3_g,ex3_b);
    end
  end

  RasterPipelineEX3 raster_pipe_ex3(
    .i_clk            (i_clk),
    .i_write_enable   (ex2_write_pixel),
    .i_x_pos          (ex2_x),
    .i_y_pos          (ex2_y),
    .i_w1             (ex2_w1),
    .i_w2             (ex2_w2),
    .i_w3             (ex2_w3),
    .i_r              (ex2_r),
    .i_g              (ex2_g),
    .i_b              (ex2_b),
    .i_v1_u           (ex2_v1_u),
    .i_v1_v           (ex2_v1_v),
    .i_v2_u           (ex2_v2_u),
    .i_v2_v           (ex2_v2_v),
    .i_v3_u           (ex2_v3_u),
    .i_v3_v           (ex2_v3_v),
    .o_write_pixel    (ex3_write_pixel),
    .o_x              (ex3_x),
    .o_y              (ex3_y),
    .o_r              (ex3_r),
    .o_g              (ex3_g),
    .o_b              (ex3_b)
  );

endmodule
