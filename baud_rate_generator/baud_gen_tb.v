module baud_gen_tb;

reg pclk, preset_n, spiswai, cpol, cpha, SS;
reg [1:0] spi_mode;
reg [2:0] sppr, spr;

wire sclk;
wire miso_rcv_pos, miso_rcv_neg;
wire mosi_snd_pos, mosi_snd_neg;
wire [11:0] baud_rate_divisor;

baud_gen dut(pclk, preset_n, spi_mode, spiswai, sppr, spr, cpol, cpha, SS, sclk, miso_rcv_pos, miso_rcv_neg, mosi_snd_pos, mosi_snd_neg, baud_rate_divisor );

always #5 pclk = ~pclk;

task reset;
begin
	 @(negedge pclk);
    preset_n = 0;
    @(negedge pclk);
    preset_n = 1;
end
endtask

task data(input [2:0] sppr_val,
          input [2:0] spr_val,
          input       cpol_val,
          input       cpha_val);
begin
    spi_mode = 2'b00;
    sppr     = sppr_val;
    spr      = spr_val;
    spiswai  = 1'b0;
    SS       = 1'b0;
    cpol     = cpol_val;
    cpha     = cpha_val;

     @(negedge pclk);
end
endtask

initial begin

    pclk    = 0;
    preset_n = 1;
    spi_mode = 2'b00;
    spiswai = 0;
    SS      = 0;
    sppr    = 3'b000;
    spr     = 3'b000;
    cpol    = 0;
    cpha    = 0;

    reset;
	 
    repeat(20)
        data(3'b000, 3'b001, 1'b0, 1'b0);

    // SPPR = 1, SPR = 1, CPOL = 0, CPHA = 0
    repeat(20)
        data(3'b001, 3'b001, 1'b0, 1'b0);

    // SPPR = 0, SPR = 2, CPOL = 0, CPHA = 0
    repeat(20)
        data(3'b000, 3'b010, 1'b0, 1'b0);

    // CPOL = 1, CPHA = 0
    repeat(20)
        data(3'b000, 3'b001, 1'b1, 1'b0);

    // CPOL = 0, CPHA = 1
    repeat(20)
        data(3'b000, 3'b001, 1'b0, 1'b1);

    // CPOL = 1, CPHA = 1
    repeat(20)
        data(3'b000, 3'b001, 1'b1, 1'b1);

    #100 $finish;

end

endmodule
