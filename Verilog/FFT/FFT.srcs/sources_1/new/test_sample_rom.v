`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 11:21:13 AM
// Design Name: 
// Module Name: test_sample_rom
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


module test_sample_rom(
    input clk,
    input [8:0] addr,
    output [15:0] dout
    );

(* ram_style = "block" *) reg signed [15:0] test_samples [511:0];
initial $readmemh("test_samples.mem", test_samples);

reg [15:0] dout_reg;
always @ (posedge clk)
begin
  dout_reg <= test_samples[addr];
end

assign dout = dout_reg;
endmodule
