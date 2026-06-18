module IO_Interface(	input		[31:0] out_pad_o, oen_padoe_o,
							input		ext_clk_pad_i,
							output 	gpio_eclk,
							output	[31:0] in_pad_i,
							inout		[31:0] io_pad);
	genvar i;
	generate
		for(i=0;i<32;i=i+1)
		begin:ioio
			assign io_pad[i] = oen_padoe_o[i]? out_pad_o[i]:1'bz;
		end
	endgenerate

	assign in_pad_i = io_pad;
	assign gpio_eclk = ext_clk_pad_i;
	
endmodule
