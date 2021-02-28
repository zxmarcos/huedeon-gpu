
module VRAM(
	input clk,
	input [16:0] address,
	input writeEnable,
	input [15:0] dataIn,
	output reg [15:0] dataOut,
	
	
	input clk2,
	input [16:0] address2,
	input writeEnable2,
	input [15:0] dataIn2,
	output reg [15:0] dataOut2
);
	reg [15:0] VRAM[0:320*240-1];// /* synthesis ram_init_file = "src/vram.mif" */;
	
	//initial begin
	//	$readmemh("riscvlogo.mem", VRAM);
	//end

	always @(posedge clk)
	begin
		if (writeEnable)
			VRAM[address] <= dataIn;
		else
			dataOut <= VRAM[address];
	end
	
	always @(posedge clk2)
	begin
		if (writeEnable2)
			VRAM[address2] <= dataIn2;
		else
			dataOut2 <= VRAM[address2];
	end
endmodule
