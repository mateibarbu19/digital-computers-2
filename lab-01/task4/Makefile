CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: fetcher

fetcher.vvp: test_fetcher.v fetcher.v rom.v sram.v
	$(CC) $(FLAGS) -o $@ $^

connections.json: synth.ys fetcher.v
	yosys synth.ys
	rm -f *.pid

synthesis: connections.json

waves.vcd: fetcher.vvp
	$(SIM) $<

run: waves.vcd

clean:
	rm -rf fetcher.vvp waves.vcd schematic*.dot *.pid *.json
