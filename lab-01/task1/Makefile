CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: rom.vvp

rom.vvp: rom.v test_rom.v
	$(CC) $(FLAGS) -o $@ $^

waves.vcd: rom.vvp
	$(SIM) $<

run: waves.vcd

connections.json: synth.ys rom.v
	yosys synth.ys
	rm -f *.pid

synthesis: connections.json

clean:
	rm -rf rom.vvp waves.vcd schematic*.dot *.pid *.json
