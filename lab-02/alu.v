// Last modified: 21.10.2018 
// Author: dosarudaniel@gmail.com
`timescale 1ns / 1ps
`include "defines.vh"

module alu #(
        parameter DATA_WIDTH = 8
    )(
        input  wire [`OPSEL_COUNT-1:0] opsel,
        /* verilator lint_off UNUSED */
        input  wire                    enable,
        /* verilator lint_on UNUSED */
        input  wire   [DATA_WIDTH-1:0] rd,
        input  wire   [DATA_WIDTH-1:0] rr,
        output reg    [DATA_WIDTH-1:0] out,
        input  wire   [DATA_WIDTH-1:0] flags_in,
        output reg    [DATA_WIDTH-1:0] flags_out
    );

    /* flags_out is of type reg, so it could be attributed inside an always
     * block, but it will be synthesized using combinational logic (because
     * the ALU doesn't even have a clk input)
     */

    /* Decode some operations from defines.vh and implement them here
     * using this instruction set manual:
     * http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf [1]
     */
    always @* begin
        case (opsel)
            // Example: Add with carry. See page 30 at [1].
            `OPSEL_ADC: begin
                out = rd + rr + {7'd0, flags_in[`FLAGS_C]};
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = (rd[3] & rr[3]) | (rr[3] & ~out[3]) | (~out[3] & rd[3]);
                flags_out[`FLAGS_V] = (rd[7] & rr[7] & ~out[7]) | (~rd[7] & ~rr[7] & out[7]);
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = (rd[7] & rr[7]) | (rr[7] & ~out[7]) | (~out[7] & rd[7]);
            end

            `OPSEL_NOP: begin
                out = 8'bx;
                flags_out = flags_in;
            end

            `OPSEL_NEG: begin
                out = ~rd + 1; // 0 - rd
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = out[3] | ~rd[3];
                flags_out[`FLAGS_V] = out[7] == 1'b1 && out[6:0] == 7'd0;
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = |out;
            end

            `OPSEL_ADD: begin
                out = rd + rr;
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = (rd[3] & rr[3]) | (rr[3] & ~out[3]) | (~out[3] & rd[3]);
                flags_out[`FLAGS_V] = (rd[7] & rr[7] & ~out[7]) | (~rd[7] & ~rr[7] & out[7]);
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = (rd[7] & rr[7]) | (rr[7] & ~out[7]) | (~out[7] & rd[7]);
            end

            `OPSEL_SUB: begin
                out = rd - rr;
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = (~rd[3] & rr[3]) | (rr[3] & out[3]) | (out[3] & ~rd[3]);
                flags_out[`FLAGS_V] = (rd[7] & ~rr[7] & ~out[7]) | (~rd[7] & rr[7] & out[7]);
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = (~rd[7] & rr[7]) | (rr[7] & out[7]) | (out[7] & ~rd[7]);
            end

            `OPSEL_AND: begin
                out = rd & rr;
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                flags_out[`FLAGS_V] = 1'b0;
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
            end

            `OPSEL_OR: begin
                out = rd | rr;
                
                flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                flags_out[`FLAGS_V] = 1'b0;
                flags_out[`FLAGS_N] = out[7];
                flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; // S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
                flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
            end

            default: begin
                out = 8'bx;
                flags_out = flags_in;
            end
        endcase
    end
endmodule
