/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module rom #(
        parameter   DATA_WIDTH = 16,
        parameter   ADDR_WIDTH = 8          // 2 * 1024 bytes of ROM
    )(
        input  wire                  clk,
        input  wire [ADDR_WIDTH-1:0] addr,  // here comes the program counter
        output  reg [DATA_WIDTH-1:0] data   // here goes the instruction
    );

    reg [DATA_WIDTH-1:0] value;

    always @* begin
        case (addr)
        /*   rjmp   main        */
        0:      value = 16'b1100000000010010;
        /*   reti           */
        1:      value = 16'b1001010100011000;
        /*   reti           */
        2:      value = 16'b1001010100011000;
        /*   reti           */
        3:      value = 16'b1001010100011000;
        /*   reti           */
        4:      value = 16'b1001010100011000;
        /*   reti           */
        5:      value = 16'b1001010100011000;
        /*   reti           */
        6:      value = 16'b1001010100011000;
        /*   reti           */
        7:      value = 16'b1001010100011000;
        /*   reti           */
        8:      value = 16'b1001010100011000;
        /*   reti           */
        9:      value = 16'b1001010100011000;
        /*   reti           */
        10:     value = 16'b1001010100011000;
        /*   rjmp   tim0_ovf_isr        */
        11:     value = 16'b1100000000000101;
        /*   reti           */
        12:     value = 16'b1001010100011000;
        /*   reti           */
        13:     value = 16'b1001010100011000;
        /*   reti           */
        14:     value = 16'b1001010100011000;
        /*   reti           */
        15:     value = 16'b1001010100011000;
        /*   reti           */
        16:     value = 16'b1001010100011000;
        /*   ldi    r31, 0x2a       */
        17:     value = 16'b1110001011111010;
        /*   reti           */
        18:     value = 16'b1001010100011000;
        /*   ldi    r16, 0b00000000         */
        20:     value = 16'b1011101100001001;
        /*   ldi    r16, 0b00000001         */
        21:     value = 16'b1110000000000001;
        /*   out    tccr0b, r16         */
        22:     value = 16'b1011101100001000;
        /*   ldi    r16, 0b00000001         */
        23:     value = 16'b1110000000000001;
        /*   out    timsk, r16      */
        24:     value = 16'b1011110100000110;
        /*   sei            */
        25:     value = 16'b1001010001111000;
        /*   rjmp   loop        */
        26:     value = 16'b1100111111111111;
        default:        value = 16'b0000000000000000;
        endcase
    end

    always @(negedge clk) begin
        data <= value;
    end

endmodule
