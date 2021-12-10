/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps

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
            /* ldi r16, 5 */
            0: value = 16'b1110000000000101;
            /* rjmp main_function */
            1: value = 16'b1100000000000010;
            /* ldi r17, 15 */
            2: value = 16'b1110000000011111;
            /* ret */
            3: value = 16'b1001010100001000;
            /* ldi r17, 10 */
            4: value = 16'b1110000000011010;
            /* rcall first_function */
            5: value = 16'b1101111111111100;
            /* ldi r18, 20 */
            6: value = 16'b1110000100100100;
            default: value = 16'b0000000000000000;
        endcase
    end

    always @(negedge clk) begin
        data <= value;
    end

endmodule
