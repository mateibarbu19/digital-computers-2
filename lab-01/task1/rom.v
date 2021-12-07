/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module rom (
    input      [3:0] address,
    output reg [7:0] data
);
    always @* begin
        case (address)
            4'd0:    data = 8'd1;
            4'd1:    data = 8'd2;
            4'd2:    data = 8'd4;
            4'd3:    data = 8'd8;
            4'd4:    data = 8'd16;
            4'd5:    data = 8'd32;
            4'd6:    data = 8'd64;
            4'd7:    data = 8'd128;
            4'd8:    data = 8'd170;
            4'd9:    data = 8'd85;
            4'd10:   data = 8'd153;
            default: data = 8'd0;
        endcase
    end
endmodule
