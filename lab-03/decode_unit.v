`timescale 1ns / 1ps
`include "defines.vh"
module decode_unit #(
        parameter  INSTR_WIDTH  = 16,   // instructions are 16 bits in width
        parameter  R_ADDR_WIDTH = 5

    )(
        input  wire  [INSTR_WIDTH-1:0]   instruction,
        output reg   [`OPCODE_COUNT-1:0] opcode_type,
        /* verilator lint_off UNOPTFLAT */
        output wire  [`GROUP_COUNT-1:0]  opcode_group,
        /* verilator lint_on UNOPTFLAT */
        output reg   [R_ADDR_WIDTH-1:0]  opcode_rd,
        output reg   [R_ADDR_WIDTH-1:0]  opcode_rr,
        output reg               [11:0]  opcode_imd,
        output reg                [2:0]  opcode_bit
    );

/*
Fiindca register file-ul procesorului nostru (ATtiny20)
are doar 16 registre, putem ignora bitii Rr si Rd de pe pozitiile 9 si 8
(Atmel garanteaza ca, din motive de compatibilitate, vor fi mereu setati
pe 1, sau, echivalent, vor fi folosite numai registrele R16 ? R31).
Deci opcode = 000111rdxxxxxxxx devifne 00011111xxxxxxxx. (Btw, that's ADD)
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

              /* TODO 5: LD_Y (i) */

            /* TODO 7: MOV */

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

              /* TODO 4: STS */

            /* TODO 6: LDS */

            /* TODO 3: LDI */
            
            default: begin
                opcode_type = `TYPE_UNKNOWN;
                opcode_rd   = {R_ADDR_WIDTH{1'bx}};
                opcode_rr   = {R_ADDR_WIDTH{1'bx}};
            end
        /*TODO : completati cu opcodes ale voastre.
          Where can I find such opcodes? Make them up or read the lab and see
          they're at http://www.atmel.com/images/Atmel-0856-AVR-Instruction-Set-Manual.pdf  */
          /* Cand gasiti o instructiune de UAL, setati opcode_type la valoarea corecta */
          /*  instruction seamana cu un ADD? -> opcode_type = `TYPE_ADD; */
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
        0;
    assign opcode_group[`GROUP_LOAD_INDIRECT] =
        0;

    assign opcode_group[`GROUP_STORE_DIRECT] =
        0;
    assign opcode_group[`GROUP_STORE_INDIRECT] =
        0;

    assign opcode_group[`GROUP_REGISTER] =
        /* TODO 3: LDI */
        (opcode_type == `TYPE_MOV);

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
