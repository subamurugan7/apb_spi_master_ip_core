module slave_select_control_tb();
reg pclk,preset_n,mstr,spiswai;
reg [1:0]spi_mode;
reg send_data;
reg [11:0]baud_rate_divisor;
wire receive_data,ss,tip;
slave_select_control DUT(pclk,preset_n,mstr,spiswai,spi_mode,send_data,baud_rate_divisor,receive_data,ss,tip);
always #5 pclk=~pclk;
task initialize;
	begin
		pclk=0;
		preset_n=1;
		mstr=0;
		spiswai=1;
		send_data=0;
	end
endtask
task preset;
	begin
		@(posedge pclk)
		preset_n=1'b0;
		@(posedge pclk)
		preset_n=1'b1;
	end
endtask
initial
begin
	initialize;
	preset;
	mstr=1;
	spiswai=0;
	spi_mode=2'b00;
	send_data=1;
	baud_rate_divisor=12'd8;
	@(posedge pclk);
	send_data=0;
	#800 $finish;
end
initial
begin
	$monitor("pclk=%b,preset_n=%b,mstr=%b,spiswai=%b,spi_mode=%b,send_data=%b,baud_rate_divisor=%b,receive_data=%b,ss=%b,tip=%b",pclk,preset_n,mstr,spiswai,spi_mode,send_data,baud_rate_divisor,receive_data,ss,tip);
end
endmodule
