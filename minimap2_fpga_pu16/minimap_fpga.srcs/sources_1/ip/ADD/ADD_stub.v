// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Jul 15 11:20:57 2019
// Host        : gpu-server5 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/cj/Learning/Vivado/minimap_fpga/minimap_fpga.srcs/sources_1/ip/ADD/ADD_stub.v
// Design      : ADD
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *)
module ADD(A, B, CLK, SCLR, S)
/* synthesis syn_black_box black_box_pad_pin="A[15:0],B[15:0],CLK,SCLR,S[15:0]" */;
  input [15:0]A;
  input [15:0]B;
  input CLK;
  input SCLR;
  output [15:0]S;
endmodule
