/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module test_sram();
    reg       clk;
    reg       oe;
    reg       cs;
    reg       we;
    reg       reset;
    reg [6:0] address;


    reg  [7:0] buffer;
    /* verilator lint_off UNUSED */
    wire [7:0] data;
    /* verilator lint_on UNUSED */


    // Initialize Unit Under Test (UUT).
    sram single_memory_chip(
        .clk(clk),
        .reset(reset),
        .oe(oe),
        .cs(cs),
        .we(we),
        .address(address),
        .data(data)
    );

    always #2 clk = ~clk;
    
    assign data = (cs && we && !oe && !reset) ? buffer : 8'bz;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, test_sram);

        // Initialize the memory contents.
        clk = 0;
        buffer = 8'bz;
        reset = 1;
        we = 0;
        oe = 0;
        #4;

        // Small Test
        cs = 1;
        reset = 0;
        address = 7'b0001000;
        we = 1;
        oe = 0;
        buffer = 8'b10000001;
        #4;

        we = 0;
        oe = 1;
        #4;

        address = 7'b0;
        #4;

        reset = 1;
        #2;
        reset = 0;
        #2;

        // Write values
        we = 1;
        oe = 0;
        address = 0;
        buffer = 73;  
        #4;

        address = 1;
        buffer = 19;
        #4;

        address = 2;
        buffer = 34;
        #3;

        // Read the written values
        we = 0;
        #1;
        address = 0;
        oe = 1;
        // Warning! Until the next posedge of the clk we will read again the
        // last value read from the SRAM
        #4;
        address = 1;
        #4;
        cs = 0;
        address = 2;
        #4;
        oe = 0;

        $finish();
    end
endmodule
