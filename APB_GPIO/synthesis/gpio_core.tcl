remove_design -all

set search_path {/home/cad/eda/SYNOPSYS/Design_Compiler/syn/T-2022.03-SP4/libraries/syn}

set target_library {lsi_10k.db}

set link_library "* lsi_10k.db"

analyze -format verilog {../rtl/apb_slave_interface.v ../rtl/Auxiliary_Interface.v 
			../rtl/GPIO_Registers.v ../rtl/IO_Interface.v ../rtl/GPIO_top.v}
	
elaborate GPIO_top

link

check_design

current_design GPIO_top

compile_ultra -no_autoungroup

report_area > area.rpt

write_file -f verilog -hier -output gpio_core_netlist.v
