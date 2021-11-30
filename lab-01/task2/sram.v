 /*
 * clk - clock
 * oe - output enable, active high
 * cs - chip select, active high
 * we - write enable: 0 = read, 1 = write
 * adresa - 128 bit address space
 * data_in - 8bit input
 * data_out - 8bit output
 */
module sram(
    input        clk,
    input        reset,
    input        oe,
    input        cs,
    input        we,
    input  [6:0] address,
    input  [7:0] data_in,
    output [7:0] data_out
);

    integer i;
    reg [7:0] buffer;
    reg [7:0] memory [0:127];

    always @(posedge clk) begin
        if (reset) begin
            buffer <= 8'bz;
            for (i = 0; i < 128; i++) begin
                /* verilator lint_off BLKLOOPINIT */
                memory[i] <= 8'b0;
                /* verilator lint_on BLKLOOPINIT */
            end
        end
        else if (cs) begin
            if (we && !oe) begin
                memory[address] <= data_in;
            end else if (!we && oe) begin
                buffer <= memory[address];
            end
        end
    end

    assign data_out = (cs && oe && !we && !reset) ? buffer : 8'bz;
endmodule
