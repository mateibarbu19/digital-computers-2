CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: sram

sram: sram.v test_sram.v
	$(CC) $(FLAGS) -o $@.vvp $^

run: sram
	$(SIM) $<.vvp

clean:
	rm -rf sram.vvp waves.vcd
