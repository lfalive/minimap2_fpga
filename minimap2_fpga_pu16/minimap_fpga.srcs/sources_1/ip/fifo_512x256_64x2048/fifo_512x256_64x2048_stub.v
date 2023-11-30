// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Thu Dec 12 11:25:07 2019
// Host        : fpga-0 running 64-bit Ubuntu 18.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/fpga-0/NGS_prj/minimap_fpga_PU8/minimap_fpga.srcs/sources_1/ip/fifo_512x256_64x2048/fifo_512x256_64x2048_stub.v
// Design      : fifo_512x256_64x2048
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module fifo_512x256_64x2048(wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty, 
  rd_data_count, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="wr_clk,rd_clk,din[63:0],wr_en,rd_en,dout[511:0],full,empty,rd_data_count[8:0],wr_data_count[11:0]" */;
  input wr_clk;
  input rd_clk;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [511:0]dout;
  output full;
  output empty;
  output [8:0]rd_data_count;
  output [11:0]wr_data_count;
endmodule
