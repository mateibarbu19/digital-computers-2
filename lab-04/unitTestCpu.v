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
	wire result;
   wire [`TEST_I_ADDR_WIDTH-1:0] pc;
	wire [`STAGE_COUNT-1:0] pipeline_stage;

	// Instantiate the Unit Under Test (UUT)
	unitTest uut (
		.clk(clk), 
		.reset(reset), 
		.result(result),
		.debug_program_counter(pc),
		.debug_pipeline_stage(pipeline_stage)
	);

	always #10 clk = ~clk;

	initial begin
		$dumpfile("waves.vcd");
        $dumpvars(0, unitTestCpu);
		// Initialize Inputs
		clk = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#10;
      	reset = 0;
		// Add stimulus here

		#2300;
        $finish();
	end
      
endmodule

