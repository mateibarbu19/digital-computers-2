# Laboratory 4

## Task 1

> Description: Implement the `RJMP` instruction.

## Task 2

> Description: Implement the `BRBS` instruction.

## Task 3

> Description: Implement the `BRBC` instruction.

## Task 4

> Description: Implement the `PUSH` and `POP` instructions.

---

The solutions follow the same guidelines as the last ones. The only difference
is that this one contains more changes to the [control_unit](control_unit.v).

For example I added the stack decrementation and incrementation
[control block](control_unit.v#L203) and more advanced
[program counter jumps](control_unit.v#L151).
