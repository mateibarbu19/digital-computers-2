/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"
module decode_unit #(
        parameter  INSTR_WIDTH  = 16,   // instructions are 16 bits in width
        parameter  R_ADDR_WIDTH = 5

    )(
        input  wire [INSTR_WIDTH-1:0]   instruction,
        output reg  [`OPCODE_COUNT-1:0] opcode_type,
        /* verilator lint_off UNOPTFLAT */
        /* verilator lint_off UNDRIVEN */
        output wire [`GROUP_COUNT-1:0]  opcode_group,
        /* verilator lint_on UNDRIVEN */
        /* verilator lint_on UNOPTFLAT */
        output reg  [R_ADDR_WIDTH-1:0]  opcode_rd,
        output reg  [R_ADDR_WIDTH-1:0]  opcode_rr,
        output reg  [11:0]              opcode_imd,
        /* verilator lint_off UNDRIVEN */
        output reg  [2:0]               opcode_bit
        /* verilator lint_on UNDRIVEN */
    );

    /*
    Because the register file of our ATtiny20 implementation has only 16
    registers, we can ignore the Rr and Rd bits at positions 9 and 8.
    (Atmel guarantees for compatibility reasons that they will always be 1, or
    equivalently ont the R16-R31 registers will be used.
    So opcode = 000111rdxxxxxxxx becomes 00011111xxxxxxxx. (Btw, that's ADD.)
    */

    always @* begin
        casez (instruction)
            16'b0000_0000_0000_0000: begin
                opcode_type = `TYPE_NOP;
                opcode_rd   = {R_ADDR_WIDTH{1'bx}};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
            end
            16'b0001_10??_????_????: begin
                opcode_type = `TYPE_SUB;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end
            16'b0010_10??_????_????: begin
                opcode_type = `TYPE_OR;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end
            16'b1001_010?_????_0001: begin
                opcode_type = `TYPE_NEG;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
            end

            16'b0010_01??_????_????: begin
                opcode_type = `TYPE_EOR;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end
            16'b0010_00??_????_????: begin
                opcode_type = `TYPE_AND;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end
            16'b0001_11??_????_????: begin
                opcode_type = `TYPE_ADC;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end
            16'b0000_11??_????_????: begin
                opcode_type = `TYPE_ADD;
                opcode_rd   = instruction[8:4];
                opcode_rr   = {instruction[9], instruction[3:0]};
            end

            16'b1110_????_????_????: begin
                opcode_type = `TYPE_LDI;
                opcode_rd   = {1'b1, instruction[7:4]};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
                opcode_imd  = {4'd0, instruction[11:8], instruction[3:0]};
            end

            16'b1010_1???_????_????: begin
                opcode_type = `TYPE_STS;
                opcode_rd   = {R_ADDR_WIDTH{1'bx}};
                opcode_rr   = {1'b1, instruction[7:4]};
                opcode_imd  = {4'd0, ~instruction[8], instruction[8], 
                               instruction[10], instruction[9],
                               instruction[3:0]};
            end

            16'b1000_000?_????_1000: begin
                opcode_type = `TYPE_LD_Y;
                opcode_rd   = {1'b1, instruction[7:4]};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
            end

            16'b1010_0???_????_????: begin
                opcode_type = `TYPE_LDS;
                opcode_rd   = {1'b1, instruction[7:4]};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
                opcode_imd  = {4'd0, ~instruction[8], instruction[8], 
                               instruction[10], instruction[9],
                               instruction[3:0]};
            end

            16'b0010_11??_????_????: begin
                opcode_type = `TYPE_MOV;
                opcode_rd   = {1'b1, instruction[7:4]};
                opcode_rr   = {1'b1, instruction[3:0]};
            end

            default: begin
                opcode_type = `TYPE_UNKNOWN;
                opcode_rd   = {R_ADDR_WIDTH{1'bx}};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
            end
          endcase
    end

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

    assign opcode_group[`GROUP_LOAD_DIRECT] =
        (opcode_type == `TYPE_LDS);
    assign opcode_group[`GROUP_LOAD_INDIRECT] =
        (opcode_type == `TYPE_LD_Y);

    assign opcode_group[`GROUP_STORE_DIRECT] =
        (opcode_type == `TYPE_STS);
    assign opcode_group[`GROUP_STORE_INDIRECT] =
        0;

    assign opcode_group[`GROUP_REGISTER] =
        (opcode_type == `TYPE_MOV) ||
        (opcode_type == `TYPE_LDI);

    assign opcode_group[`GROUP_LOAD] =
        opcode_group[`GROUP_LOAD_DIRECT] ||
        opcode_group[`GROUP_LOAD_INDIRECT];
    assign opcode_group[`GROUP_STORE] =
        opcode_group[`GROUP_STORE_DIRECT] ||
        opcode_group[`GROUP_STORE_INDIRECT];
    assign opcode_group[`GROUP_MEMORY] =
        (opcode_group[`GROUP_LOAD] ||
         opcode_group[`GROUP_STORE]);
endmodule
