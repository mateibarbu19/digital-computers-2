CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: fetcher

fetcher: fetcher.v fetcher.v rom.v sram.v
	$(CC) $(FLAGS) -o $@.vvp $^

run: fetcher
	$(SIM) $<.vvp

clean:
	rm -rf fetcher.vvp waves.vcd
