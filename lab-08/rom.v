/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNOPTFLAT */
module rom #(
        parameter   DATA_WIDTH = 16,
        parameter   ADDR_WIDTH = 8          // 2 * 1024 bytes of ROM
    )(
        input  wire                  clk,
        input  wire [ADDR_WIDTH-1:0] addr,  // here comes the program counter
        output  reg [DATA_WIDTH-1:0] data   // here goes the instruction
    );

    reg [DATA_WIDTH-1:0] value;

    always @* begin
        case (addr)
             /*  rjmp    main     */
      0:    value = 16'b1100000000010100;
      /*  reti          */
      1:    value = 16'b1001010100011000;
      /*  reti          */
      2:    value = 16'b1001010100011000;
      /*  reti          */
      3:    value = 16'b1001010100011000;
      /*  reti          */
      4:    value = 16'b1001010100011000;
      /*  reti          */
      5:    value = 16'b1001010100011000;
      /*  reti          */
      6:    value = 16'b1001010100011000;
      /*  reti          */
      7:    value = 16'b1001010100011000;
      /*  reti          */
      8:    value = 16'b1001010100011000;
      /*  rjmp    tim0_compa_isr       */
      9:    value = 16'b1100000000000111;
      /*  reti          */
      10:      value = 16'b1001010100011000;
      /*  reti          */
      11:      value = 16'b1001010100011000;
      /*  reti          */
      12:      value = 16'b1001010100011000;
      /*  reti          */
      13:      value = 16'b1001010100011000;
      /*  reti          */
      14:      value = 16'b1001010100011000;
      /*  reti          */
      15:      value = 16'b1001010100011000;
      /*  reti          */
      16:      value = 16'b1001010100011000;
      /*  in   r16, porta     */
      17:      value = 16'b1011000100000010;
      /*  ldi  r17, 1      */
      18:      value = 16'b1110000000010001;
      /*  eor  r16, r17       */
      19:      value = 16'b0010011100000001;
      /*  out  porta, r16     */
      20:      value = 16'b1011100100000010;
      /*  ldi  r16, 1      */
      21:      value = 16'b1110000000000001;
      /*  out  ddra, r16      */
      22:      value = 16'b1011100100000001;
      /*  ldi  r16, 0      */
      23:      value = 16'b1110000000000000;
      /*  out  tccr0a, r16       */
      24:      value = 16'b1011101100001001;
      /*  ldi  r16, 1      */
      25:      value = 16'b1110000000000001;
      /*  out  tccr0b, r16       */
      26:      value = 16'b1011101100001000;
      /*  ldi  r16, 42     */
      27:      value = 16'b1110001000001010;
      /*  out  ocr0a, r16     */
      28:      value = 16'b1011101100000110;
      /*  ldi  r16, 2      */
      29:      value = 16'b1110000000000010;
      /*  out  timsk, r16     */
      30:      value = 16'b1011110100000110;
      /*  sei        */
      31:      value = 16'b1001010001111000;
      /*  rjmp    loop     */
      32:      value = 16'b1100111111111111;
      default:    value = 16'b0000000000000000;
        endcase
    end

    always @(negedge clk) begin
        data <= value;
    end

endmodule
