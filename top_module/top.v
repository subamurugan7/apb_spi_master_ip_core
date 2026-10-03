
module top (pclk,preset_n,paddr,pwrite,psel,penable,pwdata,miso,ss,sclk,spi_interrupt_req,mosi,pr_data,pready,pslverr);
input pclk,preset_n,pwrite,psel,penable,miso;
input[2:0]paddr;
input [7:0]pwdata;
output ss,sclk,spi_interrupt_req,pready,pslverr;
output  mosi;
output [7:0]pr_data;
wire miso,spiswai,cpol,cpha,rcv_data,send_data,lsbfe;
wire[2:0]sppr,spr;
wire[1:0]spi_mode;
wire miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,tip,mstr;
wire [11:0]baud_rate_divisor;
wire [7:0]data_mosi;
wire[7:0]data_miso;

// blk 1 baud_generator 
baud_gen blk1(pclk,preset_n,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,baud_rate_divisor);

//blk 2 shift register
shift_register blk2(pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_recieve_sclk,miso_recieve_sclk0,mosi_send_sclk,mosi_send_sclk0,data_mosi,miso,rcv_data,mosi,data_miso);

// blk 3 slave select 
slave_select_control blk3(pclk,preset_n,mstr,spiswai,spi_mode,send_data,baud_rate_divisor,rcv_data,ss,tip);

// blk 4 apb and spi interface block
apb_slave_interface blk4(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,ss,data_miso,rcv_data,tip,pr_data,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_interrupt_req,pready,pslverr,send_data,data_mosi,spi_mode);

endmodule
