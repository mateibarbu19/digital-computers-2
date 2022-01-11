# Laboratory 6

For the tasks which do not describe what I did follow the comments which contain
the string `DONE *` for more explications, where `*` is a task number.

## Task 1

> Description: Implement the communcation with the GPIO sram, through the
> bus_interface unit.

Code source: [bus_interface_unit.v](bus_interface_unit.v).

## Task 2

> Description: Implement the GPIO.

Code source: [io_sram.v](io_sram.v).

## Task 3 & 4

> Description: Implement the IN, OUT, CBI and SBI instructions.

As usual, I started off decoding the instructions. (See the comments for knowing
in which groups they belong.)

In [control_unit.v](control_unit.v) I set the `data_to_store` to take into
consideration the new instructions and the `writeback_value`.

For the alu input, I feed the `bus_data` and a bit mask, and set it to either an
`OPSEL_AND` or a `OPSEL_OR`.

Last, I tweaked the `CONTROL_REG_RR_READ` and `CONTROL_REG_RD_WRITE` for the
`IN`/`OUT` instr. The `CONTROL_IO_READ` was set as `CONTROL_MEM_READ`. But for
`CONTROL_IO_WRITE` the `GROUP_ALU_AUX` is allowed to write in the `STAGE_EX`.

**Warning!** Because this implementation does not execute any pipeline stages in
parallel we can write in the execute stage.

---

Since this was one of the hardest laboratories, allow me to end in a happier
note:

> Whatever doesn’t kill you makes you stronger. - Friedrich Nietzsche