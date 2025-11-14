`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/29/2024 09:41:52 AM
// Design Name: 
// Module Name: tf_seg7
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


module tf_seg7();

reg        clk;
reg        rst;
reg  [3:0] din0;
reg  [3:0] din1;
reg  [3:0] din2;
reg  [3:0] din3;
    
wire [3:0] dig;
wire [7:0] seg;

seg7 seg7_i(
    .clk(clk),
    .rst(rst),

    .din0(din0),
    .din1(din1),
    .din2(din2),
    .din3(din3),

    .dig(dig),
    .seg(seg)
);

initial
begin
    clk = 0;
end
always #5 clk <= ~clk;

initial
begin
    rst = 1;
    #102;
    rst = 0;
end

initial
begin
    din0 = 4'd0;
    din1 = 4'd1;
    din2 = 4'd2;
    din3 = 4'd3;
    
    #10000000;
    din0 = 4'd4;
    din1 = 4'd5;
    din2 = 4'd6;
    din3 = 4'd7;
end


endmodule
