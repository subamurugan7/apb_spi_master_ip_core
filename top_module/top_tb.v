module top_tb();
reg pclk,preset_n,pwrite,psel,penable,miso;
reg[2:0]paddr;
reg [7:0]pwdata;
wire ss,sclk,spi_interrupt_req,pready,pslverr;
wire mosi;
wire[7:0]pr_data;
//integer i;
top dut(pclk,preset_n,paddr,pwrite,psel,penable,pwdata,miso,ss,sclk,spi_interrupt_req,mosi,pr_data,pready,pslverr);
initial 
begin
	pclk=1'b0;
	forever #5 pclk=~pclk;
end
task resets();
	begin
		@(negedge pclk);
		preset_n=1'b0;
		@(negedge pclk);
		preset_n=1'b1;
	end
endtask
task initialize();
	begin
		@(negedge pclk);
		paddr=3'b0;
		pwdata=8'h0;
		psel=1'b0;
		penable=1'b0;
		pwrite=1'b0;
                miso=1'b0;
	end
endtask
task inputs1(input[7:0]data,input[2:0]addr);
	begin
		@(negedge pclk);
		paddr=addr;
		pwdata=data;
		psel=1'b1;
		penable=1'b0;
		pwrite=1'b1;
		@(negedge pclk);
		penable=1'b1;
		wait(!pready)
		@(negedge pclk);
		psel=1'b0;
		penable=1'b0;
	end
endtask
task inputs2();
	begin
		miso=0;
		wait(~ss)
        	begin
			@(negedge sclk);
	        	miso=1'b1;
			@(negedge sclk);
	        	miso=1'b0;

			@(negedge sclk);
	        	miso=1'b1;

			@(negedge sclk);
	        	miso=1'b0;

			@(negedge sclk);
	        	miso=1'b1;

			@(negedge sclk);
	        	miso=1'b0;

			@(negedge sclk);
	        	miso=1'b1;
			@(negedge sclk);
	        	miso=1'b0;
		end




		end
endtask

task read(input[2:0]addr);
	begin
		@(negedge pclk);
		paddr=addr;
		psel=1'b1;
		penable=1'b0;
		pwrite=1'b0;
		@(negedge pclk);
		penable=1'b1;
		wait(!pready)
		@(negedge pclk);
		psel=1'b0;
		penable=1'b0;
	end
endtask
initial 
begin
	resets;
	initialize;
	inputs1(8'b00011101,3'b000); // spi_cr1
   	inputs1(8'b11001000,3'b001);
	inputs1(8'd10010001,3'b010);
   	inputs1(8'd11001101,3'b101);
	inputs2();
        read(3'b000);
	read(3'b001);
	read(3'b010);
	read(3'b101);
	read(3'b011);
	#1000 $stop;
end


initial $monitor("paddr=%b,pwdata=%b",paddr,pwdata);
endmodule





/*

task inputs3(input [7:0]miso_data);
	begin
		miso=0;
		wait(~ss)
		for(i=0;i<7;i=i+1)
		begin
			@(posedge sclk);
			miso=miso_data[i];
			#20;
		end
	end
endtask
*/

	


