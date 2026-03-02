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

reg signed [31:0] window_coeffs [512]; //Q1.31

initial begin
  $readmemh("window_coeffs.mem", window_coeffs);
end

//FSM: resetnél feltölteni 512 elemmel
localparam [1:0] BEGIN = 2'b00;
localparam [1:0] SAMPLE_IN = 2'b01;
localparam [1:0] CALC_SAMPLES = 2'b10;

reg [1:0] state_reg;
reg [8:0] input_sample_count;
reg [15:0] input_samples [512];
reg [4:0] shift_cntr;
reg [47:0] windowed_samples [512];
reg [8:0] window_cntr;
reg [47:0] window_mult_res_low;
reg [47:0] window_mult_res_high;



always @ (posedge clk) begin
  if (rst == 1) begin
    state_reg <= BEGIN;
    input_sample_count <= 0;
    shift_cntr <= 0;
    window_cntr <= 0;



  end else begin
    case(state_reg)
      BEGIN: begin
        input_samples[input_sample_count] <= sample;
        input_sample_count <= input_sample_count + 1;

        if (input_sample_count == 511) begin
          state_reg <= SAMPLE_IN;
        end
        else state_reg <= BEGIN;

      end

      SAMPLE_IN: begin
        input_samples <= {input_sample, input_samples[0:510]};
        shift_cntr <= shift_cntr + 1;

        if (shift_cntr == 31) begin
          state_reg <= CALC_SAMPLES;
        end
        else state_reg <= SAMPLE_IN;
      end

      CALC_SAMPLES: begin



      end


    default: begin
      state_reg <= SAMPLE_IN;
      input_sample_count <= 0;
    end

  endcase
  end




end







endmodule
