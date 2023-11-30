onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib afifo_16x8_opt

do {wave.do}

view wave
view structure
view signals

do {afifo_16x8.udo}

run -all

quit -force
