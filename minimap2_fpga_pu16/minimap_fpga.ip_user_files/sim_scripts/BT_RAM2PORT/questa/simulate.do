onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib BT_RAM2PORT_opt

do {wave.do}

view wave
view structure
view signals

do {BT_RAM2PORT.udo}

run -all

quit -force
