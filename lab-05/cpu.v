/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module cpu #(
    parameter INSTR_WIDTH      = 16, // instructions are 16 bits in width
    parameter DATA_WIDTH       = 8 , // registers are 8 bits in width
    parameter I_ADDR_WIDTH     = 10, // 2 * 1024 bytes of flash (or ROM in our case)
    parameter ADDR_WIDTH       = 16, // 64KB address space
    parameter D_ADDR_WIDTH     = 7 , // 128 bytes of SRAM
    parameter R_ADDR_WIDTH     = 5 , // 32 registers
    parameter RST_ACTIVE_LEVEL = 1   // level on which reset is active
) (
    input wire clk  ,
    input wire reset
);

    wire [`STAGE_COUNT-1:0] pipeline_stage ;
    wire [I_ADDR_WIDTH-1:0] program_counter;
    wire [ INSTR_WIDTH-1:0] instruction    ;
    wire [R_ADDR_WIDTH-1:0] rr_addr        ;
    wire [R_ADDR_WIDTH-1:0] rd_addr        ;
    wire [  DATA_WIDTH-1:0] rr_data        ;
    wire [  DATA_WIDTH-1:0] rd_data        ;
    wire                    rr_cs          ;
    wire                    rd_cs          ;
    wire                    rr_we          ;
    wire                    rd_we          ;
    wire                    rr_oe          ;
    wire                    rd_oe          ;
    wire                    alu_enable     ;
    wire [`OPSEL_COUNT-1:0] alu_opsel      ;
    wire [  DATA_WIDTH-1:0] alu_rr         ;
    wire [  DATA_WIDTH-1:0] alu_rd         ;
    wire [  DATA_WIDTH-1:0] alu_out        ;
    wire [   `FLAG_COUNT:0] alu_flags_in   ;
    wire [   `FLAG_COUNT:0] alu_flags_out  ;
    wire [ INSTR_WIDTH-1:0] bus_addr       ;
    wire [  DATA_WIDTH-1:0] bus_data       ;
    wire                    mem_cs         ;
    wire                    mem_we         ;
    wire                    mem_oe         ;

    initial
        begin
            $display("Start cpu ...");
            $display("Legend:");
            $display("OPERATION OP1, OP2 - STAGE: OK <=> PASS");
            $display("OPERATION OP1, OP2 - STAGE: FAILED => EXPECTED_VALUE VS COMPUED_VALUE <=> FAIL");
        end

    control_unit #(
        .I_ADDR_WIDTH(I_ADDR_WIDTH),
        .R_ADDR_WIDTH(R_ADDR_WIDTH),
        .INSTR_WIDTH (INSTR_WIDTH )
    ) control (
        .program_counter(program_counter),
        .instruction    (instruction    ),
        .pipeline_stage (pipeline_stage ),
        .clk            (clk            ),
        .reset          (reset          ),
        .rr_addr        (rr_addr        ),
        .rd_addr        (rd_addr        ),
        .rr_data        (rr_data        ),
        .rd_data        (rd_data        ),
        .rr_cs          (rr_cs          ),
        .rd_cs          (rd_cs          ),
        .rr_we          (rr_we          ),
        .rd_we          (rd_we          ),
        .rr_oe          (rr_oe          ),
        .rd_oe          (rd_oe          ),
        .alu_enable     (alu_enable     ),
        .alu_opsel      (alu_opsel      ),
        .alu_flags_in   (alu_flags_in   ),
        .alu_flags_out  (alu_flags_out  ),
        .alu_rr         (alu_rr         ),
        .alu_rd         (alu_rd         ),
        .alu_out        (alu_out        ),
        .bus_addr       (bus_addr       ),
        .bus_data       (bus_data       ),
        .mem_cs         (mem_cs         ),
        .mem_we         (mem_we         ),
        .mem_oe         (mem_oe         )
    );

    alu #(.DATA_WIDTH(DATA_WIDTH)) ual (
        .opsel    (alu_opsel    ),
        .enable   (alu_enable   ),
        .rd       (alu_rd       ),
        .rr       (alu_rr       ),
        .out      (alu_out      ),
        .flags_in (alu_flags_in ),
        .flags_out(alu_flags_out)
    );

    // Rom implements a generic read-only-memory.
    // It is used to store the instructions, that's why we instantiate DATA_WIDTH
    // with INSTR_WIDTH and ADDR_WIDTH with I_ADDR_WIDTH
    // It responds on negedge clk
    rom #(
        .DATA_WIDTH(INSTR_WIDTH ),
        .ADDR_WIDTH(I_ADDR_WIDTH)
    ) instruction_mem (
        .clk (clk            ),
        .addr(program_counter),
        .data(instruction    )
    );
    dual_port_sram #(
        .DATA_WIDTH(DATA_WIDTH  ),
        .ADDR_WIDTH(R_ADDR_WIDTH)
    ) reg_file (
        .clk    (clk    ),
        .rr_addr(rr_addr),
        .rd_addr(rd_addr),
        .rr_data(rr_data),
        .rd_data(rd_data),
        .rr_cs  (rr_cs  ),
        .rd_cs  (rd_cs  ),
        .rr_we  (rr_we  ),
        .rd_we  (rd_we  ),
        .rr_oe  (rr_oe  ),
        .rd_oe  (rd_oe  )
    );

    sram #(
        .ADDR_WIDTH(D_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH  )
    ) data_mem (
        .clk    (clk                       ),
        .oe     (mem_oe                    ),
        .cs     (mem_cs                    ),
        .we     (mem_we                    ),
        .address(bus_addr[D_ADDR_WIDTH-1:0]),
        .data   (bus_data                  )
    );

endmodule
