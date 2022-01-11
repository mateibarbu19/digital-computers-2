CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp
SOURCES = alu.v bus_interface_unit.v control_unit.v cpu_test.v cpu.v \
 	decode_unit.v dual_port_sram.v gpio_unit.v interrupt_controller.v io_sram.v \
	reg_file_interface_unit.v rom.v signal_generation_unit.v sram.v \
	state_machine.v timer_unit.v

.PHONY: build clean

build: avr.vvp

avr.vvp: $(SOURCES)
	$(CC) $(FLAGS) -o $@ $^

task0%_assembled.vh: ../resources/avrasm.jar task0%.asm
	java -jar $^ $@

asm: task01_assembled.vh task02_assembled.vh task03_assembled.vh task04_assembled.vh

waves.vcd: avr.vvp
	$(SIM) $<

run: waves.vcd

clean:
	rm -f avr.vvp waves.vcd task*_assembled.vh
