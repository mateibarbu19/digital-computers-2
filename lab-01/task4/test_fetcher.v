module test_fetcher ();
    
    // Inputs
    reg     clk;
    reg     rst;
    integer address;

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
        clk = 0;
        rst = 1;
        address = 0;

        // Wait 100 ns for global reset to finish
        #10;

        // Add stimulus here
        rst = 0;
        //#10;

        for (address = 0; address < 16; address = address + 1) 
        begin
            #40;
        end

        for (address = 0; address < 16; address = address + 1) 
        begin
            #30;
        end

        $finish();
    end
endmodule