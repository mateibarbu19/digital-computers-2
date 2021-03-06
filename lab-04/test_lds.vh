/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"

function TEST_LDS;
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
			`STAGE_IF:  TEST_LDS = 1'b1;
			`STAGE_ID:
				// because of how the STS address is defined, we need
				if(opcode_group[`GROUP_LOAD]
				&& opcode_type == `TYPE_LDS
				// because of how the LDS address is defined, we need to force the first bit to 1
				&& opcode_imd == (address[11:0] | 128))
					TEST_LDS = 1'b1;
				else
					TEST_LDS = 1'bx;
			`STAGE_EX:  TEST_LDS = 1'b1;
			`STAGE_MEM:
				// we need to set the start of the of the ram too
				if(bus_address == (64 | address[`TEST_INSTR_WIDTH-1:0]))
					TEST_LDS = 1'b1;
				else
					TEST_LDS = 1'bx;
			`STAGE_WB:
				if(writeback_value == value[`TEST_DATA_WIDTH-1:0]
				&& signals[`CONTROL_REG_RD_WRITE]
				&& rd_addr == register_rd)
					TEST_LDS = 1'b1;
				else
					TEST_LDS = 1'bx;
		endcase
	end
endfunction
