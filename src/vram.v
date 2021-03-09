/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module VRAM(
  input               i_a_clk,
  input               i_a_enable,
  input [17:0]        i_a_address,
  input               i_a_write_enable,
  input [15:0]        i_a_wr_data,
  output reg [15:0]   o_a_rd_data,
    
  input               i_b_clk,
  input               i_b_enable,
  input [17:0]        i_b_address,
  input               i_b_write_enable,
  input [15:0]        i_b_wr_data,
  output reg [15:0]   o_b_rd_data
);
  (* ramstyle = "no_rw_check" *) reg [15:0] VRAM[0:320*(240*2)-1] /* synthesis ram_init_file = "../src/vram.mif" */;
  
  //initial begin
  //  $readmemh("riscvlogo.mem", VRAM);
  //end

  always @(posedge i_a_clk)
  begin
    if (i_a_enable)
    begin
      if (i_a_write_enable)
        VRAM[i_a_address] <= i_a_wr_data;
      else
        o_a_rd_data <= VRAM[i_a_address];
    end
  end
  
  always @(posedge i_b_clk)
  begin
    if (i_b_enable)
    begin
      if (i_b_write_enable)
        VRAM[i_b_address] <= i_b_wr_data;
      else
        o_b_rd_data <= VRAM[i_b_address];
    end
  end

endmodule
