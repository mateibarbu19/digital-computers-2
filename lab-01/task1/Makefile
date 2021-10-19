CC = iverilog
FLAGS = -Wall -Winfloop
SIM = vvp

.PHONY: build clean

build: rom

rom: rom.v test_rom.v
	$(CC) $(FLAGS) -o $@ $^

run: rom
	$(SIM) $<

clean:
	rm -rf rom waves.vcd
