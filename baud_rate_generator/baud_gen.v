module baud_gen(pclk,preset_n,spi_mode,spiswai,sppr,spr,cpol,cpha,ss,sclk,miso_rcv_pos,miso_rcv_neg,mosi_snd_pos,mosi_snd_neg,baud_rate_divisor);

	// input declaration
	input pclk,preset_n,ss,spiswai,cpol,cpha;
	input [1:0]spi_mode;
	input [2:0]sppr,spr;
	
	// output declaration 
	output reg sclk,miso_rcv_pos,miso_rcv_neg,mosi_snd_pos,mosi_snd_neg;
	output [11:0]baud_rate_divisor;
	
	// idle state sclk and count for sclk postive cycle and negative cycle 
	wire pre_sclk;
	reg [11:0]count;
	
	// generating inital state of sclk
	//default making cpol value 1 for making  idle state of sclk is high.
	assign pre_sclk=(cpol==1'b1);
	
	//baud_rate_divisor formula =(sppr+1)*2^(spr+1)
	// max value is sppr=111 ;spr=111 ; baud_rate divisor max=2048(12 bits)
	assign baud_rate_divisor=(sppr+1)*2**(spr+1);
	
	// generating sclk 
	// sclk=pclk/baud_rate_divisor
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			begin 
				sclk<=pre_sclk;
				count<=12'b0;
			end
		else 
			begin
				if(!ss && !spiswai && ((spi_mode==2'b00) || (spi_mode==2'b01)))
					begin
						if(count==(baud_rate_divisor/2)-1'b1)
							begin
								sclk<=~sclk;
								count<=12'b0;
							end
						else
							begin
								count<=count+1'b1;
							end
					end
				else 
					begin
						sclk<=pre_sclk;
						count<=12'b0;
					end	
			end
	end
	
	// generation of miso flags 
	// miso_rcv_pos and miso_rcv_neg logic generation logic this flags are occuring based upon cpol and cpha (occurs at same edge of sclk)
	always@(posedge pclk or negedge preset_n)
	begin
		if(!preset_n)
			begin
				miso_rcv_pos<=1'b0;
				miso_rcv_neg<=1'b0;
			end
		else 
			begin 
				if((!cpol&&cpha)||(cpol&&!cpha)) // for miso_recieve_negedge_flag
					begin
						if(sclk)
							begin
								if(count==((baud_rate_divisor/2)-1)) begin
									miso_rcv_neg<=1'b1;
									end
								else begin
									miso_rcv_neg<=1'b0;
									end
							end
						else begin
								miso_rcv_neg<=1'b0;
							end
					end
				else // for miso_recieve_posedge flag
					begin 
						if(!sclk)
							begin
								if(count==(baud_rate_divisor/2)-1)
									miso_rcv_pos<=1'b1;
								else 
									miso_rcv_pos<=1'b0;
							end
						else 
								miso_rcv_pos<=1'b0;
					end
			end
	end
	
	// generatings mosi flags 
	//mosi_snd_neg and mosi_snd_pos flags generated based on cpol and cpha logic (same as miso but one clk before sclk)
	always@(posedge pclk or negedge preset_n)
		begin 
			if(!preset_n)
				begin 
					mosi_snd_pos<=1'b0;
					mosi_snd_neg<=1'b0;
				end
			else
				begin 
					if((!cpol&&cpha)||(cpol&&!cpha)) // for mosi_send_negedge flags 
						begin 
							if(sclk)
								begin
									if(count==(baud_rate_divisor/2)-2)
										mosi_snd_neg<=1'b1;
									else
										mosi_snd_neg<=1'b0;
								end
							else 
								mosi_snd_neg<=1'b0;
						end
					else 
						begin 
							if(!sclk)
								begin
									if(count==(baud_rate_divisor/2)-2)
										mosi_snd_pos<=1'b1;
									else
										mosi_snd_pos<=1'b0;
								end
							else 
								mosi_snd_pos<=1'b0;
						end
				end
		end
		
endmodule							
