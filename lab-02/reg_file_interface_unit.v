/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module reg_file_interface_unit #(
        /* verilator lint_off UNUSED */
        parameter INSTR_WIDTH  = 16,   // instructions are 16 bits in width
        /* verilator lint_on UNUSED */
        parameter DATA_WIDTH   = 8,    // registers are 8 bits in width
        parameter R_ADDR_WIDTH = 5     // 32 registers
    )(
        /* verilator lint_off UNUSED */
        input  wire [`OPCODE_COUNT-1:0] opcode_type,
        /* verilator lint_on UNUSED */
        input  wire    [DATA_WIDTH-1:0] writeback_value,
        /* verilator lint_off UNDRIVEN */
        /* verilator lint_off UNUSED */
        input  wire [`SIGNAL_COUNT-1:0] signals,
        /* verilator lint_on UNUSED */
        output wire  [R_ADDR_WIDTH-1:0] rr_addr,
        output wire  [R_ADDR_WIDTH-1:0] rd_addr,
        /* verilator lint_on UNDRIVEN */
        inout  wire    [DATA_WIDTH-1:0] rr_data,
        inout  wire    [DATA_WIDTH-1:0] rd_data,
        output wire                     rr_cs,
        output wire                     rd_cs,
        output wire                     rr_we,
        output wire                     rd_we,
        output wire                     rr_oe,
        output wire                     rd_oe
    );
    /* All the assignments below suppose that the current instruction has the
     * following format: [opcode] Rd Rr. In this case the register file will be
     * accessed twice: once during the instruction decode/register fetch state,
     * in order to read both register values, and the second time during the
     * write-back stage, to store the result (alu_out) in the Rd register.
     * Obviously, not all instructions have the same format. This will be
     * modified in the next laboratories.
     */

    assign rd_data = signals[`CONTROL_REG_RD_WRITE] ? writeback_value :
                     {DATA_WIDTH{1'bz}};
    assign rr_data = {DATA_WIDTH{1'bz}};
    assign rd_we   = signals[`CONTROL_REG_RD_READ]  ? 1'b0 :
                     signals[`CONTROL_REG_RD_WRITE] ? 1'b1 : 1'bx;
    assign rr_we   = signals[`CONTROL_REG_RR_READ]  ? 1'b0 : 1'bx;
    assign rd_oe   = signals[`CONTROL_REG_RD_READ]  ? 1'b1 : 1'bx;
    assign rr_oe   = signals[`CONTROL_REG_RR_READ]  ? 1'b1 : 1'bx;
    assign rd_cs   = signals[`CONTROL_REG_RD_READ] ||
                     signals[`CONTROL_REG_RD_WRITE];
    assign rr_cs   = signals[`CONTROL_REG_RR_READ];

endmodule
