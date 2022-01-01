/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module cpu #(
    parameter INSTR_WIDTH      = 16, // instructions are 16 bits in width
    parameter DATA_WIDTH       = 8 , // registers are 8 bits in width
    parameter I_ADDR_WIDTH     = 10, // 2 * 1024 bytes of flash (or ROM in our case)
    parameter ADDR_WIDTH       = 16, // 64KB address space
    parameter D_ADDR_WIDTH     = 7 , // 128 bytes of SRAM
    parameter IO_ADDR_WIDTH    = 6 , // 64 I/O registers
    parameter R_ADDR_WIDTH     = 5 , // 32 registers
    parameter RST_ACTIVE_LEVEL = 1   // level on which reset is active
) (
    input  wire                    osc_clk    ,
    input  wire                    trace_clk  ,
    input  wire                    trace_mode ,
    input  wire [             4:0] prescaler  , // HOW_TO_USE_PRESCALER
    input  wire                    reset      ,
    inout  wire [  DATA_WIDTH-1:0] pa         ,
    inout  wire [  DATA_WIDTH-1:0] pb         ,
    output wire                    oc0a       ,
    output wire                    oc0b
);

    wire [`STATE_COUNT-1:0] state          ;
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
    wire                    alu_cin_en     ;
    wire                    alu_cout_en    ;
    wire                    alu_enable     ;
    wire [`OPSEL_COUNT-1:0] alu_opsel      ;
    wire [  DATA_WIDTH-1:0] alu_rr         ;
    wire [  DATA_WIDTH-1:0] alu_rd         ;
    wire [  DATA_WIDTH-1:0] alu_out        ;
    wire [  DATA_WIDTH-1:0] alu_flags_in   ;
    wire [  DATA_WIDTH-1:0] alu_flags_out  ;
    wire [  ADDR_WIDTH-1:0] bus_addr       ;
    wire [  DATA_WIDTH-1:0] bus_data       ;
    wire                    mem_cs         ;
    wire                    mem_we         ;
    wire                    mem_oe         ;
    wire                    io_cs          ;
    wire                    io_we          ;
    wire                    io_oe          ;
    reg  [            31:0] clk_counter    ;
    wire                    clk_ps         ;
    wire                    clk            ;
    wire                    corrected_reset;


    always @(posedge osc_clk, posedge corrected_reset)
        if (corrected_reset)
            clk_counter <= 0;
        else
            clk_counter <= clk_counter + 1;

    assign corrected_reset = (reset == RST_ACTIVE_LEVEL);

    assign clk_ps = (prescaler == 0) ? osc_clk : clk_counter[prescaler - 1]; // HOW_TO_USE_PRESCALER
    assign clk    = (trace_mode == 0) ? clk_ps : trace_clk;


    control_unit #(
        .DATA_WIDTH  (DATA_WIDTH  ),
        .ADDR_WIDTH  (ADDR_WIDTH  ),
        .D_ADDR_WIDTH(D_ADDR_WIDTH),
        .I_ADDR_WIDTH(I_ADDR_WIDTH),
        .R_ADDR_WIDTH(R_ADDR_WIDTH),
        .INSTR_WIDTH (INSTR_WIDTH )
    ) control (
        .program_counter(program_counter),
        .instruction    (instruction    ),
        .state          (state          ),
        .clk            (clk            ),
        .reset          (corrected_reset),
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
        .alu_cin_en     (alu_cin_en     ),
        .alu_cout_en    (alu_cout_en    ),
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
        .mem_oe         (mem_oe         ),
        .io_cs          (io_cs          ),
        .io_we          (io_we          ),
        .io_oe          (io_oe          )
    );

    alu #(.DATA_WIDTH(DATA_WIDTH)) ual (
        .opsel    (alu_opsel    ),
        .enable   (alu_enable   ),
        .rd       (alu_rd       ),
        .rr       (alu_rr       ),
        .out      (alu_out      ),
        .flags_in (alu_flags_in ),
        .flags_out(alu_flags_out),
        .cin_en   (alu_cin_en   ),
        .cout_en  (alu_cout_en  )
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

    rom #(
        .DATA_WIDTH(INSTR_WIDTH ),
        .ADDR_WIDTH(I_ADDR_WIDTH)
    ) instruction_mem (
        .clk (clk            ),
        .addr(program_counter),
        .data(instruction    )
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

    gpio_sram #(
        .ADDR_WIDTH(IO_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH   )
    ) io (
        .clk    (clk                        ),
        .reset  (reset                      ),
        .oe     (io_oe                      ),
        .cs     (io_cs                      ),
        .we     (io_we                      ),
        .address(bus_addr[IO_ADDR_WIDTH-1:0]),
        .data   (bus_data                   ),
        .pa     (pa                         ),
        .pb     (pb                         ),
        .oc0a   (oc0a                       ),
        .oc0b   (oc0b                       )
    );

endmodule
