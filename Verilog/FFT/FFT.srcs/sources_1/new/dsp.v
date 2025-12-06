`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2025 11:45:49 AM
// Design Name: 
// Module Name: dsp
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


module dsp(
  input clk,
  input signed [15:0] in_a,
  input signed [15:0] in_b,

  output signed [47:0] out

    );


  reg signed [15:0] reg_a;
  reg signed [15:0] reg_b;
  reg signed [31:0] m_reg;

  reg signed [47:0] out_reg;


  always @ (posedge clk)
    begin
      reg_a <= in_a;
      reg_b <= in_b;

      m_reg <= reg_a * reg_b;

      out_reg <= m_reg;
    end

assign out = out_reg;

endmodule
