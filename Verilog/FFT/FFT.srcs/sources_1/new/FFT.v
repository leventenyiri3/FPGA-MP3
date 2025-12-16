`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2025 09:35:59 AM
// Design Name: 
// Module Name: FFT
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


module FFT (
    input clk,
    input rst,
    input [15:0] data_in,
    output [31:0] fft_out,
    output fft_out_valid,
    output fft_out_last,
    output config_ready,
    output data_in_ready
);

  /********** INITIALIZING HANN WINDOWS **********/

  reg signed [15:0] hann_256_coeffs[0:255];
  reg signed [15:0] hann_1024_coeffs[0:1023];  //Q1.15

  initial begin
    $readmemh("hann_256_coeffs.mem", hann_256_coeffs);
    $readmemh("hann_1024_coeffs.mem", hann_1024_coeffs);
  end


  reg [31:0] config_tdata;
  reg config_valid;

  wire [15:0] buffer_out_raw;
  wire [31:0] buffer_out;
  wire [31:0] buffer_out_ext;

  reg data_in_valid[0:4];
  reg data_in_last[0:4];

  wire frame_started;
  wire tlast_unexpected;
  wire event_tlast_missing;


  xfft_0 fft_radix2 (
      .aclk                  (clk),                 // input wire aclk
      .aresetn               (rst),                 // input wire aresetn
      .s_axis_config_tdata   (config_tdata),        // input wire [31 : 0] s_axis_config_tdata
      .s_axis_config_tvalid  (config_valid),        // input wire s_axis_config_tvalid
      .s_axis_config_tready  (config_ready),        // output wire s_axis_config_tready
      .s_axis_data_tdata     (buffer_out_ext),      // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid    (data_in_valid[4]),    // input wire s_axis_data_tvalid
      .s_axis_data_tready    (data_in_ready),       // output wire s_axis_data_tready
      .s_axis_data_tlast     (data_in_last[4]),     // input wire s_axis_data_tlast
      .m_axis_data_tdata     (fft_out),            // output wire [31 : 0] m_axis_data_tdata
      .m_axis_data_tvalid    (fft_out_valid),      // output wire m_axis_data_tvalid
      .m_axis_data_tlast     (fft_out_last),       // output wire m_axis_data_tlast
      .event_frame_started   (frame_started),       // output wire event_frame_started
      .event_tlast_unexpected(tlast_unexpected),    // output wire event_tlast_unexpected
      .event_tlast_missing   (event_tlast_missing)  // output wire event_tlast_missing
  );


  reg we_a_reg;
  reg [9:0] smpl_wr_addr;
  reg [9:0] smpl_rd_addr;


  reg [12:0] fs_cntr;
  reg start;
  reg [9:0] start_cntr;

  /*** GENERATING F_s, INCREMENTING RAM INPUT ADDRESS ***/

  always @(posedge clk) begin
    if (rst == 0) begin
      fs_cntr <= 0;
      we_a_reg <= 0;
      smpl_wr_addr <= 0;
      start <= 0;
      start_cntr <= 0;
    end else begin
      //Write_en generálás
      fs_cntr <= fs_cntr + 1;
      if (fs_cntr == 4534) begin
        fs_cntr  <= 0;
        we_a_reg <= 1;
      end else begin
        we_a_reg <= 0;
      end

      // mindig itt írunk FSM-ben csak az olvasást kezeljük
      if (we_a_reg == 1) begin
        smpl_wr_addr <= smpl_wr_addr + 1;

        if (start == 0) begin
          start_cntr <= start_cntr + 1;
          if (start_cntr == 1023) start <= 1;  // FSM start trigger
        end
      end
    end
  end


  /*************** INPUT SAMPLE RAM ***************/
  ram #(
      .DATA_W(16),
      .ADDR_W(10)   // 2^10 -1 = 1023
  ) buffer (
      .clk_a (clk),
      .we_a  (we_a_reg),
      .addr_a(smpl_wr_addr),
      .din_a (data_in),
      .dout_a(),

      .clk_b (clk),
      .we_b  (),
      .addr_b(smpl_rd_addr),
      .din_b (),
      .dout_b(buffer_out_raw)
  );

  /************************* FINITE STATE MACHINE ***************************/

  localparam [1:0] SAMPLE_IN = 2'b00;
  localparam [1:0] SMALL_BLOCK_READ = 2'b01;
  localparam [1:0] LARGE_BLOCK_READ = 2'b10;
  localparam [1:0] CONFIG = 2'b11;


  reg [1:0] state_reg;
  reg [7:0] small_read_cntr;
  reg [7:0] small_smpl_cntr;
  reg [9:0] small_read_cntr_offset;
  reg [9:0] large_read_cntr;
  reg [9:0] large_smpl_cntr;
  reg [9:0] large_read_cntr_offset;

  always @(posedge clk) begin
    if (rst == 0) begin
      state_reg <= SAMPLE_IN;
      config_tdata <= 0;
      small_read_cntr <= 0;
      small_smpl_cntr <= 0;
      large_read_cntr <= 0;
      large_smpl_cntr <= 0;
      small_read_cntr_offset <= 0;
      large_read_cntr_offset <= 0;
      data_in_last[0] <= 0;
      data_in_last[1] <= 0;
      data_in_last[2] <= 0;
      data_in_last[3] <= 0;
      data_in_last[4] <= 0;
      smpl_rd_addr <= 0;
      smpl_wr_addr <= 0;
      config_valid <= 0;
      data_in_valid[0] <= 0;
      data_in_valid[1] <= 0;
      data_in_valid[2] <= 0;
      data_in_valid[3] <= 0;
      data_in_valid[4] <= 0;

    end else if (start == 1) begin
      case (state_reg)
        SAMPLE_IN: begin
          if (small_smpl_cntr == 192) begin
            state_reg <= CONFIG;

          end else if (large_smpl_cntr == 576) begin
            state_reg <= CONFIG;

          end else begin
            if (we_a_reg == 1) begin

              small_smpl_cntr <= small_smpl_cntr + 1;

              large_smpl_cntr <= large_smpl_cntr + 1;
            end

          end
        end

        CONFIG: begin
          if (small_smpl_cntr == 192) begin
            config_tdata <= {
              7'b0000000,  // PAD hogy 32 bit legyen, mert byte- többszörösnek kell a hossznak lennie
              16'b0101010101010101,  // SCALE_SCH 8db 01pár
              1'b1,  // FWD/INV 
              //8'b00000000,         // CP_LEN 
              3'b000,
              5'b01000  // PAD, NFFT :256
            };

            config_valid <= 1;
            if (config_ready == 1 && config_valid == 1) begin
              small_smpl_cntr <= 0;
              config_valid <= 0;
              smpl_rd_addr <= small_read_cntr_offset;
              state_reg <= SMALL_BLOCK_READ;
            end
          end else if (large_smpl_cntr == 576) begin
            config_tdata <= {
              3'b000,  // PAD hogy 32 bit legyen, mert byte- többszörösnek kell a hossznak lennie
              20'b01010101010101010101,  // SCALE_SCH 10db 01pár
              1'b1,  // FWD/INV 
              //8'b00000000,         // CP_LEN 
              3'b000,
              5'b01010  // NFFT :1024
            };  // SCALE_SCH FWD/INV PAD CP_LEN PAD NFFT nem fér bele...


            config_valid <= 1;
            if (config_ready == 1 && config_valid == 1) begin
              large_smpl_cntr <= 0;
              config_valid <= 0;
              smpl_rd_addr <= large_read_cntr_offset; //ezt itt azért kell, hogy a legelső olvasásnál ne rossz helyről olvasson, utána úgyis korrigálva lenne
              state_reg <= LARGE_BLOCK_READ;
            end

          end
        end

        SMALL_BLOCK_READ: begin

          data_in_valid[0] <= 1;

          if (data_in_valid[0] == 1 && data_in_ready == 1) begin //ha képes adatot fogadni az FFT core, akkor megkezdünk egy olvasást


            if (small_read_cntr == 255) begin
              small_read_cntr_offset <= small_read_cntr_offset + 192;  //overlap
              small_read_cntr <= 0;
              // smpl_rd_addr <= 0;

              data_in_last[0] <= 0;
              data_in_valid[0] <= 0;
              state_reg <= SAMPLE_IN;
            end else begin
              small_read_cntr  <= small_read_cntr + 1;
              smpl_rd_addr <= (small_read_cntr_offset + small_read_cntr + 1);

              if (small_read_cntr == 254) begin
                data_in_last[0] <= 1;
              end

            end
          end
        end

        LARGE_BLOCK_READ: begin

          data_in_valid[0] <= 1;

          if (data_in_valid[0] == 1 && data_in_ready == 1) begin //ha képes adatot fogadni az FFT core, akkor megkezdünk egy olvasást


            if (large_read_cntr == 1023) begin
              large_read_cntr_offset <= large_read_cntr_offset + 576;  //overlap
              large_read_cntr <= 0;
              //smpl_rd_addr <= 0;

              data_in_last[0] <= 0;
              data_in_valid[0] <= 0;
              state_reg <= SAMPLE_IN;
            end else begin
              large_read_cntr  <= large_read_cntr + 1;
              smpl_rd_addr <= (large_read_cntr_offset + large_read_cntr + 1);

              if (large_read_cntr == 1022) begin
                data_in_last[0] <= 1;
              end


            end
          end
        end

        default: begin
          state_reg <= SAMPLE_IN;

          small_read_cntr <= 0;
          large_read_cntr <= 0;
          data_in_valid[0] <= 0;
          data_in_last[0] <= 0;
        end

      endcase
    end
  end

  /***************************** HANN WINDOW ***************************/

  reg [9:0] hann_cntr;
  reg signed  [15:0] hann_coeff;

  always @(*) begin
    if (data_in_valid[1] == 1 && config_tdata[1] == 0) hann_coeff <= hann_256_coeffs[hann_cntr];

    else if (data_in_valid[1] == 1 && config_tdata[1] == 1) begin
      hann_coeff <= hann_1024_coeffs[hann_cntr];
    end
  end


  always @(posedge clk) begin
    if (rst == 0) begin
      hann_coeff   <= 0;
      config_tdata <= 0;

    end else begin
      data_in_valid[1] <= data_in_valid[0];
      data_in_valid[2] <= data_in_valid[1];
      data_in_valid[3] <= data_in_valid[2];
      data_in_valid[4] <= data_in_valid[3];

      data_in_last[1]  <= data_in_last[0];
      data_in_last[2]  <= data_in_last[1];
      data_in_last[3]  <= data_in_last[2];
      data_in_last[4]  <= data_in_last[3];
    end
  end

  //1-el késleltetni kell a cntr-t, mert a ramból olvasás is 1clk
  always @(posedge clk) begin
    if (rst == 0) begin
      hann_cntr <= 0;
    end else if (data_in_valid[0] == 1 && config_tdata[1] == 0) hann_cntr <= small_read_cntr;

    else if (data_in_valid[0] == 1 && config_tdata[1] == 1) hann_cntr <= large_read_cntr;

  end

  wire signed [15:0] dsp_in;
  assign dsp_in = data_in_valid[1] == 0 ? 16'b0 : buffer_out_raw;

  //Hann ablakozás FFT előtt
  dsp dsp0 (
      .clk (clk),
      .in_a(dsp_in),
      .in_b(hann_coeff),
      .out (buffer_out)
  );

  assign buffer_out_ext = {16'b0, buffer_out[30:15]};

  reg [32:0] out_abs;
  wire signed [15:0] fft_real = fft_out[15:0];
  wire signed [15:0] fft_imag = fft_out[31:16];

  /************************ POWER DENSITY SPECTRUM ************************/
  //skálázás is kell (8/3)
  //ezt is itt inkább dsp-vel
  always @(posedge clk) begin
    if (rst == 0) begin
      out_abs <= 0;
    end else begin
      out_abs <= (fft_real * fft_real) + (fft_imag * fft_imag);
    end
  end


endmodule
