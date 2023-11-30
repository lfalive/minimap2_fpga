onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_512x16_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_512x16.udo}

run -all

quit -force
