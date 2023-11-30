// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Sat Dec 12 19:21:12 2020
// Host        : fpga-0 running 64-bit Ubuntu 18.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/fpga-0/NGS_prj/minimap_fpga_PU16/minimap_fpga.srcs/sources_1/ip/BT_RAM2PORT/BT_RAM2PORT_stub.v
// Design      : BT_RAM2PORT
// Purpose     : Stub declaration of top-level module interface
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module BT_RAM2PORT(clka, ena, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[63:0],clkb,enb,addrb[9:0],doutb[63:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [63:0]dina;
  input clkb;
  input enb;
  input [9:0]addrb;
  output [63:0]doutb;
endmodule
