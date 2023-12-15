set hdlin_translate_off_skip_text "TRUE"
set edifout_netlist_only "TRUE"
set verilogout_no_tri true
set plot_command {lpr -Plw}
set hdlin_auto_save_templates "TRUE"
set compile_fix_multiple_port_nets "TRUE"

set DESIGN "QR_Engine"
set CLOCK "i_clk"
set CLOCK_PERIOD 4.5

sh rm -rf Netlist
sh rm -rf Report
sh mkdir Netlist
sh mkdir Report

read_file -format verilog ./filelist.v
current_design $DESIGN
link

create_clock $CLOCK -period $CLOCK_PERIOD
set_ideal_network -no_propagate $CLOCK
set_dont_touch_network [get_ports $CLOCK]

# ========== Do not modified block ================= #
set_clock_uncertainty  0.1  $CLOCK
set_input_delay  1.0 -clock $CLOCK [remove_from_collection [all_inputs] [get_ports $CLOCK]]
set_output_delay 1.0 -clock $CLOCK [all_outputs]
set_drive 1    [all_inputs]
set_load  0.05 [all_outputs]
set_max_fanout 8 [current_design]

set_operating_conditions -max_library slow -max slow
set_wire_load_model -name tsmc13_wl10 -library slow
# =================================================== #
check_design > Report/check_design.txt
check_timing > Report/check_timing.txt

# Clock Gating
set_clock_gating_style \
    -max_fanout 4 \
    -pos integrated \
    -control_point before \
    -control_signal scan_enable

uniquify
set_fix_multiple_port_nets -all -buffer_constants  [get_designs *]
set_fix_hold [all_clocks]

compile_ultra -gate_clock

report_area > Report/$DESIGN\.area
report_power > Report/$DESIGN\.power
report_timing -max_path 20 -delay_type max > Report/$DESIGN\.max.timing
report_timing -max_path 20 -delay_type min > Report/$DESIGN\.min.timing

report_clock_gating -gating_elements > "./Report/${DESIGN}_syn.gating_elements"
report_clock_gating -ungated > "./Report/${DESIGN}_syn.ungated"

set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive

write -format verilog -hierarchy -output Netlist/$DESIGN\_syn.v
write_sdf -version 2.1 -context verilog Netlist/$DESIGN\_syn.sdf
write_sdc Netlist/$DESIGN\_syn.sdc
