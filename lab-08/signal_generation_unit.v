/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module signal_generation_unit (
        input  wire  [`STATE_COUNT-1:0] state,
        input  wire                     cycle_count,
        input  wire [`OPCODE_COUNT-1:0] opcode_type,
        input  wire  [`GROUP_COUNT-1:0] opcode_group,
        output wire [`SIGNAL_COUNT-1:0] signals
    );

    /* Control signals */

    /* Register interface logic */
    assign signals[`CONTROL_REG_RR_READ] =
            (state == `STATE_ID) &&// || state == `STATE_EX) &&
            (opcode_group[`GROUP_ALU_TWO_OP] ||
             opcode_group[`GROUP_LOAD_INDIRECT]  ||
             // corect, dar redundant
             //opcode_group[`GROUP_STORE_INDIRECT] ||
             opcode_group[`GROUP_STORE] ||
             opcode_type == `TYPE_MOV ||
             opcode_type == `TYPE_OUT);
    assign signals[`CONTROL_REG_RR_WRITE] = 0;
    assign signals[`CONTROL_REG_RD_READ] =
            (state == `STATE_ID) &&// || state == `STATE_EX) &&
            (opcode_group[`GROUP_ALU] ||
             opcode_group[`GROUP_ALU_IMD] ||
            ((opcode_group[`GROUP_STORE_INDIRECT] ||   // X, Y or Z
              opcode_group[`GROUP_LOAD_INDIRECT]) &&
             !opcode_group[`GROUP_STACK]));

    /*  Done 3: Activate the RD read signal when necessary. (HINT: RETI behaves
     * like RET.) */
    assign signals[`CONTROL_REG_RD_WRITE] =
            (state == `STATE_WB) &&
            (opcode_group[`GROUP_REGISTER] ||
            (opcode_group[`GROUP_ALU]  && opcode_type != `TYPE_CP)  ||
            (opcode_group[`GROUP_ALU_IMD] && opcode_type != `TYPE_CPI) ||
            (opcode_group[`GROUP_LOAD] && opcode_type != `TYPE_RET) ||
             opcode_type == `TYPE_IN);

    /* Memory interface logic */
    assign signals[`CONTROL_MEM_READ] =
           (state == `STATE_MEM) &&
           opcode_group[`GROUP_LOAD];
    assign signals[`CONTROL_MEM_WRITE] =
           (state == `STATE_MEM) &&
           opcode_group[`GROUP_STORE];

    /* IO interface logic */
    assign signals[`CONTROL_IO_READ] =
        (state == `STATE_ID) &&
        opcode_group[`GROUP_IO_READ];
    assign signals[`CONTROL_IO_WRITE] =
        (state == `STATE_WB) &&
        opcode_group[`GROUP_IO_WRITE];

    /* DONE 3: Activate the SP post-decremental and pre-incremental signal when
     * necessary. HINT: With what instr. are CALL_ISR and RETI alike? */
    assign signals[`CONTROL_POSTDEC] =
            (opcode_type == `TYPE_PUSH  ||
             opcode_type == `TYPE_RCALL ||
             opcode_type == `TYPE_CALL_ISR) &&
            (state == `STATE_MEM);
    assign signals[`CONTROL_PREINC] =
            (opcode_type == `TYPE_POP) ?
                (state == `STATE_EX) :
            (opcode_type == `TYPE_RET || opcode_type == `TYPE_RETI) &&
                (state == `STATE_EX || (state == `STATE_MEM && cycle_count == 0));

endmodule
