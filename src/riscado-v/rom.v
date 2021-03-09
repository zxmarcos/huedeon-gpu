/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module ROM(
  input             clk,
  input             enable,
  input [31:0]      address,
  input [31:0]      dataIn,
  input             writeEnable,
  output reg [31:0] dataOut
);
  parameter LEN = 10000;
  //parameter filePath = "D:/dev/DE1-SOC/Tools/SystemBuilder/CodeGenerated/DE1_SOC/RISCV_GPU_SOC/gcc/rom.mem";
  
  reg [31:0] memory[0:LEN-1] /* synthesis ram_init_file = "../src/riscado-v/gcc/rom.mif" */;
  wire [30:0] daddr = address[31:2];
  
  //initial begin
  //  $readmemh(filePath, memory);
  //end
  
  // Acesso a memória.
  always @(posedge clk)
  begin
    if (enable)
	 begin
      dataOut <= memory[daddr];
    end
  end
endmodule
  