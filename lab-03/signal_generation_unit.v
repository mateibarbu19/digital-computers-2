/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"
module signal_generation_unit (
          input  wire [`STAGE_COUNT-1:0]  pipeline_stage,
          input  wire [`OPCODE_COUNT-1:0] opcode_type,
          /* verilator lint_off UNUSED */
          input  wire [`GROUP_COUNT-1:0]  opcode_group,
          /* verilator lint_on UNUSED */
          output wire [`SIGNAL_COUNT-1:0] signals
     );

     /* Control signals */

     /* Register interface logic */
     /* DONE 4: STS */
     /* DONE 7: register reads */
     assign signals[`CONTROL_REG_RR_READ] = 
          (pipeline_stage == `STAGE_ID) &&
          (opcode_group[`GROUP_ALU_TWO_OP]    ||
           opcode_group[`GROUP_STORE]         ||
           opcode_group[`GROUP_LOAD_INDIRECT] ||
           opcode_type == `TYPE_MOV);
     assign signals[`CONTROL_REG_RR_WRITE] = 0;
     assign signals[`CONTROL_REG_RD_READ] =
          (pipeline_stage == `STAGE_ID) &&
          (opcode_group[`GROUP_ALU]           || 
           opcode_group[`GROUP_STORE]         ||
           opcode_group[`GROUP_LOAD_INDIRECT] ||
           opcode_type == `TYPE_MOV);
     assign signals[`CONTROL_REG_RD_WRITE] = 
          /* DONE 5,6,7: register writes */
          (pipeline_stage == `STAGE_WB) &&
          (opcode_group[`GROUP_ALU]      ||
           opcode_group[`GROUP_REGISTER] ||
           opcode_group[`GROUP_LOAD]);
        
     /* Memory interface logic */
     /* DONE 5,6: LOADs */
     assign signals[`CONTROL_MEM_READ] =
          (pipeline_stage == `STAGE_MEM) &&
          (opcode_group[`GROUP_LOAD]);
     /* DONE 4: STS 
         inspectati bus_interface_unit.v */
     assign signals[`CONTROL_MEM_WRITE] =
          (pipeline_stage == `STAGE_MEM) &&
          (opcode_group[`GROUP_STORE]);
endmodule