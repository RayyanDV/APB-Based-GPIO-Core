module apb_slave_interface(input PCLK,
											PRESET,
											PSEL,
											PENABLE,
											PWRITE,
											gpio_inta_o,
									input 	[31:0] PWDATA, gpio_dat_o,
									input		[31:0] PADDR,
									
									output PREADY,
											IRQ,
											sys_clk,
											sys_rst,
											gpio_we,
									output	[31:0] PRDATA, gpio_dat_i,
									output	[31:0] gpio_addr);
	parameter IDLE=2'd0;
	parameter SETUP=2'd1;
	parameter ENABLE=2'd2;
	reg [1:0] present,next;
	reg [31:0] wdata,rdata;
	reg we;
	
	always@(posedge PCLK or posedge PRESET)	//prsent state logic
	begin
		if(PRESET)
			present<=IDLE;
		else
			present<=next;
	end

	always@(PSEL or PENABLE or present)	//next state logic
	begin
		next<=IDLE;
		case(present)
			IDLE:	 	case({PSEL,PENABLE})
							2'b01:	next<=IDLE;
							2'b10:	next<=SETUP;
							default: next<=IDLE;		//doubtful
						endcase
					 
			SETUP: 	case({PSEL,PENABLE})
							2'b10:	next<=SETUP;
							2'b11:	next<=ENABLE;
							default: next<=IDLE;		//doubtful
						endcase
						
			ENABLE:	case(PSEL)
							1'b0:	next<=IDLE;
							1'b1:	next<=SETUP;
							default: next<=IDLE;		//doubtful							
						endcase
			default:	next<=IDLE;						//doubtful
		endcase
	end
	
	assign PREADY=(present==IDLE && PRESET) || (present==ENABLE);
	assign IRQ=gpio_inta_o;
	assign gpio_addr=PADDR;
	assign sys_rst=PRESET;
	assign sys_clk=PCLK;
	
	always@(present or PWRITE or gpio_dat_o or PWDATA)	//PRDATA, gpio_we, gpio_dat_i logic
	begin
		case({present,PWRITE})
			{~ENABLE,1'b0}:	begin
										rdata<=32'b0;
										we<=1'b0;
										wdata<=32'b0;
									end
			{~ENABLE,1'b1}: 	begin
										rdata<=32'b0;
										we<=1'b0;
										wdata<=32'b0;
									end
			{ENABLE,1'b0}: 	begin
										rdata<=gpio_dat_o;
										we<=1'b0;
										wdata<=32'b0;
									end
			{ENABLE,1'b1}: 	begin
										rdata<=32'b0;
										we<=1'b1;
										wdata<=PWDATA;
									end
			default:				begin
										rdata<=32'b0;	//doubtful
										we<=1'b0;		//doubtful
										wdata<=32'b0;	//doubtful
									end
		endcase
	end
	assign PRDATA=rdata;
	assign gpio_we=we;
	assign gpio_dat_i=wdata;
	

endmodule
