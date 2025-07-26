# ==============================================================================
# file:    [recompile.tcl]
# author:  [cjy]
# created: [2025-06-13]
# lastest: [2025-06-13]
# version: [1.0.0]
# about:   [this file is to recompile subdesign]
# ==============================================================================

puts ">>> INFO: Running recompile.tcl"
current_design aes_128
source "${WORK_SCRIPTS_DIR}/syn_default.tcl"

source "${FLOW_STEP_BUFFER_DIR}/one_round.wtcl"
set_dont_touch t*/t*
compile_ultra -spg
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/one_round_wtcl.ddc"
set rpt_file one_round_wtcl.rpt
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"

source "${FLOW_STEP_BUFFER_DIR}/expand_key_128.wtcl"
set_dont_touch S4_0
compile_ultra -spg
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/expand_key_128_wtcl.ddc"
set rpt_file expand_key_128_wtcl.rpt
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"

source "${FLOW_STEP_BUFFER_DIR}/final_round.wtcl"
set_dont_touch S4_1
set_dont_touch S4_2
set_dont_touch S4_3
set_dont_touch S4_4
compile_ultra -spg
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/final_round_wtcl.ddc"
set rpt_file final_round_wtcl.rpt
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"

source "${FLOW_STEP_BUFFER_DIR}/top_comb.wtcl"
compile_ultra -spg
write -format ddc -hier -o "${FLOW_STEP_BUFFER_DIR}/top_comb_wtcl.ddc"
set rpt_file top_comb_wtcl.rpt
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"
