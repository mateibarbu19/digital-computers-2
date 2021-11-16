function TEST_PUSH;
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
	input [`TEST_D_ADDR_WIDTH-1:0] bus_address;
	input [`TEST_DATA_WIDTH-1:0] sp;
	input integer address;
	input integer register_rr;
	input integer register_rd;
	input integer value;
	input integer stack_pointer;
	begin
		case (pipeline_stage)
			`STAGE_IF:  TEST_PUSH = 1'b1;
			`STAGE_ID:
				if(opcode_group[`GROUP_STACK] &&
					opcode_type == `TYPE_PUSH &&
					rr_addr == register_rr)
					begin
						TEST_PUSH = 1'b1;
						$display("PUSH R%2d - ID: OK", register_rr);
					end
				else
					begin
						TEST_PUSH = 1'bx;
						$display("PUSH R%2d - ID: FAILED", register_rr);
					end
			`STAGE_EX:  TEST_PUSH = 1'b1;
			`STAGE_MEM:
				if (bus_address == address[7:0] - 8'h40)
					begin
						TEST_PUSH = 1'b1;
						$display("PUSH R%2d - MEM: OK (bus_address = %2H, signals[`CONTROL_STACK_POSTDEC] = 1)", register_rr, bus_address);
					end
				else begin
					TEST_PUSH = 1'bx;
					if (bus_address !== address[7:0] - 8'h40)
						begin
							$display("PUSH R%2d - MEM: FAILED => bus_address: (%2H) vs (%2H)", register_rr, address[7:0] - 8'h40, bus_address);
						end
					
				end
			`STAGE_WB:  begin
				TEST_PUSH = 1'b1;
				if( sp == stack_pointer[7:0] && signals[`CONTROL_STACK_POSTDEC] == 1) begin
					TEST_PUSH = 1'b1;
					$display("PUSH R%2d - MEM: OK (sp = %2H)",register_rr, stack_pointer);
				end
				else begin	
					TEST_PUSH = 1'bx;
					if(signals[`CONTROL_STACK_POSTDEC] !== 1)
						begin
							$display("PUSH R%2d - WB: FAILED => signals[`CONTROL_STACK_POSTDEC]: 1 vs 0", register_rr);		
						end
					if ( sp !== stack_pointer[7:0])
						begin
							$display("PUSH R%2d - WB: FAILED =>  sp: (%2H) vs (%2H)", register_rr, stack_pointer[7:0], sp);
						end
				end 
			end 
		endcase
	end
endfunction
