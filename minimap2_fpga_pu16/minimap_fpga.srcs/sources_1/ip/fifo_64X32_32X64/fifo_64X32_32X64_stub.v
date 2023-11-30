// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Dec 14 17:32:31 2020
// Host        : fpga-0 running 64-bit Ubuntu 18.04.1 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top fifo_64X32_32X64 -prefix
//               fifo_64X32_32X64_ fifo_64x32_32x64_stub.v
// Design      : fifo_64x32_32x64
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_3,Vivado 2018.3" *)
module fifo_64X32_32X64(wr_clk, wr_rst, rd_clk, rd_rst, din, wr_en, rd_en, 
  dout, full, empty)
/* synthesis syn_black_box black_box_pad_pin="wr_clk,wr_rst,rd_clk,rd_rst,din[31:0],wr_en,rd_en,dout[63:0],full,empty" */;
  input wr_clk;
  input wr_rst;
  input rd_clk;
  input rd_rst;
  input [31:0]din;
  input wr_en;
  input rd_en;
  output [63:0]dout;
  output full;
  output empty;
endmodule
