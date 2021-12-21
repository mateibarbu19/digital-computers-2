`include "defines.vh"
module control_unit #(
    parameter INSTR_WIDTH  = 16, // instructions are 16 bits in width
    parameter DATA_WIDTH   = 8 , // registers are 8 bits in width
    parameter I_ADDR_WIDTH = 10, // 2*1024 bytes of flash (or ROM in our case)
    parameter ADDR_WIDTH   = 16, // 64KB address space
    parameter D_ADDR_WIDTH = 7 , // 128 bytes of SRAM
    parameter R_ADDR_WIDTH = 5   // 32 registers
) (
    input  wire                        clk            ,
    input  wire                        reset          ,
    // To/from instruction memory
    output      reg [I_ADDR_WIDTH-1:0] program_counter,
    input  wire     [ INSTR_WIDTH-1:0] instruction    ,
    // From FSM
    output wire     [`STATE_COUNT-1:0] state          ,
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
    output wire                        alu_cin_en     ,
    output wire                        alu_cout_en    ,
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
    output wire                        mem_oe         ,
    output wire                        io_cs          ,
    output wire                        io_we          ,
    output wire                        io_oe
);

    // From decode unit and signal generation unit
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
    reg  [ ADDR_WIDTH-1:0] saved_pc       ;
    wire                   alu_save_flags ;

    state_machine fsm (
        .state       (state       ),
        .cycle_count (cycle_count ),
        .opcode_group(opcode_group),
        .clk         (clk         ),
        .reset       (reset       )
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
        .state       (state       ),
        .cycle_count (cycle_count ),
        .opcode_type (opcode_type ),
        .opcode_group(opcode_group),
        .signals     (signals     )
    );

    reg_file_interface_unit #(
        .DATA_WIDTH  (DATA_WIDTH  ),
        .INSTR_WIDTH (INSTR_WIDTH ),
        .D_ADDR_WIDTH(D_ADDR_WIDTH),
        .R_ADDR_WIDTH(R_ADDR_WIDTH)
    ) rf_int (
        .opcode_type    (opcode_type    ),
        .opcode_rd      (opcode_rd      ),
        .opcode_rr      (opcode_rr      ),
        .signals        (signals        ),
        .writeback_value(writeback_value),
        .rr_addr        (rr_addr        ),
        .rd_addr        (rd_addr        ),
        .rr_data        (rr_data        ),
        .rd_data        (rd_data        ),
        .rr_cs          (rr_cs          ),
        .rd_cs          (rd_cs          ),
        .rr_we          (rr_we          ),
        .rd_we          (rd_we          ),
        .rr_oe          (rr_oe          ),
        .rd_oe          (rd_oe          )
    );

    bus_interface_unit #(
        .MEM_START_ADDR(8'h40     ),
        .MEM_STOP_ADDR (8'hBF     ),
        .IO_START_ADDR (8'h00     ),
        .IO_STOP_ADDR  (8'h3F     ),
        .DATA_WIDTH    (DATA_WIDTH),
        .ADDR_WIDTH    (ADDR_WIDTH)
    ) bus_int (
        .opcode_group (opcode_group ),
        .opcode_imd   (opcode_imd   ),
        .signals      (signals      ),
        .cycle_count  (cycle_count  ),
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
        (opcode_group[`GROUP_STACK] ?
            //(cycle_count == 0) ? {8'b0, sp} : `SREG :
            {8'b0, sp} :
            // else, indirect to memory => X or Y or Z
            {alu_rr, alu_rd}) :
        // else, not indirect
        {ADDR_WIDTH{1'bx}};

    assign data_to_store =
        signals[`CONTROL_MEM_WRITE] ?
        opcode_type == `TYPE_RCALL ?
        cycle_count ? saved_pc[7:0] :
        saved_pc[15:8] :
        alu_rr :
        signals[`CONTROL_IO_WRITE] ?
        opcode_group[`GROUP_STACK] ? (cycle_count == 0) ? sp : sreg :
        opcode_group[`GROUP_ALU] ? sreg :
        opcode_group[`GROUP_ALU_AUX] ? alu_out_buffer : // SBI and CBI
        opcode_type == `TYPE_OUT ? alu_rr :
        {DATA_WIDTH{1'bx}} :
        opcode_group[`GROUP_ALU_AUX] ?
        alu_out_buffer :
        {DATA_WIDTH{1'bx}};

    assign alu_enable = (state == `STATE_EX) &&
        (opcode_group[`GROUP_ALU] ||
            opcode_group[`GROUP_ALU_IMD] ||
            opcode_group[`GROUP_ALU_AUX]);

    assign alu_flags_in = sreg;
    /* Bloc de atribuire al sreg-ului */
    always @(posedge clk, posedge reset)
        if (reset)
            sreg <= 0;
        else if (bus_addr == `SREG)
            sreg <= bus_data;
        else if (alu_enable && alu_save_flags)
            sreg <= alu_flags_out;
        else if (state == `STATE_EX)
            sreg <= alu_out;

    /* Bloc de atribuire al sp-ului */
    always @(posedge clk, posedge reset) begin
        if (reset)
            sp <= 0;
        else if (bus_addr == `SPL)
            sp <= bus_data;
        else
            if (signals[`CONTROL_POSTDEC])
                sp <= sp - 8'b1;
        else if (signals[`CONTROL_PREINC])
            sp <= sp + 8'b1;
    end

    /* Bloc de atribuire al program counter-ului */
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            program_counter <= 0;
        end else if (state == `STATE_EX) begin
            case (opcode_type)
                `TYPE_RJMP : begin
                    program_counter <= program_counter + opcode_imd[9:0];
                end
                `TYPE_BRBS : begin
                    if (sreg[opcode_bit] == 1)
                        program_counter <= program_counter + opcode_imd[9:0];
                end
                `TYPE_BRBC : begin
                    if (sreg[opcode_bit] == 0)
                        program_counter <= program_counter + opcode_imd[9:0];
                end
                `TYPE_RCALL : begin
                    program_counter <= program_counter + opcode_imd[9:0]; //truncated from 12
                end
            endcase
        end else if (state == `STATE_WB) begin
            if (opcode_type == `TYPE_RET) begin
                program_counter <= saved_pc[9:0];
            end else begin
                program_counter <= program_counter + 10'b1;
            end

            $display("Program counter is now at: %2d", program_counter + 1);
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset)
            saved_pc <= 0;
        else if (state == `STATE_ID)
            begin
                // save _next_ PC before call
                if (opcode_type == `TYPE_RCALL)
                    saved_pc <= {6'b0, program_counter} + 12'b1;
            end
        else if (state == `STATE_MEM &&
            (opcode_type == `TYPE_RET))
        begin
            if (cycle_count == 0) begin
                saved_pc[7:0] <= bus_data;
            end else begin
                saved_pc[15:8] <= bus_data;
            end
        end
    end

    always @(posedge clk, posedge reset) begin
        if (reset)
            writeback_value <= {DATA_WIDTH{1'b0}};
        else if (opcode_type == `TYPE_LDI)
            writeback_value <= opcode_imd[DATA_WIDTH-1:0];
        else if (signals[`CONTROL_IO_READ] ||
            signals[`CONTROL_MEM_READ])
        writeback_value <= bus_data;
        else if (opcode_group[`GROUP_ALU] || opcode_group[`GROUP_ALU_IMD])
            writeback_value <= alu_out_buffer;
        else if (opcode_type == `TYPE_MOV)
            writeback_value <= alu_rr;
    end

    /* Buffer pentru instructiunea citita */
    always @(posedge clk, posedge reset)
        if (reset) begin
            instr_buffer <= 0;
        end else if (state == `STATE_IF) begin
            instr_buffer <= instruction;
        end

    /* Buffer pentru output-ul UAL-ului */
    always @(posedge clk, posedge reset)
        if (reset) begin
            alu_out_buffer <= 0;
        end else if (state == `STATE_EX) begin
            alu_out_buffer <= alu_out;
        end

    /* Buffer pentru rd_data si rr_data */
    always @(posedge clk, posedge reset)
        if (reset) begin
            alu_rd <= 0;
            alu_rr <= 0;
        end else if (state == `STATE_ID) begin
            if (opcode_type == `TYPE_SBI)
                begin
                    alu_rd <= bus_data;
                    alu_rr <= (8'b1 << opcode_bit);
                end else if (opcode_type == `TYPE_CBI)
            begin
                alu_rd <= bus_data;
                alu_rr <= ~(8'b1 << opcode_bit);
            end else if (opcode_type == `TYPE_INC ||
                opcode_type == `TYPE_DEC)
            begin
                alu_rd <= rd_data;
                alu_rr <= 1;
            end else if (opcode_group[`GROUP_ALU_IMD])
            begin
                alu_rd <= rd_data;
                alu_rr <= opcode_imd;
            end else begin
                alu_rd <= rd_data;
                alu_rr <= rr_data;
            end
        end

    /* Set alu_opsel to appropriate operation,
    * according to opcode_type and alu_enable */
    always @* begin
        if (alu_enable == 0)
            alu_opsel = `OPSEL_COUNT'bx;
        else begin
            case (opcode_type)
                `TYPE_ADD, `TYPE_ADC, `TYPE_INC:
                alu_opsel = `OPSEL_ADD;
                `TYPE_SUB, `TYPE_DEC:
                alu_opsel = `OPSEL_SUB;
                `TYPE_AND, `TYPE_CBI:
                alu_opsel = `OPSEL_AND;
                `TYPE_EOR :
                alu_opsel = `OPSEL_XOR;
                `TYPE_OR, `TYPE_SBI:
                alu_opsel = `OPSEL_OR;
                `TYPE_NEG :
                alu_opsel = `OPSEL_NEG;
                default   :
                    alu_opsel = `OPSEL_NONE;
            endcase
        end
    end

    assign alu_cin_en     = alu_enable && (opcode_type == `TYPE_ADC);
    assign alu_cout_en    = alu_enable && (opcode_type != `TYPE_INC) && (opcode_type != `TYPE_DEC);
    assign alu_save_flags = (opcode_group[`GROUP_ALU_AUX] == 0);

endmodule
