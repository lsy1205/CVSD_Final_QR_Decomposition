## PrimeTime Script
set power_enable_analysis TRUE
set power_analysis_mode time_based
set power_clock_network_include_register_clock_pin_power false
set CYCLE 5.0

read_file -format verilog  ../02_SYN/Netlist/QR_Engine_syn.v
current_design QR_Engine
link

# ===== modified to your max clock freq ===== #
create_clock -period $CYCLE [get_ports i_clk]
set_propagated_clock        [get_clock i_clk]
# ===== active window ===== #
read_fsdb  -strip_path testfixture/u_dut ../03_GATE/testfixture.fsdb

update_power
report_power 
report_power -verbose > try_active.power

# exit
