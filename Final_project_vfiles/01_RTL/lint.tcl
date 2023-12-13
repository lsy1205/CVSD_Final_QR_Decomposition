read_file -type verilog {flist.v}
set_option top QR_Engine
current_goal Design_Read -top QR_Engine
current_goal lint/lint_rtl -top QR_Engine
run_goal
capture ./spyglass-1/QR_Engine/lint/lint_rtl/spyglass_reports/spyglass_violations.rpt {write_report spyglass_violations}
current_goal lint/lint_rtl_enhanced -top QR_Engine
set_goal_option ignorerule W164b
run_goal
capture ./spyglass-1/QR_Engine/lint/lint_rtl_enhanced/spyglass_reports/spyglass_violations.rpt {write_report spyglass_violations}

exit -force