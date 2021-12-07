/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
/*
 * clk - clock
 * oe - output enable, active high
 * cs - chip select, active high
 * we - write enable: 0 = read, 1 = write
 * adresa - 128 address space
 * data - 8bit input
 */
module sram(
    input       clk,
    input       reset,
    input       oe,
    input       cs,
    input       we,
    input [6:0] address,
    inout [7:0] data
);


    integer i;
    reg [7:0] buffer;
    reg [7:0] memory [0:127];

    assign data = (cs && oe && !we && !reset) ? buffer : 8'bz;

    always @(posedge clk) begin
        if (reset) begin
            buffer <= 8'bz;
            for (i = 0; i < 128; i++) begin
                /* verilator lint_off BLKLOOPINIT */
                memory[i] <= 8'bz;
                /* verilator lint_on BLKLOOPINIT */
            end
        end if (cs) begin
            if (we && !oe) begin
                memory[address] <= data;
            end else if (!we && oe) begin
                buffer <= memory[address];
            end
        end
    end
endmodule