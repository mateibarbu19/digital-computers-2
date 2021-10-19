CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: ram

ram: ram.v test_ram.v
	$(CC) $(FLAGS) -o $@ $^

run: ram
	$(SIM) $<

clean:
	rm -rf ram waves.vcd
