/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
function TEST_RJMP;
	input integer relative_jump_address;
	begin
		case (uut.pipeline_stage)
			`STAGE_IF:  TEST_RJMP = 1'b1;
			`STAGE_ID:
				if(uut.control.opcode_group[`GROUP_CONTROL_FLOW]
					&& uut.control.opcode_type == `TYPE_RJMP
					&& uut.control.opcode_imd == relative_jump_address)
					begin
						TEST_RJMP = 1'b1;
						$display("RJMP LABEL - ID: OK");
					end
				else
					begin
						TEST_RJMP = 1'bx;
						$display("RJMP LABEL - ID: FAILED => OPCODE_TYPE: ( %d ) vs ( %d ). Check defines.vh.",
									`TYPE_RJMP, uut.control.opcode_type);
					end
			`STAGE_EX:  TEST_RJMP = 1'b1;
			`STAGE_MEM: TEST_RJMP = 1'b1;
			`STAGE_WB:  TEST_RJMP = 1'b1;
		endcase
	end
endfunction