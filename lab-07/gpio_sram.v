/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module gpio_sram #(
    parameter DATA_WIDTH   = 8 ,
    parameter ADDR_WIDTH   = 6 , // 64 I/O registers
    parameter I_ADDR_WIDTH = 10  // 1024 valid instructions
) (
    // to host cpu
    input  wire                  clk    ,
    input  wire                  reset  ,
    input  wire                  oe     ,
    input  wire                  cs     ,
    input  wire                  we     ,
    input  wire [ADDR_WIDTH-1:0] address,
    inout  wire [DATA_WIDTH-1:0] data   ,
    // to external pins
    inout  wire [DATA_WIDTH-1:0] pa     ,
    inout  wire [DATA_WIDTH-1:0] pb     ,
    output wire                  oc0a   ,
    output wire                  oc0b
);

    reg  [DATA_WIDTH-1:0] memory  [0:(1<<ADDR_WIDTH)-1];
    reg  [ADDR_WIDTH-1:0] addr_buf                     ;
    wire                  readonly                     ;
    wire [DATA_WIDTH-1:0] pa_buf                       ;
    wire [DATA_WIDTH-1:0] pb_buf                       ;
    wire [DATA_WIDTH-1:0] tcnt0                        ;
    reg  [  ADDR_WIDTH:0] i                            ;

    always @(negedge clk)
        begin
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
            memory[`PINA] <= pa; // taken directly from external pin
            memory[`PINB] <= pb; // taken directly from external pin
            // resolve write conflict between CPU and timer0,
            // give priority to CPU
            if (address == `TCNT0 && cs && we)
                memory[`TCNT0] <= data; // cpu allowed to change counter
            else
                memory[`TCNT0] <= tcnt0; // increment timer0 here
        end

    assign data     = (cs && oe && !we) ? memory[addr_buf] : {DATA_WIDTH{1'bz}};
    assign readonly = (address == `PINA || address == `PINB);

    assign pa = pa_buf; // directly to external pin
    assign pb = pb_buf; // directly to external pin

    gpio_unit #(.DATA_WIDTH(DATA_WIDTH)) gpio (
        .clk      (clk           ),
        .reset    (reset         ),
        .mem_ddra (memory[`DDRA] ),
        .mem_ddrb (memory[`DDRB] ),
        .mem_porta(memory[`PORTA]),
        .mem_portb(memory[`PORTB]),
        .pa_buf   (pa_buf        ),
        .pb_buf   (pb_buf        )
    );

    timer_unit #(.DATA_WIDTH(DATA_WIDTH)) timer0 (
        .clk       (clk            ),
        .reset     (reset          ),
        .mem_tcnt0 (memory[`TCNT0] ),
        .mem_tccr0a(memory[`TCCR0A]),
        .mem_tccr0b(memory[`TCCR0B]),
        .mem_ocr0a (memory[`OCR0A] ),
        .mem_ocr0b (memory[`OCR0B] ),
        .tcnt0     (tcnt0          ),
        .oc0a      (oc0a           ),
        .oc0b      (oc0b           )
    );

endmodule
