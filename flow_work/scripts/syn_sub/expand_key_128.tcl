# ==============================================================================
# file:    [expand_key_128.tcl]
# author:  [cjy]
# created: [2025-06-13]
# lastest: [2025-06-13]
# version: [1.0.0]
# about:   [this file is to contold the initial constrain for subdeisgn expand_key_128]
# ==============================================================================

current_design expand_key_128
reset_design
set rpt_file "initial_expand_key_128.rpt"
set design "expand_key_128"
source "${WORK_SCRIPTS_DIR}/syn_default.tcl"

# Define design environment
set ALL_INP_EXC_CLK [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set ALL_INP_EXC_CLK [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set MAX_INPUT_LOAD [expr {[load_of $CORNER_LIB_NAME/AND2V1_8TR40/A1]} * 10]; #a typical Velocity AND2V1
set_load [expr {$MAX_INPUT_LOAD * 3}] [all_outputs]
set_driving_cell -no_design_rule -lib_cell INV4_8TR40 $ALL_INP_EXC_CLK
set_drive 0 $CLK_NAME ; #infinite clk driving strength

#Define design constraints
set_input_delay  [expr {$CLK_PERIOD * $OUTPUT_BUDGET - 0.12}]  $ALL_INP_EXC_CLK -clock $CLK_NAME
set_output_delay [expr {$CLK_PERIOD * $OUTPUT_BUDGET}] [all_outputs] -clock $CLK_NAME
set_clock_uncertainty -setup $CLOCK_UNCERTAINTY $CLK_NAME
set_clock_transition -max $TRANSITION $CLK_NAME
set_clock_latency -source -max $SOURCE_LATENCY $CLK_NAME
set_clock_latency  -max $LATENCY $CLK_NAME

#try dc's best to decrease the area
set_max_area 0

#dont touch the S4 subdesign , it has done
set_dont_touch S4_0
set_ungroup S4_0 false
#defualt compile
redirect -tee -file "${FLOW_STEP_LOG_DIR}/initial_${design}_compile.rpt" {compile_ultra}

#generate report
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/${design}.ddc"
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"