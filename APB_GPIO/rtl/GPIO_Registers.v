`define RGPIO_IN 32'h00
`define RGPIO_OUT 32'h04
`define RGPIO_OE 32'h08
`define RGPIO_INTE 32'h0C
`define RGPIO_PTRIG 32'h10
`define RGPIO_AUX 32'h14
`define RGPIO_CTRL 32'h18
`define RGPIO_INTS 32'h1C
`define RGPIO_ECLK 32'h20
`define RGPIO_NEC 32'h24
`define RGPIO_CTRL_INTE 0
`define RGPIO_CTRL_INTS 1

module GPIO_Registers(input 		sys_clk,
											sys_rst,
											gpio_we,
											gpio_eclk,
								input		[31:0] gpio_addr,
								input		[31:0] gpio_dat_i, aux_i, in_pad_i,
								output 	reg [31:0] gpio_dat_o, 
								output	[31:0] out_pad_o, oen_padoe_o, 
								output	gpio_inta_o);
	reg [31:0] rgpio_in;
	reg [31:0] rgpio_out;
	reg [31:0] rgpio_oe;
	reg [31:0] rgpio_inte;
	reg [31:0] rgpio_ptrig;
	reg [31:0] rgpio_aux;
	reg [1:0] rgpio_ctrl;
	reg [31:0] rgpio_ints;
	reg [31:0] rgpio_eclk;
	reg [31:0] rgpio_nec;
	reg [31:0] dat_reg;
	
	
	
	wire [31:0] in_muxed;
	wire [31:0] extc_in;
	reg [31:0] pextc_sampled;
	reg [31:0] nextc_sampled;
	
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_ctrl<=2'b0;
		else if((gpio_addr==`RGPIO_CTRL) && gpio_we)
			rgpio_ctrl<=gpio_dat_i[1:0];
		else if(rgpio_ctrl[`RGPIO_CTRL_INTE])
			rgpio_ctrl[`RGPIO_CTRL_INTS]<=rgpio_ctrl[`RGPIO_CTRL_INTS]|gpio_inta_o;
			

	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_out<=32'b0;
		else if((gpio_addr==`RGPIO_OUT) && gpio_we)
			rgpio_out<=gpio_dat_i[31:0];
		else
			rgpio_out<=rgpio_out;

	
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_oe<=32'b0;
		else if((gpio_addr==`RGPIO_OE) && gpio_we)
			rgpio_oe<=gpio_dat_i[31:0];


	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_inte<=32'b0;
		else if((gpio_addr==`RGPIO_INTE) && gpio_we)
			rgpio_inte<=gpio_dat_i[31:0];	
			
			
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_ptrig<=32'b0;
		else if((gpio_addr==`RGPIO_PTRIG) && gpio_we)
			rgpio_ptrig<=gpio_dat_i[31:0];
			

	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_aux<=32'b0;
		else if((gpio_addr==`RGPIO_AUX) && gpio_we)
			rgpio_aux<=gpio_dat_i[31:0];
			
	
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_eclk<=32'b0;
		else if((gpio_addr==`RGPIO_ECLK) && gpio_we)
			rgpio_eclk<=gpio_dat_i[31:0];
			
			
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_nec<=32'b0;
		else if((gpio_addr==`RGPIO_NEC) && gpio_we)
			rgpio_nec<=gpio_dat_i[31:0];

	
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_in<=32'b0;
		else
			rgpio_in<=in_muxed;
			
	
	assign in_muxed=(rgpio_eclk & extc_in)|(~rgpio_eclk & in_pad_i);
	assign extc_in=(rgpio_nec & pextc_sampled)|(~rgpio_nec & nextc_sampled);
	
	
	always@(posedge gpio_eclk or posedge sys_rst)
		if(sys_rst)
			pextc_sampled<=32'b0;
		else
			pextc_sampled<=in_pad_i;
			
			
	always@(negedge gpio_eclk or posedge sys_rst)
		if(sys_rst)
			nextc_sampled<=32'b0;
		else
			nextc_sampled<=in_pad_i;
			
	always@(*)
	begin
		case(gpio_addr)
			`RGPIO_IN:		dat_reg=rgpio_in; 
			`RGPIO_OUT:		dat_reg=rgpio_out; 
			`RGPIO_OE:		dat_reg=rgpio_oe; 
			`RGPIO_INTE:	dat_reg=rgpio_inte; 
			`RGPIO_PTRIG:	dat_reg=rgpio_ptrig; 
			`RGPIO_AUX:		dat_reg=rgpio_aux; 
			`RGPIO_CTRL:	begin
									dat_reg[1:0]=rgpio_ctrl;
									dat_reg[31:2]=30'b0;
								end
			`RGPIO_INTS:	dat_reg=rgpio_ints; 
			`RGPIO_ECLK:	dat_reg=rgpio_eclk; 
			`RGPIO_NEC:		dat_reg=rgpio_nec; 
			default:			dat_reg=rgpio_in;
		endcase
	end
	
	
	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			gpio_dat_o<=32'b0;
		else
			gpio_dat_o<=dat_reg;
			

	always@(posedge sys_clk or posedge sys_rst)
		if(sys_rst)
			rgpio_ints<=32'b0;
		else if((gpio_addr==`RGPIO_INTS) && gpio_we)
			rgpio_ints<=gpio_dat_i[1:0];
		else if(rgpio_ctrl[`RGPIO_CTRL_INTE])
			rgpio_ints<=(rgpio_ints|((in_muxed^rgpio_in) & ~(in_muxed^rgpio_ptrig)) & rgpio_inte);

	
	assign gpio_inta_o= |rgpio_ints ? rgpio_ctrl[`RGPIO_CTRL_INTE]:1'b0;
	assign oen_padoe_o= rgpio_oe;
	assign out_pad_o	= rgpio_out & ~rgpio_aux | aux_i & rgpio_aux;



endmodule
