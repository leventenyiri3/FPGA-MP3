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

FFT testFFT(
    .clk(clk),
    .rst(rst),
//    .config_tdata(config_tdata), //ezt nem is kéne, hogy input legyen...
//    .config_valid(config_valid),
    .config_ready(config_ready),
    .data_in(data_in),
//    .data_in_valid(data_in_valid),
    .data_in_ready(data_in_ready),
//    .data_in_last(data_in_last),
    .data_out(data_out),
    .data_out_valid(data_out_valid),
    .data_out_last(data_out_last)
//    .fs_out(fs_out)
    
);

reg clk;
reg rst;
//reg [39:0] config_tdata;
reg config_valid;
wire config_ready;
reg [15:0] data_in;
reg data_in_valid;
wire data_in_ready;
//reg data_in_last;
wire [31:0] data_out;
wire data_out_valid;
reg data_out_ready;
wire data_out_last;



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
        data_in <= {data_in[14:0], data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[2]}; 
    end
end




endmodule
