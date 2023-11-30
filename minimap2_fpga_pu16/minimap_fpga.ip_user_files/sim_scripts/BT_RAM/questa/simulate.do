onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib BT_RAM_opt

do {wave.do}

view wave
view structure
view signals

do {BT_RAM.udo}

run -all

quit -force
