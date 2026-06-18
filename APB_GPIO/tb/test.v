`timescale 1ns / 1ps

module test;

	// Inputs
	reg PCLK;
	reg PRESET;
	reg PSEL;
	reg PENABLE;
	reg PWRITE;
	reg ext_clk_pad_i;
	reg [31:0] PWDATA;
	reg [31:0] PADDR;
	reg [31:0] aux_in;

	// Outputs
	wire PREADY;
	wire IRQ;
	wire [31:0] PRDATA;

	// Bidirs
	wire [31:0] io_pad;
	
	
	reg io_dir=1'b1;
	reg [31:0] temp=32'bz;

	// Instantiate the Unit Under Test (UUT)
	GPIO_top uut (
		.PCLK(PCLK),
		.PRESET(PRESET),
		.PSEL(PSEL),
		.PENABLE(PENABLE),
		.PWRITE(PWRITE),
		.ext_clk_pad_i(ext_clk_pad_i),
		.PWDATA(PWDATA),
		.PADDR(PADDR),
		.aux_in(aux_in),
		.PREADY(PREADY),
		.IRQ(IRQ),
		.PRDATA(PRDATA),
		.io_pad(io_pad)
	);
	
	always
		#2 PCLK=~PCLK;
	always
		#4 ext_clk_pad_i=~ext_clk_pad_i;
		
	task initialize;
	begin
		PCLK = 0;
		PRESET = 0;
		PSEL = 0;
		PENABLE = 0;
		PWRITE = 0;
		PWDATA = 32'b0;
		PADDR = 32'b0;
		aux_in = 32'b0;
		ext_clk_pad_i = 0;
		#8;
	end
	endtask
	
	task rst;
	begin
		@(negedge PCLK)
		PRESET=1'b1;
		#8;
		PRESET=1'b0;
	end
	endtask
	
	task auxx(input [31:0] auxer);
	begin
		@(negedge PCLK)
		aux_in=auxer;
	end
	endtask
	
	task write(input [31:0] addr,input [31:0] data);
	begin
		@(negedge PCLK)
		PWRITE=1'b1;
		PSEL = 1'b1;
		PENABLE = 1'b0;
		PWDATA = data;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b1;
		PSEL = 1'b1;
		PENABLE = 1'b1;
		PWDATA = data;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b1;
		PSEL = 1'b1;
		PENABLE = 1'b0;
		PWDATA = data;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b0;
		PSEL = 1'b0;
		PENABLE = 1'b0;
		PWDATA = data;
		PADDR = addr;
	end
	endtask
	
	task read(input [31:0] addr);
	begin
		@(negedge PCLK)
		PWRITE=1'b0;
		PSEL = 1'b1;
		PENABLE = 1'b0;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b0;
		PSEL = 1'b1;
		PENABLE = 1'b1;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b0;
		PSEL = 1'b1;
		PENABLE = 1'b0;
		PADDR = addr;
		@(negedge PCLK)
		PWRITE=1'b0;
		PSEL = 1'b0;
		PENABLE = 1'b0;
		PADDR = addr;
	end
	endtask
	
	task io_in(input [31:0] in_temp);
	begin
		io_dir=1'b0;
		temp=in_temp;
	end
	endtask
	
	task io_out;
	begin
		io_dir=1'b1;
	end
	endtask
	
	initial 
	begin
		initialize;
		rst;
		
		// as output
		io_out;
		write(32'h08,32'hffffffff);
		write(32'h04,32'h56781234);
		write(32'h0c,32'h0);
		write(32'h08,32'h0);


		//as aux input
		io_out;
		write(32'h08,32'hffffffff);
		write(32'h14,32'hffffffff);
		auxx(32'hf7f6f504);
		write(32'h14,32'h0);
		
		io_out;
		write(32'h08,32'hffffffff);
		write(32'h14,32'hffffffff);
		auxx(32'hffffffff);
		write(32'h14,32'h0);

		io_out;
		write(32'h08,32'hffffffff);
		write(32'h14,32'hffffffff);
		auxx(32'h00000000);
		write(32'h14,32'h0);

		
		// polled input
		
		io_in(32'h12345678);
		write(32'h08,32'h0);
		write(32'h18,32'h0);
		write(32'h0c,32'h0);
		write(32'h20,32'h0);
		read(32'h0);
		
		io_in(32'hffffffff);
		write(32'h08,32'h0);
		write(32'h18,32'h0);
		write(32'h0c,32'h0);
		write(32'h20,32'h0);
		read(32'h0);

				
		io_in(32'h00000000);
		write(32'h08,32'h0);
		write(32'h18,32'h0);
		write(32'h0c,32'h0);
		write(32'h20,32'h0);
		read(32'h0);
		
		
		// bidirectional
		io_out;
		write(32'h0c,32'h0);
		write(32'h20,32'h0);
		write(32'h04,32'h10203040);
		write(32'h08,32'hf0f0f0f0);
		io_in(32'hz5z1z0z9);
		read(32'h0);
		
		// input with interrupt
		io_in(32'h0000ffff);
		write(32'h08,32'h0);
		write(32'h18,2'b01);
		write(32'h0c,32'hffffffff);
		write(32'h10,32'hffff0000);
		write(32'h1c,32'h0);
		write(32'h20,32'h0);
		io_in(32'h87654321);
		read(32'h1c);
		wait(IRQ)
		read(32'h0);
		write(32'h1c,32'h0);
		
		
		// polled input with eclk
		write(32'h08,32'h0);
		write(32'h18,32'h0);
		write(32'h0c,32'h0);
		write(32'h24,32'h0000f0f0);
		write(32'h20,32'h0000ffff);
		io_in(32'h12345678);
		read(32'h0);

		// input w interrupt with eclk
		write(32'h08,32'h0);
		write(32'h0c,32'hffffffff);
		write(32'h10,32'hffff0000);
		write(32'h1c,32'h0);
		write(32'h18,2'b01);
		write(32'h24,32'h0000f0f0);
		write(32'h20,32'h0000ffff);
		io_in(32'h87654321);
		read(32'h1c);
		wait(IRQ)
		read(32'h0);
		write(32'h1c,32'h0);
		
		// bidirectional i/o with eclk
		write(32'h0c,32'h0);
		write(32'h04,32'h10203040);
		write(32'h08,32'hf0f0f0f0);
		write(32'h24,32'h0f0ff0f0);
		write(32'h20,32'h0f0f0f0f);
		io_out;
		io_in(32'hz4z5z6z7);
		read(32'h0);
		
		//Extra test cases to boost FSM Coverage 

		@(negedge PCLK)
		PSEL = 1'b0;
		PENABLE = 1'b0;

		@(negedge PCLK)
		PSEL = 1'b1;
		PENABLE = 1'b0;

		@(negedge PCLK)
		PSEL = 1'b1;
		PENABLE = 1'b1;

		@(negedge PCLK)
		PSEL = 1'b0;
		PENABLE = 1'b0;



		#100;
		$finish;
		
	end
	
	assign io_pad=io_dir?32'bz:temp;
      
endmodule

