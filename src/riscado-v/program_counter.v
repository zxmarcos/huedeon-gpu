/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
module ProgramCounter(
  input               clk,
  input               reset,
  input [31:0]        dataIn,
  input               writeEnable,
  input               increment,
  output wire [31:0]  currentPc,
  output reg  [31:0]  prevPc
);

  reg [31:0] pc = 0;
  
  always @(posedge clk)
  begin
    if (reset)
      pc <= 0;
    else begin
      if (writeEnable)
      begin
        pc <= dataIn;
        prevPc <= pc;
      end
      else
      if (increment)
      begin
        pc <= pc + 4;
        prevPc <= pc;
      end
    end
  end
  assign currentPc = pc;
endmodule
