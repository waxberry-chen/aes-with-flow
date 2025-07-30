# ==============================================================================
# file:    [characterize.tcl]
# author:  [cjy]
# created: [2025-06-13]
# lastest: [2025-06-13]
# version: [1.0.0]
# about:   [this file is to get characterize constrain of subdesign for 
#           compile-characterize-write_script-recompile mode]
# ==============================================================================

puts ">>> INFO: Running characterize.tcl"
current_design aes_128
characterize r9
current_design one_round
write_script > "${FLOW_STEP_BUFFER_DIR}/one_round.wtcl"

current_design aes_128
characterize a9
current_design expand_key_128
write_script > "${FLOW_STEP_BUFFER_DIR}/expand_key_128.wtcl"

current_design aes_128
characterize rf
current_design final_round
write_script > "${FLOW_STEP_BUFFER_DIR}/final_round.wtcl"

current_design aes_128
characterize U3
current_design top_comb
echo "111111111111111111111111111"
write_script > "${FLOW_STEP_BUFFER_DIR}/top_comb.wtcl"
echo "111111111111111111111111111"