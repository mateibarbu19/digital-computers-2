/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module timer_unit #(
        parameter    DATA_WIDTH = 8
    )(
        input  wire                  clk,        // input clock
        input  wire                  reset,      // reset signal
        input  wire [DATA_WIDTH-1:0] mem_ocr0a,  // OCR0A / OCR0B (Output Compare Register 0, channel A/B)
        input  wire [DATA_WIDTH-1:0] mem_ocr0b,  // OCR0A / OCR0B (Output Compare Register 0, channel A/B)
        input  wire [DATA_WIDTH-1:0] mem_tcnt0,  // value from memory of counter for timer 0 (8 bits)
        input  wire [DATA_WIDTH-1:0] mem_tifr,   // TIFR - Timer/Counter Interrupt Flag Register
        input  wire [DATA_WIDTH-1:0] mem_tccr0a, // TCCR0A, TCCR0B (Timer/Counter Control Registers A and B)
        input  wire [DATA_WIDTH-1:0] mem_tccr0b, // TCCR0A, TCCR0B (Timer/Counter Control Registers A and B)
        output reg  [DATA_WIDTH-1:0] tcnt0,      // next value of counter
        output reg  [DATA_WIDTH-1:0] tifr,       // next tifr
        output reg                   oc0a,       // output pin channel A
        output reg                   oc0b        // output pin channel B
    );

    // Signals used for prescaling
    wire    clk_t;
    wire    clk_io,      // original clk signal
            clk_io_8,    // clk prescaled with 8    (8   times slower)
            clk_io_64,   // clk prescaled with 64   (64  times slower)
            clk_io_256,  // clk prescaled with 256  (256 times slower)
            clk_io_1024; // clk prescaled with 1024 (1024 times slower)

    wire     [7:0] clk_sources;  // array of clk signals
    reg     [13:0] count;        // helper for prescaler

    always @(posedge clk, posedge reset) begin
        if (reset)
            count <= 0;
        else
            count <= count + 1;
    end

    assign clk_io           = clk;
    assign clk_io_8         = count[2]; // clk / 2^3
    assign clk_io_64        = count[5]; // clk / 2^6
    assign clk_io_256       = count[7]; // clk / 2^8
    assign clk_io_1024      = count[9]; // clk / 2^10

    assign clk_sources = {
        1'b0, // cs0 == 7 - We don't support this options, so don't change this
        1'b0, // cs0 == 6 - We don't support this options, so don't change this
        clk_io_1024,  // cs0 == 5 - clkI/O / 1024   (From prescaler)
        clk_io_256,   // cs0 == 4 - clkI/O / 256    (From prescaler)
        clk_io_64,    // cs0 == 3 - clkI/O / 64     (From prescaler)
        clk_io_8,     // cs0 == 2 - clkI/O / 8      (From prescaler)
        clk_io,       // cs0 == 1 - clkI/O          (No prescaling)
        1'b0          // cs0 == 0 - No clock source (Timer/Counter stopped)
        };

    assign clk_t = clk_sources[cs0];

    // Bits in configuration register
    wire            [1:0] com0a; // COM0A[1:0]: Compare Match Output A Mode
    wire            [1:0] com0b; // COM0B[1:0]: Compare Match Output B Mode
    wire            [2:0] wgm0;  // WGM0 [2:0]: Waveform Generation Mode
    wire            [2:0] cs0;   // CS0[2:0]: Clock Select

    assign com0a =  mem_tccr0a[7:6];                  // datasheet pages: 69
    assign com0b =  mem_tccr0a[5:4];                  // datasheet pages: 69
    assign wgm0  =  {mem_tccr0b[3], mem_tccr0a[1:0]}; // datasheet pages: 69, 72
    assign cs0   =  mem_tccr0b[2:0];                  // datasheet pages: 72

    wire [5:0]             timer_mode;  // Timer operation mode
    wire [DATA_WIDTH-1:0]  top;         // Value at which counter resets

    assign timer_mode =
        (wgm0 == 0) ? `NORMAL :
        (wgm0 == 2) ? `CTC :
        (wgm0 == 3) ? `FAST_PWM_MAX :
        (wgm0 == 7) ? `FAST_PWM_OCR :
        `INVALID;

    assign top =
        (timer_mode == `NORMAL) ? 8'hFF :
        (timer_mode == `CTC) ? mem_ocr0a :
        (timer_mode == `FAST_PWM_MAX) ? 8'hFF :
        (timer_mode == `FAST_PWM_OCR) ? mem_ocr0a :
        0;

    // Counter assignment block.
    always @(posedge clk_t, posedge reset) begin
        if (reset) begin
            tcnt0 <= 0;
        end else begin
            if (mem_tcnt0 == top) begin
                tcnt0 <= 0;
            end else begin
                tcnt0 <= mem_tcnt0 + 1;
            end
        end
    end

    // Interrupt flag assignment block.
    always @(posedge clk_t, posedge reset) begin
        if (reset) begin
            tifr  <= 0;
        end else begin
            tifr <= mem_tifr;

            // Warning, does not support multiple sets
            if (mem_tcnt0 == top && (timer_mode != `CTC || mem_tcnt0 == 8'hFF)) begin
                tifr  <= mem_tifr | (1 << `TOV0);
            end

            if (mem_tcnt0 == mem_ocr0a) begin
                tifr  <= mem_tifr | (1 << `OCF0A);
            end

            if (mem_tcnt0 == mem_ocr0b) begin
                tifr  <= mem_tifr | (1 << `OCF0B);
            end
        end
    end

    // OC0A, OC0B assignment block.
    always @(posedge clk_t, posedge reset) begin
        if (reset) begin
            oc0a <= 0;
            oc0b <= 0;
        end else begin
            case (timer_mode)
                `NORMAL, `CTC: begin
                    case (com0a)
                        1: if (mem_tcnt0 == mem_ocr0a) oc0a <= ~oc0a;   // Toggle OC0A on compare match
                        2: if (mem_tcnt0 == mem_ocr0a) oc0a <= 0;       // Clear OC0A on compare match
                        3: if (mem_tcnt0 == mem_ocr0a) oc0a <= 1;       // Set OC0A on compare match
                        default: ;                                      // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        1: if (mem_tcnt0 == mem_ocr0b) oc0b <= ~oc0b;   // Toggle OC0B on compare match
                        2: if (mem_tcnt0 == mem_ocr0b) oc0b <= 0;       // Clear OC0B on compare match
                        3: if (mem_tcnt0 == mem_ocr0b) oc0b <= 1;       // Set OC0B on compare match
                        default: ;                                      // Do nothing, OC0B disconnected from timer
                    endcase
                end

                `FAST_PWM_MAX, `FAST_PWM_OCR: begin
                    case (com0a)
                        1: if (wgm0[2] == 1 && mem_tcnt0 == mem_ocr0a) oc0a <= ~oc0a;  // WGM02 == 0: Do nothing, OC0A Disconnected from timer; WGM02 == 1: Toggle OC0A on Compare Match
                        2: if (mem_tcnt0 == mem_ocr0a) oc0a <= 0;                      // Clear OC0A on compare match, set OC0A at BOTTOM
                           else if (mem_tcnt0 == 0) oc0a <= 1;
                        3: if (mem_tcnt0 == mem_ocr0a) oc0a <= 1;                      // Set OC0A on compare match, clear OC0A at BOTTOM
                           else if (mem_tcnt0 == 0) oc0a <= 0;
                        default: ;                                                     // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        2: if (mem_tcnt0 == mem_ocr0b) oc0b <= 0; // Clear OC0B on compare match, set OC0B at BOTTOM
                           else if (mem_tcnt0 == 0) oc0b <= 1;
                        3: if (mem_tcnt0 == mem_ocr0b) oc0b <= 1; // Set OC0B on compare match, clear OC0B at BOTTOM
                           else if (mem_tcnt0 == 0) oc0b <= 0;
                        default: ;                                // Do nothing, OC0B disconnected from timer
                    endcase
                end

                default: begin
                    case (com0a)
                        default: ; // Do nothing, OC0A disconnected from timer
                    endcase

                    case (com0b)
                        default: ; // Do nothing, OC0B disconnected from timer
                    endcase
                end
            endcase
        end
    end

endmodule
