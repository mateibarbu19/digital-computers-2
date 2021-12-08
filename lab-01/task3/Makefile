CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: sram.vvp

sram.vvp: sram.v test_sram.v
	$(CC) $(FLAGS) -o $@ $^

waves.vcd: sram.vvp
	$(SIM) $<

run: waves.vcd

clean:
	rm -rf sram.vvp waves.vcd
