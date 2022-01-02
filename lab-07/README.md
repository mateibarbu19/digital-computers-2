# Laboratory 7

# Task 1

> Description: Implement the prescaling logic for the timer.

At first, I assigned the `clk_io_*` wires to divide the global clock frequency.

# Task 2

> Description: Decode the `TCCR0*` registers and implement the TOP value attribution.

From the `mem_tccr0` registers I grouped bits into the `com0*`, `wgm0` and `cs`
registers. Based on them the clock source is selected and wired to `clk_t`
and a easier `timer_mode` management is done.

# Task 3

> Description: Implement the `OC0*` output logic.

The `tcnt0` register is incremented based on `clk_t`. Based on
the `timer_mode` and `com0*` the `oc0*` pins are set/cleared.
