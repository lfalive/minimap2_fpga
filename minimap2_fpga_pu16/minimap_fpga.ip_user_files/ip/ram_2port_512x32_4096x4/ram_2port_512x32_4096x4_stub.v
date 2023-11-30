// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Jul 22 20:31:56 2019
// Host        : gpu-server5 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/cj/Learning/Vivado/minimap_fpga/minimap_fpga.srcs/sources_1/ip/ram_2port_512x32_4096x4/ram_2port_512x32_4096x4_stub.v
// Design      : ram_2port_512x32_4096x4
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module ram_2port_512x32_4096x4(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[8:0],dina[31:0],clkb,addrb[11:0],doutb[3:0]" */;
  input clka;
  input [0:0]wea;
  input [8:0]addra;
  input [31:0]dina;
  input clkb;
  input [11:0]addrb;
  output [3:0]doutb;
endmodule
