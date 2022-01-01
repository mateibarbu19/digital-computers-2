/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module rom #(
    parameter DATA_WIDTH = 16,
    parameter ADDR_WIDTH = 8   // 2 * 1024 bytes of ROM
) (
    input  wire                      clk ,
    input  wire     [ADDR_WIDTH-1:0] addr, // here comes the program counter
    output      reg [DATA_WIDTH-1:0] data  // here goes the instruction
);

    reg [DATA_WIDTH-1:0] value;

    always @* begin
        case (addr)
            /* ldi r16, 0b10000011 */
            0       : value = 16'b1110100000000011;
            /* out tccr0a, r16 */
            1       : value = 16'b1011101100001001;
            /* ldi r16, 0b00001001 */
            2       : value = 16'b1110000000001001;
            /* out tccr0b, r16 */
            3       : value = 16'b1011101100001000;
            /* ldi r16, 7 */
            4       : value = 16'b1110000000000111;
            /* out ocr0a, r16 */
            5       : value = 16'b1011101100000110;
            default : value = 16'b0000000000000000;
        endcase
    end
    always @(negedge clk) begin
        data <= value;
    end

endmodule
