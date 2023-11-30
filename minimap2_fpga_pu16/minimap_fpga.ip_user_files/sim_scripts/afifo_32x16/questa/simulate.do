onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib afifo_32x16_opt

do {wave.do}

view wave
view structure
view signals

do {afifo_32x16.udo}

run -all

quit -force
