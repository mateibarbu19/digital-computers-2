/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module bus_interface_unit #(
    parameter IO_START_ADDR  = 16'h00,
    parameter IO_STOP_ADDR   = 16'h3F,
    parameter MEM_START_ADDR = 16'h40,
    parameter MEM_STOP_ADDR  = 16'hBF,
    parameter DATA_WIDTH     = 8    , // registers are 8 bits in width
    parameter ADDR_WIDTH     = 16     // 64KB address space
) (
    input  wire     [ `GROUP_COUNT-1:0] opcode_group ,
    input  wire     [             11:0] opcode_imd   ,
    input  wire     [`SIGNAL_COUNT-1:0] signals      ,
    input  wire     [   DATA_WIDTH-1:0] data_to_store,
    input  wire     [   ADDR_WIDTH-1:0] indirect_addr,
    output      reg [   ADDR_WIDTH-1:0] bus_addr     ,
    inout  wire     [   DATA_WIDTH-1:0] bus_data     ,
    output wire                         mem_cs       ,
    output wire                         mem_we       ,
    output wire                         mem_oe       ,
    output wire                         io_cs        ,
    output wire                         io_we        ,
    output wire                         io_oe
);

    wire [ADDR_WIDTH-1:0] internal_mem_addr;
    wire                  mem_access, io_access;
    wire                  uses_indirect    ;
    wire                  should_store     ;
    wire                  should_load      ;

    // DONE 1: update should_* to include the IO operations.
    assign should_load = signals[`CONTROL_MEM_READ]
        || signals[`CONTROL_IO_READ];
    assign should_store = signals[`CONTROL_MEM_WRITE]
        || signals[`CONTROL_IO_WRITE];

    assign uses_indirect =
        (opcode_group[`GROUP_LOAD_INDIRECT] ||
            opcode_group[`GROUP_STORE_INDIRECT]);
    assign mem_access = signals[`CONTROL_MEM_READ] ||
        signals[`CONTROL_MEM_WRITE];

    /* DONE 1: activate io_access for the instructions who have the right and
     * want to access the I/O address space
     */
    assign io_access = signals[`CONTROL_IO_READ] &&
        signals[`CONTROL_IO_WRITE];
    assign internal_mem_addr =
        uses_indirect ?
        indirect_addr :
        {4'b0, opcode_imd};

    assign mem_cs = (internal_mem_addr >= MEM_START_ADDR &&
        internal_mem_addr <= MEM_STOP_ADDR);
    assign mem_we = (mem_cs && should_store) ? 1'b1 :
        (mem_cs && should_load) ? 1'b0 : 1'bx;
    assign mem_oe = (mem_cs && should_load) ? 1'b1 : 1'bx;

    /* logic for generating io_cs, io_we and io_oe.*/
    assign io_cs = internal_mem_addr <= IO_STOP_ADDR; // redundant internal_mem_addr >= IO_START_ADDR
    assign io_we = (io_cs && should_store) ? 1'b1 :
        (io_cs && should_load) ? 1'b0 : 1'bx;
    assign io_oe = (io_cs && should_load) ? 1'b1 : 1'bx;

    /* logic for bus operations.
    * DONE 1: Add a case in which to put the IO memory address on the bus.atunci
    * Use the memory case as an example. From where do the IN and OUT instr. get
    * their address? Look at these modules ports. What information do we have in
    * hand?
    */
    always @(*) begin
        if(mem_cs) begin
            bus_addr = internal_mem_addr - MEM_START_ADDR;
        end else if (io_cs) begin
            bus_addr = internal_mem_addr - IO_START_ADDR;
        end
    end
    assign bus_data = should_store ? data_to_store : {DATA_WIDTH{1'bz}};

endmodule
