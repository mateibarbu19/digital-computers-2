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
    TODO 1, 2: Hint: saved_pc este un buffer de ADDR_WIDTH biti care ajuta la
    stocarea PC pe stiva si la citirea lui de pe stiva.

    NU aveti nevoie sa modificati nimic aici.
    */
    reg [  ADDR_WIDTH-1:0] saved_pc            ;
    reg [I_ADDR_WIDTH-1:0] next_program_counter;

    /*
    Tranzitiile intre etapele procesorului
    */
    state_machine fsm (
        .pipeline_stage(pipeline_stage),
        .clk           (clk           ),
        .reset         (reset         ),
        .cycle_count   (cycle_count   ),
        .opcode_group  (opcode_group  )
    );
    /* ID: decodificarea instructiunilor */
    decode_unit #(.INSTR_WIDTH(INSTR_WIDTH)) decode (
        .instruction (instr_buffer),
        .opcode_type (opcode_type ),
        .opcode_group(opcode_group),
        .opcode_imd  (opcode_imd  ),
        .opcode_rd   (opcode_rd   ),
        .opcode_rr   (opcode_rr   ),
        .opcode_bit  (opcode_bit  )
    );
    /*
    Activarea semnalelor pentru fiecare etapa
    */
    signal_generation_unit sig (
        .pipeline_stage(pipeline_stage),
        .cycle_count   (cycle_count   ),
        .signals       (signals       ),
        .opcode_type   (opcode_type   ),
        .opcode_group  (opcode_group  )
    );

    /*
    Interfata de control pentru registre
    */
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

    /*
    Interfata de control cu memoria
    */
    bus_interface_unit #(
        .MEM_START_ADDR(8'h40     ),
        .MEM_STOP_ADDR (8'hBF     ),
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


    /*
    IF: Punerea instructiunii din memoria rom intr-un buffer
    */
    always @(posedge clk, posedge reset)
        if (reset)
            instr_buffer <= 0;
        else if (pipeline_stage == `STAGE_IF) begin
            instr_buffer <= instruction;
            if (program_counter < 7) begin
                $display("\nPC => %d", program_counter);
            end
        end

    /*
    ID : Tipul operatiei executate de ALU
    */
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

    /*
    ID: Buffere pentru rd_data si rr_data
    */
    always @(posedge clk, posedge reset)
        if (reset) begin
            alu_rd <= 0;
            alu_rr <= 0;
        end else if (pipeline_stage == `STAGE_ID) begin
            alu_rd <= rd_data;
            alu_rr <= rr_data;
        end


    /* Bloc de atribuire al sreg-ului */
    assign alu_flags_in = sreg;
    always @(posedge clk, posedge reset)
        if (reset)
            sreg <= 0;
        else
            sreg <= alu_flags_out;

    /*
    EX: Buffer pentru output-ul UAL-ului
    */
    always @(posedge clk, posedge reset)
        if (reset)
            alu_out_buffer <= 0;
        else if (pipeline_stage == `STAGE_EX)
            alu_out_buffer <= alu_out;

    assign alu_enable = (pipeline_stage == `STAGE_EX);

    /*
    MEM:
    */
    /* Adresare indirecta a memoriei, care momentan poate fi facuta
    prin insructiunile:
    - din grupurile opcode_group[`GROUP_LOAD_INDIRECT] || opcode_group[`GROUP_STORE_INDIRECT]
    - instructiunile care vor folosi stack pointerul (sp)
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
    Ce date vor merge in memorie:

    TODO 1: Hint: RCALL va trebui sa stocheze PC pe stiva in cei doi cicli din
    etapa de memorie pe care ii are la dispozitie
    */
    assign data_to_store =
        signals[`CONTROL_MEM_WRITE] ?
        (opcode_type == `TYPE_RCALL) ?
        (cycle_count == 0) ?
        /*
        TODO 1: Stocati prima parte a adresei de intoarcere. Hint:
        Vedeti liniile 65 si 295.
        */
        {DATA_WIDTH{1'bx}} : // Change this
        /*
        TODO 1: Stocati restul adresei de intoarcere.
        */
        {DATA_WIDTH{1'bx}} : // Change this
        alu_rr:
        {DATA_WIDTH{1'bx}};

    /*
    WB:
    Valoarea care va fi pusa in RD.
    */
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

    /*
    ID + MEM:
    Controlul cu bufferul pentru program counter folosit pentru RCALL si RET
    */
    always @(posedge clk, posedge reset) begin
        if (reset)
            saved_pc <= 0;
        else
            if (pipeline_stage == `STAGE_ID) begin
                if (opcode_type == `TYPE_RCALL) begin
                    /*
                    TODO 1: Salvati in registru adresa de intoarcere din functie.
                    Atentie, aceasta nu este egala cu program_counter. Care este relatia
                    dintre cele doua valori?
                    */
                    saved_pc <= {ADDR_WIDTH{1'bx}};
                end
            end
        else if (pipeline_stage == `STAGE_MEM && opcode_type == `TYPE_RET)
            begin
                if (cycle_count == 0) begin
                    /*
                    TODO 2: Restaurati prima parte a adresei de intoarcere. Aceasta adresa
                    a fost salvata pe stiva, care este o regiune de memorie. Prin ce
                    magistrala vin datele de la memorie?
                    */
                    saved_pc <= {ADDR_WIDTH{1'bx}};
                end else begin
                    /*
                    TODO 2: Restaurati restul adresei de intoarcere.
                    */
                    saved_pc <= {ADDR_WIDTH{1'bx}};
                end
            end
    end
    /*
    Bloc de atribuire calculare al urmatorului program counter
    */
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
                    /*
                    TODO 1: Implementati saltul la adresa functiei. Hint: este un
                    salt relativ. PC ← PC + k + 1
                    */

                    next_program_counter <= program_counter + 1;
                end
                default : begin
                    next_program_counter <= program_counter + 1;
                end
            endcase
        end else if (pipeline_stage == `STAGE_WB) begin
            if (opcode_type == `TYPE_RET) begin
                /*
                TODO 2: Implementati intoarcerea din functie.
                PC ← return address (de pe stivă)
                */
                program_counter <= next_program_counter;
            end else begin
                program_counter <= next_program_counter;
            end
        end
    end


    /*
    EX si MEM
    Bloc de atribuire al sp-ului
    */
    always @(posedge clk, posedge reset) begin
        if (reset)
            sp <= `STACK_START;
        else
            if (signals[`CONTROL_STACK_POSTDEC])
                sp <= sp - 8'b1;
        else if (signals[`CONTROL_STACK_PREINC])
            sp <= sp + 8'b1;
    end

endmodule
