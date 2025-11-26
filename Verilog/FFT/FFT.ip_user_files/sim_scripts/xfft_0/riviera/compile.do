transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xbip_utils_v3_0_14
vlib riviera/axi_utils_v2_0_10
vlib riviera/c_reg_fd_v12_0_10
vlib riviera/xbip_dsp48_wrapper_v3_0_7
vlib riviera/xbip_pipe_v3_0_10
vlib riviera/c_addsub_v12_0_20
vlib riviera/c_shift_ram_v12_0_19
vlib riviera/mult_gen_v12_0_23
vlib riviera/floating_point_v7_1_20
vlib riviera/cmpy_v6_0_26
vlib riviera/xfft_v9_1_14
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xbip_utils_v3_0_14 riviera/xbip_utils_v3_0_14
vmap axi_utils_v2_0_10 riviera/axi_utils_v2_0_10
vmap c_reg_fd_v12_0_10 riviera/c_reg_fd_v12_0_10
vmap xbip_dsp48_wrapper_v3_0_7 riviera/xbip_dsp48_wrapper_v3_0_7
vmap xbip_pipe_v3_0_10 riviera/xbip_pipe_v3_0_10
vmap c_addsub_v12_0_20 riviera/c_addsub_v12_0_20
vmap c_shift_ram_v12_0_19 riviera/c_shift_ram_v12_0_19
vmap mult_gen_v12_0_23 riviera/mult_gen_v12_0_23
vmap floating_point_v7_1_20 riviera/floating_point_v7_1_20
vmap cmpy_v6_0_26 riviera/cmpy_v6_0_26
vmap xfft_v9_1_14 riviera/xfft_v9_1_14
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../../../../../../../../opt/Xilinx/2025.1/data/rsb/busdef" -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l c_reg_fd_v12_0_10 -l xbip_dsp48_wrapper_v3_0_7 -l xbip_pipe_v3_0_10 -l c_addsub_v12_0_20 -l c_shift_ram_v12_0_19 -l mult_gen_v12_0_23 -l floating_point_v7_1_20 -l cmpy_v6_0_26 -l xfft_v9_1_14 -l xil_defaultlib \
"/opt/Xilinx/2025.1/Vivado/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"/opt/Xilinx/2025.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_14 -93  -incr \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_10 -93  -incr \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work c_reg_fd_v12_0_10 -93  -incr \
"../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_7 -93  -incr \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10 -93  -incr \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_20 -93  -incr \
"../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work c_shift_ram_v12_0_19 -93  -incr \
"../../../ipstatic/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_23 -93  -incr \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_20 -93  -incr \
"../../../ipstatic/hdl/floating_point_v7_1_vh_rfs.vhd" \

vcom -work cmpy_v6_0_26 -93  -incr \
"../../../ipstatic/hdl/cmpy_v6_0_vh_rfs.vhd" \

vcom -work xfft_v9_1_14 -2008  -incr \
"../../../ipstatic/hdl/xfft_v9_1_vh08_rfs.vhd" \

vcom -work xfft_v9_1_14 -93  -incr \
"../../../ipstatic/hdl/xfft_v9_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../FFT.gen/sources_1/ip/xfft_0/sim/xfft_0.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

