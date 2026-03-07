`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/04/2026 07:35:26 PM
// Design Name: 
// Module Name: c_coeff_rom_512x32
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


module c_coeff_rom_512x32(
    input clk,
    input [8:0] addr,
    output [31:0] dout

    );

(* ram_style = "block" *) reg signed [31:0] data_reg [512];
initial $readmemh("window_coeffs.mem", window_coeffs);

reg signed [31:0] dout_reg [512];

always @ (posedge clk)
begin
  dout_reg <= window_coeffs[addr];
end

assign dout = dout_reg;


endmodule
