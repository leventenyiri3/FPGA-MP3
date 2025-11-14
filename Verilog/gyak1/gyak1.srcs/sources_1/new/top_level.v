`timescale 1ns / 1ps

module top_level(
    input  wire       clk,
    input  wire       rst,
    
    output wire [3:0] dig,
    output wire [7:0] seg
);

seg7 seg7_i(
    .clk(clk),
    .rst(rst),

    .din0(4'd0),
    .din1(4'd1),
    .din2(4'd2),
    .din3(4'd4),

    .dig(dig),
    .seg(seg)
);


endmodule
