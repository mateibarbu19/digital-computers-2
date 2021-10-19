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
    input oe,
    input cs,
    input we,
    input   [6:0] address,
    inout   [7:0] data
);
    reg [7:0] memory [0:127];
    reg [7:0] buffer;
    reg [7:0] input_data;

    assign data = (oe && !we) ? buffer : 8'bz;
    assign input_data = data;

    always @(posedge clk) begin
        if (cs) begin
            if (we) begin
                memory[address] = input_data;
            end else begin
                buffer = memory[address];
            end
        end
    end
endmodule