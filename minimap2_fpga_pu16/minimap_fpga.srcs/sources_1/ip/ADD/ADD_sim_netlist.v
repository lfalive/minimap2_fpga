// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Jul 15 11:20:58 2019
// Host        : gpu-server5 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode funcsim
//               /home/cj/Learning/Vivado/minimap_fpga/minimap_fpga.srcs/sources_1/ip/ADD/ADD_sim_netlist.v
// Design      : ADD
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ADD,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module ADD
   (A,
    B,
    CLK,
    SCLR,
    S);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [15:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [15:0]B;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF s_intf:c_out_intf:sinit_intf:sset_intf:bypass_intf:c_in_intf:add_intf:b_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 s_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_intf, LAYERED_METADATA undef" *) output [15:0]S;

  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [15:0]S;
  wire SCLR;
  wire NLW_U0_C_OUT_UNCONNECTED;

  (* C_AINIT_VAL = "0" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintexu" *) 
  (* c_a_type = "0" *) 
  (* c_a_width = "16" *) 
  (* c_add_mode = "0" *) 
  (* c_b_constant = "0" *) 
  (* c_b_type = "0" *) 
  (* c_b_value = "0000000000000000" *) 
  (* c_b_width = "16" *) 
  (* c_bypass_low = "0" *) 
  (* c_has_bypass = "0" *) 
  (* c_has_c_in = "0" *) 
  (* c_has_c_out = "0" *) 
  (* c_latency = "2" *) 
  (* c_out_width = "16" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  ADD_c_addsub_v12_0_12 U0
       (.A(A),
        .ADD(1'b1),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b1),
        .CLK(CLK),
        .C_IN(1'b0),
        .C_OUT(NLW_U0_C_OUT_UNCONNECTED),
        .S(S),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADD_MODE = "0" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "0" *) 
(* C_A_WIDTH = "16" *) (* C_BORROW_LOW = "1" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_CONSTANT = "0" *) (* C_B_TYPE = "0" *) (* C_B_VALUE = "0000000000000000" *) 
(* C_B_WIDTH = "16" *) (* C_CE_OVERRIDES_BYPASS = "1" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_C_OUT = "0" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "2" *) 
(* C_OUT_WIDTH = "16" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintexu" *) (* ORIG_REF_NAME = "c_addsub_v12_0_12" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module ADD_c_addsub_v12_0_12
   (A,
    B,
    CLK,
    ADD,
    C_IN,
    CE,
    BYPASS,
    SCLR,
    SSET,
    SINIT,
    C_OUT,
    S);
  input [15:0]A;
  input [15:0]B;
  input CLK;
  input ADD;
  input C_IN;
  input CE;
  input BYPASS;
  input SCLR;
  input SSET;
  input SINIT;
  output C_OUT;
  output [15:0]S;

  wire \<const0> ;
  wire [15:0]A;
  wire [15:0]B;
  wire CLK;
  wire [15:0]S;
  wire SCLR;
  wire NLW_xst_addsub_C_OUT_UNCONNECTED;

  assign C_OUT = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_AINIT_VAL = "0" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "kintexu" *) 
  (* c_a_type = "0" *) 
  (* c_a_width = "16" *) 
  (* c_add_mode = "0" *) 
  (* c_b_constant = "0" *) 
  (* c_b_type = "0" *) 
  (* c_b_value = "0000000000000000" *) 
  (* c_b_width = "16" *) 
  (* c_bypass_low = "0" *) 
  (* c_has_bypass = "0" *) 
  (* c_has_c_in = "0" *) 
  (* c_has_c_out = "0" *) 
  (* c_latency = "2" *) 
  (* c_out_width = "16" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  ADD_c_addsub_v12_0_12_viv xst_addsub
       (.A(A),
        .ADD(1'b0),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b0),
        .CLK(CLK),
        .C_IN(1'b0),
        .C_OUT(NLW_xst_addsub_C_OUT_UNCONNECTED),
        .S(S),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
INaBf8vh5mCmDzf2yp77pxZAxQdyEQiT/vG2dEgvrFjseUnGc6ldwH4JvdnpZSpdf/ihioPyMNjl
u6ooyzv5TA==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
S5XIZZtuFR/MZffuhwdnvE3H9oRWM4uXoaGZTa/Dyk62O+Wa0v41pjmZELCiR7uodZPFQfykZ6K9
2ZDMu8dB3afQRMs5lnd/53M1b9ke+MNEeZ/wzjUcsJghubnEAwzdWeW/0tlqST1WD9B/KCxYqwH5
Gj6IZTTFHAXcaVhnCT8=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CM6IcdzP0PbD6yMSqylmi4JE2qpmxiNeI+prjGwJiD8e3Xsynu3PbGKJAOpOxtR1hT/3mpBcx1Rz
Fkz0QBh4wtE8fiziv1i+xi8T6cqC8ClamjrpZ//sn6dh7NvwSYik14MlwVuei4DZoZJZF63aoPUn
RXkQ13wtK+MkYKBcPVSZMFZmaCU6jMMBYclXzvRG1JqqZoa7mWFTeFZePUTXG7Wo12QaZ8GUi0AV
UIshoN25yn5e2Xr3FyuEtm5AvsZb+iLsgLeHBtKBnsVaHQphicgqwgwv6MQQF6ZNBgU/aACfibDS
3+n/mMMm8k1cj2bW6VCi7a+c8LmCf81NlJuLww==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ehl0CusS7+JNGq6HfhyaBMy68nccIdIGqixoEztEZfkCpXuUYsdqw6G9MIJdWdu0Ck2acV7K6IVg
rzb8/bNaDDVWp48kupToegTkOdwDkCejEqppido4BkJ+iEkjPniz+aJHlOlOwmauETy2hCMuuC57
oWDprzGWlsqbCjqzKrXmPYm6fNdcOa2DiOYstQaMFNbPU2ccrbLJAiYMHNDqtPNqWxKBsD67kiGf
2eOneDOmdmy7YkNsL+cx8MJc3BVUsYBrpAEsGyFMkmX8a8nYz8R/wlFQFGQAd/t5XrfxFNI58mj1
AHXbcAMhGKVq9YdKeU/vSXY/NwMqp12xJ1nUaw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
h/qRAwiPuqY/Zg/QWqbaYm8xWTi9SshYuPzyL0UME9ZDDF+C2CyGAugh9HzMdD0kZmT94TKmBgLR
dKP28nlE8VCCU5rvbjKxfn/wNtNKHCvZ1hns8CF7+pGuelhxGvXNmYKFw5co8+4grYFaDXeoZZR6
S5sjvhqtSVD3+qq4vYWRjT2Y/yes7L9dRsLq2D3iZ4xjgVHuIbOQLT/EUKW+9iYudT9Uy6YTwB+5
mSb0QK3YfZdGwZyXB4S3mdF9vNQHdW/rnACq3yngF+lprNkh3ooQKdGqtxtz8KSQxNZOAFE+koOw
h00o7AKpvDAp3uNguLvnNJH3rugOhh95b8Jatw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
TsA04vIYHDZne2CBj5bWCBFH4MtNoFDCn/3DNEi0BwutuUf+X+lD9kAO3kl352WHjQbF79Ssm+PT
fCYpODgWdxSVbzaHFpITxCQ4HcIJhUeW5PC5tw09Tand68D6eg84qRguH+llbb5jdGJkJeTCf+Mx
pupkkLiDvNyTYWe+nqw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rx9hgQkvaJJTJJcTjGFW1DrrWiT+xanrcMvFn0Z3KRXlZvf+SE7IQgGCiP7ZDA6T5z1Zv5nzS4h5
cVi+CvwC9UMZRWmLDAjzASJ2nx1g9BjbYe2vHAUmyurIiR6LSigTeM/9TlMv+fFwJbqwuH6FJ3/z
Vl4tIMk4NrqkMn/riOG87SjhesepM6kcQOBgDGzLTG14z3qeZG8OPzxgApfyubmX4qdD1oTgGm2u
Q4mQfFxEye6Jqkn4Rzjhifs/ieNYomHlK7R2/72QJj5j0WyYBIhvO+09izz299Z54ZP2ZXaRMfDT
lU4lQNqQU14PX9Yk9p7sy2PnK4vTwwF0CFIgSQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NYvW6OwCjTgMFqTsnFfotfUjrIiKoZ3M6MDySOQTZt9gnkFkao2VG4WodSbBxBCC8DhLDGYdxeZp
vSxZEb3/s90J/UCP4S/99ahC0fOVjnWda4OA2cM/6lxa/a+qzDpkNDD/u4nz3IeLwoOGtQVXed3l
YgUtxt7e/INhyDR2k5yPSfEHBjRW+VZoL4krfT05FcVoCX89OTUpa40bvqNpn93coS22bSr/qINL
dlNj2DchgYbfo+o+BaAkZl6BACjUaNiTRKvasEtAwts/gwngegUB/CpAyK6/96nQZhZynTDr2JLP
ykyD4qIRUFBCRKdbnQ7A1LtfZGTcpUt5CJKpVw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Oq04/yP7U9aWsciiMSZuw9jekzF4tLgMG6nosUo4Di46c10Y6kGCScTSizKgGfl9xJ5UhJNdaBao
N8Af+9Wc/bI7iXJ/PLXpwYhuvxebxwqziaIXI/9tOsENn9bqkqvRog1qvQg3c6BVwV8whhj8/zrw
NT9dfGAWqC4vEDYbeBeBYFZEjAHBQDkVnqGusUlvKLwhiCExoZQig2rIm9vvBtDzV1tDM3D4dqan
KDcIdHRkM0UP4oWomaROQKCTClxubcMCOa7XGuI7u31Tpqgg01DUwh2CtVIf3X5WVU5klCYj6EiX
T2UYoWua/0CrqBQgNArPW6rI39AaR2HRNSPECA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 21872)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
