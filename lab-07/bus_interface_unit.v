`include "defines.vh"
module bus_interface_unit #(
    parameter MEM_START_ADDR = 8'h40,
    parameter MEM_STOP_ADDR  = 8'hBF,
    parameter IO_START_ADDR  = 8'h00,
    parameter IO_STOP_ADDR   = 8'h3F,
    parameter DATA_WIDTH     = 8    , // registers are 8 bits in width
    parameter ADDR_WIDTH     = 16     // 64KB address space
) (
    input  wire [ `GROUP_COUNT-1:0] opcode_group ,
    input  wire [             11:0] opcode_imd   ,
    input  wire [`SIGNAL_COUNT-1:0] signals      ,
    input  wire                     cycle_count  ,
    input  wire [   DATA_WIDTH-1:0] data_to_store,
    input  wire [   ADDR_WIDTH-1:0] indirect_addr,
    output wire [   ADDR_WIDTH-1:0] bus_addr     ,
    inout  wire [   DATA_WIDTH-1:0] bus_data     ,
    output wire                     mem_cs       ,
    output wire                     mem_we       ,
    output wire                     mem_oe       ,
    output wire                     io_cs        ,
    output wire                     io_we        ,
    output wire                     io_oe
);

    wire [ADDR_WIDTH-1:0] internal_mem_addr ;
    wire [ADDR_WIDTH-1:0] internal_io_addr  ;
    wire                  mem_access, io_access;
    wire                  mem_addr_is_in_mem;
    wire                  mem_addr_is_in_io ;
    wire                  uses_indirect     ;
    wire                  should_store      ;
    wire                  should_load       ;

    assign should_load =
        signals[`CONTROL_MEM_READ] || signals[`CONTROL_IO_READ];
    assign should_store =
        signals[`CONTROL_MEM_WRITE] || signals[`CONTROL_IO_WRITE];
    assign uses_indirect =
        (opcode_group[`GROUP_LOAD_INDIRECT] ||
            opcode_group[`GROUP_STORE_INDIRECT]);
    assign mem_access = signals[`CONTROL_MEM_READ] ||
        signals[`CONTROL_MEM_WRITE];
    assign io_access = signals[`CONTROL_IO_READ] ||
        signals[`CONTROL_IO_WRITE];
    assign mem_addr_is_in_mem = mem_access &&
        (internal_mem_addr >= MEM_START_ADDR &&
            internal_mem_addr <= MEM_STOP_ADDR);
    assign mem_addr_is_in_io = mem_access &&
        (internal_mem_addr >= IO_START_ADDR &&
            internal_mem_addr <= IO_STOP_ADDR);

    assign internal_io_addr =
        io_access ?
        opcode_group[`GROUP_STACK] ? `SPL :
        opcode_group[`GROUP_ALU] ? `SREG :
        {4'b0, opcode_imd} :
        mem_addr_is_in_io ?
        internal_mem_addr :
        {ADDR_WIDTH{1'bx}};
    assign internal_mem_addr =
        uses_indirect ?
        indirect_addr :
        {4'b0, opcode_imd};

    assign mem_cs = mem_addr_is_in_mem;
    assign mem_we = (mem_cs && signals[`CONTROL_MEM_WRITE]) ? 1'b1 :
        (mem_cs && signals[`CONTROL_MEM_READ]) ? 1'b0 : 1'bx;
    assign mem_oe = (mem_cs && signals[`CONTROL_MEM_READ]) ? 1'b1 : 1'bx;

    /* logic for generating io_cs, io_we and io_oe.
    * Hint: check defines.vh */
    assign io_cs = io_access || mem_addr_is_in_io;
    assign io_we = (io_cs && should_store) ? 1'b1 :
        (io_cs && should_load) ? 1'b0 : 1'bx;
    assign io_oe = (io_cs && should_load) ? 1'b1 : 1'bx;

    /* logic for io operations.
    * Hint: check defines.vh */
    assign bus_addr = mem_cs ? internal_mem_addr - MEM_START_ADDR:
        io_cs ? internal_io_addr - IO_START_ADDR :
        {ADDR_WIDTH{1'bx}};
    assign bus_data = should_store ? data_to_store : {DATA_WIDTH{1'bz}};

endmodule
