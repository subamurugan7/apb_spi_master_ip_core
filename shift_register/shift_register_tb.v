module shift_register_tb();
	reg PCLK,PRESET,ss,send_data,lsbfe,cpha,cpol,miso_rec_pos,miso_rec_neg,mosi_send_pos,mosi_send_neg;
	reg [7:0] data_mosi;
	reg miso,receive_data;
	wire mosi;
	wire [7:0] data_miso;

	
	reg [1:0] spi_mode;
	reg [2:0] sppr,spr;
	reg sclk,spiswai;

	wire [11:0] BaudRateDivisor;
	wire pre_sclk;
	reg [11:0] count;

	shift_register uut(PCLK,PRESET,ss,send_data,lsbfe,cpha,cpol,miso_rec_pos,miso_rec_neg,mosi_send_pos,mosi_send_neg,data_mosi,miso,receive_data,mosi,data_miso);
	
	always begin
		#10 PCLK=~PCLK;
	end
	assign BaudRateDivisor=(2**(spr+1))*(sppr+1);
	assign pre_sclk=(cpol==1'b1);

	//sclk generation

	always @(posedge PCLK or negedge PRESET) begin
		if(!PRESET) begin
			count<=12'b0;
			sclk<=pre_sclk;
		end
		else begin
			if((!ss)&&(spi_mode==2'b00||(spi_mode==2'b01&&(!spiswai)))) begin
				if(count==((BaudRateDivisor/2)-1'b1)) begin
						sclk <= ~sclk;
						count<=12'b0;
				end
				else begin
					count<=count+1'b1;
				end
			end
			else begin
				sclk<=pre_sclk;
				count<=12'b0;
			end
		end
	end

	// flag generation for miso rescive at posedge or negedge
	
	always @(posedge PCLK or negedge PRESET) begin
		if(!PRESET) begin
			miso_rec_pos<=1'b0;
			miso_rec_neg<=1'b0;
		end

		else begin
			if((!cpha&&cpol)||(!cpol&&cpha)) begin
				if(sclk) begin
					if(count==((BaudRateDivisor/2)-1'b1)) begin
						miso_rec_neg<=1'b1;
					end
					else begin
						miso_rec_neg<=1'b0;
					end
				end
				else begin
					miso_rec_neg<=1'b0;
				end
			end
			else begin
				if(!sclk) begin
					if(count==((BaudRateDivisor/2)-1'b1)) begin
						miso_rec_pos<=1'b1;
					end
					else begin
						miso_rec_pos<=1'b0;
					end
				end
				else begin
					miso_rec_pos<=1'b0;
				end
			end
		end
	end

	//flag generation for mosi send at posedge or negedge
	
	always @(posedge PCLK or negedge PRESET) begin
		if(!PRESET) begin
			mosi_send_pos<=1'b0;
			mosi_send_neg<=1'b0;
		end

		else begin
			if((!cpha&&cpol)||(!cpol&&cpha)) begin
				if(sclk) begin
					if(count==((BaudRateDivisor/2)-2'b10)) begin
						mosi_send_neg<=1'b1;
					end      
					else begin
						mosi_send_neg<=1'b0;
					end
				end
				else begin
					mosi_send_neg<=1'b0;
				end
			end
			else begin
				if(!sclk) begin
					if(count==((BaudRateDivisor/2)-2'b10)) begin
						mosi_send_pos<=1'b1;
					end
					else begin
						mosi_send_pos<=1'b0;
					end
				end
				else begin
					mosi_send_pos<=1'b0;
				end
			end
		end
	end
	
	
	
	task reset; begin
		@(negedge PCLK) PRESET=1'b0;
		@(negedge PCLK) PRESET=1'b1;
	end
	endtask
	
	task initialize; begin
		{PCLK,PRESET,send_data,lsbfe,cpha,cpol,data_mosi,miso,receive_data}=0;
		{sppr,spr,spi_mode,spiswai}=0;
		ss=1'b1;
		
	end
	endtask

	task configure(); begin
		@(negedge PCLK);
		ss=1'b0;
		spr=3'b010;
		sppr=3'b000;
		spi_mode=2'b01;
		spiswai=1'b0;
		cpha=1'b1;
		cpol=1'b0;
		//miso_rec_pos =1;
		//miso_rec_neg = 1;
		//mosi_send_pos =1;
		//mosi_send_neg =1;
		
	end
	endtask
	
	task send_stimulus(input [7:0] data,input lsb); begin
		@(negedge PCLK);
		send_data=1'b1;
		data_mosi=data;
		lsbfe=lsb;
		@(negedge PCLK);
		send_data=1'b0;
	end
	endtask

	task receive_stimulus(input [7:0] data);
	integer i;
	begin
		miso=1'bz;
		wait(!ss)
		for(i=0;i<8;i=i+1) begin
			@(posedge sclk) miso=data[i];
		end
	end
	endtask
	
	initial begin
		initialize;
		reset();
		configure;
		send_stimulus(8'hFA,1'b1);
		receive_data=1'b0;
		receive_stimulus(8'hAA);
		@(negedge sclk);
		receive_data=1'b1;
		@(negedge sclk);
		receive_data=1'b0;
		#500;
		send_stimulus(8'h55,1'b0);
		//receive_data=1'b0;
		receive_stimulus(8'hAA);
		@(negedge sclk);
		receive_data=1'b1;
		@(negedge sclk);
		receive_data=1'b0;
	end

 	initial #5000 $finish;

endmodule