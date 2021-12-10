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
    CONTROL_REG_RR_READ cite?te valoarea lui rr ?
    CONTROL_REG_RD_READ cite?te valoarea lui rd ?
    EX:
    CONTROL_STACK_PREINC când citim din stiva o incrementam înainte
    MEM:
    CONTROL_STACK_PREINC daca e o operatie cu mai multe etape de memorie ?
    CONTROL_STACK_POSTDEC decrementam stiva dupa ce scriem
    CONTROL_MEM_READ trebuie sa citeasca din memorie ?
    CONTROL_MEM_WRITE trebuie sa scrie în memorie ?
    WB:
    CONTROL_REG_RR_WRITE scrie în rr ?
    CONTROL_REG_RD_WRITE scrie în rd ?
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
    TODO 1: RCALL trebuie sa scrie date pe stiva, deci SP trebuie decrementat
    pentru aceasta operatie. Problema este ca RCALL dace doua scrieri. Asigurati-va
    ca SP este decrementat dupa ambele.
    */
    assign signals[`CONTROL_STACK_POSTDEC] =
        (pipeline_stage == `STAGE_MEM) &&
            ((opcode_type == `TYPE_PUSH))
                ;
    /*
    TODO 2: RET trebuie sa citeasca date de pe stiva, deci SP trebuie
    incrementat inainte de aceasta operatie. Problema este ca RET face doua
    citiri, deci SP trebuie incrementat inainte de ambele. Cele doua citiri se
    fac in stagiile STAGE_MEM (cycle_count == 0) si
    STAGE_MEM (cycle_count == 1). Ce stagii vin inainte de acestea doua?

    Hint: FSM-ul cicleaza prin stagii astfel:
    ... -> STAGE_IF -> STAGE_ID -> STAGE_EX ->
    STAGE_MEM (cycle_count == 0) -> STAGE_MEM (cycle_count == 1) ->
    STAGE_WB -> STAGE_IF -> ...
    */
    assign signals[`CONTROL_STACK_PREINC] =
        ((pipeline_stage == `STAGE_EX) && (opcode_type == `TYPE_POP)) ||
            ((pipeline_stage == `STAGE_MEM && cycle_count == 0))
                ;

endmodule
