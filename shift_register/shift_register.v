module shift_register(pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_rec_pos,miso_rec_neg,mosi_send_pos,mosi_send_neg,data_mosi,miso,receive_data,mosi,data_miso);
	input pclk,preset_n,ss,send_data,lsbfe,cpha,cpol,miso_rec_pos,miso_rec_neg,mosi_send_pos,mosi_send_neg,miso,receive_data;
	input [7:0] data_mosi;
	output reg mosi;
	output [7:0] data_miso;
	
	reg [7:0] shif_reg,temp_reg;
	reg [2:0] count0,count1,count2,count3;
	
	assign data_miso=(receive_data)?temp_reg:8'h0;
	
	always @(posedge pclk, negedge preset_n) begin
		if(!preset_n) begin
			shif_reg<=8'b0;
		end
		else begin
			if(send_data) begin
				shif_reg<=data_mosi;
			end
			else begin
				shif_reg<=shif_reg;
			end
		end
	end
	
	always @(posedge pclk, negedge preset_n) begin
		if(! preset_n) begin
			mosi<=1'b0;
			count0<=3'd0;
			count1<=3'd7;
		end
		else begin
			if(ss) begin
				mosi<=mosi;
				count0<=count0;
				count1<=count1;
			end
			else begin
				if((!cpha&&cpol)||(!cpol&&cpha)) begin
					if(lsbfe) begin
						if(count0<=3'd7) begin
							if(mosi_send_neg) begin
								mosi<=shif_reg[count0];
								count0<=count0+1'b1;
							end
							else begin
								count0<=count0;
							end
						end
						else begin
							count0<=3'd0;
						end
					end
					else begin
						if(count1>=3'd0) begin
							if(mosi_send_neg) begin
								mosi<=shif_reg[count1];
								count1<=count1-1'b1;
							end
							else begin
								count1<=count1;
							end
						end
						else begin
							count1<=3'd7;
						end
					end
				end
				else begin
					if(lsbfe) begin
						if(count0<=3'd7) begin
							if(mosi_send_pos) begin
								mosi<=shif_reg[count0];
								count0<=count0+1'b1;
							end
							else begin
								count0<=count0;
							end
						end
						else begin
							count0<=3'd0;
						end
					end
					else begin
						if(count1>=3'd0) begin
							if(mosi_send_pos) begin
								mosi<=shif_reg[count1];
								count1<=count1-1'b1;
							end
							else begin
								count1<=count1;
							end
						end
						else begin
							count1<=3'd7;
						end
					end
				end
			end
		end
	end
	
	always @(posedge pclk, negedge preset_n) begin
		if(!preset_n) begin
			temp_reg<=8'b0;
			count2<=3'd0;
			count3<=3'd7;
		end
		else begin
			if(ss) begin
				temp_reg<=temp_reg;
				count2<=count2;
				count3<=count3;
			end
			else begin
				if((!cpha&&cpol)||(!cpol&&cpha)) begin
					if(lsbfe) begin
						if(count2<=3'd7) begin
							if(miso_rec_neg) begin
								temp_reg[count2]<=miso;
								count2<=count2+1'b1;
							end
							else begin
								count2<=count2;
							end
						end
						else begin
							count2<=3'd0;
						end
					end
					else begin
						if(count3>=3'd0) begin
							if(miso_rec_neg) begin
								temp_reg[count3]<=miso;
								count3<=count3-1'b1;
							end
							else begin
								count3<=count3;
							end
						end
						else begin
							count3<=3'd7;
						end
					end
				end
				else begin
					if(lsbfe) begin
						if(count2<=3'd7) begin
							if(miso_rec_pos) begin
								temp_reg[count2]<=miso;
								count2<=count2+1'b1;
							end
							else begin
								count2<=count2;
							end
						end
						else begin
							count2<=3'd0;
						end
					end
					else begin
						if(count3>=3'd0) begin
							if(miso_rec_pos) begin
								temp_reg[count3]<=miso;
								count3<=count3-1'b1;
							end
							else begin
								count3<=count3;
							end
						end
						else begin
							count3<=3'd7;
						end
					end
				end
			end
		end
	end
	
endmodule


  
    
    
  

 
