`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2026 12:58:04 PM
// Design Name: 
// Module Name: filterbank_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module filterbank_test();

reg clk;
reg rst;

initial
begin
  clk = 0;
end

always #5 clk = ~clk;

initial
begin
  rst = 1;
  #120
  rst = 0;
end


//test sample ROM random 16 bites értékekkel feltöltve
wire signed [15:0] sample;
reg [8:0] sample_addr;

always @ (posedge clk)
begin
  if(rst)
    sample_addr <= 0;
  else
    sample_addr <= sample_addr + 1;
end

test_sample_rom sample_rom(
  .clk(clk),
  .addr(sample_addr),
  .dout(sample)
);

Filterbank filterbank(
  .clk(clk),
  .sample(sample),
  .rst(rst)
);

endmodule
