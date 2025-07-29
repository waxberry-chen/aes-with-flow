#######################################################
# ============== Common design settings ============= #
# created by :mxw                                     #
# Information: Need to be sourced after flow_init.tcl #
#######################################################
# ===== error not fatal, continue ===== #
set_app_var sh_continue_on_error true

# ===== 0p5_ndm files ===== #
set db_search_path "${LOGIC_LIB_PATH}"
set design ${FLOW_DESIGN_NAME}

##### WATCH SEQUENCE !!!!! #####
set ndm_flow_steps [list normal physical_only aggregate]
set ndm_names [list ${FLOW_DESIGN_NAME}_multi-scenarios ${FLOW_DESIGN_NAME}_physical_only ${FLOW_DESIGN_NAME}_multi-scenario-merge]

set multi-scenarios_name [lindex ndm_names 0]
set physical_only_name [lindex ndm_names 1]
set multi-scenario-merge_name [lindex ndm_names 2]

set ref_physical_ndm "${FLOW_STEP_OUTPUT_DIR}/${multi-scenarios_name}.ndm"
lappend ref_physical_ndm "${FLOW_STEP_OUTPUT_DIR}/${physical_only_name}.ndm"



# ===== 01_import files ===== #
set ndm_files "${ndm_dir}/aes_128_multi-scenario-merge.ndm"
set golden_upf_file "${FLOW_INPUT_DIR}/${FLOW_DESIGN_NAME}.upf"

set user_define_names "multi-scenario-merge"





# ===== design information ===== #

set design_root_dir ${FLOW_STEP_DIR}
# ===== design data directory ===== #

#-------- Library ndm dir----------#
set ndm_dir "${FLOW_INPUT_DIR}/ndm"
file mkdir $ndm_dir

set nlib_dir "${FLOW_STEP_OUTPUT_DIR}/nlib"
file mkdir $nlib_dir

set temp_dir "${FLOW_STEP_OUTPUT_DIR}"
file mkdir $temp_dir
if {![file exists $temp_dir/ID_file]} {
    echo "0:initial_add_virtual.nlib" > $temp_dir/ID_file
}


#-------- report dir----------#

set report_dir ${FLOW_STEP_REPORTS_DIR}
file mkdir $report_dir

#################################################
# ===== gate level netlist files ===== #
#################################################
set import_netlists     ""
#lappend import_netlists "./netlist/aes_128_post_dc.v"
lappend import_netlists "${FLOW_PREDECESSOR_DIR}/aes_128_final.v"

set ddc_files ""
lappend ddc_files "${FLOW_PREDECESSOR_DIR}/aes_128_final.ddc"

# ===== library ===== #
## smic
set smic_lib_dir ${PDK_ROOT}

set lef_files "${smic_lib_dir}/lef/macro/scc40nll_hdc40_rvt.lef"
set db_files "scc40nll_hdc40_rvt_tt_v0p9_25c_basic.db"
lappend db_files "scc40nll_hdc40_rvt_ss_v0p81_125c_basic.db"
lappend db_files "scc40nll_hdc40_rvt_ff_v0p99_-40c_basic.db"

# standardize paths
#set data_dir [file normalize $data_dir]
set nlib_dir [file normalize $nlib_dir]


# ===== library files ===== #
### SMIC
# place & routing
# rc,  corner
set smic_icc2rc_tech(cmin)          "${TLUPLUS_PATH}/${TLUPLUS_MIN_FILE}"
set smic_icc2rc_tech(cmax)          "${TLUPLUS_PATH}/${TLUPLUS_MAX_FILE}"
set smic_icc2rc_tech(typical)       "${TLUPLUS_PATH}/${TLUPLUS_TYP_FILE}"
set smic_itf_tluplus_map            "${TLUPLUS_PATH}/${TLUPLUS_MAP_FILE}"

# ===== scenarios of each step ===== #
set default_scenarios  "func_ss0p75v125c_cmax"
set placeopt_scenarios "func_ss0p75v125c_cmax test_ss0p75v125c_cmax"
set clock_scenarios    "cts_ss0p75v125c_cmax"
set clockopt_scenarios "func_ss0p75v125c_cmax test_ss0p75v125c_cmax func_ff0p95vm40c_cmin test_ff0p95v125c_cmin"
set routeopt_scenarios "func_ss0p75v125c_cmax test_ss0p75v125c_cmax func_ff0p95vm40c_cmin test_ff0p95v125c_cmin"

# ===== cells type settings; used in commands like add_fillers, add_tap_cells, insert_endcaps ===== #



# ===== 02_floorplan files ===== #
set sdc_file "${FLOW_PREDECESSOR_DIR}/aes_128_final.sdc"
set tap_cells "*/F_FILL2_8TR40"
set tie_cells "*/FILLTIE_8TR40"

################################
# used for eval string
# icc2_shell eval command var
# usage:
# icc2_shell> eval $var_name
################################
# show timing path: defined in var setting
set showpath "source ${WORK_SCRIPTS_DIR}/place_ShowPath.tcl"



#######################################################
# created by : mxw                                    #
# Thise file for scripts global var                   #
# modify thise file before 'make'                     #
#######################################################

#########################
# ID_file/nlib
# GetProjectResult.tcl
# OpenLibGUI.tcl
# delete_id_ndm.tcl
# GetCellArea.tcl
#########################
#open nlib /GetProjectResult.tcl/OpenLibGUI/GetCellArea.tcl
# mode=1 open id file ; mode=0 open 'file'
set mode 0
set id 1
set file results/place_test/output/nlib/aes_128_01_import_multi_scenarios_physical.nlib
#delete nlib/delete_id_ndm.tcl
#only delete id file with logs/reports
set del_ndm_id 12
# used for floorplan square lenght /GetCellArea.tcl
set utilization_ratio 0.65 

##########################
# used for define ndm name
# op5_lm_ndm.tcl
##########################


##########################
# used for read ndm 
# 01_import_design.tcl
##########################
set 01_import_nlib_name "01_import_multi_scenarios_physical"
set user_select_ndms ""


##########################
# used for setiing design 
# 02_floorplan.tcl
##########################
set 02_floorplan_nlib_name "02_place"
set 02_floorplan_before_nlib  "01_import_multi_scenarios_physical"

# ------------ floorplan ----------#
# set core_size {{0 0} {699.96 700}}
set core_size {{0 0} {839.99 840}}
set core_offset {0 1.12}
#---------- Scenarios -------------#
set max_trans_clk 0.3
set max_trans_data 0.3
set max_capacitance 200
#------------- Tag ---------------#
set MSG "\
add temp clk tree / script 
-> change trans 0.1>0.3
-> import new scenario
-> time.remove_clock_reconvergence_pessimism true
-> change size 700 700
-> change scenarios to only ss
-> clk uncertainty 0.2/ derate 5% to ss
-> change ss ff parasitic file to cmax cmin && set temp clock tree
-> fix bug in gen_scenario.tcl
-> use new sdc file
-> use new ndm with physical only cells
-> use tap cells and tie cell in place opt
"

##########################
# used for get reports 
# GetProjectResult.tcl
##########################
# for report timing
set path_type full     ;#full|full_clock|full_clock_expanded|only|end|end_detailed
set delay_type max     ;#min|min_rise|min_fall|max|max_rise|max_fall
set report_by scenario ;#design|mode|corner|scenario|group
set nworst 2            
set max_paths 2

##########################
# used for show path 
# ShowPath.tcl
##########################
set start_point rf/state_out_reg[98]
set end_point out[98]
