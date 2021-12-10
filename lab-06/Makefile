CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp
SOURCES = alu.v bus_interface_unit.v control_unit.v cpu.v decode_unit.v \
	dual_port_sram.v gpio_sram.v reg_file_interface_unit.v rom.v \
	 signal_generation_unit.v sram.v state_machine.v unitTest.v
SCHEMATIC = connections.json 

.PHONY: build clean

build: avr.vvp

avr.vvp: $(SOURCES)
	$(CC) $(FLAGS) -o $@ $^

asm: ../resources/avrasm.jar
	java -jar $< input.asm output.txt

waves.vcd: avr.vvp
	$(SIM) $<

run: waves.vcd

$(SCHEMATIC): synth.ys alu.v
	yosys synth.ys
	rm -f *.pid

synthesis: $(SCHEMATIC)

clean:
	rm -f avr.vvp waves.vcd output.txt
