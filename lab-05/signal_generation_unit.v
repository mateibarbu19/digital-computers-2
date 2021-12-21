/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module signal_generation_unit (
    input  wire [ `STAGE_COUNT-1:0] pipeline_stage,
    input  wire [`OPCODE_COUNT-1:0] opcode_type   ,
    input  wire [ `GROUP_COUNT-1:0] opcode_group  ,
    input  wire                     cycle_count   ,
    output wire [`SIGNAL_COUNT-1:0] signals
);

    /* Control signals */
    /*
    ID:
    CONTROL_REG_RR_READ do we read the value of rr ?
    CONTROL_REG_RD_READ do we read the value of rd ?
    EX:
    CONTROL_STACK_PREINC before reading from the stack, increment sp first
    MEM:
    CONTROL_STACK_PREINC is it a op. with multiple memory stages?
    CONTROL_STACK_POSTDEC do we decrement sp after writing?
    CONTROL_MEM_READ do we read from the memory?
    CONTROL_MEM_WRITE do we write to the memory?
    WB:
    CONTROL_REG_RR_WRITE writes in rr ?
    CONTROL_REG_RD_WRITE writes in rd ?
    */

    /* Register interface logic */
    assign signals[`CONTROL_REG_RR_READ] =
        (pipeline_stage == `STAGE_ID) &&
            (opcode_group[`GROUP_ALU_TWO_OP] ||
                (opcode_group[`GROUP_LOAD_INDIRECT] && !opcode_group[`GROUP_STACK]) ||
                opcode_group[`GROUP_REGISTER] ||
                opcode_group[`GROUP_STORE]);
    assign signals[`CONTROL_REG_RR_WRITE] = 0;

    assign signals[`CONTROL_REG_RD_READ] =
        (pipeline_stage == `STAGE_ID) &&
            (opcode_group[`GROUP_ALU] ||
                ((opcode_group[`GROUP_STORE_INDIRECT] || // X, Y sau Z
                        opcode_group[`GROUP_LOAD_INDIRECT]) && !opcode_group[`GROUP_STACK]));
    assign signals[`CONTROL_REG_RD_WRITE] =
        (pipeline_stage == `STAGE_WB) &&
            (opcode_group[`GROUP_ALU] ||
                opcode_group[`GROUP_REGISTER] ||
                opcode_group[`GROUP_LOAD]);

    /* Memory interface logic */
    assign signals[`CONTROL_MEM_READ] =
        (pipeline_stage == `STAGE_MEM) &&
            opcode_group[`GROUP_LOAD];
    assign signals[`CONTROL_MEM_WRITE] =
        (pipeline_stage == `STAGE_MEM) &&
            opcode_group[`GROUP_STORE];

    /*
    DONE 1: RCALL must push to the stack, so SP must be decremented for this op.
    Notice that RCALL makes two pushes. Make sure SP is decremented after both
    of them.
    */
    assign signals[`CONTROL_STACK_POSTDEC] =
        (pipeline_stage == `STAGE_MEM) &&
            ((opcode_type == `TYPE_PUSH) ||
                (opcode_type == `TYPE_RCALL));
    /*
    DONE 2: RET must first read from the stack, so SP must be pre-incremented
    for this op. Notice that RET does two pops, so SP must be incremented before
    both. These read occur at STAGE_MEM (cycle_count == 0) and STAGE_MEM
    (cycle_count == 1). What stages come beforehand?

    Hint: FSM-ul cycles in this way:
    ... -> STAGE_IF -> STAGE_ID -> STAGE_EX ->
    STAGE_MEM (cycle_count == 0) -> STAGE_MEM (cycle_count == 1) ->
    STAGE_WB -> STAGE_IF -> ...
    */
    assign signals[`CONTROL_STACK_PREINC] =
        ((pipeline_stage == `STAGE_EX) &&
            ((opcode_type == `TYPE_POP) || (opcode_type == `TYPE_RET))) ||
        (pipeline_stage == `STAGE_MEM && (opcode_type == `TYPE_RET) && cycle_count == 0);

endmodule
