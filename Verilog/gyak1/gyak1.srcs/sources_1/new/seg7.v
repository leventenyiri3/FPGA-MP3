`timescale 1ns / 1ps
`default_nettype none


module seg7(
    input  wire       clk,
    input  wire       rst,
    
    input  wire [3:0] din0,
    input  wire [3:0] din1,
    input  wire [3:0] din2,
    input  wire [3:0] din3,
    
    output reg [3:0] dig,
    output reg [7:0] seg
);

reg [16:0] cntr_en = 0;
always @ (posedge clk)
if (cntr_en[16])
    cntr_en <= 17'b0;
else
    cntr_en <= cntr_en + 1;

wire en;
assign en = cntr_en[16];

reg [1:0] cntr_dig;
reg [3:0] shr_dig;
always @ (posedge clk)
if (rst)
begin
    cntr_dig <= 2'b0;
    shr_dig  <= 4'b0001; 
end
else if (en)
begin
    cntr_dig <= cntr_dig + 1;
    shr_dig  <= {shr_dig[2:0], shr_dig[3]};
end

reg [3:0] mux;
always @ ( * )
case (cntr_dig)
    2'b01:   mux <= din1;
    2'b10:   mux <= din2;
    2'b11:   mux <= din3;
    default: mux <= din0;
endcase

// 7-segment encoding
//      0
//     ---
//  5 |   | 1
//     --- <--6
//  4 |   | 2
//     ---
//      3
reg [6:0] dec;
always @( * )
case (mux)
    4'b0001 : dec = 7'b1111001;   // 1
    4'b0010 : dec = 7'b0100100;   // 2
    4'b0011 : dec = 7'b0110000;   // 3
    4'b0100 : dec = 7'b0011001;   // 4
    4'b0101 : dec = 7'b0010010;   // 5
    4'b0110 : dec = 7'b0000010;   // 6
    4'b0111 : dec = 7'b1111000;   // 7
    4'b1000 : dec = 7'b0000000;   // 8
    4'b1001 : dec = 7'b0010000;   // 9
    4'b1010 : dec = 7'b0001000;   // A
    4'b1011 : dec = 7'b0000011;   // b
    4'b1100 : dec = 7'b1000110;   // C
    4'b1101 : dec = 7'b0100001;   // d
    4'b1110 : dec = 7'b0000110;   // E
    4'b1111 : dec = 7'b0001110;   // F
    default : dec = 7'b1000000;   // 0
endcase

always @ (posedge clk)
begin
    dig <= shr_dig;
    seg <= {1'b0, ~dec};
end

endmodule
