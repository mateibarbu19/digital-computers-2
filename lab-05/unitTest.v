/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module unitTest (
    input  wire                              clk                  ,
    input  wire                              reset                ,
    output      reg                          result               ,
    output wire     [`TEST_I_ADDR_WIDTH-1:0] debug_program_counter,
    output wire     [      `STAGE_COUNT-1:0] debug_pipeline_stage
);


    // Instantiate the Unit Under Test (UUT) - cpu
    cpu #(
        .INSTR_WIDTH     (`TEST_INSTR_WIDTH ),
        .DATA_WIDTH      (`TEST_DATA_WIDTH  ),
        .I_ADDR_WIDTH    (`TEST_I_ADDR_WIDTH),
        .RST_ACTIVE_LEVEL(1                 )
    ) uut (
        .clk  (clk  ),
        .reset(reset)
    );


    assign debug_program_counter = uut.program_counter;
    assign debug_pipeline_stage  = uut.pipeline_stage;

    wire [`TEST_DATA_WIDTH-1:0] debug_alu_rr  = uut.alu_rr ;
    wire [`TEST_DATA_WIDTH-1:0] debug_alu_rd  = uut.alu_rd ;
    wire [`TEST_DATA_WIDTH-1:0] debug_alu_out = uut.alu_out;

    wire [`TEST_R_ADDR_WIDTH-1:0] debug_rr_addr     = uut.rr_addr      ;
    wire [`TEST_R_ADDR_WIDTH-1:0] debug_rd_addr     = uut.rd_addr      ;
    wire [       `FLAG_COUNT-1:0] debug_flags_out   = uut.alu_flags_out;
    wire [`TEST_D_ADDR_WIDTH-1:0] debug_bus_address = uut.bus_addr     ;
    wire [  `TEST_DATA_WIDTH-1:0] debug_bus_data    = uut.bus_data     ;

    wire [`TEST_D_ADDR_WIDTH-1:0] debug_register_Y = {uut.reg_file.memory[29], uut.reg_file.memory[28]};

    wire [                11:0] debug_opcode_imd      = uut.control.opcode_imd     ;
    wire [   `OPCODE_COUNT-1:0] debug_opcode_type     = uut.control.opcode_type    ;
    wire [    `GROUP_COUNT-1:0] debug_opcode_group    = uut.control.opcode_group   ;
    wire [                 2:0] debug_opcode_bit      = uut.control.opcode_bit     ;
    wire [`TEST_DATA_WIDTH-1:0] debug_writeback_value = uut.control.writeback_value;
    wire [   `SIGNAL_COUNT-1:0] debug_signals         = uut.control.signals        ;

    reg [`TEST_I_ADDR_WIDTH-1:0] last_pc;

    integer reg_16, reg_17, reg_18, reg_22, reg_21, reg_20, reg_30;
    integer stack [`STACK_START:0];
    integer sp                    ;

`include "unit_tests.vh"// include test function in unitTest scope

    integer address ;
    integer rr_addr ;
    integer rd_addr ;
    integer value   ;
    integer next_pc ;
    integer saved_pc;

    initial begin
        $display("Init regs..");
        reg_16 = 32'dX;
        reg_17 = 32'dX;
        reg_18 = 32'dX;
        reg_22 = 32'dX;

        sp = `STACK_START;

        address = 32'dX;
        rr_addr = 32'dX;
        rd_addr = 32'dX;
        value   = 32'dX;
        result  = 0;
    end


    always @(posedge clk) begin
        case(debug_program_counter)
            0 : /* ldi r16, 5 */
                begin
                    // cod executat de procesor
                    rd_addr = 32'd16;
                    value   = 5;
                    result  = TEST_LDI(rd_addr, value);
                    // cod pentru debug
                    if (debug_pipeline_stage == `STAGE_WB) begin
                        reg_16 = value;
                    end
                end

            1 : /* rjmp main_function */
                begin
                    // cod executat de procesor
                    address = 2;
                    result  = TEST_RJMP(address);

                end

            2 : /* ldi r17, 15 */
                begin
                    // cod executat de procesor
                    rd_addr = 17;
                    value   = 15;
                    result  = TEST_LDI(rd_addr, value);

                    // cod pentru debug
                    if (debug_pipeline_stage == `STAGE_WB) begin
                        reg_17 = value;
                    end
                end

            3 : /* ret */
                begin
                    // cod executat de procesor
                    next_pc  = 6;
                    saved_pc = 6;
                    result   = TEST_RET(value, saved_pc, next_pc);

                end

            4 : /* ldi R17,10 */
                begin
                    // cod executat de procesor
                    rd_addr = 17;
                    value   = 10;
                    result  = TEST_LDI(rd_addr, value);

                    // cod pentru debug
                    if (debug_pipeline_stage == `STAGE_WB) begin
                        reg_17 = value;
                    end
                end

            5 : /* rcall first_function */
                begin
                    // cod executat de procesor
                    next_pc  = 2;
                    saved_pc = 6;
                    result   = TEST_RCALL(value, saved_pc, next_pc);

                end

            6 : /* ldi R18,20 */
                begin
                    rd_addr = 18;
                    value   = 20;
                    result  = TEST_LDI(rd_addr, value);
                    // cod pentru debug
                    if (debug_pipeline_stage == `STAGE_WB) begin
                        reg_18 = value;
                    end
                end

            default :
                result = 1'bz;
        endcase
        last_pc = debug_program_counter;
    end

endmodule
