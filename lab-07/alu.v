/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module alu #(parameter DATA_WIDTH = 8) (
    input  wire     [`OPSEL_COUNT-1:0] opsel    ,
    input  wire                        enable   ,
    input  wire     [  DATA_WIDTH-1:0] rd       ,
    input  wire     [  DATA_WIDTH-1:0] rr       ,
    output      reg [  DATA_WIDTH-1:0] out      ,
    input  wire     [  DATA_WIDTH-1:0] flags_in ,
    output      reg [  DATA_WIDTH-1:0] flags_out,
    input  wire                        cin_en   , // carry_in_enable
    input  wire                        cout_en    // carry_out_enable
);

    /* flags_out was transformed to reg, so it could be attributed inside
     * always block, though it will be synthesized using combinational logic,
     * because UAL has no input clk
     */
    always @* begin
        if (enable)
            case (opsel)

                `OPSEL_ADD :
                begin
                    if (cout_en) begin
                        {flags_out[`FLAGS_C], out} = rd + rr + {8'd0, cin_en & flags_in[`FLAGS_C]};
                    end else begin
                        out                 = rd + rr + {7'd0, cin_en & flags_in[`FLAGS_C]};
                        flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    end
                    flags_out[`FLAGS_V] = (rd[7] == 1 && rr[7] == 1 && out[7] == 0) ||
                        (rd[7] == 0 && rr[7] == 0 && out[7] == 1);
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = (rd[3] == 1 && rr[3] == 1 && out[3] == 0) ||
                        (rd[3] == 0 && rr[3] == 0 && out[3] == 1);
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_SUB :
                begin
                    if (cout_en) begin
                        {flags_out[`FLAGS_C], out} = rd - rr - {8'd0, cin_en & flags_in[`FLAGS_C]};
                    end else begin
                        out                 = rd - rr - {7'd0, cin_en & flags_in[`FLAGS_C]};
                        flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    end
                    flags_out[`FLAGS_V] = (rd[7] == 1 && rr[7] == 1 && out[7] == 0) ||
                        (rd[7] == 0 && rr[7] == 0 && out[7] == 1);
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = (rd[3] == 1 && rr[3] == 1 && out[3] == 0) ||
                        (rd[3] == 0 && rr[3] == 0 && out[3] == 1);
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_AND :
                begin
                    out                 = rd & rr;
                    flags_out[`FLAGS_V] = 0;
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                    flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_XOR :
                begin
                    out                 = rd ^ rr;
                    flags_out[`FLAGS_V] = 0;
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                    flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_OR :
                begin
                    out                 = rd | rr;
                    flags_out[`FLAGS_V] = 0;
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                    flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_NEG :
                begin
                    out                 = ~rd;
                    flags_out[`FLAGS_V] = 0;
                    flags_out[`FLAGS_Z] = (out == 0);
                    flags_out[`FLAGS_N] = out[7];
                    flags_out[`FLAGS_S] = flags_out[`FLAGS_N] ^ flags_out[`FLAGS_V];
                    flags_out[`FLAGS_H] = flags_in[`FLAGS_H];
                    flags_out[`FLAGS_C] = flags_in[`FLAGS_C];
                    flags_out[`FLAGS_T] = flags_in[`FLAGS_T];
                    flags_out[`FLAGS_I] = flags_in[`FLAGS_I];
                end

                `OPSEL_NONE : begin
                    out       = rr;
                    flags_out = flags_in;
                end

                /* To avoid a latch synthesis, flags_out must be assigned here
                * also. It is our duty to not store this value in control_unit.
                */
                default :
                    begin
                        out       = {DATA_WIDTH{1'bx}};
                        flags_out = flags_in;
                    end
            endcase
        else /* if alu_enable == false */ begin
            out       = {DATA_WIDTH{1'bx}};
            flags_out = flags_in;
        end
    end

endmodule
