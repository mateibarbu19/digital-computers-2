 /*
 * clk - clock
 * oe - output enable, active high
 * cs - chip select, active high
 * we - write enable: 0 = read, 1 = write
 * adresa - adrese pentru 128 de intrari
 * data_in - intrare de date de 8 biti
 * data_out - iesire de date de 8 biti
 */
module sram(
    input clk,
    input reset,
    input oe,
    input cs,
    input we,
    input[6:0] address,
    input[7:0] data_in,
    output[7:0] data_out
);

    integer i;
    reg [7:0] buffer;
    reg [7:0] memory [0:127];
    
    always @(posedge clk) begin
        if (!reset && cs) begin
            if (we) begin
                memory[address] <= data_in;
            end else begin
                buffer = memory[address];
            end
        end
    end

    always @(reset) begin
        if (reset) begin
            buffer = 8'bz;
            for (i = 0; i < 128; i++) begin
                memory[i] = 8'b0;
            end
        end
    end

    assign data_out = (cs && oe && !we && !reset) ? buffer : 8'bz;
endmodule