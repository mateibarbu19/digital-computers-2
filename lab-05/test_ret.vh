/* verilator lint_off WIDTH */
/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
function TEST_RET;
	input integer value;
	input integer saved_pc;
	input integer expected_pc;
	begin
		
		case (uut.pipeline_stage)
			`STAGE_IF: begin
				TEST_RET = 1'b1;
			end
			`STAGE_ID:
				// because of how the STS address is defined, we need
				if(!uut.control.opcode_type == `TYPE_RET) begin 
					$display("RET - ID: FAILED %d vs %d", `TYPE_RET, uut.control.opcode_type);
					TEST_RET = 1'bx;
				end 
				else if(!uut.control.opcode_group[`GROUP_TWO_CYCLE_MEM]) begin 
					$display("RET - ID: FAILED. RET instruction should be in GROUP_TWO_CYCLE_MEM");
					TEST_RET = 1'bx;
				end 
				else if (!uut.control.opcode_group[`GROUP_STACK]) begin 
					$display("RET - ID: FAILED. RET instruction should be in GROUP_STACK");
					TEST_RET = 1'bx;
				end
				else if (!uut.control.opcode_group[`GROUP_CONTROL_FLOW]) begin 
					$display("RET - ID: FAILED. RET instruction should be in GROUP_CONTROL_FLOW");
					TEST_RET = 1'bx;
				end  
				else if (!uut.control.opcode_group[`GROUP_LOAD_INDIRECT]) begin 
					$display("RET - ID: FAILED. RET instruction should be in GROUP_LOAD_INDIRECT");
					TEST_RET = 1'bx;
				end
				else begin 
					$display("RET - ID: OK");
					TEST_RET = 1'b1;
				end
				
				
			`STAGE_EX:
				if(!uut.control.signals[`CONTROL_STACK_PREINC]) begin 
					$display("RET - EX: FAILED. signal CONTROL_STACK_PREINC should be active");
					TEST_RET = 1'bx;
				end 
				else begin 
					$display("RET - EX: OK");
					TEST_RET = 1'b1;
				end
				
			`STAGE_MEM:
				if(!uut.control.signals[`CONTROL_STACK_PREINC] 
				&& (uut.control.cycle_count == 0)) begin 
					$display("RET - MEM: cycle_count 0, FAILED. signal CONTROL_STACK_PREINC should be active");
					TEST_RET = 1'bx;
				end 
				else begin 
					TEST_RET = 1'b1;
				end
			`STAGE_WB: begin // program_counter-ul trebuie verificat manual pt RET
				if (!(uut.control.saved_pc === saved_pc)) begin 
					$display("RET - MEM: FAILED: saved_pc => %d vs %d", saved_pc, uut.control.saved_pc);
					TEST_RET = 1'bx;
				end  
				else begin
					TEST_RET = 1'b1;
				end
			end
				
		endcase
	end
endfunction
