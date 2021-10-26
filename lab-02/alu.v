// Last modified: 21.10.2018 
// Author: dosarudaniel@gmail.com
`include "defines.vh"
module alu #(
        parameter DATA_WIDTH = 8
    )(
        input  wire [`OPSEL_COUNT-1:0] opsel,
        input  wire                    enable,
        input  wire   [DATA_WIDTH-1:0] rd,
        input  wire   [DATA_WIDTH-1:0] rr,
        output reg    [DATA_WIDTH-1:0] out,
        input  wire   [DATA_WIDTH-1:0] flags_in,
        output reg    [DATA_WIDTH-1:0] flags_out
    );

    /* flags_out a fost transformat in reg, pentru a putea
     * fi atribuit in interiorul unui bloc always, insa va fi
     * sintetizat tot combinational (UAL-ul nici macar nu are clk
     * drept input) */

    /* TODO: De codificat cateva operatii
     * in defines.vh si de implementat aici folosind acest instruction set manual:
	  * http://ww1.microchip.com/downloads/en/devicedoc/atmel-0856-avr-instruction-set-manual.pdf [1]
     */
    always @* begin
        case (opsel)
				// Example: Add with carry. See page 30 at [1].
            `OPSEL_ADC: begin
					 out = rd + rr + flags_in[`FLAGS_C];
					 
					 flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                flags_out[`FLAGS_H] = (rd[3] & rr[3]) | (rr[3] & ~out[3]) | (~out[3] & rd[3]);
					 flags_out[`FLAGS_V] = (rd[7] & rr[7] & ~out[7]) | (~rd[7] & ~rr[7] & out[7]);
                flags_out[`FLAGS_N] = out[7];
					 flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V]; 					// S = N ⊕ V
                flags_out[`FLAGS_Z] = (out == 0);
					 flags_out[`FLAGS_C] = (rd[7] & rr[7]) | (rr[7] & ~out[7]) | (~out[7] & rd[7]);
            end
				
            /* TODO: Adaugati implementarea operatiilor aici. */
				default: begin
                out = 8'bx;
                flags_out = flags_in;
            end
        endcase
    end
endmodule
