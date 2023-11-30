onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_256x512_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_256x512.udo}

run -all

quit -force
