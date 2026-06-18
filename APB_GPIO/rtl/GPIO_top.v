module GPIO_top(input PCLK,
								PRESET,
								PSEL,
								PENABLE,
								PWRITE,
								ext_clk_pad_i,
					input 	[31:0] PWDATA,PADDR,aux_in,
					
					output 	PREADY,
								IRQ,
					output	[31:0] PRDATA,
					inout		[31:0] io_pad);
					
	wire [4:0] w;
	wire [31:0] ww [6:0];

	apb_slave_interface apb_dut(.PCLK(PCLK),
											.PRESET(PRESET),
											.PSEL(PSEL),
											.PENABLE(PENABLE),
											.PWRITE(PWRITE),
											.gpio_inta_o(w[3]),
											.PWDATA(PWDATA),
											.gpio_dat_o(ww[0]),
											.PADDR(PADDR),
									
											.PREADY(PREADY),
											.IRQ(IRQ),
											.sys_clk(w[0]),
											.sys_rst(w[1]),
											.gpio_we(w[2]),
											.PRDATA(PRDATA),
											.gpio_dat_i(ww[1]),
											.gpio_addr(ww[2]));
											
	Auxiliary_Interface aux_dut(.sys_clk(w[0]),
											.sys_rst(w[1]),
											.aux_in(aux_in),
											.aux_i(ww[3]));
											
	GPIO_Registers GPIOreg_dut(.sys_clk(w[0]),
											.sys_rst(w[1]),
											.gpio_we(w[2]),
											.gpio_eclk(w[4]),
											.gpio_addr(ww[2]),
											.gpio_dat_i(ww[1]), 
											.aux_i(ww[3]), 
											.in_pad_i(ww[4]),
											.gpio_dat_o(ww[0]), 
											.out_pad_o(ww[5]), 
											.oen_padoe_o(ww[6]), 
											.gpio_inta_o(w[3]));
											
	IO_Interface 			IO_dut(	.out_pad_o(ww[5]), 
											.oen_padoe_o(ww[6]),
											.ext_clk_pad_i(ext_clk_pad_i),
											.gpio_eclk(w[4]),
											.in_pad_i(ww[4]),
											.io_pad(io_pad));									
	
endmodule
