/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module state_machine (
    output      reg [`STAGE_COUNT-1:0] pipeline_stage,
    input  wire                        clk           ,
    input  wire                        reset         ,
    output      reg                    cycle_count   ,
    input  wire     [`GROUP_COUNT-1:0] opcode_group
);

    reg [`STAGE_COUNT-1:0] next_stage;

    /*
    Schimbarea etapei de pe procesor la fiecare ciclu de ceas
    */
    always @(posedge clk, posedge reset)
        if (reset)
            pipeline_stage <= `STAGE_RESET;
        else
            pipeline_stage <= next_stage;

    /* Counting cycles when operations have multiple cycles in one stage */
    always @(posedge clk, posedge reset) begin
        if (reset)
            cycle_count <= 0;
        /*
        Done: 1, 2. Read this note. Do not modify anything.

        If we are in the memory stage and we have a operation that needs two
        cycles. We change cycle_count to signal in which step we are.
        0 - first cycle
        1 - second cycle
        */
        else if (pipeline_stage == `STAGE_MEM && opcode_group[`GROUP_TWO_CYCLE_MEM])
            cycle_count <= ~cycle_count;
    end

    /* Select the next stage */
    always @* begin
        case (pipeline_stage)
            `STAGE_RESET:
            next_stage = `STAGE_IF;
            `STAGE_IF:
            next_stage = `STAGE_ID;
            `STAGE_ID:
            next_stage = `STAGE_EX;
            `STAGE_EX:
            next_stage = `STAGE_MEM;
            /*
            Done: 1, 2. Read this note. Do not modify anything.

            In the case of RCALL and RET operations we will need to access twice
            the memory twice to save the PC on the stack, or to pop it off.
            So, if we have a operation in the `GROUP_TWO_CYCLE_MEM, the next
            stage is also a memory one if we were in the first cycle of the two.
            */
            `STAGE_MEM:
            if (opcode_group[`GROUP_TWO_CYCLE_MEM] && cycle_count == 0)
                next_stage = `STAGE_MEM;
            else
                next_stage = `STAGE_WB;
            `STAGE_WB:
            next_stage = `STAGE_IF;
            default:
                next_stage = `STAGE_RESET;
        endcase
    end

endmodule
