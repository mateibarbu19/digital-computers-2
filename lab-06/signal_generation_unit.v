/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module signal_generation_unit (
    input  wire [ `STAGE_COUNT-1:0] pipeline_stage,
    input  wire                     cycle_count   ,
    input  wire [`OPCODE_COUNT-1:0] opcode_type   ,
    input  wire [ `GROUP_COUNT-1:0] opcode_group  ,
    output wire [`SIGNAL_COUNT-1:0] signals
);

    /* Control signals */

    /* Register interface logic */

    /* DONE 3 & 4: Activate the signals to be able to work with register in the new instr.
    * What group uses RR? How does it use it?
    * What group uses RD? How does it use it?
    */

    assign signals[`CONTROL_REG_RR_READ] =
        (pipeline_stage == `STAGE_ID) &&
        (opcode_group[`GROUP_ALU_TWO_OP]
            || opcode_group[`GROUP_LOAD_INDIRECT]
            || opcode_group[`GROUP_REGISTER]
            || opcode_group[`GROUP_STORE]
            || opcode_type == `TYPE_MOV
            || opcode_type == `TYPE_OUT
        );
    assign signals[`CONTROL_REG_RR_WRITE] = 0;
    assign signals[`CONTROL_REG_RD_READ]  =
        (pipeline_stage == `STAGE_ID)
            && (opcode_group[`GROUP_ALU] ||
                opcode_group[`GROUP_ALU_IMD] ||
                ((opcode_group[`GROUP_STORE_INDIRECT] || // X, Y or Z
                        opcode_group[`GROUP_LOAD_INDIRECT])
                    && !opcode_group[`GROUP_STACK]));
    assign signals[`CONTROL_REG_RD_WRITE] =
        (pipeline_stage == `STAGE_WB) &&
            (opcode_group[`GROUP_ALU]
                || opcode_group[`GROUP_REGISTER]
                || (opcode_group[`GROUP_LOAD] && opcode_type != `TYPE_RET)
                || opcode_type == `TYPE_IN
            );

    /* Memory interface logic */
    assign signals[`CONTROL_MEM_READ] =
        (pipeline_stage == `STAGE_MEM) &&
            opcode_group[`GROUP_LOAD];
    assign signals[`CONTROL_MEM_WRITE] =
        (pipeline_stage == `STAGE_MEM) &&
            opcode_group[`GROUP_STORE];

    // DONE 3 & 4: Activate the control signals for addressing the I/O space

    /* DONE 4:
    * For the GROUP_ALU_AUX group, the signal appears in the in EX stage (after
    * we have the ALU result).
    * Attention! If it appears in the EX stage, it doesn't in WB stage!
    * In other words, activate the CONTROL_IO_WRITE signal for the GROUP_ALU_AUX
    * group during the EX stage. Deactivate it afterwards.
    */

    /* IO interface logic */
    assign signals[`CONTROL_IO_READ] =
        (pipeline_stage == `STAGE_ID) &&
            (opcode_group[`GROUP_IO_READ]);
    assign signals[`CONTROL_IO_WRITE] =
        (pipeline_stage == `STAGE_WB &&
            opcode_group[`GROUP_IO_WRITE] && !opcode_group[`GROUP_ALU_AUX]) ||
        (pipeline_stage == `STAGE_EX &&
            opcode_group[`GROUP_IO_WRITE] && opcode_group[`GROUP_ALU_AUX]);

    assign signals[`CONTROL_POSTDEC] =
        (opcode_type == `TYPE_PUSH || opcode_type == `TYPE_RCALL) &&
            (pipeline_stage == `STAGE_MEM);
    assign signals[`CONTROL_PREINC] =
        (opcode_type == `TYPE_POP) ?
            (pipeline_stage == `STAGE_EX) :
                (opcode_type == `TYPE_RET) &&
                    (pipeline_stage == `STAGE_EX || (pipeline_stage == `STAGE_MEM && cycle_count == 0));

endmodule
