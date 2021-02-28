/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

module EdgeFunctionTest(
  input             i_clk,
  input `FIXPT      i_px,
  input `FIXPT      i_py,
  input `FIXPT      i_x1,
  input `FIXPT      i_y1,
  input `FIXPT      i_x2,
  input `FIXPT      i_y2,
  output reg `FIXPT o_function,
  output reg        o_inside
);  
  wire `FIXPT s0 = `FIXPT_MUL(i_px - i_x1, i_y2 - i_y1);
  wire `FIXPT s1 = `FIXPT_MUL(i_py - i_y1, i_x2 - i_x1);

  always @(posedge i_clk)
  begin
    o_function  <= (s0 - s1);
    o_inside    <= (s0 - s1) >= 0;
  end

endmodule

module EdgeFunctionTestP(
  input             i_clk,
  input `FIXPT      i_px,
  input `FIXPT      i_py,
  input `FIXPT      i_x1,
  input `FIXPT      i_y1,
  input `FIXPT      i_x2,
  input `FIXPT      i_y2,
  output reg `FIXPT o_function,
  output reg        o_inside
);  

  reg `FIXPT s0_a_pipe [0:1];
  reg `FIXPT s0_b_q;
  reg `FIXPT s1_a_pipe [0:1];
  reg `FIXPT s1_b_q;


  wire `FIXPT sq = s0_a_pipe[1] - s1_a_pipe[1];

  always @(posedge i_clk)
  begin
    // 1st stage
    s0_a_pipe[0]  <= i_px - i_x1;
    s0_b_q        <= i_y2 - i_y1;
    s1_a_pipe[0]  <= i_py - i_y1;
    s1_b_q        <= i_x2 - i_x1;
    // 2st stage
    s0_a_pipe[1]  <= `FIXPT_MUL(s0_a_pipe[0], s0_b_q);
    s1_a_pipe[1]  <= `FIXPT_MUL(s1_a_pipe[0], s1_b_q);
    // 3st stage
    o_function    <= sq;
    o_inside      <= sq >= 0 ? 1 : 0;

  end

endmodule