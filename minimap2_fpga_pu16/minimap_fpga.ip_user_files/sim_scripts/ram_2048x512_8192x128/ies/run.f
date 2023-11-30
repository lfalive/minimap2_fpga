-makelib ies_lib/xil_defaultlib -sv \
  "/home/cj/Software/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/home/cj/Software/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "/home/cj/Software/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/blk_mem_gen_v8_4_2 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../minimap_fpga.srcs/sources_1/ip/ram_2048x512_8192x128/sim/ram_2048x512_8192x128.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

