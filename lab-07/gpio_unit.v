`include "defines.vh"
module gpio_unit #(parameter DATA_WIDTH = 8) (
    // host interface
    input  wire                      clk      ,
    input  wire                      reset    ,
    input  wire     [DATA_WIDTH-1:0] mem_ddra ,
    input  wire     [DATA_WIDTH-1:0] mem_ddrb ,
    input  wire     [DATA_WIDTH-1:0] mem_porta,
    input  wire     [DATA_WIDTH-1:0] mem_portb,
    // output buffers for GPIO external pins
    output      reg [DATA_WIDTH-1:0] pa_buf   ,
    output      reg [DATA_WIDTH-1:0] pb_buf
);

    reg [DATA_WIDTH:0] i;
    always @(posedge clk) begin
        if (reset)
            begin
                pa_buf <= 0;
                pb_buf <= 0;
            end
        else
            for (i = 0; i < DATA_WIDTH; i = i + 1) begin : gen_ports
                pa_buf[i] <= mem_ddra[i]?mem_porta[i] : 1'bz;
                pb_buf[i] <= mem_ddrb[i]?mem_portb[i] : 1'bz;
            end
    end

endmodule
