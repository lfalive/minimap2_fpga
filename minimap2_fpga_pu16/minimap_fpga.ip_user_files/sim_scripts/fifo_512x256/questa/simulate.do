onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_512x256_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_512x256.udo}

run -all

quit -force
