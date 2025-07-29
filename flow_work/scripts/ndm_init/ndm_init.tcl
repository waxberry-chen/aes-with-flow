#######################################################
# ============== Common design settings ============= #
# created by :mxw                                     #
# Information: Need to be sourced after flow_init.tcl #
#######################################################
# ===== error not fatal, continue ===== #
set_app_var sh_continue_on_error true

# ===== 0p5_ndm files ===== #
set db_search_path "${LOGIC_LIB_PATH}"

##### BE AWARE OF SEQUENCE !!!!! #####
set ndm_flow_steps [list normal physical_only aggregate]
set ndm_names [list ${FLOW_DESIGN_NAME}_multi-scenarios ${FLOW_DESIGN_NAME}_physical_only ${FLOW_DESIGN_NAME}_multi-scenario-merge]

set multi-scenarios_name [lindex $ndm_names 0]
set physical_only_name [lindex $ndm_names 1]
set multi-scenario-merge_name [lindex $ndm_names 2]

set ref_physical_ndm "${FLOW_STEP_OUTPUT_DIR}/${multi-scenarios_name}.ndm"
lappend ref_physical_ndm "${FLOW_STEP_OUTPUT_DIR}/${physical_only_name}.ndm"

set target_ndm "${FLOW_STEP_OUTPUT_DIR}/${multi-scenario-merge_name}.ndm"

set lef_files "${LEF_FILE_PATH}/${LEF_FILE_NAME}"
set db_files "$CORNER_LIBS(tt)"
lappend db_files "$CORNER_LIBS(ff)"
lappend db_files "$CORNER_LIBS(ss)"
