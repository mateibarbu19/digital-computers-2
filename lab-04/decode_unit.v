/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"
module decode_unit #(
		parameter  INSTR_WIDTH  = 16,   // instructions are 16 bits in width
		parameter  R_ADDR_WIDTH = 5

	)(
		input  wire  [INSTR_WIDTH-1:0]   instruction,
		output reg   [`OPCODE_COUNT-1:0] opcode_type,
		output wire  [`GROUP_COUNT-1:0]  opcode_group,
		output reg   [R_ADDR_WIDTH-1:0]  opcode_rd,
		output reg   [R_ADDR_WIDTH-1:0]  opcode_rr,
		output reg               [11:0]  opcode_imd,
		output reg                [2:0]  opcode_bit
	);

	/*Fiindca register file-ul procesorului nostru (ATtiny20)
	are doar 16 registre, putem ignora bitii Rr si Rd de pe pozitiile 9 si 8
	(Atmel garanteaza ca, din motive de compatibilitate, vor fi mereu setati
	pe 1, sau, echivalent, vor fi folosite numai registrele R16 ? R31).
	Deci opcode = 000111rdxxxxxxxx devifne 00011111xxxxxxxx. (Btw, that's ADD)
	*/

	always @* begin
		  casez (instruction)
			16'b0000_11??_????_????: begin
				opcode_type = `TYPE_ADD;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
			16'b0001_11??_????_????: begin
				opcode_type = `TYPE_ADC;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
			16'b0010_00??_????_????: begin
				opcode_type = `TYPE_AND;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
	
			16'b0010_01??_????_????: begin
				opcode_type = `TYPE_EOR;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
				16'b1000_000?_????_1000: begin
				opcode_type = `TYPE_LD_Y;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = 3'bx;
				opcode_imd  = 12'bx;
			end
			16'b1110_????_????_????: begin
				opcode_type = `TYPE_LDI;
				opcode_rd   = {1'b1, instruction[7:4]};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = 3'bx;
				opcode_imd  = {4'b0, instruction[11:8], instruction[3:0]};
			end
			16'b1010_0???_????_????: begin
				opcode_type = `TYPE_LDS;
				opcode_rd   = {1'b1, instruction[7:4]};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = 3'bx;
				// info extracted from the datasheet
				opcode_imd  = {4'd0, ~instruction[8], instruction[8],
							  instruction[10:9], instruction[3:0]};
			end
				16'b0010_11??_????_????: begin
				opcode_type = `TYPE_MOV;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
				opcode_bit  = 3'bx;
				opcode_imd  = 12'bx;
			end
				16'b1001_010?_????_0001: begin
				opcode_type = `TYPE_NEG;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
			end
			16'b0000_0000_0000_0000: begin
				opcode_type = `TYPE_NOP;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
			end
			
			16'b0010_10??_????_????: begin
				opcode_type = `TYPE_OR;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
			
			16'b0001_10??_????_????: begin
				opcode_type = `TYPE_SUB;
				opcode_rd   = instruction[8:4];
				opcode_rr   = {instruction[9], instruction[3:0]};
			end
			
			16'b1010_1???_????_????: begin
				opcode_type = `TYPE_STS;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {1'b1, instruction[7:4]};
				opcode_bit  = 3'bx;
				// info extracted from the datasheet
				opcode_imd  = {4'd0, ~instruction[8], instruction[8],
							  instruction[10:9], instruction[3:0]};
			end
			
		   /* DONE 1: Decode RJMP*/
			
			/* DONE 2: Decode BRBS*/
			
			/* DONE 3: Decode BRBC*/
			
			/* DONE 4: Decode PUSH si POP*/
			16'b1001_001?_????_1111: begin
				opcode_type = `TYPE_PUSH;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {instruction[8:4]};
				opcode_bit  = 3'bx;
				// info extracted from the datasheet
				opcode_imd  = {12'bx};
			end

			16'b1001_000?_????_1111: begin
				opcode_type = `TYPE_POP;
				opcode_rd   = {instruction[8:4]};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = 3'bx;
				// info extracted from the datasheet
				opcode_imd  = {12'bx};
			end

			16'b1100_????_????_????: begin
				opcode_type = `TYPE_RJMP;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = 3'bx;
				// info extracted from the datasheet
				opcode_imd  = instruction[11:0];
			end

			16'b1111_00??_????_????: begin
				opcode_type = `TYPE_BRBS;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = instruction[2:0];
				// info extracted from the datasheet
				opcode_imd  = {5'd0, instruction[9:3]};
			end
			
			16'b1111_01??_????_????: begin
				opcode_type = `TYPE_BRBC;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
				opcode_bit  = instruction[2:0];
				// info extracted from the datasheet
				opcode_imd  = {5'd0, instruction[9:3]};
			end

			default: begin
				opcode_type = `TYPE_UNKNOWN;
				opcode_rd   = {R_ADDR_WIDTH{1'bx}};
				opcode_rr   = {R_ADDR_WIDTH{1'bx}};
			end
		  endcase
	end
	
	/* -------------------------------------- */
	assign opcode_group[`GROUP_ALU_ONE_OP] =
		(opcode_type == `TYPE_NEG);
		
	assign opcode_group[`GROUP_ALU_TWO_OP] =
		(opcode_type == `TYPE_ADD) ||
		(opcode_type == `TYPE_ADC) ||
		(opcode_type == `TYPE_SUB) ||
		(opcode_type == `TYPE_AND) ||
		(opcode_type == `TYPE_EOR) ||
		(opcode_type == `TYPE_OR);
	
	assign opcode_group[`GROUP_ALU] =
		opcode_group[`GROUP_ALU_ONE_OP] ||
		opcode_group[`GROUP_ALU_TWO_OP];

	/* -------------------------------------- */
	assign opcode_group[`GROUP_LOAD_DIRECT] =
		(opcode_type == `TYPE_LDS);
	
	/* DONE 4: Add POP in the LOAD_INDIRECT group. Check defines.vh. */
	assign opcode_group[`GROUP_LOAD_INDIRECT] =
		(opcode_type == `TYPE_LD_Y) ||
		(opcode_type == `TYPE_POP);
	assign opcode_group[`GROUP_STORE_DIRECT] =
		(opcode_type == `TYPE_STS)
		;
		
	/* DONE 4: Add PUSH in the STORE_INDIRECT group. Check defines.vh. */
	assign opcode_group[`GROUP_STORE_INDIRECT] = 
		(opcode_type == `TYPE_PUSH); 

	/* -------------------------------------- */
	assign opcode_group[`GROUP_REGISTER] =
		(opcode_type == `TYPE_LDI) ||
		(opcode_type == `TYPE_MOV)
		;
  
    /* DONE 1,2,3: Add control instr. to the GROUP_CONTROL_FLOW group. */
    assign opcode_group[`GROUP_CONTROL_FLOW] = 
		(opcode_type == `TYPE_RJMP) ||
		(opcode_type == `TYPE_BRBS) ||
		(opcode_type == `TYPE_BRBC);
		

   /* -------------------------------------- */
	assign opcode_group[`GROUP_LOAD] =
		opcode_group[`GROUP_LOAD_DIRECT] ||
		opcode_group[`GROUP_LOAD_INDIRECT];
		
	assign opcode_group[`GROUP_STORE] =
		opcode_group[`GROUP_STORE_DIRECT] ||
		opcode_group[`GROUP_STORE_INDIRECT];
	
	/* DONE 4: Set the GROUP_STACK signal. Check defines.vh. */
	assign opcode_group[`GROUP_STACK]  = 
		(opcode_type == `TYPE_PUSH) ||
		(opcode_type == `TYPE_POP);

	assign opcode_group[`GROUP_MEMORY] =
		(opcode_group[`GROUP_LOAD] ||
		 opcode_group[`GROUP_STORE]);
endmodule
