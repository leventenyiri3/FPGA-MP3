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
wire [31:0] fft_out;
wire fft_out_valid;
reg fft_out_ready;
wire fft_out_last;

FFT testFFT(
    .clk(clk),
    .rst(rst),
    .config_ready(config_ready),
    .data_in(data_in),
    .fft_out(fft_out),
    .fft_out_valid(fft_out_valid),
    .fft_out_last(fft_out_last)
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

//always @ (posedge clk)
//begin
//    if (rst == 0)
//    begin
//        data_in <= 16'b0100010101001010;
//    end
//
//    else
//    begin
//        data_in <= {data_in[14:0], data_in[15] ^ data_in[13] ^ data_in[12] ^ data_in[10]};
//    end
//end

reg signed [15:0] sin_mem [0:1023];

initial
begin
  $readmemh("sine_lut.mem",sin_mem);
end

reg [14:0] sin_cntr_en; //10 kHz-s szinusz legyen

reg  [9:0] sin_cntr;
reg [12:0] fs_sync_cntr; // Match the FFT's 4534 counter

always @ (posedge clk) begin
  if (rst == 0) begin
    sin_cntr <= 0;
    fs_sync_cntr <= 0;
  end else begin
   //FFT sampling rate-el sync
    if (fs_sync_cntr == 4534) begin
       fs_sync_cntr <= 0;

//       sin_cntr <= sin_cntr + 232; // (1024*10 000)/(44 100) ~= 232
       sin_cntr <= sin_cntr + 23; // (1024*1 000)/(44 100) ~= 23

       data_in <= sin_mem[sin_cntr];
    end else begin
       fs_sync_cntr <= fs_sync_cntr + 1;
    end
  end
end


endmodule
