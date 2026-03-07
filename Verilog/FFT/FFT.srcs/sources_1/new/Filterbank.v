`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03/01/2026 04:03:10 PM
// Design Name:
// Module Name: Filterbank
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


module Filterbank(
  input clk,
  input [15:0] sample,
  input rst



    );


//FSM: resetnél feltölteni 512 elemmel
localparam [1:0] BEGIN = 2'b00;
localparam [1:0] SAMPLE_IN = 2'b01;
localparam [1:0] CALC_SAMPLES = 2'b10;

reg [1:0] state_reg;
reg [8:0] input_sample_count;
reg [15:0] input_samples [512];
reg sample_write_en;
reg [8:0] sample_write_addr;
reg [8:0] sample_read_addr;
wire [15:0] sample_to_mul;
reg [4:0] sample_shift_cntr;

reg [4:0] shift_cntr;
reg [47:0] windowed_samples [512];
reg [8:0] window_cntr;
reg [47:0] window_mult_res_low;
reg [47:0] window_mult_res_high;

reg [8:0] coeff_read_addr;




always @ (posedge clk) begin
  if (rst == 1) begin
    state_reg <= BEGIN;
    input_sample_count <= 0;
    shift_cntr <= 0;
    window_cntr <= 0;
    sample_write_en <= 0;
    sample_write_addr <= 0;
    sample_read_addr <= 0;
    sample_read_addr_offset <= 0;
    sample_shift_cntr <= 0;
    sample_to_mul <= 0;
    coeff_read_addr <= 0;



  end else begin
    case(state_reg)
      BEGIN: begin

        if (input_sample_count == 511) begin
          state_reg <= SAMPLE_IN;
          sample_write_en <= 0;
          input_sample_count <= 0;
        end

        else begin
          state_reg <= BEGIN;
          input_sample_count <= input_sample_count + 1;
          sample_write_en <= 1;
        end

      end

      SAMPLE_IN: begin

        if (sample_shift_cntr == 31) begin
          state_reg <= CALC_SAMPLES;
          sample_shift_cntr <= 0;
          sample_read_addr_offset <= sample_read_addr_offset + 32;
          sample_write_en <= 0;
        end

        else begin
          state_reg <= SAMPLE_IN;
          sample_shift_cntr <= sample_shift_cntr + 1;
          sample_write_en <= 1;
        end

      end




      CALC_SAMPLES: begin

        if (input_sample_count == 511) begin
          state_reg <= SAMPLE_IN;
          sample_write_en <= 0;
          input_sample_count <= 0;
        end

        else begin
          state_reg <= SAMPLE_IN;
          input_sample_count <= input_sample_count + 1;
          sample_read_addr <= sample_read_addr_offset + input_sample_count;
          coeff_read_addr <= coeff_read_addr + coeff_read_addr;
        end



      end


    default: begin
      state_reg <= SAMPLE_IN;
      input_sample_count <= 0;
    end

  endcase
  end




end

wire [31:0] coeff;


c_coeff_rom_512x32 c_coeff_rom(
  .clk(clk),
  .addr(coeff_read_addr),
  .dout(coeff)
);

ram
#
(
  .DATA_W(16),
  .ADDR_W(9)
)(
  .clk_a(clk),
  .we_a(sample_write_en),
  .addr_a(sample_write_addr),
  .din_a(input_sample),
  .dout_a(),

  .clk_b(clk),
  .we_b(),
  .addr_b(sample_read_addr),
  .din_b(),
  .dout_b(sample_to_mul)
);

mul_24x35 mul_sample_and_coeff_c(
  .clk(clk),
  .a({{8{sample_to_mul[15]}}, sample_to_mul}),
  .b({{3{coeff[31]}}, coeff}),
  .m(mult_res) // ezt még vissza kell shiftelni (vagy csak wire-ban azokat a jeleket használni...)
);





endmodule
