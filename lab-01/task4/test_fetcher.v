/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module test_fetcher ();
    
    // Inputs
    reg       clk;
    reg       rst;
    reg [4:0] address;

    // Outputs
    /* verilator lint_off UNUSED */
    wire [7:0] data;
    /* verilator lint_off UNUSED */

    // Instantiate the Unit Under Test (UUT)
    fetcher uut (
        .clk(clk), 
        .rst(rst), 
        .address(address[3:0]), 
        .data(data)
    );
    
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, test_fetcher);

        // Initialize Inputs
        clk = 1;
        rst = 1;
        address = 5'bz;

        // Wait for global reset to finish
        #20;

        // Add stimulus here
        rst = 0;

        for (address = 0; address < 16; address = address + 1) 
        begin
            #30;
        end

        for (address = 0; address < 16; address = address + 1) 
        begin
            #30;
        end

        $finish();
    end
endmodule