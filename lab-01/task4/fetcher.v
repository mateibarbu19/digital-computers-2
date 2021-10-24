module fetcher (
    output wire [7:0] data,
    input  wire       clk,     // clock
    input  wire       rst,     // reset
    input  wire [3:0] address
);

    reg [1:0] state;
    reg [7:0] out_buffer;
    
    /* Memory params */
    reg        we, oe, cs;
    wire [7:0] rom_buffer;  // used for rom instance
    wire [7:0] sram_buffer; // used for sram instance

    localparam TRUE                 = 1'b1,
               FALSE                = 1'b0,
               STATE_IDLE           = 2'd0,
               STATE_SRAM_READ_INIT = 2'b01,
               STATE_SRAM_READ      = 2'b10;
    
    task clear_signals;
        // input reg       we_s;
        // input reg       cs_s;
        // input reg       oe_s;
        // input reg [1:0] state_s;
        // input reg [7:0] out_buffer_s;
        begin
            we         <= FALSE; 
            cs         <= FALSE;
            oe         <= FALSE;
            state      <= STATE_IDLE;
            out_buffer <= 8'bz;
        end
    endtask

    always @(posedge clk) begin
        if (rst) begin
            clear_signals;
        end else begin
            case (state)
                STATE_IDLE: begin
                    we <= FALSE;
                    cs <= FALSE;
                    oe <= FALSE;
                    if (address != 4'dz) begin
                        state <= STATE_IDLE; 
                    end else begin
                        state <= STATE_SRAM_READ_INIT;
                    end
                end

                STATE_SRAM_READ_INIT: begin
                    we    <= FALSE; 
                    cs    <= TRUE;
                    oe    <= TRUE;
                    state <= STATE_SRAM_READ;
                end

                STATE_SRAM_READ: begin
                    if (sram_buffer !== 8'dx) begin  // if data is in SRAM ????
                        out_buffer <= sram_buffer;
                        state      <= STATE_IDLE;
                    end else begin
                        out_buffer <= rom_buffer; // if data is NOT SRAM, take it from ROM
                        // set flags to write data in SRAM
                        oe    <= FALSE; 
                        we    <= TRUE; 
                        state <= STATE_IDLE;
                    end
                end

                default: begin
                    clear_signals;
                end
            endcase
        end
    end

    // Assign a value to data bus
    assign data = out_buffer;
    assign sram_buffer = ((state == STATE_SRAM_READ) & we) ? out_buffer : 8'dz;

    rom memory (
        .address(address),
        .data(rom_buffer)
    );
    
    sram cache (
        .clk(clk),
        .reset(rst),
        .oe(oe),
        .cs(cs),
        .we(we),
        .address({3'b000, address}),
        .data(sram_buffer)
    );
endmodule