/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module test_sram();
    // Inputs.
    reg       clk;
    reg       oe;
    reg       cs;
    reg       we;
    reg       reset;
    reg [6:0] address;
    reg [7:0] data_in;

    // Outputs.
    /* verilator lint_off UNUSED */
    wire [7:0] data_out;
    /* verilator lint_on UNUSED */

    // Initialize Unit Under Test (UUT).
    sram single_memory_chip(
        .clk(clk),
        .reset(reset),
        .oe(oe),
        .cs(cs),
        .we(we),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #1 clk = ~clk;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, test_sram);

        // Initialize the memory contents.
        clk = 0;
        reset = 1;
        we = 0;
        oe = 0;
        #2;

        cs = 1;
        reset = 0;
        address = 7'b0001000;
        we = 1;
        oe = 0;
        data_in = 8'b10000001;
        #2;

        we = 0;
        oe = 1;
        #2;

        address = 7'b0;
        #2;

        reset = 1;
        #1;
        reset = 0;
        #1;
        $finish();
    end
endmodule
