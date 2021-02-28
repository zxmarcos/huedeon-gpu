/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module TextureUnit(
	input									i_clk,
	input signed [15:0]		i_x,
	input signed [15:0] 	i_y,
	output reg [15:0]			o_address
);
	// 128x128
	always @(posedge i_clk)
	begin
		o_address <= {i_y,i_x[6:0]}; 
	end

endmodule