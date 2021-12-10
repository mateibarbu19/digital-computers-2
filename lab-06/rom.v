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
            // NU SCHIMBATI PANA LA VERIFICAREA EX. 1-4
            /* ldi r16, 1 */
            0       : value = 16'b1110000000000001;
            /* out 0x01, r16 */
            1       : value = 16'b1011100100000001;
            /* sbi 0x01, 1 */
            2       : value = 16'b1001101000001001;
            /* cbi 0x01, 0 */
            3       : value = 16'b1001100000001000;
            /* in r17, 0x01 */
            4       : value = 16'b1011000100010001;
            default : value = 16'b0000000000000000;
        endcase
    end

    always @(negedge clk) begin
        data <= value;
    end

endmodule
