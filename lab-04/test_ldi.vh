/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"

function TEST_LDI;
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
			`STAGE_IF:  TEST_LDI = 1'b1;
			`STAGE_ID:
				if(opcode_group[`GROUP_REGISTER]
				&& opcode_type == `TYPE_LDI
				&& opcode_imd == value[11:0])
					begin
						TEST_LDI = 1'b1;
						$display("LDI R%2d, %3d - ID: OK", register_rd, value);
					end
				else
					begin
						TEST_LDI = 1'bx;
						$display("LDI R%2d, %3d - ID: FAILED", register_rd, value);
					end
			`STAGE_EX:  TEST_LDI = 1'b1;
			`STAGE_MEM: TEST_LDI = 1'b1;
			`STAGE_WB:
				if(writeback_value == value[`TEST_DATA_WIDTH-1:0]
				&& signals[`CONTROL_REG_RD_WRITE]
				&& rd_addr == register_rd)
					begin
							TEST_LDI = 1'b1;
							$display("LDI R%2d, %3d - WB: OK (R%2d = %3d)", rd_addr, value, rd_addr, value);
					end
				else
					begin
						TEST_LDI = 1'bx;
						$display("LDI R%2d, %3d - WB: FAILED => (%3d) vs (%3d)", rd_addr, value, writeback_value, value);
					end
		endcase
	end
endfunction
