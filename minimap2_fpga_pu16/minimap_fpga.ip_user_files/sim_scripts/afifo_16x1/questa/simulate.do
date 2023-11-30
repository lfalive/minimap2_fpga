onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib afifo_16x1_opt

do {wave.do}

view wave
view structure
view signals

do {afifo_16x1.udo}

run -all

quit -force
