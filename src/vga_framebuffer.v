/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module VGAFramebuffer(
  input               i_clk,
  input [15:0]        i_pixel,
  input [17:0]        i_display_offset,
  output [17:0]       o_address,
  output wire         o_vga_clk,
  output wire [7:0]   o_vga_r,
  output wire [7:0]   o_vga_g,
  output wire [7:0]   o_vga_b,
  output wire         o_vga_blank_n,
  output wire         o_vga_sync_n,
  output wire         o_vga_hs,
  output wire         o_vga_vs
);
  reg [17:0] vram_pix_address;
  reg [17:0] vram_row_address;
  reg [15:0] pixel;
  reg [17:0] display_offset = 0;

  assign o_address = display_offset + vram_pix_address;

  wire [9:0] x;
  wire [9:0] y;
  wire hsync, vsync, visible;
  wire xmax, ymax;
  
  reg [7:0] r_color;
  reg [7:0] g_color;
  reg [7:0] b_color;

  
  assign o_vga_r = r_color;
  assign o_vga_b = b_color;
  assign o_vga_g = g_color;
  assign o_vga_blank_n = 1'b1;
  assign o_vga_sync_n = 1'b0;
  assign o_vga_hs = hsync;
  assign o_vga_vs = vsync;
  assign o_vga_clk = i_clk;
  
  VGAEncoder vga(
    .clk      (i_clk),
    .x        (x),
    .y        (y),
    .hsync    (hsync),
    .vsync    (vsync),
    .visible  (visible),
    .xmax     (xmax),
    .ymax     (ymax)
  );

  always @(posedge i_clk)
  begin
    if (y == 0)
    begin
      // Update display offset on first pixel of frame
      display_offset   <= i_display_offset;
      vram_row_address <= 0;
      vram_pix_address <= 0;
    end
    if (xmax)
    begin
      if (y[0])
        vram_row_address <= vram_row_address + 320;
      vram_pix_address <= vram_row_address;
    end
    
    if (visible)
    begin
      pixel     <= i_pixel;
      r_color <= (({3'b0, pixel[15:11]} * 527 + 23) >> 6);
      g_color <= (({3'b0, pixel[10: 5]} * 259 + 33) >> 6);
      b_color <= (({3'b0, pixel[ 4: 0]} * 527 + 23) >> 6);
      
      if (x[0])
        vram_pix_address <= vram_pix_address + 1;
    end
    else
    begin
      r_color <= 5'b0;
      g_color <= 6'b0;
      b_color <= 5'b0;
    end
  end

  
endmodule
