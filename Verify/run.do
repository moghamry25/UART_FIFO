vlib work
vlog FIFO.v RX.v TX.v UART.v baud_rate_generator.v tb.sv 
vsim -voptargs=+acc work.tb
add wave *
run -all
#quit -sim