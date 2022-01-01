/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module interrupt_controller #(
        parameter   DATA_WIDTH = 8,
        parameter I_ADDR_WIDTH = 10
    )(
        input wire                    clk,
        input wire                    reset,
        input wire   [DATA_WIDTH-1:0] mem_tifr,
        input wire   [DATA_WIDTH-1:0] mem_timsk,
        input wire   [DATA_WIDTH-1:0] mem_sreg,
        output reg                    irq,
        output reg [I_ADDR_WIDTH-1:0] vector
    );

    wire [DATA_WIDTH-1:0] if_ext;
    wire [DATA_WIDTH-1:0] int_src;

    assign if_ext  = {DATA_WIDTH{mem_sreg[`FLAGS_I]}};
    assign int_src = mem_tifr & mem_timsk & if_ext;

    always @(posedge clk) begin
        if (reset) begin
            irq    <= 0;
            vector <= 0;
        end else begin
            /* DONE 1: Replace the ? in the code below
             * First determine if we will generate an interrupt request or not. 
             *
             * E.g.: To generate a interrupt request for TIM0_OVF, three
             * conditions must be meet:
             *  - The interrupts must be globally activated (Hint: Which bit in
             *    SREG can help us?)
             *  - The TIM0_OVF interrupt must be unmasked (Hint: Which bit in
             *    TIMSK (see p. 74 in the datasheet) can help us?)
             *  - Timer/Counter0 must of overflowed (HINT: Which bit in TIFR
             *    (see p. 75 in the datasheet?) can help us?)
             *
             * If all of them are met, then a interrupt request will be
             * generated and the interrupt vector for TIM0_OVF_ISR will be sent.
             * HINT: What values must irq and vector take?
             *
             * The same logic applies for both TIM0_COMPA and TIM0_COMPB.
             */

            if (int_src[`OCF0B]) begin
                irq    <= 1;
                vector <= `TIM0_COMPB_ISR;
            end else if (int_src[`OCF0A]) begin
                irq    <= 1;
                vector <= `TIM0_COMPA_ISR;
            end else if (int_src[`TOV0]) begin
                irq    <= 1;
                vector <= `TIM0_OVF_ISR;
            end else begin
                irq    <= 0;
                // Let the vector register unchanged vector in order to know
                // which interrupt to acknowledge.
            end
        end
    end
endmodule
