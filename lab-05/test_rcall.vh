/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
function TEST_RCALL;
	input integer value;
	input integer saved_pc;
	input integer next_pc;
	
	begin
		case (uut.pipeline_stage)
			`STAGE_IF: begin
				TEST_RCALL = 1'b1;
			end
			`STAGE_ID:
				if(!(uut.control.opcode_type == `TYPE_RCALL)) begin 
					$display("RCALL FUNCTION - ID: FAILED opcode_type -> %d vs %d", `TYPE_RCALL, uut.control.opcode_type);
					TEST_RCALL = 1'bx;
				end 
				else if(!uut.control.opcode_group[`GROUP_TWO_CYCLE_MEM]) begin 
					$display("RCALL FUNCTION - ID: FAILED RCALL should be in GROUP_TWO_CYCLE_MEM");
					TEST_RCALL = 1'bx;
				end 
				else if (!uut.control.opcode_group[`GROUP_STACK]) begin 
					$display("RCALL FUNCTION - ID: FAILED RCALL should be in GROUP_STACK");
					TEST_RCALL = 1'bx;
				end  
				else if (!uut.control.opcode_group[`GROUP_CONTROL_FLOW]) begin 
					$display("RCALL FUNCTION - ID: FAILED RCALL should be in GROUP_CONTROL_FLOW");
					TEST_RCALL = 1'bx;
				end  
				else if (!uut.control.opcode_group[`GROUP_STORE_INDIRECT]) begin 
					$display("RCALL FUNCTION - ID: FAILED RCALL should be in GROUP_STORE_INDIRECT");
					TEST_RCALL = 1'bx;
				end
				else begin
					// nu afisez ok pentru ca mai am o verificare pt ID in stagiul EX.
					TEST_RCALL = 1'b1;
				end
				
			`STAGE_EX:
				if (!(uut.control.saved_pc === saved_pc)) begin  // saved_pc is updated in ID using `<=`, it will be visible here in EX
					$display("RCALL FUNCTION - ID: FAILED saved_pc => %d vs %d", saved_pc, uut.control.saved_pc);
					TEST_RCALL = 1'bx;
				end
				else begin
					TEST_RCALL = 1'b1;
				end 
				
			`STAGE_MEM:
				if(!(uut.control.next_program_counter == next_pc)
					&& uut.control.cycle_count == 0) begin  // next_pc is updated in EX using `<=`, it will be visible here in MEM
					$display("RCALL FUNCTION - EX2: FAILED: next_program_counter => %d vs %d", next_pc, uut.control.next_program_counter);
					TEST_RCALL = 1'bx;
				end
				else if(!uut.control.signals[`CONTROL_STACK_POSTDEC]) begin 
					$display("RCALL FUNCTION - MEM: FAILED signal CONTROL_STACK_POSTDEC should be active");
					TEST_RCALL = 1'bx;
				end 
				// salvare program counter pe stiva (primul octet)
				else if (uut.control.cycle_count == 0 &&
							!(uut.control.data_to_store === 6)) begin // trebuie verificat ce se stocheaza a.k.a data_to_store
					$display("RCALL FUNCTION - MEM, cycle_count 0: FAILED 6 vs %d", uut.control.data_to_store);
					TEST_RCALL = 1'bx;
				end 
				// salvare program counter pe stiva (al doilea octet)
				else if ((uut.control.cycle_count == 1) &&
							!(uut.control.data_to_store === 0)) begin // trebuie verificat ce se stocheaza a.k.a data_to_store
					$display("RCALL FUNCTION - MEM, cycle_count 1: FAILED 0 vs %d", uut.control.data_to_store);
					TEST_RCALL = 1'bx;
				end 
				else begin
					$display("RCALL LABEL - MEM: OK");
					TEST_RCALL = 1'b1;
				end
			`STAGE_WB: begin
				TEST_RCALL = 1'b1;
			 end
		endcase
	end 
endfunction
