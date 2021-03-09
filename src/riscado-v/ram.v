/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module RAM(
  input             clk,
  input             enable,
  input [31:0]      address,
  input [31:0]      dataIn,
  input             writeEnable,
  output reg [31:0] dataOut
);
  parameter LEN = 4096;
  
  reg [31:0] memory[0:LEN-1];
  wire [30:0] daddr = address[31:2];
  
  // Acesso a memória.
  always @(posedge clk)
  begin
    if (enable)
	 begin
	   if (writeEnable)
	   begin
        memory[daddr] <= dataIn;
      end
		else
		begin
			dataOut <= memory[daddr];
		end
    end
  end
endmodule
  