module apb_slave_interface (pclk,preset_n,paddr,pwrite,psel,penable,pwdata,ss,miso_data,recieve_data,tip,pr_data,mstr,cpol,cpha,lsbfe,spiswai,sppr,spr,spi_interrupt_req,pready,pslverr,send_data,mosi_data,spi_mode);
input pclk,preset_n,pwrite,psel,penable,ss,recieve_data,tip;
input[2:0]paddr;
input[7:0]pwdata,miso_data;
output mstr,cpol,cpha,lsbfe,spiswai,pready,pslverr;
output reg spi_interrupt_req;
output reg send_data;
output[2:0]sppr,spr;
output reg [7:0]pr_data;
output reg [1:0]spi_mode;
output reg[7:0]mosi_data;
wire wr_enable,rd_enable;
wire sptef,modf,spif,spie,sptie,ssoe,spe,modfen;
wire [7:0]spi_sr;
reg[7:0]spi_cr1,spi_cr2,spi_br,spi_dr;
parameter cr2_mask=8'b00011011;
parameter br_mask=8'b01110111;
parameter idle=3'b011;
  parameter setup=3'b100;
  parameter access=3'b101;
  parameter spi_run=2'b00;
  parameter spi_wait=2'b01;
  parameter spi_stop=2'b10;
  reg[2:0]state,next_state;
  reg [1:0]next_state_spi;
  
//logic for control register1
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		spi_cr1<=8'h04;
	else if(wr_enable)
	begin
		if(paddr==3'b000)
			spi_cr1<=pwdata;
		else
			spi_cr1<=spi_cr1;
	end
	else
		spi_cr1<=spi_cr1;
end

//logic for control register 2
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		spi_cr2<=8'b0;
	else if(wr_enable)
	begin
		if(paddr==3'b001)
			spi_cr2<=(pwdata&cr2_mask);
		else
			spi_cr2<=spi_cr2;
	end
	else 
		spi_cr2<=spi_cr2;
end

//logic for baudrate register
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		spi_br<=8'h00;
	else if(wr_enable)
	begin
		if(paddr==3'b010)
			spi_br<=(pwdata&br_mask);
		else
			spi_br<=spi_br;
	end
	else
		spi_br<=spi_br;
end

// logic for status register
assign spi_sr=preset_n?8'b00100000:{spif,1'b0,sptef,modf,4'b0};


//logic for data register
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		spi_dr<=8'b0;
	else if(wr_enable)
	begin
		if(paddr==3'b101)
			spi_dr<=pwdata;
		else
			spi_dr<=spi_dr;
	end
	else if(!wr_enable)
	begin
		if(((spi_mode==2'b01)||(spi_mode==2'b00))&&(spi_dr!=miso_data)&&(spi_dr==pwdata))
			spi_dr<=8'b0;
		else if(((spi_mode==2'b00)||spi_mode==2'b01)&&recieve_data)
			spi_dr<=miso_data;
		else
			spi_dr<=spi_dr;
	end
end
//logic for send data
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		send_data<=1'b0;
	else if(!wr_enable)
	begin
		if(((spi_mode==2'b01)||(spi_mode==2'b00))&&(spi_dr!=miso_data)&&(spi_dr==pwdata))
			send_data<=1'b1;
		else 
			send_data<=1'b0;
	end
end
//logic for mosi data
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		mosi_data<=8'h0;
	else if(((spi_mode==2'b01)||(spi_mode==2'b00))&&(spi_dr!=miso_data)&&(spi_dr==pwdata))
	   mosi_data<=spi_dr;
   else
	   mosi_data<=mosi_data;
   end
//logic for pr_data
always@(*)
begin
	if(rd_enable)
	begin
		case(paddr)
			3'b000:pr_data=spi_cr1;
			3'b001:pr_data=spi_cr2;
			3'b010:pr_data=spi_br;
			3'b011:pr_data=spi_sr;
			3'b101:pr_data=spi_dr;
			default:pr_data=8'b0;
		endcase
	end
	else
		pr_data=8'b0;
end
//logic for spi interrupt request
always@(posedge pclk or negedge preset_n)
begin
	if(!preset_n)
		spi_interrupt_req <= 1'b0;

	else if((!spie)&&(!sptie))
		spi_interrupt_req <= 1'b0;

	
	else if((!sptie)&& spie)
		spi_interrupt_req<=(spif||modf);

	else if((!spie)&&(sptie))
	 	spi_interrupt_req<=sptef;
			
	else
		spi_interrupt_req<=(spif||modf||sptef);
	

end


// logic for assigns
assign sptef=(spi_dr==8'b0)? 1'b1:1'b0;
assign spif=(spi_dr!=8'b0)? 1'b1:1'b0;
assign modf=((!ss)&&(!ssoe)&& mstr && modfen );
assign spiswai=spi_cr2[1];
assign sppr=spi_br[6:4];
assign spr=spi_br[2:0];
assign ssoe=spi_cr1[1];
assign mstr=spi_cr1[4];
assign cpol=spi_cr1[3];
assign cpha=spi_cr1[2];
assign lsbfe=spi_cr1[0];
assign spie=spi_cr1[7];
assign spe=spi_cr1[6];
assign sptie=spi_cr1[5];
assign modfen=spi_cr2[4];
assign pslverr=(state==access)?(~tip):1'b0;
assign pready=(state==access)?1'b1:1'b0;
assign wr_enable=((pwrite)&&(state==access))?1'b1:1'b0;
assign rd_enable=((~pwrite)&&(state==access))?1'b1:1'b0;


//logic for apb slave inrterface

 always@(posedge pclk or negedge preset_n)
 begin
	 if(!preset_n)
		 state<=idle;
	 else
		 state<=next_state;
 end
always@(*)
begin
	case(state)
		idle:begin
			if(psel&&!penable)
				next_state=setup;
			else
				next_state=idle;
		end
		setup :
		begin
			if(psel&&penable)
				next_state=access;
			else
				next_state=setup;
		end
		access:
		begin
			if(psel)
				next_state=setup;
			else
				next_state=idle;
		end
		default next_state=idle;
	endcase
end
//logic for spi mode
 always@(posedge pclk or negedge preset_n )
 begin
	 if(!preset_n)
		 spi_mode<=spi_run;
	 else
		 spi_mode<=next_state_spi;
 end
always@(*)
begin
	case(spi_mode)
		spi_run:begin
			if(!spe)
				next_state_spi=spi_wait;
			else
				next_state_spi=spi_run;
		end
		spi_wait:
		begin
			
			if(spiswai)
				next_state_spi=spi_stop;
			else
				next_state_spi=spi_wait;
		end
		spi_stop:
		begin
			if(!spiswai)
				next_state_spi=spi_wait;
			else if(spe)
				next_state_spi=spi_run;
			else
				next_state_spi=spi_stop;
		end
		default :
		       	next_state_spi=spi_stop;
	endcase
end
endmodule




