onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_64X32_32X64_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_64X32_32X64.udo}

run -all

quit -force
