/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module control_unit #(
    parameter INSTR_WIDTH  = 16,
    parameter DATA_WIDTH   = 8 ,
    parameter I_ADDR_WIDTH = 10,
    parameter ADDR_WIDTH   = 16,
    parameter R_ADDR_WIDTH = 5
) (
    input  wire                        clk            ,
    input  wire                        reset          ,
    // To/from instruction memory
    output      reg [I_ADDR_WIDTH-1:0] program_counter,
    input  wire     [ INSTR_WIDTH-1:0] instruction    ,
    // From FSM
    output wire     [`STAGE_COUNT-1:0] pipeline_stage ,
    // To/from register file
    output wire     [R_ADDR_WIDTH-1:0] rr_addr        ,
    output wire     [R_ADDR_WIDTH-1:0] rd_addr        ,
    inout  wire     [  DATA_WIDTH-1:0] rr_data        ,
    inout  wire     [  DATA_WIDTH-1:0] rd_data        ,
    output wire                        rr_cs          ,
    output wire                        rd_cs          ,
    output wire                        rr_we          ,
    output wire                        rd_we          ,
    output wire                        rr_oe          ,
    output wire                        rd_oe          ,
    // To/from ALU
    output wire                        alu_enable     ,
    output      reg [`OPSEL_COUNT-1:0] alu_opsel      ,
    output wire     [  DATA_WIDTH-1:0] alu_flags_in   ,
    input  wire     [  DATA_WIDTH-1:0] alu_flags_out  ,
    output      reg [  DATA_WIDTH-1:0] alu_rr         ,
    output      reg [  DATA_WIDTH-1:0] alu_rd         ,
    input  wire     [  DATA_WIDTH-1:0] alu_out        ,
    // To/from bus interface unit
    output wire     [  ADDR_WIDTH-1:0] bus_addr       ,
    inout  wire     [  DATA_WIDTH-1:0] bus_data       ,
    output wire                        mem_cs         ,
    output wire                        mem_we         ,
    output wire                        mem_oe
);

    // From decode unit
    wire [`SIGNAL_COUNT-1:0] signals     ;
    wire [`OPCODE_COUNT-1:0] opcode_type ;
    wire [ `GROUP_COUNT-1:0] opcode_group;
    wire [ R_ADDR_WIDTH-1:0] opcode_rd   ;
    wire [ R_ADDR_WIDTH-1:0] opcode_rr   ;
    wire [             11:0] opcode_imd  ;
    wire [              2:0] opcode_bit  ;
    wire                     cycle_count ;
    // Buffers for various stuff
    reg  [INSTR_WIDTH-1:0] instr_buffer   ;
    reg  [ DATA_WIDTH-1:0] alu_out_buffer ;
    reg  [ DATA_WIDTH-1:0] writeback_value;
    wire [ ADDR_WIDTH-1:0] indirect_addr  ;
    wire [ DATA_WIDTH-1:0] data_to_store  ;
    reg  [ DATA_WIDTH-1:0] sreg           ;
    reg  [ DATA_WIDTH-1:0] sp             ;

    /*
    DONE 1, 2: Hint: saved_pc is a ADDR_WIDTH-bit buffer that helps with pushing
    or poping the PC to/from the stack.
    Do not change anything here.
    */
    reg [  ADDR_WIDTH-1:0] saved_pc            ;
    reg [I_ADDR_WIDTH-1:0] next_program_counter;

    /* Transitions between processor stages */
    state_machine fsm (
        .pipeline_stage(pipeline_stage),
        .clk           (clk           ),
        .reset         (reset         ),
        .cycle_count   (cycle_count   ),
        .opcode_group  (opcode_group  )
    );
    /* ID: instruction decode */
    decode_unit #(.INSTR_WIDTH(INSTR_WIDTH)) decode (
        .instruction (instr_buffer),
        .opcode_type (opcode_type ),
        .opcode_group(opcode_group),
        .opcode_imd  (opcode_imd  ),
        .opcode_rd   (opcode_rd   ),
        .opcode_rr   (opcode_rr   ),
        .opcode_bit  (opcode_bit  )
    );
    /* Signal activation for each stage */
    signal_generation_unit sig (
        .pipeline_stage(pipeline_stage),
        .cycle_count   (cycle_count   ),
        .signals       (signals       ),
        .opcode_type   (opcode_type   ),
        .opcode_group  (opcode_group  )
    );

    /* Registor control interface */
    reg_file_interface_unit #(
        .DATA_WIDTH  (DATA_WIDTH  ),
        .INSTR_WIDTH (INSTR_WIDTH ),
        .R_ADDR_WIDTH(R_ADDR_WIDTH)
    ) rf_int (
        .opcode_type    (opcode_type    ),
        .writeback_value(writeback_value),
        .signals        (signals        ),
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
        .opcode_rd      (opcode_rd      ),
        .opcode_rr      (opcode_rr      )
    );

    /* Memory control interface */
    bus_interface_unit #(
        .MEM_START_ADDR(16'h40    ),
        .MEM_STOP_ADDR (16'hBF    ),
        .DATA_WIDTH    (DATA_WIDTH),
        .ADDR_WIDTH    (ADDR_WIDTH)
    ) bus_int (
        .opcode_group (opcode_group ),
        .opcode_imd   (opcode_imd   ),
        .signals      (signals      ),
        .bus_addr     (bus_addr     ),
        .bus_data     (bus_data     ),
        .mem_cs       (mem_cs       ),
        .mem_we       (mem_we       ),
        .mem_oe       (mem_oe       ),
        .indirect_addr(indirect_addr),
        .data_to_store(data_to_store)
    );


    /* IF: Buffering of the instruction fetched from rom */
    always @(posedge clk, posedge reset)
        if (reset)
            instr_buffer <= 0;
        else if (pipeline_stage == `STAGE_IF) begin
            instr_buffer <= instruction;
            if (program_counter < 7) begin
                $display("\nPC => %d", program_counter);
            end
        end

    /* ID : The type of operation executed by the ALU */
    always @* begin
        if (alu_enable == 0)
            alu_opsel = `OPSEL_COUNT'bx;
        else begin
            case (opcode_type)
                `TYPE_ADD :
                alu_opsel = `OPSEL_ADD;
                `TYPE_ADC :
                alu_opsel = `OPSEL_ADC;
                `TYPE_SUB :
                alu_opsel = `OPSEL_SUB;
                `TYPE_AND :
                alu_opsel = `OPSEL_AND;
                `TYPE_EOR :
                alu_opsel = `OPSEL_EOR;
                `TYPE_OR  :
                alu_opsel = `OPSEL_OR;
                `TYPE_NEG :
                alu_opsel = `OPSEL_NEG;
                default   :
                    alu_opsel = `OPSEL_NONE;
            endcase
        end
    end

    /* ID: Buffering of rd_data and rr_data */
    always @(posedge clk, posedge reset)
        if (reset) begin
            alu_rd <= 0;
            alu_rr <= 0;
        end else if (pipeline_stage == `STAGE_ID) begin
            alu_rd <= rd_data;
            alu_rr <= rr_data;
        end


    /* sreg attribution block */
    assign alu_flags_in = sreg;
    always @(posedge clk, posedge reset)
        if (reset)
            sreg <= 0;
        else
            sreg <= alu_flags_out;

    /* EX: buffering of the ALU output */
    always @(posedge clk, posedge reset)
        if (reset)
            alu_out_buffer <= 0;
        else if (pipeline_stage == `STAGE_EX)
            alu_out_buffer <= alu_out;

    assign alu_enable = (pipeline_stage == `STAGE_EX);

    /* MEM:
    Indirect memory addressing, that could be, for now, done by these instr.:
    - in opcode_group[`GROUP_LOAD_INDIRECT] or opcode_group[`GROUP_STORE_INDIRECT]
    - which use the stack pointer (sp)
    */
    assign indirect_addr =
        // if indirect access
        (opcode_group[`GROUP_LOAD_INDIRECT] || opcode_group[`GROUP_STORE_INDIRECT]) ?
        // if indirect to stack
        opcode_group[`GROUP_STACK] ?
        {8'b0, sp} :
        // else, indirect to memory => X or Y or Z
        {alu_rr, alu_rd} :
        // else, not indirect
        {ADDR_WIDTH{1'bx}};

    /*
    What data goes to the memory.

    DONE 1: Hint: RCALL will push PC on the stack during two clock cycles in the
    memory stage.
    */
    assign data_to_store =
        signals[`CONTROL_MEM_WRITE] ?
        (opcode_type == `TYPE_RCALL) ?
        (cycle_count == 0) ?
        /* DONE 1: Store the first part of the return address. */
        saved_pc[DATA_WIDTH-1:0] :
        /* DONE 1: Store the rest of the return address. */
        saved_pc[ADDR_WIDTH-1:DATA_WIDTH] :
        alu_rr:
        {DATA_WIDTH{1'bx}};

    /* WB: The value to be stored in RD. */
    always @(posedge clk, posedge reset) begin
        if (reset)
            writeback_value <= {DATA_WIDTH{1'b0}};
        else if (opcode_group[`GROUP_ALU])
            writeback_value <= alu_out_buffer;
        else if (signals[`CONTROL_MEM_READ])
            writeback_value <= bus_data;
        else if (opcode_type == `TYPE_LDI)
            writeback_value <= opcode_imd[DATA_WIDTH-1:0];
        else if (opcode_type == `TYPE_MOV)
            writeback_value <= alu_rr;
    end

    /* ID + MEM: Program counter buffer control for RCALL and RET. */
    always @(posedge clk, posedge reset) begin
        if (reset)
            saved_pc <= 0;
        else
            if (pipeline_stage == `STAGE_ID) begin
                if (opcode_type == `TYPE_RCALL) begin
                    /*
                    DONE 1: Save in the register the return address for the
                    function call. Pay attention, for it is not the program
                    counter!
                    */
                    saved_pc[I_ADDR_WIDTH-1:0] <= program_counter + 1;
                end
            end
        else if (pipeline_stage == `STAGE_MEM && opcode_type == `TYPE_RET)
            begin
                if (cycle_count == 0) begin
                    /*
                    DONE 2: Restore the second part of the return address. This
                    value was previously saved on the stack. On which bus does
                    the memory read data arrive?
                    */
                    saved_pc <= {bus_data, 8'd0};
                end else begin
                    /* DONE 2: Restore the rest of the return address. */
                    saved_pc[DATA_WIDTH-1:0] <= bus_data;
                end
            end
    end

    /* Program counter attribution and computation block */
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            program_counter <= 0;
        end else if (pipeline_stage == `STAGE_EX) begin
            case (opcode_type)
                `TYPE_BRBS : begin
                    if (sreg[opcode_bit] == 1)
                        next_program_counter <= program_counter + opcode_imd[9:0] + 1;
                    else
                        next_program_counter <= program_counter + 1;
                end
                `TYPE_BRBC : begin
                    if (sreg[opcode_bit] == 0)
                        next_program_counter <= program_counter + opcode_imd[9:0] + 1;
                    else
                        next_program_counter <= program_counter + 1;
                end
                `TYPE_RJMP : begin
                    next_program_counter <= program_counter + opcode_imd[9:0] + 1;
                end
                `TYPE_RCALL : begin
                    /* DONE 1: Implement the jump to the address of the
                    function. Hint: it'a relative jump. PC <= PC + k + 1. */

                    next_program_counter <= program_counter + opcode_imd[I_ADDR_WIDTH-1:0] + 1;
                end
                default : begin
                    next_program_counter <= program_counter + 1;
                end
            endcase
        end else if (pipeline_stage == `STAGE_WB) begin
            if (opcode_type == `TYPE_RET) begin
                /* DONE 2: Implement the return from the function call.
                PC <= return address (from the stack) */
                program_counter <= saved_pc[I_ADDR_WIDTH-1:0];
            end else begin
                program_counter <= next_program_counter;
            end
        end
    end


    /* EX + MEM: SP attribution block */
    always @(posedge clk, posedge reset) begin
        if (reset)
            sp <= `STACK_START;
        else if (signals[`CONTROL_STACK_POSTDEC])
            sp <= sp - 8'b1;
        else if (signals[`CONTROL_STACK_PREINC])
            sp <= sp + 8'b1;
    end

endmodule
