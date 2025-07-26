# ==============================================================================
# file:    [T.tcl]
# author:  [cjy]
# created: [2025-06-13]
# lastest: [2025-06-13]
# version: [1.0.0]
# about:   [this file is to contold the initial constrain for subdeisgn T]
# ==============================================================================
# We already have:
# set FLOW_DESIGN_NAME aes_128;
# set FLOW_TAG test;
# set FLOW_DEBUG true;
# set FLOW_SCRIPTS_DIR /home/cym/prj/aes/aes-with-flow/flow_control/scripts;
# set FLOW_STEP_NAME syn;
# set FLOW_PREDECESSOR_DIR ../global_input;

# set FLOW_STEP_DIR results/syn_test;
# set FLOW_STEP_OUTPUT_DIR results/syn_test/output_syn;
# set FLOW_STEP_LOG_DIR results/syn_test/log;
# set FLOW_STEP_REPORTS_DIR results/syn_test/reports;
# set FLOW_STEP_BUFFER_DIR results/syn_test/intermedia;

puts ">>> INFO: Running T.tcl"
current_design T
reset_design
set rpt_file "initial_T.rpt"
set design "T"
source ${WORK_SCRIPTS_DIR}/syn_default.tcl
# source "${FLOW_SCRIPTS_DIR}/default.con"

# Define design environment
set ALL_INP_EXC_CLK [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set ALL_INP_EXC_CLK [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set MAX_INPUT_LOAD [expr {[load_of $CORNER_LIB_NAME/AND2V1_8TR40/A1]} * 10]; #a typical Velocity AND2V1
set_load [expr {$MAX_INPUT_LOAD * 3}] [all_outputs]
set_driving_cell -no_design_rule -lib_cell INV4_8TR40 $ALL_INP_EXC_CLK
set_drive 0 $CLK_NAME ; #infinite clk driving strength

#Define design constraints
set input_budget_for_T 0.49
set output_budget_for_T 0.49
set clock_uncertainty_for_T 0.3
set_input_delay  [expr {$CLK_PERIOD * $input_budget_for_T}] $ALL_INP_EXC_CLK -clock $CLK_NAME
set_output_delay [expr {$CLK_PERIOD * $output_budget_for_T}] [all_outputs] -clock $CLK_NAME
set_clock_uncertainty -setup $clock_uncertainty_for_T $CLK_NAME
set_clock_transition -max $TRANSITION $CLK_NAME
set_clock_latency -source -max $SOURCE_LATENCY $CLK_NAME
set_clock_latency  -max $LATENCY $CLK_NAME

#try dc's best to decrease the area
set_max_area 0

#defualt compile,use ungroup
set_ungroup s0
set_ungroup s1
set_ungroup s4
set_ungroup s6

##### Remember set direction #####
redirect -tee -file "${FLOW_STEP_LOG_DIR}/initial_${design}_compile.rpt" {compile_ultra}

#set group to improve the timing 
#get output_ports [get_ports out*]
# foreach_in_collection output_port $output_ports {
#     set output_port_fanin [all_fanin -to $output_port -only_cell]
#     set output_fanin_reg [filter_collection -regexp $output_port_fanin {name =~ "^R.*"}]
#     set 
# }
set critical_port_T [get_ports out*]
group_path -name high_effort_out_T -to $critical_port_T -critical_range 0.2 -weight 5



#generate report
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/${design}.ddc"
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"
