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
    //    input [39:0] config_tdata,
    //    input config_valid,

    input [15:0] data_in,
    //    input data_in_valid,
    //    input data_in_last,

    output [31:0] data_out,
    output data_out_valid,
    output data_out_last,
    output config_ready,
    output data_in_ready


    // TEST PORTS

    //output fs_out

);

  //reg clk;
  //reg rst;
  reg [31:0] config_tdata;
  reg config_valid;
  //wire config_ready;
  //reg [31:0] data_in;
  reg data_in_valid;
  //wire data_in_ready;
  reg data_in_last;
  //wire [31:0] data_out;
  //wire data_out_valid;
  //reg data_out_ready;
  //wire data_out_last;

  wire frame_started;
  wire tlast_unexpected;
  wire tlast_missing;
  wire status_channel_halt;
  wire data_in_channel_halt;
  wire data_out_channel_halt;

  wire [15:0] buffer_out_raw;
  reg [31:0] buffer_out_reg_ext;
  wire [31:0] buffer_out;  //ezt majd még Hann ablakozni

  reg data_in_valid_d1, data_in_valid_d2;
  reg data_in_last_d1, data_in_last_d2;

  reg [31:0] shadow_reg;
  reg shadow_valid;

  // A 0-k hozzáfűzése miatt késik az FFT bemenete, hogy ne legyen
  // adatveszteség kell egy skid buffer, mivel mindig az első elküldött adat
  // után egy clk-ra data_in_ready 0-ba megy, ekkor egy adatot elvesztünk,
  // elcsúszik a pipeline
  always @(posedge clk) begin
    if (rst == 0) begin
      data_in_valid_d1 <= 0;
      data_in_valid_d2 <= 0;
      data_in_last_d1 <= 0;
      data_in_last_d2 <= 0;
      buffer_out_reg_ext <= 0;
      shadow_reg <= 0;
      shadow_valid <= 0;
    end else begin

      if (data_in_ready) begin

        data_in_valid_d1 <= data_in_valid;
        data_in_last_d1  <= data_in_last;
        data_in_valid_d2 <= data_in_valid_d1;
        data_in_last_d2  <= data_in_last_d1;

        if (shadow_valid) begin
          buffer_out_reg_ext <= shadow_reg;
          shadow_valid <= 0;
        end else begin
          buffer_out_reg_ext <= {16'b0, buffer_out_raw};
        end
      end else begin
        // 1-el delayelt valid még 1-es, de a data_in_ready épp lement 0-ba,
        // mentjük az adatot, flaget állítunk
        if (data_in_valid_d1 == 1 && shadow_valid == 0) begin
          shadow_reg   <= {16'b0, buffer_out_raw};
          shadow_valid <= 1;
        end
      end
    end
  end

  assign buffer_out = buffer_out_reg_ext;


  xfft_0 fft_radix2 (
      .aclk                  (clk),                 // input wire aclk
      .aresetn               (rst),                 // input wire aresetn
      .s_axis_config_tdata   (config_tdata),        // input wire [31 : 0] s_axis_config_tdata
      .s_axis_config_tvalid  (config_valid),        // input wire s_axis_config_tvalid
      .s_axis_config_tready  (config_ready),        // output wire s_axis_config_tready
      .s_axis_data_tdata     (buffer_out),          // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid    (data_in_valid_d2),    // input wire s_axis_data_tvalid
      .s_axis_data_tready    (data_in_ready),       // output wire s_axis_data_tready
      .s_axis_data_tlast     (data_in_last_d2),     // input wire s_axis_data_tlast
      .m_axis_data_tdata     (data_out),            // output wire [31 : 0] m_axis_data_tdata
      .m_axis_data_tvalid    (data_out_valid),      // output wire m_axis_data_tvalid
      //  .m_axis_data_tready(data_out_ready),                    // input wire m_axis_data_tready
      .m_axis_data_tlast     (data_out_last),       // output wire m_axis_data_tlast
      .event_frame_started   (frame_started),       // output wire event_frame_started
      .event_tlast_unexpected(tlast_unexpected),    // output wire event_tlast_unexpected
      .event_tlast_missing   (event_tlast_missing)  // output wire event_tlast_missing
      //.event_status_channel_halt(tlast_missing),              // output wire event_status_channel_halt
      // .event_data_in_channel_halt(data_in_channel_halt),      // output wire event_data_in_channel_halt

      //  .event_data_out_channel_halt(data_out_channel_halt)     // output wire event_data_out_channel_halt
  );


  reg we_a_reg;
  reg we_b_reg;
  reg [13:0] smpl_wr_addr_reg;
  reg [13:0] smpl_rd_addr_reg;


  reg [12:0] fs_cntr;
  reg start;
  reg [9:0] start_cntr;

always @(posedge clk) begin
    if (rst == 0) begin
      fs_cntr <= 0;
      we_a_reg <= 0;
      smpl_cntr <= 0;
      smpl_wr_addr_reg <= 0;
      start <= 0;
      start_cntr <= 0;
    end 
    else begin
      //Write_en generálás
      fs_cntr <= fs_cntr + 1;
      if(fs_cntr == 4534) begin
        fs_cntr  <= 0;
        we_a_reg <= 1;
      end else begin
        we_a_reg <= 0;
      end

      // mindig itt írunk FSM-ben csak az olvasást kezeljük
      if (we_a_reg == 1) begin
        smpl_cntr <= smpl_cntr + 1;
        smpl_wr_addr_reg <= smpl_cntr;

        if (start == 0) begin
            start_cntr <= start_cntr + 1;
            if (start_cntr == 1023)
                start <= 1; // Trigger FSM to start
        end
      end
    end
  end


  ram #(
      .DATA_W(16),
      .ADDR_W(10)   // 2^10 -1 = 1023
  ) buffer (
      .clk_a (clk),
      .we_a  (we_a_reg),
      .addr_a(smpl_wr_addr_reg),
      .din_a (data_in),
      .dout_a(),

      .clk_b (clk),
      .we_b  (),
      .addr_b(smpl_rd_addr_reg),
      .din_b (),
      .dout_b(buffer_out_raw)
  );





  /************************* FINITE STATE MACHINE ***************************/

  localparam [1:0] SAMPLE_IN = 2'b00;
  localparam [1:0] SMALL_BLOCK_READ = 2'b01;
  localparam [1:0] LARGE_BLOCK_READ = 2'b10;
  localparam [1:0] CONFIG = 2'b11;

  reg [7:0] small_read_cntr;
  reg [7:0] small_smpl_cntr;
  reg [9:0] small_read_cntr_offset;
  reg [9:0] large_read_cntr;
  reg [9:0] large_smpl_cntr;
  reg [9:0] large_read_cntr_offset;
  reg [9:0] smpl_cntr;

  reg [1:0] state_reg;

  always @(posedge clk) begin
    if (rst == 0) begin
      state_reg <= SAMPLE_IN;
      config_tdata <= 0;
      smpl_cntr <= 0;
      small_read_cntr <= 0;
      small_smpl_cntr <= 0;
      large_read_cntr <= 0;
      large_smpl_cntr <= 0;
      small_read_cntr_offset <= 0;
      large_read_cntr_offset <= 0;
      data_in_last <= 0;
      smpl_rd_addr_reg <= 0;
      smpl_wr_addr_reg <= 0;
      config_valid <= 0;
      data_in_valid <= 0;

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
              smpl_rd_addr_reg <= small_read_cntr_offset;
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
              smpl_rd_addr_reg <= large_read_cntr_offset; //ezt itt azért kell, hogy a legelső olvasásnál ne rossz helyről olvasson, utána úgyis korrigálva lenne
              state_reg <= LARGE_BLOCK_READ;
            end

          end
        end

        SMALL_BLOCK_READ: begin

          data_in_valid <= 1;

          if (data_in_valid == 1 && data_in_ready == 1) begin //ha képes adatot fogadni az FFT core, akkor megkezdünk egy olvasást


            if (small_read_cntr == 255) begin
              small_read_cntr_offset <= small_read_cntr_offset + 192;  //overlap
              small_read_cntr <= 0;
              // smpl_rd_addr_reg <= 0;

              data_in_last <= 0;
              data_in_valid <= 0;
              state_reg <= SAMPLE_IN;
            end else begin
              small_read_cntr  <= small_read_cntr + 1;
              smpl_rd_addr_reg <= (small_read_cntr_offset + small_read_cntr + 1);

              if (small_read_cntr == 254) begin
                data_in_last <= 1;
              end

            end


          end

        end

        LARGE_BLOCK_READ: begin

          data_in_valid <= 1;

          if (data_in_valid == 1 && data_in_ready == 1) begin //ha képes adatot fogadni az FFT core, akkor megkezdünk egy olvasást


            if (large_read_cntr == 1023) begin
              large_read_cntr_offset <= large_read_cntr_offset + 576;  //overlap
              large_read_cntr <= 0;
              //smpl_rd_addr_reg <= 0;

              data_in_last <= 0;
              data_in_valid <= 0;
              state_reg <= SAMPLE_IN;
            end else begin
              large_read_cntr  <= large_read_cntr + 1;
              smpl_rd_addr_reg <= (large_read_cntr_offset + large_read_cntr + 1);

              if (large_read_cntr == 1022) begin
                data_in_last <= 1;
              end


            end
          end
        end

        default: begin
          state_reg <= SAMPLE_IN;

          small_read_cntr <= 0;
          large_read_cntr <= 0;
          data_in_valid <= 0;
          data_in_last <= 0;
        end

      endcase
    end
  end

  reg [32:0] out_abs;
  wire signed [15:0] fft_real = data_out[15:0];
  wire signed [15:0] fft_imag = data_out[31:16];

  always @(posedge clk) begin
    if (rst == 0) begin
      out_abs <= 0;
    end
    else begin
      out_abs <= (fft_real * fft_real) + (fft_imag * fft_imag);
    end
  end


endmodule
