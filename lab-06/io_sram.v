/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module io_sram #(
    parameter DATA_WIDTH   = 8 ,
    parameter ADDR_WIDTH   = 6 , // 64 I/O registers
    parameter I_ADDR_WIDTH = 10  // 1024 valid instructions
) (
    // to host cpu
    input wire                  clk    ,
    input wire                  reset  ,
    input wire                  oe     ,
    input wire                  cs     ,
    input wire                  we     ,
    input wire [ADDR_WIDTH-1:0] address,
    inout wire [DATA_WIDTH-1:0] data   ,
    // to external pins
    inout wire [DATA_WIDTH-1:0] pa     ,
    inout wire [DATA_WIDTH-1:0] pb
);

    reg  [DATA_WIDTH-1:0] memory  [0:(1<<ADDR_WIDTH)-1];
    reg  [ADDR_WIDTH-1:0] addr_buf                     ;
    wire                  readonly                     ;
    reg  [DATA_WIDTH-1:0] pa_buf                       ; // buffer for PORTA
    reg  [DATA_WIDTH-1:0] pb_buf                       ; // buffer for PORTB
    integer               i                            ;

    always @(negedge clk, posedge reset) begin // posedge
        if (reset) begin
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
                memory[i[ADDR_WIDTH-1:0]] <= 0;
            end
        end
        else if (cs) begin
            if (we && !readonly) begin
                memory[address] <= data;
            end else begin
                addr_buf <= address;
            end
        end

        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            /* Attention! The following explications use Port A as an
            example. They are valid and must be applied for Port B also.

            Reminder:
            DDRA - sets the pins directions, so:
            DDRA[5] == 0 means that pin 5 of port A reads.
            DDRA[3] == 1 means that pin 3 of port A writes.
            PORTA[3] this bit sets the value of pin 3, if DDRA[3] == 1 (otherwise it has no effect).
            PINA[6] tells the value of pin 6
            */

            /* DONE 2:
            For each bit, if DDRA is set for reading, we store the port value in memory.
            (In what register do we store it? Where do we read the value of a pin.)
            If DDRA is set for writing, we store in port_buffer the value to be set on the pin.
            (With what register do we assign the value to be set on the pin?)
            Do the same for Port B.
            */

            if (memory[`DDRA][i[2:0]] == 0) begin
                memory[`PINA][i[2:0]] <= pa[i[2:0]];
            end else begin
                pa_buf[i[2:0]] <= memory[`PORTA][i[2:0]];
                // Check out page Figure 10-2. General Digital I/O in the
                // Datasheet to understand the next line
                memory[`PINA][i[2:0]] <= memory[`PORTA][i[2:0]];
            end

            if (memory[`DDRB][i[2:0]] == 0) begin
                memory[`PINB][i[2:0]] <= pb[i[2:0]];
            end else begin
                pa_buf[i[2:0]] <= memory[`PORTB][i[2:0]];
                // Check out page Figure 10-2. General Digital I/O in the
                // Datasheet to understand the next line
                memory[`PINB][i[2:0]] <= memory[`PORTB][i[2:0]];
            end

        end
    end

    assign data     = (cs && oe && !we) ? memory[addr_buf] : {DATA_WIDTH{1'bz}};
    assign readonly = (address == `PINA || address == `PINB);

    /* DONE 1: Assign output values for each (individual) pin of PORTA and PORTB.
    * If the coresponding bit of DDRA is set, we will assign to PORTA the bit value from
    * PORTA's bufferul (declared at line 23), otherwise the pin will be in a high impedance state.
    * Example:
    * assign pa[0] = memory[`DDRA][0] ? pa_buf[0] : 1'bz;
    */
    generate
        genvar j;
        for (j = 0; j < 8; j = j + 1) begin : pin_buffering
            assign pa[j] = memory[`DDRA][j] ? pa_buf[j] : 1'bz;
            assign pb[j] = memory[`DDRB][j] ? pb_buf[j] : 1'bz;
        end
    endgenerate

endmodule

