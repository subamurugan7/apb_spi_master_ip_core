module apb_slave_interface_tb();
 reg pclk,presetn,pwrite,psel,penable,ss,recieve_data,tip;
reg[2:0]paddr;
reg[7:0]pwdata,miso_data;
wire mstr,cpol,cpha,lsbfe,spi_swai,pready,pslverr;
wire spi_interrupt_req;
wire send_data;
wire[2:0]sppr,spr;
wire[7:0]pr_data;
wire[1:0]spi_mode;
wire [7:0]mosi_data;
 apb_slave_interface dut(pclk,presetn,paddr,pwrite,psel,penable,pwdata,ss,miso_data,recieve_data,tip,pr_data,mstr,cpol,cpha,lsbfe,spi_swai,sppr,spr,spi_interrupt_req,pready,pslverr,send_data,mosi_data,spi_mode);

 initial 
 begin
	 pclk=1'b0;
	 forever #5 pclk=~pclk;
 end
 task resets();
	 begin
		 @(negedge pclk);
		 presetn=1'b0;
		 @(negedge pclk);
		 presetn=1'b1;
	 end
 endtask
 task write_cr1;
	 begin
		 @(negedge pclk);
		 paddr=3'b000;
		 pwrite=1'b1;
		 psel=1'b1;
		 penable=1'b0;
		 pwdata=8'b01011101;
		 @(negedge pclk);
		 penable=1'b1;
		 @(negedge pclk);
		 penable=1'b0;
		 psel=1'b0;
	 end
 endtask
 task write_cr2;
	 begin
		  @(negedge pclk);
		 paddr=3'b001;
		 pwrite=1'b1;
		 psel=1'b1;
		 penable=1'b0;
		 pwdata=8'b01010101;
		 @(negedge pclk);
		 penable=1'b1;
		 @(negedge pclk);
		 penable=1'b0;
		 psel=1'b0;
	 end
 endtask
task write_br;
	 begin
		  @(negedge pclk);
		 paddr=3'b010;
		 pwrite=1'b1;
		 psel=1'b1;
		 penable=1'b0;
		 pwdata=8'b01000100;
		 @(negedge pclk);
		 penable=1'b1;
		 @(negedge pclk);
		 penable=1'b0;
		 psel=1'b0;
	 end
 endtask
task write_dr;
	 begin
		 @(negedge pclk);
		 paddr=3'b101;
		 pwrite=1'b1;
		 psel=1'b1;
		 penable=1'b0;
		 pwdata=8'b10110110;
		 @(negedge pclk);
		 penable=1'b1;
		 @(negedge pclk);
		 penable=1'b0;
		 psel=1'b0;
	 end
 endtask
 task sr;
	 begin
		  @(negedge pclk);
		 paddr=3'b011;
		 pwrite=1'b0;
		 psel=1'b1;
		 penable=1'b0;
		 @(negedge pclk);
		 penable=1'b1;
		 @(negedge pclk);
		 penable=1'b0;
		 psel=1'b0;
	 end
 endtask
task inputs;
begin
@(negedge pclk);
recieve_data=1'b0;
tip=1'b1;
ss=1'b0;
miso_data=8'd10;
end
endtask

task input2;
begin
#20;
@(negedge pclk);
recieve_data=1'b1;
tip=1'b1;
ss=1'b1;
miso_data=8'd10;
end
endtask

initial 
begin
	resets;
	inputs;
	write_cr1;
	write_cr2;
	write_br;
	sr;
        write_dr;
	@(negedge pclk);
	input2;
        //inputs;


	#1000 $finish;
end
initial $monitor("paddr=%b,pwdata=%b",paddr,pwdata);
endmodule


