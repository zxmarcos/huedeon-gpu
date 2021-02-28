/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
// Gera sinais VGA
module VGAEncoder(
  input             clk,
  output reg [9:0]  x,
  output reg [9:0]  y,
  output reg        hsync,
  output reg        vsync,
  output reg        visible,
  output reg        ymax,
  output reg        xmax
);
  parameter H_VISIBLE_AREA = 640;
  parameter H_FRONT_PORCH  = 16;
  parameter H_SYNC_PULSE   = 96;
  parameter H_BACK_PORCH   = 48;
  parameter H_WHOLE_LINE   = 800;
  parameter H_SYNC_START   = H_VISIBLE_AREA + H_FRONT_PORCH;
  parameter H_SYNC_END     = H_VISIBLE_AREA + H_FRONT_PORCH + H_SYNC_PULSE - 1;
  
  parameter V_VISIBLE_AREA = 480;
  parameter V_FRONT_PORCH  = 10;
  parameter V_SYNC_PULSE   = 2;
  parameter V_BACK_PORCH   = 33;
  parameter V_WHOLE_FRAME  = 525;
  parameter V_SYNC_START   = V_VISIBLE_AREA + V_FRONT_PORCH;
  parameter V_SYNC_END     = V_VISIBLE_AREA + V_FRONT_PORCH + V_SYNC_PULSE - 1;
  
  always @(posedge clk)
  begin
    visible <= (x < H_VISIBLE_AREA) && (y < V_VISIBLE_AREA);
    hsync   <= ~((x >= H_SYNC_START) && (x <= H_SYNC_END));
    vsync   <= ~((y >= V_SYNC_START) && (y <= V_SYNC_END));
    xmax    <= x == (H_WHOLE_LINE - 1);
    ymax    <= y == (V_WHOLE_FRAME - 1);
    // Incrementa os contadores
    if (x == (H_WHOLE_LINE - 1))
    begin
      x <= 0;
      y <= (y == (V_WHOLE_FRAME - 1)) ? 0 : y + 1;
    end
    else
      x <= x + 1;
  end
endmodule
