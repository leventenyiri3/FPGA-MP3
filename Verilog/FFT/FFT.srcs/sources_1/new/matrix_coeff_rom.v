`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2026 11:07:27 AM
// Design Name: 
// Module Name: matrix_coeff_rom
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


module matrix_coeff_rom(
  input clk,
  input [10:0] addr,
  output [31:0] dout

    );

(* ram_style = "block" *) reg signed [31:0] matrix_coeffs [2047:0];
initial $readmemh("matrix_coeffs.mem", matrix_coeffs);

reg [31:0] dout_reg;
always @ (posedge clk)
begin
  dout_reg <= matrix_coeffs[addr];
end

assign dout = dout_reg;

endmodule
