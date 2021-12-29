# Laboratory 05

## Task 1&2

> Description: Implement the RCALL instruction.
> Description: Implement the RET instruction.

Since the first two tasks were solved together, they are commented upon as
such.

Because the pipeline design has changed for this lab, I began with tweaking the
`state_machine`.

For the decode stage see how [RCALL](decode_unit.v#L143) and
[RET](decode_unit.v#L152) are interpreted and set in their corresponding group.

The `data_to_store` becomes useful when the `CONTROL_MEM_WRITE` signal is
activated. (If you are curios enough, in the
[bus_interface_unit](bus_interface_unit.v) you shall see that a three-state
logic is implemented so we don't mess voltages up when we're not intending to
write.) It is modified to enable the store of the 10-bit program counter,
similar to two pushes. To store the program counter on the stack for a `RCALL`
op. we stash it's value `+ 1` to `saved_pc`. This is useful for the value of
the program counter will be forever lost when we at the relative jump during the
execute stage (i.e. the next stage).

If the program counter was pushed in two clock cycles expect it to be popped
likewise.

At last, I added the special cases for the stack post-decrementing and
pre-incrementing for the new instr.
