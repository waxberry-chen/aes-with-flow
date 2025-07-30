
##### RELATED ##### 
# place_gen_scenarios.tcl
# rc,  corner
set smic_icc2rc_tech(cmin)          "${TLUPLUS_PATH}/${TLUPLUS_MIN_FILE}"
set smic_icc2rc_tech(cmax)          "${TLUPLUS_PATH}/${TLUPLUS_MAX_FILE}"
set smic_icc2rc_tech(typical)       "${TLUPLUS_PATH}/${TLUPLUS_TYP_FILE}"
set smic_itf_tluplus_map            "${TLUPLUS_PATH}/${TLUPLUS_MAP_FILE}"

# ===== 02_floorplan files ===== #
# $tap_cells
# $tie_cells
set sdc_file "${SYN_OUTPUT_PATH}/aes_128_final.sdc"
set tap_cells "*/F_FILL2_8TR40"
set tie_cells "*/FILLTIE_8TR40"

#---------- Scenarios -------------#
set max_trans_clk 0.3
set max_trans_data 0.3
set max_capacitance 200

puts "\n ----------------- Scenarios -------------------------------"
source ${WORK_SCRIPTS_DIR}/place_settings/place_gen_scenarios.tcl
puts "\n-------------------Place optimizer--------------------------"
### set tap cells and tie cell
create_tap_cells -lib_cell $tap_cells -pattern stagger -distance 70 -skip_fixed_cells  -voltage_area "DEFAULT_VA"
### enable tie cell insertion during optimization
set_lib_cell_purpose -include optimization $tie_cells
set_dont_touch $tie_cells false
set_app_options -name opt.tie_cell.max_fanout -value 8

#puts "---analyze lib cells placement---"
#analyze_lib_cell_placement -lib_cells [get_lib_cells ] > log/lib_cells_placeable.log
#puts "---analyze finish----------------

set_ignored_layers -min_routing_layer M1 -max_routing_layer M8
puts "\n --- Scan Chain ---"
### scan chain
set_app_options -name  place.coarse.continue_on_missing_scandef -value true
set_app_options -name  opt.dft.optimize_scan_chain -value false

puts "\n --- App Options ---"
### app options
set_app_option -name opt.common.user_instance_name_prefix -value "place_opt_"
set_app_options -name opt.tie_cell.max_fanout -value 16

set_app_options -name opt.common.enable_rde -value true
set_app_options -name place.legalize.enable_advanced_legalizer -value true
set_app_options -name place_opt.congestion.effort -value high
set_app_options -name route.global.effort_level -value high
set_app_options -name opt.area.effort -value ultra
set_app_options -name opt.common.buffer_area_effort -value ultra
set_app_options -name place_opt.flow.clock_aware_placement -value true
set_app_options -name refine_opt.flow.clock_aware_placement -value true
set_app_options -name opt.power.leakage_type -value conventional
set_app_options -name place.coarse.auto_timing_control -value true
set_app_options -name place_opt.final_place.effort -value high
set_app_options -name route.global.timing_driven_effort_level -value high
set_app_options -name opt.timing.effort -value high

#disable default enabled advanced feature
set_app_options -name place_opt.flow.enable_ccd -value false
#add 25-07-06 17:31
set_app_options -name place_opt.flow.trial_clock_tree -value true
#add 25-07-7 13:55
#set_app_options -name route_opt.flow.enable_ccd_clock_drc_fixing -value true
#add 25-7-10 14:00
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
