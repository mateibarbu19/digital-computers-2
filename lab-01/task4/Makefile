CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: fetcher

fetcher: test_fetcher.v fetcher.v rom.v sram.v
	$(CC) $(FLAGS) -o $@.vvp $^

synthesis: synth.ys
	yosys synth.ys
	rm -f *.pid

run: fetcher
	$(SIM) $<.vvp

clean:
	rm -rf fetcher.vvp waves.vcd schematic*.dot *.pid *.json
