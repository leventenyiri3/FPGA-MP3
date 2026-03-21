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


module dsp
#
(
  parameter A_REG = 2,
  parameter B_REG = 2
)(
  input clk,
  input signed [24:0] a,
  input signed [17:0] b,
  input signed [47:0] pci,
  output signed [47:0] p

);
integer i;
reg signed [24:0] a_reg [A_REG-1:0];
reg signed [17:0] b_reg [B_REG-1:0];
reg signed [47:0] m_reg;
reg signed [47:0] p_reg;

always @ (posedge clk)
begin
  for (i = 0; i<A_REG; i = i+1) begin
    a_reg[i] <= (i==0) ? a : a_reg[i-1];
  end

  for (i = 0; i<B_REG; i = i+1) begin
    b_reg[i] <= (i==0) ? b : b_reg[i-1];
  end
end

always @ (posedge clk)
begin
  m_reg <= a_reg[A_REG-1] * b_reg[B_REG-1];
  p_reg <= m_reg + pci;
end

assign p = p_reg;

endmodule
