onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ram_512x8192_opt

do {wave.do}

view wave
view structure
view signals

do {ram_512x8192.udo}

run -all

quit -force
