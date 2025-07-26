###################################
#     Set initials & make dir     #
###################################
# We already have:
# set FLOW_DESIGN_NAME aes_128;
# set FLOW_TAG test;
# set FLOW_DEBUG true;
# set FLOW_SCRIPTS_DIR /home/cym/prj/aes/aes-with-flow/flow_control/scripts;
# set WORK_SCRIPTS_DIR 
# set FLOW_STEP_NAME syn;
# set FLOW_PREDECESSOR_DIR ../global_input;

# set FLOW_STEP_DIR results/syn_test;
# set FLOW_STEP_OUTPUT_DIR results/syn_test/output_syn;
# set FLOW_STEP_LOG_DIR results/syn_test/log;
# set FLOW_STEP_REPORTS_DIR results/syn_test/reports;
# set FLOW_STEP_BUFFER_DIR results/syn_test/intermedia;

##### Initialization #####
source -echo -verbose flow_init.tcl

set DESIGN_NAME $FLOW_DESIGN_NAME
set TAG $FLOW_TAG
source -echo -verbose ../${DESIGN_NAME}.${TAG}.usrconfig.tcl

set_host_options -max_cores $FLOW_CORE_NUM
define_design_lib WORK -path ${FLOW_STEP_DIR}/WORK

puts "========================================================================"
puts "                STEP 0: USER CONFIG"
puts "========================================================================"

set LIB_PATH "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1/liberty/0.9v ${FLOW_PREDECESSOR_DIR}/rtl  ${FLOW_SCRIPTS_DIR} /15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1"
# --- PVT Corner ("TT", "SS", "FF") ---
set CORNER "TT"

##### Physical library #####
set SMIC_LIB_PATH "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1"




# --- design information ---
set TOP_MODULE "aes_128"
set RTL_FILES [list "${FLOW_PREDECESSOR_DIR}/rtl/aes_128.v" "${FLOW_PREDECESSOR_DIR}/rtl/round.v" "${FLOW_PREDECESSOR_DIR}/rtl/table.v" ]





puts "\n\n========================================================================"
puts "                STEP 1: ENV SETUP"
puts "========================================================================"



# --- Choose library ---
switch $CORNER {
    "TT" { set TARGET_LIBRARY_FILES "scc40nll_hdc40_rvt_tt_v0p9_25c_basic.db" }
    "SS" { set TARGET_LIBRARY_FILES "scc40nll_hdc40_rvt_ss_v0p81_125c_basic.db" }
    "FF" { set TARGET_LIBRARY_FILES "scc40nll_hdc40_rvt_ff_v0p99_-40c_basic.db" }
    default { puts "FATAL ERROR: Invalid '$CORNER'"; return -code error }
}
set CORNER_LIB_NAME scc40nll_hdc40_rvt_tt_v0p9_25c_basic
set SYMBOL_LIBRARY_FILES "scc40nll_hdc40_rvt.sdb"
set DW_LIB "dw_foundation.sldb"

set MW_REF_LIB_PATH "${SMIC_LIB_PATH}/astro/scc40nll_hdc40_rvt"
set TECH_FILE "${SMIC_LIB_PATH}/astro/tf/scc40nll_hd_10lm_2tm.tf"

set TLUPLUS_MIN_FILE      "${SMIC_LIB_PATH}/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_CMIN.tluplus"
set TLUPLUS_MAX_FILE      "${SMIC_LIB_PATH}/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_CMAX.tluplus"
set TLUPLUS_TYP_FILE      "${SMIC_LIB_PATH}/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_TYP.tluplus"
set TLUPLUS_MAP_FILE      "${SMIC_LIB_PATH}/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_cell.map"



##### Milkyway lib #####
set MW_DESIGN_LIB_NAME "${FLOW_STEP_BUFFER_DIR}/mw_aes_128"
exec rm -r ${MW_DESIGN_LIB_NAME}
puts "INFO: Making Milkyway lib..."
create_mw_lib $MW_DESIGN_LIB_NAME \
    -technology $TECH_FILE \
    -mw_reference_library [list $MW_REF_LIB_PATH]
open_mw_lib ${MW_DESIGN_LIB_NAME}


# --- set search_path, target_library, link_library ---
set_app_var search_path "[list $LIB_PATH ] $search_path"
set_app_var target_library $TARGET_LIBRARY_FILES
set_app_var symbol_library $SYMBOL_LIBRARY_FILES
set_app_var synthetic_library $DW_LIB
set_app_var link_library "* $target_library $DW_LIB"

puts "INFO: Setting TLU+ files for parasitics..."
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE \
                   -min_tluplus $TLUPLUS_MIN_FILE \
                   -tech2itf_map $TLUPLUS_MAP_FILE
# --- Other universal options ---

puts "INFO: Initialization complete."


puts "\n\n========================================================================"
puts "                STEP 2: Read RTL and Link"
puts "========================================================================"

analyze -format verilog $RTL_FILES
elaborate $TOP_MODULE
current_design $TOP_MODULE

##### ?? #####
group {k* s* C* U*} -design_name top_comb


link
# uniquify
check_design
puts "INFO: RTL read and linked"
report_hierarchy > ${FLOW_STEP_REPORTS_DIR}/hierarchy.rpt


puts "\n\n========================================================================"
puts "       STEP 3: set top module constraints and initial compile"
puts "========================================================================"
############################# default.con #####################################
source ${FLOW_SCRIPTS_DIR}/default.tcl
#########################################################################################


