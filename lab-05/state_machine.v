/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
`timescale 1ns / 1ps
`include "defines.vh"

module state_machine (
    output      reg [`STAGE_COUNT-1:0] pipeline_stage,
    input  wire                        clk           ,
    input  wire                        reset         ,
    output      reg                    cycle_count   ,
    input  wire     [`GROUP_COUNT-1:0] opcode_group
);

    reg [`STAGE_COUNT-1:0] next_stage;

    /*
    Schimbarea etapei de pe procesor la fiecare ciclu de ceas
    */
    always @(posedge clk, posedge reset)
        if (reset)
            pipeline_stage <= `STAGE_RESET;
        else
            pipeline_stage <= next_stage;

    /*
    Numararea ciclilor cand avem operatiuni care vor trebui sa stea
    mai multi cicli intr-o etapa
    */
    always @(posedge clk, posedge reset) begin
        if (reset)
            cycle_count <= 0;
        /*
        TODO 1,2: Cititi explicatia de mai jos.
        NU aveti nevoie sa modificati nimic aici.

        Daca suntem in etapa de memorie si o operatie care sta doi cicli in aceasta
        etapa. Modifica cyc_count pentru a sti in care ciclu suntem
        0 - primul ciclu
        1 - al doilea ciclu
        */
        else if (pipeline_stage == `STAGE_MEM && opcode_group[`GROUP_TWO_CYCLE_MEM])
            cycle_count <= ~cycle_count;
    end

    /*
    Calcularea urmatoarei etape pe procesor
    */
    always @* begin
        case (pipeline_stage)
            `STAGE_RESET:
            next_stage = `STAGE_IF;
            `STAGE_IF:
            next_stage = `STAGE_ID;
            `STAGE_ID:
            next_stage = `STAGE_EX;
            `STAGE_EX:
            next_stage = `STAGE_MEM;
            /*
            TODO 1,2: Cititi explicatia de mai jos.
            NU aveti nevoie sa modificati nimic aici.

            În cazul operatiilor RCALL si RET va trebuie sa accesam de doua ori
            memoria pentru a putea salva porgram counter-ul pe stiva, respectiv
            sa încarcam program counter-ul de pe stiva.
            Deci daca avem o opera?ie din grupul opera?iilor ce stau 2 cicli
            în etapa de memorie va trebui ca urmatoarea etapaa dupa primul ciclu
            de memorie sa fie tot etapa de memorie nu cea de writeback
            */
            `STAGE_MEM:
            if (opcode_group[`GROUP_TWO_CYCLE_MEM] && cycle_count == 0)
                next_stage = `STAGE_MEM;
            else
                next_stage = `STAGE_WB;
            `STAGE_WB:
            next_stage = `STAGE_IF;
            default:
                next_stage = `STAGE_RESET;
        endcase
    end

endmodule
