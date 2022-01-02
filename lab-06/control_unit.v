/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`include "defines.vh"
module control_unit #(
    parameter INSTR_WIDTH  = 16, // instructions are 16 bits in width
    parameter DATA_WIDTH   = 8 , // registers are 8 bits in width
    parameter I_ADDR_WIDTH = 10, // 2*1024 bytes of flash (or ROM in our case)
    parameter ADDR_WIDTH   = 16, // 64KB address space
    parameter R_ADDR_WIDTH = 5   // 32 registers
) (
    input  wire                         clk                  ,
    input  wire                         reset                ,
    // To/from instruction memory
    output      reg [ I_ADDR_WIDTH-1:0] program_counter      ,
    input  wire     [  INSTR_WIDTH-1:0] instruction          ,
    // From FSM
    output wire     [ `STAGE_COUNT-1:0] pipeline_stage       ,
    // To/from register file
    output wire     [ R_ADDR_WIDTH-1:0] rr_addr              ,
    output wire     [ R_ADDR_WIDTH-1:0] rd_addr              ,
    inout  wire     [   DATA_WIDTH-1:0] rr_data              ,
    inout  wire     [   DATA_WIDTH-1:0] rd_data              ,
    output wire                         rr_cs                ,
    output wire                         rd_cs                ,
    output wire                         rr_we                ,
    output wire                         rd_we                ,
    output wire                         rr_oe                ,
    output wire                         rd_oe                ,
    // To/from ALU
    output wire                         alu_enable           ,
    output      reg [ `OPSEL_COUNT-1:0] alu_opsel            ,
    output wire     [   DATA_WIDTH-1:0] alu_flags_in         ,
    input  wire     [   DATA_WIDTH-1:0] alu_flags_out        ,
    output      reg [   DATA_WIDTH-1:0] alu_rr               ,
    output      reg [   DATA_WIDTH-1:0] alu_rd               ,
    input  wire     [   DATA_WIDTH-1:0] alu_out              ,
    // To/from bus interface unit
    output wire     [   ADDR_WIDTH-1:0] bus_addr             ,
    inout  wire     [   DATA_WIDTH-1:0] bus_data             ,
    output wire                         mem_cs               ,
    output wire                         mem_we               ,
    output wire                         mem_oe               ,
    output wire                         io_cs                ,
    output wire                         io_we                ,
    output wire                         io_oe
    `ifdef DEBUG
    ,
    output wire     [             11:0] debug_opcode_imd     ,
    output wire     [   DATA_WIDTH-1:0] debug_writeback_value,
    output wire     [`SIGNAL_COUNT-1:0] debug_signals
    `endif
);
    // From decode unit
    wire [`SIGNAL_COUNT-1:0] signals     ;
    wire [`OPCODE_COUNT-1:0] opcode_type ;
    wire [ `GROUP_COUNT-1:0] opcode_group;
    wire [ R_ADDR_WIDTH-1:0] opcode_rd   ;
    wire [ R_ADDR_WIDTH-1:0] opcode_rr   ;
    wire [             11:0] opcode_imd  ;
    wire [              2:0] opcode_bit  ;
    // Buffers for various stuff
    reg  [INSTR_WIDTH-1:0] instr_buffer   ;
    reg  [ DATA_WIDTH-1:0] alu_out_buffer ;
    reg  [ DATA_WIDTH-1:0] writeback_value;
    wire [ ADDR_WIDTH-1:0] indirect_addr  ;
    wire [ DATA_WIDTH-1:0] data_to_store  ;
    reg  [ DATA_WIDTH-1:0] sreg           ;
    wire                   cycle_count    ;
    reg  [ DATA_WIDTH-1:0] sp             ;
    reg  [ ADDR_WIDTH-1:0] saved_pc       ;

    `ifdef DEBUG
        assign debug_opcode_imd      = opcode_imd;
        assign debug_writeback_value = writeback_value;
        assign debug_signals         = signals;
    `endif

    state_machine fsm (
        .pipeline_stage (pipeline_stage),
        .clk (clk),
        .reset (reset)
    );

    decode_unit #(.INSTR_WIDTH(INSTR_WIDTH)) decode (
        .instruction (instr_buffer),
        .opcode_type (opcode_type ),
        .opcode_group(opcode_group),
        .opcode_imd  (opcode_imd  ),
        .opcode_rd   (opcode_rd   ),
        .opcode_rr   (opcode_rr   ),
        .opcode_bit  (opcode_bit  )
    );

    signal_generation_unit sig (
        .pipeline_stage(pipeline_stage),
        .cycle_count   (cycle_count   ),
        .signals       (signals       ),
        .opcode_type   (opcode_type   ),
        .opcode_group  (opcode_group  )
    );

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
        .io_cs        (io_cs        ),
        .io_we        (io_we        ),
        .io_oe        (io_oe        ),
        .indirect_addr(indirect_addr),
        .data_to_store(data_to_store)
    );

    assign indirect_addr =
        (opcode_group[`GROUP_LOAD_INDIRECT] ||
            opcode_group[`GROUP_STORE_INDIRECT]) ?
        // else, indirect to memory => X or Y or Z
        {alu_rr, alu_rd} :
        // else, not indirect
        {ADDR_WIDTH{1'bx}};


    /* DONE 3 & 4: Store the value needed by the SBI & CBI & OUT instr.
    * What module returns that value? How to the instr. work?
    */
    assign data_to_store =
        signals[`CONTROL_MEM_WRITE] ?
            (opcode_type == `TYPE_RCALL ?
                (cycle_count ? saved_pc[7:0] : saved_pc[15:8]) : alu_rr) :
            signals[`CONTROL_IO_WRITE] ?
                opcode_group[`GROUP_STACK] ?
                    sp :
                    opcode_group[`GROUP_ALU] ?
                        sreg : 
                        opcode_type == `TYPE_OUT ?
                            alu_rr :
                            opcode_group[`GROUP_ALU_AUX] ?
                                alu_out :
                                {DATA_WIDTH{1'bx}} :
                {DATA_WIDTH{1'bx}};

    /* Program counter attribution and computation block */
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            program_counter <= 0;
        end else if (pipeline_stage == `STAGE_EX) begin
            case (opcode_type)
                `TYPE_RJMP : begin
                    program_counter <= program_counter + opcode_imd[9:0];
                end
                `TYPE_BREQ : begin
                    if (sreg[`FLAGS_Z] == 1) begin
                        program_counter <= program_counter + opcode_imd[9:0];
                    end
                end
                `TYPE_RCALL : begin
                    program_counter <= program_counter + opcode_imd[9:0];
                end
                `TYPE_BRVC : begin
                    if (sreg[`FLAGS_V] == 0) begin
                        program_counter <= program_counter + opcode_imd[9:0];
                    end
                end
                `TYPE_BRBS : begin
                    if (sreg[opcode_imd[2:0]] == 1) begin
                        program_counter <= program_counter + {3'd0, opcode_imd[9:3]};
                    end
                end
                `TYPE_BRBC : begin
                    if (sreg[opcode_imd[2:0]] == 0) begin
                        program_counter <= program_counter + {3'd0, opcode_imd[9:3]};
                    end
                end
            endcase
        end else if (pipeline_stage == `STAGE_WB) begin
            case (opcode_type)
                `TYPE_RET : begin
                    program_counter <= saved_pc[9:0];
                end
                default : begin
                    program_counter <= program_counter + 10'b1;
                end
            endcase
        end
    end

    assign alu_flags_in = sreg;
    /* sreg attribution block */
    always @(posedge clk, posedge reset)
        if (reset)
            sreg <= 0;
        else sreg <= alu_flags_out;

    /* sp attribution block */
    always @(posedge clk, posedge reset) begin
        if (reset)
            sp <= 8'hBF;
        else if (signals[`CONTROL_IO_READ] && opcode_group[`GROUP_STACK])
            sp <= bus_data;
        else
            if (signals[`CONTROL_POSTDEC])
                sp <= sp - 1;
        else if (signals[`CONTROL_PREINC])
            sp <= sp + 1;
    end


    always @(posedge clk, posedge reset) begin
        if (reset)
            saved_pc <= 0;
        else if (pipeline_stage == `STAGE_ID && opcode_type == `TYPE_RCALL)
            saved_pc <= {6'b0, program_counter} + 16'd1;
        else if (pipeline_stage == `STAGE_MEM && opcode_type == `TYPE_RET)
            if (cycle_count == 0) begin
                saved_pc[7:0] <= bus_data;
            end else begin
                saved_pc[15:8] <= bus_data;
            end
    end

    always @(posedge clk, posedge reset) begin
        if (reset)
            writeback_value <= {DATA_WIDTH{1'b0}};
        else if (opcode_type == `TYPE_LDI)
            writeback_value <= opcode_imd[DATA_WIDTH-1:0];
        else if (signals[`CONTROL_MEM_READ])
            writeback_value <= bus_data;
        else if (opcode_group[`GROUP_ALU])
            writeback_value <= alu_out_buffer;
        else if (opcode_type == `TYPE_MOV)
            writeback_value <= alu_rr;
        /* DONE 3: Which IO op. writes to a register using writeback_value?
         * From which module do we take that value? */
        else if (opcode_type == `TYPE_OUT)
            writeback_value <= bus_data;
        else
            writeback_value <= 0;
    end

    /* Read instruction buffer */
    always @(posedge clk, posedge reset)
        if (reset)
            instr_buffer <= 0;
        else if (pipeline_stage == `STAGE_IF) begin
            instr_buffer <= instruction;
            if (program_counter < 5) begin
                $display("\nPC => %d", program_counter);
            end
        end

    /* ALU output buffer */
    always @(posedge clk, posedge reset)
        if (reset)
            alu_out_buffer <= 0;
        else if (pipeline_stage == `STAGE_EX)
            alu_out_buffer <= alu_out;


    /* DONE 4: CBI and SBI use the ALU, so we must send two operands like the
    * model below:
    * 1. one operand is be a bit mask
    * 2. the other is be the value to be modified, either by setting or clearing
    */

    /* rd_data and rr_data buffer */
    always @(posedge clk, posedge reset)
        if (reset) begin
            alu_rd <= 0;
            alu_rr <= 0;
        end else if (pipeline_stage == `STAGE_ID) begin
            if (opcode_type == `TYPE_CBI) begin
                alu_rd <= ~(1 << opcode_bit); // the mask
                alu_rr <= bus_data; // the value
            end else if (opcode_type == `TYPE_SBI) begin
                alu_rd <= (1 << opcode_bit); // the mask
                alu_rr <= bus_data; // the value
            end else begin
                // For all the other instr. which use the ALU
                alu_rd <= rd_data;
                alu_rr <= rr_data;
            end
        end


    // DONE 4: The ALU must be also active for the CBI and SBI instr.
    assign alu_enable = (pipeline_stage == `STAGE_EX) &&
        (opcode_group[`GROUP_ALU] || opcode_group[`GROUP_ALU_AUX]);

    /* DONE 4: Define the opsel for the operation corresponding to the SBI and
    * SBI instr. What operations does each execute?
    */

    /* Set alu_opsel to appropriate operation,
    * according to opcode_type and alu_enable */
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
                `TYPE_CP  :
                alu_opsel = `OPSEL_CP;
                `TYPE_CBI :
                alu_opsel = `OPSEL_AND;
                `TYPE_SBI :
                alu_opsel = `OPSEL_OR;
                default   :
                    alu_opsel = `OPSEL_NONE;
            endcase
        end
    end

endmodule
