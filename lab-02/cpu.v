`include "defines.vh"
module cpu #(
        parameter      INSTR_WIDTH  = 16,   // instructions are 16 bits in width
        parameter       DATA_WIDTH  = 8,    // registers are 8 bits in width
        parameter     I_ADDR_WIDTH  = 10,   // 2 * 1024 bytes of flash (or ROM in our case)
        parameter     R_ADDR_WIDTH  = 5    // 32 registers
    )(
        input wire clk,
        input wire reset
`ifdef DEBUG
            ,
            output wire [`STAGE_COUNT-1:0]  debug_pipeline_stage,
            output wire [DATA_WIDTH-1:0] debug_alu_rr,
            output wire [DATA_WIDTH-1:0] debug_alu_rd,
            output wire [DATA_WIDTH-1:0] debug_alu_out,
            output wire [I_ADDR_WIDTH-1:0] debug_program_counter,
            output wire [`FLAG_COUNT-1:0] debug_flags_out
`endif
    );
`ifdef DEBUG
    assign debug_pipeline_stage   = pipeline_stage;
    assign debug_alu_rr  = alu_rr;
    assign debug_alu_rd  = alu_rd;
    assign debug_alu_out = alu_out;
     assign debug_program_counter = program_counter;
     assign debug_flags_out = alu_flags_out;
`endif

    wire [`STAGE_COUNT-1:0] pipeline_stage;
    wire [I_ADDR_WIDTH-1:0]  program_counter;
    wire [INSTR_WIDTH-1:0] instruction;
    wire [R_ADDR_WIDTH-1:0]    rr_addr;
    wire [R_ADDR_WIDTH-1:0]    rd_addr;
    wire [DATA_WIDTH-1:0]  rr_data;
    wire [DATA_WIDTH-1:0]  rd_data;
    wire                   rr_cs;
    wire                   rd_cs;
    wire                   rr_we;
    wire                   rd_we;
    wire                   rr_oe;
    wire                   rd_oe;
    wire                   alu_enable;
    wire [`OPSEL_COUNT-1:0]  alu_opsel;
    wire [DATA_WIDTH-1:0]  alu_rr;
    wire [DATA_WIDTH-1:0]  alu_rd;
    wire [DATA_WIDTH-1:0]  alu_out;
    wire [`FLAG_COUNT-1:0]   alu_flags_in;
    wire [`FLAG_COUNT-1:0]   alu_flags_out;

    control_unit #(
        .I_ADDR_WIDTH(I_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .R_ADDR_WIDTH(R_ADDR_WIDTH),
        .INSTR_WIDTH (INSTR_WIDTH)
    ) control (
        .program_counter(program_counter),
        .instruction(instruction),
        .pipeline_stage(pipeline_stage),
        .clk(clk),
        .reset(reset),
        .rr_addr(rr_addr),
        .rd_addr(rd_addr),
        .rr_data(rr_data),
        .rd_data(rd_data),
        .rr_cs(rr_cs),
        .rd_cs(rd_cs),
        .rr_we(rr_we),
        .rd_we(rd_we),
        .rr_oe(rr_oe),
        .rd_oe(rd_oe),
        .alu_enable(alu_enable),
        .alu_opsel(alu_opsel),
        .alu_flags_in(alu_flags_in),
        .alu_flags_out(alu_flags_out),
        .alu_rr(alu_rr),
        .alu_rd(alu_rd),
        .alu_out(alu_out)
    );

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) ual (
        .opsel(alu_opsel),
        .enable(alu_enable),
        .rd(alu_rd),
        .rr(alu_rr),
        .out(alu_out),
        .flags_in(alu_flags_in),
        .flags_out(alu_flags_out)
    );

    // Rom implementeaza un rom generic
    // noi vrem sa folosim Rom-ul asta ca sursa de instructiuni, 
    // deci de aia avem DATA_WIDTH instantiat cu INSTR_WIDTH
    // si ADDR_WIDTH instantiat cu I_ADDR_WIDTH
    rom #(
        .DATA_WIDTH(INSTR_WIDTH),
        .ADDR_WIDTH(I_ADDR_WIDTH)
    ) instruction_mem (
        .clk (clk),
        .addr(program_counter),
        .data(instruction)
    );
    dual_port_sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(R_ADDR_WIDTH)
    ) reg_file (
        .clk (clk),
        .rr_addr(rr_addr),
        .rd_addr(rd_addr),
        .rr_data(rr_data),
        .rd_data(rd_data),
        .rr_cs  (rr_cs),
        .rd_cs  (rd_cs),
        .rr_we  (rr_we),
        .rd_we  (rd_we),
        .rr_oe  (rr_oe),
        .rd_oe  (rd_oe)
     );

endmodule
