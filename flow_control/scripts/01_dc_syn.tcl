################################
#     RECIEVE & INITIALIZE     #
################################
# Current working path: flow_work/${design_name}
source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

set DESIGN_NAME $FLOW_DESIGN_NAME
set TAG $FLOW_TAG
set TOP_MODULE $FLOW_DESIGN_NAME
set_host_options -max_cores $FLOW_CORE_NUM
define_design_lib WORK -path ${FLOW_STEP_DIR}/WORK

#############################
#     ENVIRONMENT SETUP     #
#############################
##### Setup target library #####
if {![info exists CORNER_LIBS($ACTIVE_CORNER)]} {
    puts "FATAL ERROR: Corner '$ACTIVE_CORNER' is not defined in the 'corners' section of pdk_config.toml"
    return -code error
}
set target_library $CORNER_LIBS($ACTIVE_CORNER)
set CORNER_LIB_NAME [file rootname $target_library]
puts "INFO: Selected target library: $target_library"
puts "INFO: Library base name set to: $CORNER_LIB_NAME"
##### Setup search path #####
set search_path ""
lappend search_path .                         ;# Current directory
lappend search_path ${FLOW_PREDECESSOR_DIR}/rtl ;# RTL source directory
lappend search_path $LOGIC_LIB_PATH           ;# Logic .db libraries
lappend search_path $SYMBOL_LIB_PATH          ;# Symbol .sdb libraries
lappend search_path $FLOW_SCRIPTS_DIR         ;# Common scripts directory
puts "INFO: search_path set to: $search_path"

##### Active them #####
set_app_var search_path "[join $search_path] $search_path"
set_app_var target_library    $target_library
set_app_var symbol_library    $SYMBOL_LIBRARY_FILE
set_app_var synthetic_library $DW_FOUNDATION_FILE
set_app_var link_library      "* $target_library $DW_FOUNDATION_FILE"
##### Setup milkyway library #####
set MW_DESIGN_LIB_NAME "${FLOW_STEP_BUFFER_DIR}/mw_${FLOW_DESIGN_NAME}"
if {[file exists $MW_DESIGN_LIB_NAME]} {
    puts "INFO: Removing existing Milkyway library: $MW_DESIGN_LIB_NAME"
    exec rm -rf ${MW_DESIGN_LIB_NAME}
}
puts "INFO: Creating new Milkyway library..."
create_mw_lib $MW_DESIGN_LIB_NAME \
    -technology [file join $TECH_FILE_PATH $TECH_FILE] \
    -mw_reference_library $MW_REF_LIB_PATH
open_mw_lib ${MW_DESIGN_LIB_NAME}
puts "INFO: Milkyway library ready."

# --- 1.5: Setup TLU+ for Parasitics ---
# Construct the full paths using the base path and filenames from flow_init.tcl
puts "INFO: Setting TLU+ files for parasitics..."
set_tlu_plus_files \
    -max_tluplus [file join $TLUPLUS_PATH $TLUPLUS_MAX_FILE] \
    -min_tluplus [file join $TLUPLUS_PATH $TLUPLUS_MIN_FILE] \
    -tech2itf_map [file join $TLUPLUS_PATH $TLUPLUS_MAP_FILE]

puts ">>>INFO: Initialization complete."

###########################
#     READ RTL & LINK     #
###########################
analyze -format verilog $RTL_FILES
elaborate $TOP_MODULE
current_design $TOP_MODULE
##### ?group? #####
group {k* s* C* U*} -design_name top_comb

link
# uniquify
check_design
puts "INFO: RTL read and linked"
report_hierarchy > ${FLOW_STEP_REPORTS_DIR}/hierarchy.rpt

###########################
#     INITIAL COMPILE     #
###########################
set SUB_MODULES [list \
    "T" "S4" "table_lookup" "one_round" \
    "final_round" "expand_key_128" "top_comb" \
]

foreach module_name $SUB_MODULES {
    source ${WORK_SCRIPTS_DIR}/syn_sub/${module_name}.tcl
}
########################
#     CHARACTERIZE     #
########################
source ${WORK_SCRIPTS_DIR}/syn_characterize.tcl

#####################
#     RECOMPILE     #
#####################
source ${WORK_SCRIPTS_DIR}/syn_recompile.tcl

######################
#     GET OUTPUT     #
######################
current_design aes_128
write -format ddc -hier -out "${FLOW_STEP_OUTPUT_DIR}/aes_128_final.ddc"
write -format verilog -hier -out "${FLOW_STEP_OUTPUT_DIR}/aes_128_final.v"
set rpt_file aes_128.rpt
source "${WORK_SCRIPTS_DIR}/syn_report.tcl"
write_sdc "${FLOW_STEP_OUTPUT_DIR}/aes_128_final.sdc"

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
