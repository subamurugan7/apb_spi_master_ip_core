module slave_select_control(input pclk,preset_n,mstr,spiswai,
			input [1:0]spi_mode,
			input send_data,
			input [11:0]baud_rate_divisor,
			output reg receive_data,ss,
			output tip);
wire [15:0]target;
reg [15:0]count;
reg rcv;
parameter RUN=2'b00,
	WAIT=2'b01;
assign target = 8 * baud_rate_divisor;
assign tip = ~ss;
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
	begin
		count<=16'hffff;
		ss<=1'b1;
		rcv<=1'b0;
	end
	else if(mstr && !spiswai &&  (spi_mode==RUN || spi_mode==WAIT))
	begin
		if(send_data)
		begin
			ss<=0;
			count<=16'h0000;
                        rcv<=0;   
		end
		else if(count<target-1)
		begin
			ss<=0;
			count<=count+1;
		end
		else if(count==target-1)
		begin
			rcv<=1;
			ss<=1;
			count<=16'hffff;
		end
		else if(count>target)
		begin
			rcv<=0;
		end
		else
		begin
			ss<=1'b1;
			rcv<=0;
			count<=16'hffff;
		end
	end
	else
	begin
		ss<=1;
		rcv<=0;
		count<=16'hffff;
	end
end
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
	begin
		receive_data<=0;
	end
	else
	begin
		receive_data<=rcv;
	end
end
endmodule


   

