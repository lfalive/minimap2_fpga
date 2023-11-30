onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib SUB_opt

do {wave.do}

view wave
view structure
view signals

do {SUB.udo}

run -all

quit -force
