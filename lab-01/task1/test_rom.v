module test_rom();
    integer i;

    // Inputs.
    reg [3:0] address;

    // Outputs.
    wire [7:0] out;

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
 
