CONTROL UNIT

DECODE UNIT (decode_unit.v) - decodes instructions from machine code.
	Specifies: the type of operation, the values ​​of the RR and RD registers,
	the index of the register used, the immediate value.
	Defines the groups of operations according to: the way of accessing the memory,
	the number of operands or the access to registers.
SIGNALS (signal_generation_unit.v) - Determines the control signals, used by the processor,
	depending on the stage of the assembly line in which it is located and
	the groups of operations to which the instruction executed on the processor belongs.
FSM (state_machine.v) - simulates the pipeline.
	It is responsible for the transition between the stages of the pipeline.
REGISTERS INTERFACE UNIT (reg_file_interface.v) - determines whether to write/read to/from registers.
	Specifies the register used.
	Transports data to/from the registry.
BUS INTERFACE UNIT (bus_interface_unit.v) - establishes a communication channel of:
	1. Signals sent to memory chips
	2. Address accessed from memory
	3. Data sent/retrieved to/from memory


SRAM (sram.v) - stores and delivers to or from a specific address
Registers (register_file.v) - defines 32 8-bit registers. They are modeled as a static memory with 2 ports
ROM (rom.v) - contains the instructions that the processor is to execute, defined in the machine code.
	The generation of the instructions is done starting from the code written in the assembly using
	the avrasm utility using the command:
	java -jar avrasm.jar input.txt output.txt
ALU (alu.v) - determines the bit values ​​of the FLAGS register depending on the operation performed by
	the processor, according to the specifications in the documentation
Defines (defines.vh) - defines all constants used in the current project