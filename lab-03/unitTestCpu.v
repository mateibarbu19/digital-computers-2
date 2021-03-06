/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"
module unitTestCpu;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    /* verilator lint_off UNUSED */
    wire result;
    wire [`TEST_I_ADDR_WIDTH-1:0] PC;
    /* verilator lint_on UNUSED */

    // Instantiate the Unit Under Test (UUT)
    unitTest uut (
        .clk(clk), 
        .reset(reset), 
        .result(result)
`ifdef DEBUG
        ,
        .debug_program_counter(PC)
`endif
    );

    always #10 clk = ~clk;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, unitTestCpu);
        // Initialize Inputs
        clk = 0;
        reset = 1;

        // Wait for global reset to finish
        #10;
        reset = 0;
        // Add stimulus here

        #700;
        $finish();
    end
      
endmodule

