# Laboratory 3

This laboratory is a followup of the [last one](../lab-02/README.md).

## Task 1 & 2

> Description: Use the assembler and insert the `input.asm` instructions in the
> Verilog code. Simulate the whole thing.

Added a `make asm` command to assemble the instruction + `make run` for
simulation.

## Task 3

> Description: Implement the `LDI` instruction.

First, I went in [decode_unit.v](decode_unit.v#L75) and set the opcode type, rd
rr and imd. Still inside the decode module set in the `opcode_group` signal the
`GROUP_REGISTER` bit to one if `opcode_type` is `TYPE_LDI`.

Next, in the [control_unit](control_unit.v#L183) we set the `writeback_value` to
`opcode_imd`. This value will be interpreted by the `reg_file_interface_unit.v`.
Unlike the last laboratory we need not interpret the `opcode_type` and set the
`alu_opsel`.

Last, based on the `GROUP_REGISTER` I went and set
[`CONTROL_REG_RD_WRITE`](signal_generation_unit.v#L30) signal.

## Task 4

> Description: Implement the `STS` instruction.

First, I went in [decode_unit.v](decode_unit.v#L82) and set the opcode type, rd
rr and imd. Still inside the decode module set in the `opcode_group` signal the
`GROUP_STORE_DIRECT` bit to one if `opcode_type` is `TYPE_STS`.

Last, based on either the `GROUP_STORE` or `GROUP_STORE_DIRECT` bit I went and
set the following signals:

- [`CONTROL_REG_RR_READ`](signal_generation_unit.v#L17)
- [`CONTROL_REG_RD_READ`](signal_generation_unit.v#L24)
- [`CONTROL_MEM_WRITE`](signal_generation_unit.v#L44)

## Task 5

> Description: Implement the `LD_Y` instruction.

See the manual
[page](http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf#_OPENTOPIC_TOC_PROCESSING_d94e23368)
for clarification.

First, I went in [decode_unit.v](decode_unit.v#L91) and set the opcode type, rd
rr and imd. Still inside the decode module set in the `opcode_group` signal the
`GROUP_LOAD_INDIRECT` bit to one if `opcode_type` is `TYPE_LD_Y`.

Last, based on either the `GROUP_LOAD` or `GROUP_LOAD_INDIRECT` bit I went and
set the following signals:

- [`CONTROL_REG_RR_READ`](signal_generation_unit.v#L17)
- [`CONTROL_REG_RD_READ`](signal_generation_unit.v#L24)
- [`CONTROL_REG_RD_WRITE`](signal_generation_unit.v#L30)
- [`CONTROL_MEM_READ`](signal_generation_unit.v#L39)

## Task 6

> Description: Implement the `LDS` instruction.

First, I went in [decode_unit.v](decode_unit.v#L97) and set the opcode type, rd
rr and imd. Still inside the decode module set in the `opcode_group` signal the
`GROUP_LOAD_DIRECT` bit to one if `opcode_type` is `TYPE_LDS`.

Last, based on either the `GROUP_LOAD` or `GROUP_LOAD_DIRECT` bit I went and
set the following signals:

- [`CONTROL_REG_RD_WRITE`](signal_generation_unit.v#L30)
- [`CONTROL_MEM_READ`](signal_generation_unit.v#L39)

Don't forget to check out the `writeback_value` in
[control_unit.v](control_unit.v#L185).

## Task 7

> Description: Implement the `MOV` instruction.

First, I went in [decode_unit.v](decode_unit.v#L106) and set the opcode type, rd
rr and imd. Still inside the decode module set in the `opcode_group` signal the
`GROUP_REGISTER` bit to one if `opcode_type` is `TYPE_MOV`.

Last, based on either the `GROUP_LOAD` or `GROUP_LOAD_DIRECT` bit I went and
set the following signals:

- [`CONTROL_REG_RR_READ`](signal_generation_unit.v#L17)
- [`CONTROL_REG_RD_WRITE`](signal_generation_unit.v#L30)

Don't forget to check out the `writeback_value` in
[control_unit.v](control_unit.v#L187).