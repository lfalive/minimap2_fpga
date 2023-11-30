onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram_2port_512x32_4096x4_opt

do {wave.do}

view wave
view structure
view signals

do {ram_2port_512x32_4096x4.udo}

run -all

quit -force
