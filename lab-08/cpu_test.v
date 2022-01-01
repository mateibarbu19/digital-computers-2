/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
// `timescale 1ns / 1ps
module cpu_test;
    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [7:0] pa;
    wire [7:0] pb;
    wire       oc0a;
    wire       oc0b;

    // Instantiate the Unit Under Test (UUT)
    cpu #(
        .DATA_WIDTH(8),         // registers are 8 bits in width
        .INSTR_WIDTH(16),       // instructions are 16 bits in width
        .I_ADDR_WIDTH(10),      // 2 * 1024 bytes of flash (or ROM in our case)
        .D_ADDR_WIDTH(7),       // 128 bytes of SRAM
        .R_ADDR_WIDTH(5),       // 32 registers
        .RST_ACTIVE_LEVEL(1)
    ) uut (
        .osc_clk(clk),
        .trace_mode(1'b0),
        .prescaler(5'b0),
        .trace_clk(1'b0),
        .reset(reset),
        .pa(pa),
        .pb(pb),
        .oc0a(oc0a),
        .oc0b(oc0b)
    );

    always #5 clk = ~clk;
    initial begin
        // Initialize Inputs
        clk = 1;
        reset = 1;
        // Wait 10 ns for global reset to finish
        #10;
        reset = 0;
    end

endmodule
