/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

// Barycentric coordinates calculator
module RasterPipelineEX1(
  input                   i_clk,
  input                   i_write_enable,
  input signed [15:0]     i_x_pos,
  input signed [15:0]     i_y_pos,
  input `FIXPT            i_area,
  input `FIXPT            i_e1,
  input `FIXPT            i_e2,
  input `FIXPT            i_e3,

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
  output reg `FIXPT       o_w1,
  output reg `FIXPT       o_w2,
  output reg `FIXPT       o_w3,

  output reg [7:0]        o_v1_r,
  output reg [7:0]        o_v1_g,
  output reg [7:0]        o_v1_b,

  output reg [7:0]        o_v2_r,
  output reg [7:0]        o_v2_g,
  output reg [7:0]        o_v2_b,

  output reg [7:0]        o_v3_r,
  output reg [7:0]        o_v3_g,
  output reg [7:0]        o_v3_b,

  output reg `FIXPT       o_v1_u,
  output reg `FIXPT       o_v1_v,
  output reg `FIXPT       o_v2_u,
  output reg `FIXPT       o_v2_v,
  output reg `FIXPT       o_v3_u,
  output reg `FIXPT       o_v3_v
);
  parameter DIV_WIDTH = `FIXPT_SIZE * 2;
  parameter PIPELINE_WIDTH = `FIXPT_SIZE;
  parameter DIV_PADDING = DIV_WIDTH - (`FIXPT_SIZE - `FIXPT_FRACTION_BITS);

  reg signed [15:0] x_pos_pipe[0:PIPELINE_WIDTH];
  reg signed [15:0] y_pos_pipe[0:PIPELINE_WIDTH];

  reg `FIXPT v1_u_pipe[0:PIPELINE_WIDTH];
  reg `FIXPT v1_v_pipe[0:PIPELINE_WIDTH];
  reg `FIXPT v2_u_pipe[0:PIPELINE_WIDTH];
  reg `FIXPT v2_v_pipe[0:PIPELINE_WIDTH];
  reg `FIXPT v3_u_pipe[0:PIPELINE_WIDTH];
  reg `FIXPT v3_v_pipe[0:PIPELINE_WIDTH];


  reg [7:0] v1_r_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v1_g_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v1_b_pipe[0:PIPELINE_WIDTH];

  reg [7:0] v2_r_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v2_g_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v2_b_pipe[0:PIPELINE_WIDTH];

  reg [7:0] v3_r_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v3_g_pipe[0:PIPELINE_WIDTH];
  reg [7:0] v3_b_pipe[0:PIPELINE_WIDTH];

  reg [31:0] counter = 0;

  integer i;

  initial begin
    for (i = 0; i <= PIPELINE_WIDTH; i = i+1)
    begin
      x_pos_pipe[i] <= 0;
      y_pos_pipe[i] <= 0;
      v1_r_pipe[i]  <= 0;
      v1_g_pipe[i]  <= 0;
      v1_b_pipe[i]  <= 0;

      v2_r_pipe[i]  <= 0;
      v2_g_pipe[i]  <= 0;
      v2_b_pipe[i]  <= 0;

      v3_r_pipe[i]  <= 0;
      v3_g_pipe[i]  <= 0;
      v3_b_pipe[i]  <= 0;

      v1_u_pipe[i]  <= 0;
      v1_v_pipe[i]  <= 0;
      v2_u_pipe[i]  <= 0;
      v2_v_pipe[i]  <= 0;
      v3_u_pipe[i]  <= 0;
      v3_v_pipe[i]  <= 0;
    end
  end


  always @(posedge i_clk)
  begin
    counter <= counter + 1;
    if (i_write_enable)
    begin
      x_pos_pipe[0] <= i_x_pos;
      y_pos_pipe[0] <= i_y_pos;
      
      v1_r_pipe[0]  <= i_v1_r;
      v1_g_pipe[0]  <= i_v1_g;
      v1_b_pipe[0]  <= i_v1_b;
      
      v2_r_pipe[0]  <= i_v2_r;
      v2_g_pipe[0]  <= i_v2_g;
      v2_b_pipe[0]  <= i_v2_b;

      v3_r_pipe[0]  <= i_v3_r;
      v3_g_pipe[0]  <= i_v3_g;
      v3_b_pipe[0]  <= i_v3_b;

      v1_u_pipe[0]  <= i_v1_u;
      v1_v_pipe[0]  <= i_v1_v;
      v2_u_pipe[0]  <= i_v2_u;
      v2_v_pipe[0]  <= i_v2_v;
      v3_u_pipe[0]  <= i_v3_u;
      v3_v_pipe[0]  <= i_v3_v;
      //$display("%d, wr_enable %d,%d : %x,%x,%x,%x", counter, i_y_pos, i_x_pos, i_area, i_e1, i_e2, i_e3);
    end
    else
    begin
      x_pos_pipe[0] <= 32'bx;
      y_pos_pipe[0] <= 32'bx;
      v1_r_pipe[0]  <= 32'bx;
      v1_g_pipe[0]  <= 32'bx;
      v1_b_pipe[0]  <= 32'bx;
      v2_r_pipe[0]  <= 32'bx;
      v2_g_pipe[0]  <= 32'bx;
      v2_b_pipe[0]  <= 32'bx;
      v3_r_pipe[0]  <= 32'bx;
      v3_g_pipe[0]  <= 32'bx;
      v3_b_pipe[0]  <= 32'bx;
      v1_u_pipe[0]  <= 32'bx;
      v1_v_pipe[0]  <= 32'bx;
      v2_u_pipe[0]  <= 32'bx;
      v2_v_pipe[0]  <= 32'bx;
      v3_u_pipe[0]  <= 32'bx;
      v3_v_pipe[0]  <= 32'bx;

    end

    // Shift...
    for (i = 1; i <= PIPELINE_WIDTH; i = i+1)
    begin
      x_pos_pipe[i] <= x_pos_pipe[i - 1];
      y_pos_pipe[i] <= y_pos_pipe[i - 1];

      v1_r_pipe[i]  <= v1_r_pipe[i - 1];
      v1_g_pipe[i]  <= v1_g_pipe[i - 1];
      v1_b_pipe[i]  <= v1_b_pipe[i - 1];

      v2_r_pipe[i]  <= v2_r_pipe[i - 1];
      v2_g_pipe[i]  <= v2_g_pipe[i - 1];
      v2_b_pipe[i]  <= v2_b_pipe[i - 1];

      v3_r_pipe[i]  <= v3_r_pipe[i - 1];
      v3_g_pipe[i]  <= v3_g_pipe[i - 1];
      v3_b_pipe[i]  <= v3_b_pipe[i - 1];

      v1_u_pipe[i]  <= v1_u_pipe[i - 1];
      v1_v_pipe[i]  <= v1_v_pipe[i - 1];
      v2_u_pipe[i]  <= v2_u_pipe[i - 1];
      v2_v_pipe[i]  <= v2_v_pipe[i - 1];
      v3_u_pipe[i]  <= v3_u_pipe[i - 1];
      v3_v_pipe[i]  <= v3_v_pipe[i - 1];
    end
  end

  wire `FIXPT w_w1;
  wire `FIXPT w_w2;
  wire `FIXPT w_w3;

  wire valid;

  always @(posedge i_clk)
  begin
    if (valid)
    begin
      o_write_pixel <= 1;
      o_x           <= x_pos_pipe[PIPELINE_WIDTH];
      o_y           <= y_pos_pipe[PIPELINE_WIDTH];
      
      o_w1          <= w_w1;
      o_w2          <= w_w2;
      o_w3          <= w_w3;

      o_v1_r        <= v1_r_pipe[PIPELINE_WIDTH];
      o_v1_g        <= v1_g_pipe[PIPELINE_WIDTH];
      o_v1_b        <= v1_b_pipe[PIPELINE_WIDTH];

      o_v2_r        <= v2_r_pipe[PIPELINE_WIDTH];
      o_v2_g        <= v2_g_pipe[PIPELINE_WIDTH];
      o_v2_b        <= v2_b_pipe[PIPELINE_WIDTH];
      
      o_v3_r        <= v3_r_pipe[PIPELINE_WIDTH];
      o_v3_g        <= v3_g_pipe[PIPELINE_WIDTH];
      o_v3_b        <= v3_b_pipe[PIPELINE_WIDTH];

      o_v1_u        <= v1_u_pipe[PIPELINE_WIDTH];
      o_v1_v        <= v1_v_pipe[PIPELINE_WIDTH];
      o_v2_u        <= v2_u_pipe[PIPELINE_WIDTH];
      o_v2_v        <= v2_v_pipe[PIPELINE_WIDTH];
      o_v3_u        <= v3_u_pipe[PIPELINE_WIDTH];
      o_v3_v        <= v3_v_pipe[PIPELINE_WIDTH];


/*      $display("%d, wr_valid_  %d,%d : %x,%x,%x : %d,%d,%d;%d,%d,%d;%d,%d,%d",
        counter,
        y_pos_pipe[PIPELINE_WIDTH],
        x_pos_pipe[PIPELINE_WIDTH],
        w_w1, w_w2, w_w3,
        v1_r_pipe[PIPELINE_WIDTH],
        v1_g_pipe[PIPELINE_WIDTH],
        v1_b_pipe[PIPELINE_WIDTH],
        v2_r_pipe[PIPELINE_WIDTH],
        v2_g_pipe[PIPELINE_WIDTH],
        v2_b_pipe[PIPELINE_WIDTH],
        v3_r_pipe[PIPELINE_WIDTH],
        v3_g_pipe[PIPELINE_WIDTH],
        v3_b_pipe[PIPELINE_WIDTH]
        );*/
    end
    else begin
      o_write_pixel <= 0;
    end
  end
  
  pipeline_ctrl #(PIPELINE_WIDTH) pc(
    .i_clk      (i_clk),
    .i_enable   (i_write_enable),
    .o_ack      (valid)
  );

  div_uu #(DIV_WIDTH) w1_div(
    .clk    (i_clk),
    .ena    (1'b1),
    .z      ({ {DIV_PADDING{1'b0}}, i_e1, `FIXPT_FRACTION_BITS'b0}),
    .d      (i_area),
    .q      (w_w1)
  );

  div_uu #(DIV_WIDTH) w2_div(
    .clk    (i_clk),
    .ena    (1'b1),
    .z      ({ {DIV_PADDING{1'b0}}, i_e2, `FIXPT_FRACTION_BITS'b0}),
    .d      (i_area),
    .q      (w_w2)
  );

  div_uu #(DIV_WIDTH) w3_div(
    .clk    (i_clk),
    .ena    (1'b1),
    .z      ({ {DIV_PADDING{1'b0}}, i_e3, `FIXPT_FRACTION_BITS'b0}),
    .d      (i_area),
    .q      (w_w3)
  );

endmodule
