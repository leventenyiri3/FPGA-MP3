`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2025 10:48:12 AM
// Design Name: 
// Module Name: test
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


module test();

reg clk;
reg rst;
wire config_ready;
reg [15:0] data_in;
wire [31:0] data_out;
wire data_out_valid;
reg data_out_ready;
wire data_out_last;

FFT testFFT(
    .clk(clk),
    .rst(rst),
    .config_ready(config_ready),
    .data_in(data_in),
    .data_out(data_out),
    .data_out_valid(data_out_valid),
    .data_out_last(data_out_last)
    
);




initial
begin
    clk = 0;
end
always #2.5 clk <= ~clk; //200MHz

initial
begin
    rst <= 0;
    #120
    rst <= 1;
end

always @ (posedge clk)
begin
    if (rst == 0)
    begin
        data_in <= 16'b0100010101001010;
    end
    
    else 
    begin
        data_in <= {data_in[14:0], data_in[15] ^ data_in[13] ^ data_in[12] ^ data_in[10]};
    end
end




endmodule
