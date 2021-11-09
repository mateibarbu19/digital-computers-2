# Laboratory 2

![cheatsheet](cheatsheet_skel.png)

## CONTROL UNIT

### DECODE UNIT

> Description: decodes instructions from machine code.

Specifies: the type of operation, the values ​​of the RR and RD registers,
the index of the register used, the immediate value.
Defines the groups of operations according to: the way of accessing the memory,
the number of operands or the access to registers.

Code source: `decode_unit.v`

### SIGNALS

> Description: Determines the control signals, used by the processor,
> depending on the stage of the assembly line in which it is located and
> the groups of operations to which the instruction executed on the processor
> belongs.

Code source: `signal_generation_unit.v`

### FSM

> Description: simulates the pipeline.

It is responsible for the transition between the stages of the pipeline.

Code source: `state_machine.v`

### REGISTERS INTERFACE UNIT
> Description: determines whether to write/read to/from registers.

Specifies the register used.
Transports data to/from the registry.

Code source: `reg_file_interface.v`

### BUS INTERFACE UNIT

> Description: establishes a communication channel.

It consists of:

1. Signals sent to memory chips
2. Address accessed from memory
3. Data sent/retrieved to/from memory

Code source: `bus_interface_unit.v`

## SRAM

> Description: stores and delivers to or from a specific address.

Code source: `sram.v`

## Registers

> Description: defines 32 8-bit registers.

They are modeled as a static memory with 2 ports

Code source: `register_file.v`

## ROM

> Description: contains the instructions that the processor is to execute,
> defined in the machine code.

The generation of the instructions is done starting from the code written in
the assembly using the avrasm utility using the command:

```shell
java -jar avrasm.jar input.txt output.txt
```

Code source: `rom.v`

## ALU

> Description: determines the bit values ​​of the FLAGS register depending on
> the operation performed by the processor, according to the specifications in
> the documentation

Code source: `alu.v`

## Defines

> Description: defines all constants used in the current project

Code source: `defines.vh`
