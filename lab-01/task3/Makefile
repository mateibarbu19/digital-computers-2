CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: sram

sram: sram.v test_sram.v
	$(CC) $(FLAGS) -o $@ $^

run: sram
	$(SIM) $<

clean:
	rm -rf sram waves.vcd
