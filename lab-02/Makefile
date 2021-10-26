CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp
SOURCES = alu.v control_unit.v register_file.v state_machine.v checker.v \
			cpu.v checker_view.v decode_unit.v reg_file_interface_unit.v \
			rom.v signal_generation_unit.v

.PHONY: build clean

build: avr

avr: $(SOURCES)
	$(CC) $(FLAGS) -o $@.vvp $^

run: avr
	$(SIM) $<.vvp

clean:
	rm -f avr.vvp waves.vcd
