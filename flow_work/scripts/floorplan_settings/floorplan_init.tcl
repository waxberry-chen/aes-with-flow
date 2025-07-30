#######################################################
# ============== Common design settings ============= #
# created by :mxw                                     #
# Information: Need to be sourced after flow_init.tcl #
#######################################################
# p.s. ndm and nlib dir are all step output dir

# ===== 0p5_ndm files ===== #
set design ${FLOW_DESIGN_NAME}

set nlib_name ${FLOW_DESIGN_NAME}_${FLOW_STEP_NAME}.nlib

set target_ndm "${FLOW_PREDECESSOR_DIR}/${FLOW_DESIGN_NAME}_multi-scenario-merge.ndm"

set import_netlists     ""
lappend import_netlists "${SYN_OUTPUT_PATH}/aes_128_final.v"

set golden_upf_file "${FLOW_INPUT_DIR}/${FLOW_DESIGN_NAME}.upf"

set tf_file "${TECH_FILE_PATH}/${TECH_FILE}"

# ------------ floorplan ----------#
# set core_size {{0 0} {699.96 700}}
set core_size {{0 0} {839.99 840}}
set core_offset {0 1.12}