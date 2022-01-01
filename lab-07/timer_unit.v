/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module timer_unit #(parameter DATA_WIDTH = 8) (
    input  wire                      clk       , // input clock
    input  wire                      reset     , // reset signal
    input  wire     [DATA_WIDTH-1:0] mem_ocr0a , // OCR0A / OCR0B (Output Compare Register 0, channel A/B)
    input  wire     [DATA_WIDTH-1:0] mem_ocr0b , // OCR0A / OCR0B (Output Compare Register 0, channel A/B)
    input  wire     [DATA_WIDTH-1:0] mem_tcnt0 , // value from memory of counter for timer 0 (8 bits)
    input  wire     [DATA_WIDTH-1:0] mem_tccr0a, // TCCR0A, TCCR0B (Timer/Counter Control Registers A and B)
    input  wire     [DATA_WIDTH-1:0] mem_tccr0b, // TCCR0A, TCCR0B (Timer/Counter Control Registers A and B)
    output      reg [DATA_WIDTH-1:0] tcnt0     , // next value of counter
    output      reg                  oc0a      , // output pin channel A
    output      reg                  oc0b        // output pin channel B
);

    // Signals used for prescaling
    wire clk_t;
    wire clk_io; // original clk signal
    wire clk_io_8; // clk prescaled with 8 (8 times slower)
    wire clk_io_64; // clk prescaled with 64 (64 times slower)
    wire clk_io_256; // clk prescaled with 256 (256 times slower)
    wire clk_io_1024; // clk prescaled with 1024 (1024 times slower)

    wire [ 7:0] clk_sources; // array of clk signals
    reg  [13:0] count      ; // helper for prescaler

    always @(posedge clk, posedge reset) begin
        if (reset)
            count <= 0;
        else
            count <= count + 1;
    end

    // DONE 1: Generate prescaled clock sources
    // HINT: Which bit of count is changed every 2^X clk posedges?
    assign clk_io      = clk;
    assign clk_io_8    = count[2]; // clk / 2^3
    assign clk_io_64   = count[5]; // clk / 2^6
    assign clk_io_256  = count[7]; // clk / 2^8
    assign clk_io_1024 = count[9]; // clk / 2^10

    // DONE 1: Fill in array of available clock sources
    // HINT: This array corresponds to table 11-9, page 73, from the datasheet.
    // Remember that the array is defined [7:0], so the first item is actually
    // clk_sources[7].
    assign clk_sources = {
        1'b0, // cs0 == 7 - We don't support this options, so don't change this
        1'b0, // cs0 == 6 - We don't support this options, so don't change this
        clk_io_1024, // cs0 == 5 - clkI/O / 1024 (From prescaler)
        clk_io_256, // cs0 == 4 - clkI/O / 256 (From prescaler)
        clk_io_64, // cs0 == 3 - clkI/O / 64 (From prescaler)
        clk_io_8, // cs0 == 2 - clkI/O / 8 (From prescaler)
        clk_io, // cs0 == 1 - clkI/O (No prescaling)
        1'b0 // cs0 == 0 - No clock source (Timer/Counter stopped)
    };

    // DONE 1: Select the clock source to be used.
    // HINT: Use the array of available clock signals and cs0
    assign clk_t = clk_sources[cs0];

    // Bits in configuration register
    wire [1:0] com0a; // COM0A[1:0]: Compare Match Output A Mode
    wire [1:0] com0b; // COM0B[1:0]: Compare Match Output B Mode
    wire [2:0] wgm0 ; // WGM0 [2:0]: Waveform Generation Mode
    wire [2:0] cs0  ; // CS0[2:0]: Clock Select

    // DONE 2: Extract bits from TCCRA0A and TCCR0B.
    // HINT: Use mem_tccr0a and mem_tccr0b
    assign com0a = mem_tccr0a[7:6]; // datasheet pages: 69
    assign com0b = mem_tccr0a[5:4]; // datasheet pages: 69
    assign wgm0  = {mem_tccr0b[3], mem_tccr0a[1:0]}; // datasheet pages: 69, 72
    assign cs0   = mem_tccr0b[2:0]; // datasheet pages: 72

    wire [           5:0] timer_mode; // Timer operation mode
    wire [DATA_WIDTH-1:0] top       ; // Value at which counter resets

    // DONE 2: Set timer operation mode
    // HINT: See datasheet page 72 (Table 11-8. Waveform Generation Mode Bit Description)
    assign timer_mode =
        (wgm0 == 3'b000) ? `NORMAL :
        (wgm0 == 3'b010) ? `CTC :
        (wgm0 == 3'b011) ? `FAST_PWM_MAX :
        (wgm0 == 3'b111) ? `FAST_PWM_OCR :
        `INVALID;

    // DONE 2: Set value at which counter resets
    // HINT: See datasheet page 72 (Table 11-8. Waveform Generation Mode Bit Description)
    assign top =
        (timer_mode == `NORMAL) ?
            8'd255 :
            (timer_mode == `CTC) ?
                mem_ocr0a :
                (timer_mode == `FAST_PWM_MAX) ?
                    8'd255 :
                    (timer_mode == `FAST_PWM_OCR) ?
                        mem_ocr0a :
                        8'd0;

    // Counter assignment block.
    always @(posedge clk_t, posedge reset) begin
        $display("timp %t", $time);
        if (reset) begin
            tcnt0 <= 0;
        end else begin
            /* DONE 2: Increment counter
             * HINT: Use mem_tcnt0 to read the current counter value. The value
             * of TCNT0 should always be read from memory, because instructions
             * can also write to it.
             * HINT: Place the result into tcnt0 */
            if (mem_tcnt0 == top) begin
                tcnt0 <= {DATA_WIDTH{1'b0}}; // What should we do if we have reached TOP?
            end else begin
                tcnt0 <= mem_tcnt0 + 1; // What should we do if we have not reached TOP?
            end
        end
    end

    // Generate PWM logic on output pins OC0A and OC0B.
    always @(posedge clk_t, posedge reset) begin
        if (reset) begin
            oc0a <= 0;
            oc0b <= 0;
        end else begin
            /* DONE 3: Change the value of OC0A and OC0B
             * HINT: This depends on the timer operation mode, COM0A, COM0B,
             * the current counter value and the two compare values. See tables
             * 11-2, 11-3, 11-5 and 11-6 from the datasheet (pages 70-71). */
            case (timer_mode)
                `NORMAL, `CTC : begin
                    case (com0a)
                        2'b00   : ;
                        2'b01   : if (mem_ocr0a == tcnt0) oc0a <= ~oc0a;
                        2'b10   : if (mem_ocr0a == tcnt0) oc0a <= 0;
                        2'b11   : if (mem_ocr0a == tcnt0) oc0a <= 1;
                        default : ; // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        2'b00   : ;
                        2'b01   : if (mem_ocr0b == tcnt0) oc0b <= ~oc0b;
                        2'b10   : if (mem_ocr0b == tcnt0) oc0b <= 0;
                        2'b11   : if (mem_ocr0b == tcnt0) oc0b <= 1;
                        default : ; // Do nothing, OC0B disconnected from timer
                    endcase
                end
                `FAST_PWM_MAX, `FAST_PWM_OCR : begin
                    case (com0a)
                        2'b00   : ;
                        2'b01   : if (wgm0[2] && mem_ocr0a == tcnt0) oc0a <= ~oc0a;
                        2'b10   : if (mem_ocr0a == tcnt0) oc0a <= 0; else if (tcnt0 == 0) oc0a <= 1;
                        2'b11   : if (mem_ocr0a == tcnt0) oc0a <= 1; else if (tcnt0 == 0) oc0a <= 0;
                        default : ; // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        2'b00   : ;
                        2'b01   : if ( wgm0[2] && mem_ocr0b == tcnt0) oc0b <= ~oc0b;
                        2'b10   : if (mem_ocr0b == tcnt0) oc0b <= 0; else if (tcnt0 == 0) oc0b <= 1;
                        2'b11   : if (mem_ocr0b == tcnt0) oc0b <= 1; else if (tcnt0 == 0) oc0b <= 0;
                        default : ; // Do nothing, OC0B disconnected from timer
                    endcase
                end
                default : begin
                    case (com0a)
                        default : ; // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        default : ; // Do nothing, OC0B disconnected from timer
                    endcase
                end
            endcase
        end
    end

endmodule
