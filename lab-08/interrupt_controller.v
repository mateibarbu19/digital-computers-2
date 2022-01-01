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

    always @(posedge clk) begin
        if (reset) begin
            irq    <= 0;
            vector <= 0;
        end else begin
            /* TODO 1: Replace the ? in the code below
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

            // dummy implementation, erase it
            irq    <= 0;
            vector <= 0;

            // if (?) begin
            //     irq    <= ?;
            //     vector <= ?;
            // end else if (?) begin
            //     irq    <= ?;
            //     vector <= ?;
            // end else if (?) begin
            //     irq    <= ?;
            //     vector <= ?;
            // end else begin
            //     irq    <= 0;
            //     // Trebuie sa lasam variabila vector la valoarea anterioara
            //     // pentru a putea sti la ce intrerupere facem ACK.
            // end
        end
    end
endmodule
