`timescale 1ns / 1ps
`include "defines.vh"

module state_machine (
        output reg  [`STAGE_COUNT-1:0] pipeline_stage,
        input  wire                    clk,
        input  wire                    reset
    );

    always @(posedge clk, posedge reset) begin
        if (reset)
            pipeline_stage <= `STAGE_RESET;
        else begin
            case (pipeline_stage)
            `STAGE_RESET:
                pipeline_stage <= `STAGE_IF;
            `STAGE_IF:
                pipeline_stage <= `STAGE_ID;
            `STAGE_ID:
                pipeline_stage <= `STAGE_EX;
            `STAGE_EX:
                pipeline_stage <= `STAGE_MEM;
            `STAGE_MEM:
                pipeline_stage <= `STAGE_WB;
            `STAGE_WB:
                pipeline_stage <= `STAGE_IF;
            /* Should never get here, but anyway */
            default:
                pipeline_stage <= `STAGE_RESET;
            endcase
        end
    end

endmodule
