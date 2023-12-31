onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_2 -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.ram_2port_512x32_4096x4 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {ram_2port_512x32_4096x4.udo}

run -all

quit -force
