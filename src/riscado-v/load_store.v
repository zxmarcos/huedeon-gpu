/*
 * Copyright (c) 2021, Marcos Medeiros
 * Licensed under BSD 3-clause.
 */
`include "riscvdefs.vh"


module ByteReader(
  input  [1:0]  offset,
  input         signExtend,
  input  [31:0] dataIn,
  output [31:0] dataOut
);
  wire [7:0] byte = (offset == 0) ? dataIn[ 7: 0] :
                    (offset == 1) ? dataIn[15: 8] :
                    (offset == 2) ? dataIn[23:16] :
                    dataIn[31:24];
  assign dataOut = signExtend ? { { 24{byte[7]} }, byte } : { 24'b0, byte };
endmodule


module HalfReader(
  input  [1:0]  offset,
  input         signExtend,
  input  [31:0] dataIn,
  output [31:0] dataOut
);
  wire [15:0] half = (offset == 0) ? dataIn[15: 0] :
                     (offset == 1) ? dataIn[23: 8] :
                     dataIn[31:16];
  assign dataOut = signExtend ? { { 16{half[15]} }, half } : { 16'b0, half };
endmodule


module ByteWriter(
  input  [1:0]  offset,
  input  [7:0]  writeData,
  input  [31:0] dataIn,
  output [31:0] dataOut
);
  assign dataOut = (offset == 0) ? { dataIn[31: 8], writeData } :
                   (offset == 1) ? { dataIn[31:16], writeData, dataIn[ 7:0] } :
                   (offset == 2) ? { dataIn[31:24], writeData, dataIn[15:0] } :
                    { writeData, dataIn[23:0] };
endmodule

module HalfWriter(
  input  [1:0]  offset,
  input  [15:0] writeData,
  input  [31:0] dataIn,
  output [31:0] dataOut
);
  assign dataOut = (offset == 0) ? { dataIn[31:16], writeData } :
                   (offset == 1) ? { dataIn[31:24], writeData, dataIn[ 7:0] } :
                   { writeData, dataIn[15:0] };
endmodule



module LoadStore(
  input [31:0]        dataIn,
  input [1:0]         offset,
  input [1:0]         readLen,
  input               readSignExtend,
  output wire [31:0]  readDataOut,
  input [1:0]         writeLen,
  input [31:0]        writeDataIn,
  output wire [31:0]  writeDataOut
);
  
  
  wire [31:0] byteWriteOut;
  ByteWriter bw(
    .offset(offset),
    .writeData(writeDataIn[7:0]),
    .dataIn(dataIn),
    .dataOut(byteWriteOut)
  );
  
  wire [31:0] halfWriteOut;
  HalfWriter hw(
    .offset(offset),
    .writeData(writeDataIn[15:0]),
    .dataIn(dataIn),
    .dataOut(halfWriteOut)
  );
  
  assign writeDataOut = (writeLen == `LOAD_STORE_BYTE) ? byteWriteOut : 
                        (writeLen == `LOAD_STORE_HALF) ? halfWriteOut :
                         writeDataIn;
  
  

  wire [31:0] byteReadOut;
  ByteReader br(
    .offset(offset),
    .signExtend(readSignExtend),
    .dataIn(dataIn),
    .dataOut(byteReadOut)
  );
  
  wire [31:0] halfReadOut;
  HalfReader hr(
    .offset(offset),
    .signExtend(readSignExtend),
    .dataIn(dataIn),
    .dataOut(halfReadOut)
  );
  
  assign readDataOut = (readLen == `LOAD_STORE_BYTE) ? byteReadOut : 
                       (readLen == `LOAD_STORE_HALF) ? halfReadOut :
                       dataIn;
  
endmodule

