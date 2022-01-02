# Laboratory 8

## Task 1

> Description: Implement the interrupt controller.

At first I added the `if_ext` and `int_src` to verify if a unmasked interrupt
has occurred. If so, activate the interrupt request flag and send it's
corresponding vector.

# Task 2

> Description: Implement the `SEI` and `CLI` instr.

The usual explanation for adding new instr. applies here as well. After decode,
I just added the instr. to the already written alu cases for `SBI` and `CLI`.

# Task 3

> Description: Implement the interrupt request handling and the `RETI` instr.

The comments in the [decode_unit](decode_unit.v) explain the first step.

Next, in the [control_unit](control_unit.v) the program counter is saved on the
stack and updated with the interrupt vector. For the ALU part, I just added some
new cases.

To finish off, the control signals are updated for `CALL_ISR` and `RETI` also.

---

Important bugs:

1. The [gpio_unit](gpio_unit.v) **didn't** initialize the stack pointer
    correctly.
2. Next, [Ștefan-Dan Ciocîrlan](https://github.com/sdcioc) fixed the `indirect_addr` when `RETI` was trying to restore the `saved_pc` from the stack.
