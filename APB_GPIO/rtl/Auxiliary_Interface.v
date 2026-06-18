module Auxiliary_Interface(input sys_clk,
											sys_rst,
									input [31:0] aux_in,
									output reg [31:0] aux_i);
									
	always@(posedge sys_clk or posedge sys_rst)
	begin
		if(sys_rst)
			aux_i<=32'b0;
		else
			aux_i<=aux_in;
	end

endmodule
