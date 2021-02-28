/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "fixedpt.vh"

module huedeon_tb;

  reg clk = 0;
  reg draw = 0;
  reg reset = 0;

  always #1 clk <= !clk;


  TriRasterEngine tre(
    .i_clk      (clk),
    .i_draw     (draw),
    .i_reset    (reset),

    .i_v1_x((10)),
    .i_v1_y((10)),
    .i_v1_z((1)),
    .i_v1_u((0)),
    .i_v1_v((0)),
    .i_v1_r(8'hFF),
    .i_v1_g(8'h00),
    .i_v1_b(8'h00),

    .i_v2_x((50)),
    .i_v2_y((200)),
    .i_v2_z((1)),
    .i_v2_u((0)),
    .i_v2_v((127)),
    .i_v2_r(8'h00),
    .i_v2_g(8'hFF),
    .i_v2_b(8'h00),

    .i_v3_x((300)),
    .i_v3_y((140)),
    .i_v3_z((1)),
    .i_v3_u((127)),
    .i_v3_v((127)),
    .i_v3_r(8'h00),
    .i_v3_g(8'h00),
    .i_v3_b(8'hFF)
  );

  initial begin
    $dumpfile("huedeon.vcd");
    $dumpvars(0,huedeon_tb);

    #1
    reset <= 1;
    #3
    reset <= 0;

    #3
    draw <= 1;
    #2
    draw <= 0;
  end

endmodule
