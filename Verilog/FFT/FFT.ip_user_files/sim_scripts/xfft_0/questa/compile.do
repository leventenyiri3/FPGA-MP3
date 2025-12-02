vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xbip_utils_v3_0_14
vlib questa_lib/msim/axi_utils_v2_0_10
vlib questa_lib/msim/c_reg_fd_v12_0_10
vlib questa_lib/msim/xbip_dsp48_wrapper_v3_0_7
vlib questa_lib/msim/xbip_pipe_v3_0_10
vlib questa_lib/msim/c_addsub_v12_0_20
vlib questa_lib/msim/c_shift_ram_v12_0_19
vlib questa_lib/msim/mult_gen_v12_0_23
vlib questa_lib/msim/floating_point_v7_1_20
vlib questa_lib/msim/cmpy_v6_0_26
vlib questa_lib/msim/xfft_v9_1_14
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xbip_utils_v3_0_14 questa_lib/msim/xbip_utils_v3_0_14
vmap axi_utils_v2_0_10 questa_lib/msim/axi_utils_v2_0_10
vmap c_reg_fd_v12_0_10 questa_lib/msim/c_reg_fd_v12_0_10
vmap xbip_dsp48_wrapper_v3_0_7 questa_lib/msim/xbip_dsp48_wrapper_v3_0_7
vmap xbip_pipe_v3_0_10 questa_lib/msim/xbip_pipe_v3_0_10
vmap c_addsub_v12_0_20 questa_lib/msim/c_addsub_v12_0_20
vmap c_shift_ram_v12_0_19 questa_lib/msim/c_shift_ram_v12_0_19
vmap mult_gen_v12_0_23 questa_lib/msim/mult_gen_v12_0_23
vmap floating_point_v7_1_20 questa_lib/msim/floating_point_v7_1_20
vmap cmpy_v6_0_26 questa_lib/msim/cmpy_v6_0_26
vmap xfft_v9_1_14 questa_lib/msim/xfft_v9_1_14
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv "+incdir+../../../../../../../../../../../opt/Xilinx/2025.1/data/rsb/busdef" \
"/opt/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/opt/Xilinx/2025.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_14 -64 -93  \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_10 -64 -93  \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work c_reg_fd_v12_0_10 -64 -93  \
"../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_7 -64 -93  \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10 -64 -93  \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_20 -64 -93  \
"../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work c_shift_ram_v12_0_19 -64 -93  \
"../../../ipstatic/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_23 -64 -93  \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_20 -64 -93  \
"../../../ipstatic/hdl/floating_point_v7_1_vh_rfs.vhd" \

vcom -work cmpy_v6_0_26 -64 -93  \
"../../../ipstatic/hdl/cmpy_v6_0_vh_rfs.vhd" \

vcom -work xfft_v9_1_14 -64 -2008  \
"../../../ipstatic/hdl/xfft_v9_1_vh08_rfs.vhd" \

vcom -work xfft_v9_1_14 -64 -93  \
"../../../ipstatic/hdl/xfft_v9_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -64 -93  \
"../../../../FFT.gen/sources_1/ip/xfft_0/sim/xfft_0.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

