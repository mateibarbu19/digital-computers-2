/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"

function TEST_XXX;
	input [`STAGE_COUNT-1:0]       pipeline_stage;
	input [`GROUP_COUNT-1:0]       opcode_group;
	input [`OPCODE_COUNT-1:0]      opcode_type;
	input [11:0]                   opcode_imd;
	input [`TEST_DATA_WIDTH-1:0]   writeback_value;
	input [`SIGNAL_COUNT-1:0]      signals;
	input [`TEST_R_ADDR_WIDTH-1:0] rr_addr;
	input [`TEST_R_ADDR_WIDTH-1:0] rd_addr;
	input [`TEST_DATA_WIDTH-1:0]   alu_rr;
	input [`TEST_DATA_WIDTH-1:0]   alu_rd;
	input [`TEST_DATA_WIDTH-1:0]   alu_out;
	input [`TEST_INSTR_WIDTH-1:0]  bus_address;
	input integer address;
	input [`TEST_R_ADDR_WIDTH-1:0] register_rr;
	input [`TEST_R_ADDR_WIDTH-1:0] register_rd;
	input integer value;
	begin
		case (pipeline_stage)
			`STAGE_IF:  TEST_XXX = 1'bx;
			`STAGE_ID:  TEST_XXX = 1'bx;
			`STAGE_EX:  TEST_XXX = 1'bx;
			`STAGE_MEM: TEST_XXX = 1'bx;
			`STAGE_WB:  TEST_XXX = 1'bx;
		endcase
	end
endfunction
