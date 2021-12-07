/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module test_rom();
    integer i;

    // Inputs.
    reg [3:0] address;

    // Outputs.
    /* verilator lint_off UNUSED */
    wire [7:0] out;
    /* verilator lint_on UNUSED */

    // Initialize Unit Under Test (UUT).
    rom sample_memory (
        .address(address),
        .data(out)
    );

    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, test_rom);

        // Initialize inputs.
        for (i = 0; i < ($bits(address) << 2); i++) begin
            address = i[3:0];
            #5;
        end
    end
endmodule
 
