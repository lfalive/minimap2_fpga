-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
-- Date        : Mon Dec  7 10:14:26 2020
-- Host        : fpga-0 running 64-bit Ubuntu 18.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/fpga-0/NGS_prj/minimap_fpga_PU16/minimap_fpga.srcs/sources_1/ip/BT_RAM/BT_RAM_stub.vhdl
-- Design      : BT_RAM
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcku115-flvf1924-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BT_RAM is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 63 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 63 downto 0 )
  );

end BT_RAM;

architecture stub of BT_RAM is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,wea[0:0],addra[9:0],dina[63:0],douta[63:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_2,Vivado 2018.3";
begin
end;
