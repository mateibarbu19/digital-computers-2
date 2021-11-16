`timescale 1ns / 1ps
`include "defines.vh"
module signal_generation_unit (
        input  wire [`STAGE_COUNT-1:0]  pipeline_stage,
        input  wire [`OPCODE_COUNT-1:0] opcode_type,
        input  wire [`GROUP_COUNT-1:0]  opcode_group,
        output wire [`SIGNAL_COUNT-1:0] signals
    );
    /* Control signals */

    /* Register interface logic
		TODO 4: STACK operations are INDIRECT but they don't read from registers.
		        This todo is already solved. Just understand how things work.
	 */
    assign signals[`CONTROL_REG_RR_READ] =
            (pipeline_stage == `STAGE_ID) &&
            (opcode_group[`GROUP_ALU_TWO_OP] || 
					(opcode_group[`GROUP_LOAD_INDIRECT] || !opcode_group[`GROUP_STACK]) ||
					opcode_group[`GROUP_REGISTER] ||
					opcode_group[`GROUP_STORE]);
    assign signals[`CONTROL_REG_RR_WRITE] = 0;
	 
    assign signals[`CONTROL_REG_RD_READ] =
            (pipeline_stage == `STAGE_ID) &&
            (opcode_group[`GROUP_ALU] ||
				(opcode_group[`GROUP_STORE_INDIRECT] || !opcode_group[`GROUP_STACK] ||  // X, Y sau Z
					opcode_group[`GROUP_LOAD_INDIRECT]));
    assign signals[`CONTROL_REG_RD_WRITE] =
            (pipeline_stage == `STAGE_WB) &&
            (opcode_group[`GROUP_ALU] ||
					opcode_group[`GROUP_REGISTER] ||
					opcode_group[`GROUP_LOAD]);

    /* Memory interface logic */
    assign signals[`CONTROL_MEM_READ] =
           (pipeline_stage == `STAGE_MEM) &&
           opcode_group[`GROUP_LOAD];
    assign signals[`CONTROL_MEM_WRITE] =
           (pipeline_stage == `STAGE_MEM) &&
           opcode_group[`GROUP_STORE];
			  
	 /* Stack interface logic. 
	    TODO 4: Compute signals for stack access. I which stage should each operation take place?
    */
	 assign signals[`CONTROL_STACK_POSTDEC] = 
				1'bx
            ;
    assign signals[`CONTROL_STACK_PREINC] = 
				1'bx
				; 		  
endmodule
