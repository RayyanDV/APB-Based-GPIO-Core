#Liberty files are needed for logical and physical netlist designs
set search_path "./"
set link_library " "

set_app_var enable_lint true

configure_lint_setup -goal lint_rtl

analyze -verbose -format verilog "../rtl/apb_slave_interface.v ../rtl/Auxiliary_Interface.v ../rtl/GPIO_Registers.v ../rtl/IO_Interface.v ../rtl/GPIO_top.v"

elaborate GPIO_top

check_lint

report_lint -verbose -file report_lint_gpio.txt
