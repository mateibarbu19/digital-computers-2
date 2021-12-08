CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp
SOURCES = alu.v control_unit.v dual_port_sram.v state_machine.v checker_t.v \
			cpu.v checker_view.v decode_unit.v reg_file_interface_unit.v \
			rom.v signal_generation_unit.v

.PHONY: build clean

build: avr.vvp

avr.vvp: $(SOURCES)
	$(CC) $(FLAGS) -o $@ $^

waves.vcd: avr.vvp
	$(SIM) $<

run: waves.vcd

clean:
	rm -f avr.vvp waves.vcd
