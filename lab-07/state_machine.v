/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module state_machine (
    output      reg [`STATE_COUNT-1:0] state       ,
    output      reg                    cycle_count ,
    input  wire     [`GROUP_COUNT-1:0] opcode_group,
    input  wire                        clk         ,
    input  wire                        reset
);

    reg [`STATE_COUNT-1:0] next_state;

    always @(posedge clk, posedge reset)
        if (reset)
            state <= `STATE_RESET;
        else
            state <= next_state;

    always @(posedge clk, posedge reset) begin
        if (reset)
            cycle_count <= 0;
        else if (state == `STATE_MEM &&
            opcode_group[`GROUP_TWO_CYCLE_MEM])
        cycle_count <= ~cycle_count;
        else if (state == `STATE_WB &&
            opcode_group[`GROUP_TWO_CYCLE_WB])
        cycle_count <= ~cycle_count;
        else if (state == `STATE_ID &&
            opcode_group[`GROUP_TWO_CYCLE_ID])
        cycle_count <= ~cycle_count;
    end

    always @* begin
        case (state)
            `STATE_RESET :
            next_state = `STATE_IF;
            `STATE_IF    :
            next_state = `STATE_ID;
            `STATE_ID    :
            if (opcode_group[`GROUP_TWO_CYCLE_ID] && cycle_count == 0)
                next_state = `STATE_ID;
            else
                next_state = `STATE_EX;
            `STATE_EX  :
            next_state = `STATE_MEM;
            `STATE_MEM :
            if (opcode_group[`GROUP_TWO_CYCLE_MEM] && cycle_count == 0)
                next_state = `STATE_MEM;
            else
                next_state = `STATE_WB;
            `STATE_WB :
            if (opcode_group[`GROUP_TWO_CYCLE_WB] && cycle_count == 0)
                next_state = `STATE_WB;
            else
                next_state = `STATE_IF;
            /* Should never get here, but anyway */
            default :
                next_state = `STATE_RESET;
        endcase
    end

endmodule
