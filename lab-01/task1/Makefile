CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: rom

rom: rom.v test_rom.v
	$(CC) $(FLAGS) -o $@.vvp $^

run: rom
	$(SIM) $<.vvp

synthesis: synth.ys
	yosys synth.ys
	rm -f *.pid

clean:
	rm -rf rom.vvp waves.vcd schematic*.dot *.pid *.json
