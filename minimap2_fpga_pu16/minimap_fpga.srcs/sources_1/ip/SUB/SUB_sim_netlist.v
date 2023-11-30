// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Mon Jul 15 11:19:51 2019
// Host        : gpu-server5 running 64-bit CentOS Linux release 7.6.1810 (Core)
// Command     : write_verilog -force -mode funcsim
//               /home/cj/Learning/Vivado/minimap_fpga/minimap_fpga.srcs/sources_1/ip/SUB/SUB_sim_netlist.v
// Design      : SUB
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xcku115-flvf1924-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "SUB,c_addsub_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module SUB
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
  (* c_add_mode = "1" *) 
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
  SUB_c_addsub_v12_0_12 U0
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

(* C_ADD_MODE = "1" *) (* C_AINIT_VAL = "0" *) (* C_A_TYPE = "0" *) 
(* C_A_WIDTH = "16" *) (* C_BORROW_LOW = "1" *) (* C_BYPASS_LOW = "0" *) 
(* C_B_CONSTANT = "0" *) (* C_B_TYPE = "0" *) (* C_B_VALUE = "0000000000000000" *) 
(* C_B_WIDTH = "16" *) (* C_CE_OVERRIDES_BYPASS = "1" *) (* C_CE_OVERRIDES_SCLR = "0" *) 
(* C_HAS_BYPASS = "0" *) (* C_HAS_CE = "0" *) (* C_HAS_C_IN = "0" *) 
(* C_HAS_C_OUT = "0" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "2" *) 
(* C_OUT_WIDTH = "16" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_VERBOSITY = "0" *) (* C_XDEVICEFAMILY = "kintexu" *) (* ORIG_REF_NAME = "c_addsub_v12_0_12" *) 
(* downgradeipidentifiedwarnings = "yes" *) 
module SUB_c_addsub_v12_0_12
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
  (* c_add_mode = "1" *) 
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
  SUB_c_addsub_v12_0_12_viv xst_addsub
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
SMr+PPkWaMHckgi1V9odlIA/YhxAGX3gvewYLfYseFaA0t0KTjNzTXp2XTbyL1UmvGBEnK2Z1CbW
yEm/2+olJK8vUGq9hbeh+yK8p/LBuTZI4l/e15lodTkJZ5JCOyR8wukXBIRnzeWo5whoro0M8LEP
b0BjwkdQeL4IBA+j+glA10Z+FHkhRuKrtqK8GBfAH+pJED8Wa41DxkTR40O7T0eJOfYpJTxZHdit
gYbYBNOee+NCeF5Sbrcei7hKSMAykhY1mmA+K0EgYUlGZk39KM5ir/s6rwQZ8oyXray3cXslNVZN
kG8dJ3JAEDznJ3vw/vDWo3nnIIKkQ+sxdyb7JA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZBexaVgotTFKIC4IAVe4HbiPrnKqf0obiIOw+neYgFMzB+vjqCY4L/I2OLkEbmPwB11yYSsHh4Ka
oBaDYzS06dEIFQ8xsTQlYu341/gw7YCz61mEFFyI2P3s0Nuh05L4NFtLyMSIJJ+Q5IEV7tDnuxvj
2EXNK4pQF1tpW7JE0IcsVtvrBqv08oTaboOPZdzKcQIpqC+TLgaIHj49yI519rptK+zvkXOOIqYg
JxhDjTpEh9pDq/Rrp4pH0hHfCf/4P5M4QW0P08p7rPAfh6+r/GVJcuu9krfw6TNb8b1sWaowXCUA
aYi23NCOka2NByQgQkxtt0lFRCYTHbOALUsQxA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 25520)
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
