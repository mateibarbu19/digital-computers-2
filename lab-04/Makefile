CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp
SOURCES = alu.v bus_interface_unit.v control_unit.v cpu.v decode_unit.v \
	dual_port_sram.v reg_file_interface_unit.v rom.v signal_generation_unit.v \
	sram.v state_machine.v unitTestCpu.v unitTest.v
SCHEMATIC = connections.json 

.PHONY: build clean

build: avr

avr: $(SOURCES)
	$(CC) $(FLAGS) -o $@.vvp $^

asm: ../resources/avrasm.jar
	java -jar $< input.asm output.txt

run: avr
	$(SIM) $<.vvp

$(SCHEMATIC): synth.ys alu.v
	yosys synth.ys
	rm -f *.pid

synthesis: $(SCHEMATIC)

clean:
	rm -f avr.vvp waves.vcd output.txt
