`timescale 1ns / 1ps
`include "defines.vh"

// Check your code by simulating this file. `result` signal should be 1.
module checker_view();
		
    // Inputs
    reg clk;
    reg reset;

    // Outputs
    /* verilator lint_off UNUSED */
    wire [`TEST_I_ADDR_WIDTH - 1:0] test;
    wire                            result;
    /* verilator lint_on UNUSED */

    // Instantiate the Unit Under Test (UUT)
    checker_t uut (
        .clk(clk),
        .reset(reset),
        .test(test),
        .result(result)
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, checker_view);
        // Initialize Inputs
        clk   = 0;
        reset = 1;

        // Wait 100 ns for global reset to finish
        #100;
        reset = 0;

        #700;
        $finish();
    end
endmodule
