source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl


source ${WORK_SCRIPTS_DIR}/place_initial.tcl
source ${WORK_SCRIPTS_DIR}/place_function.tcl
################ message for current nlib##############
set msg $MSG
#######################################################

# ========== Read design into ICC2 ========== #

# ===== create nlib ===== #
#file mkdir $nlib_dir

file delete -force $nlib_dir/${design}_${01_import_nlib_name}.nlib

if {[file exist $ndm_files]} {puts "ndm files exist"} else { puts "cant find files"}

create_lib $nlib_dir/${design}_${01_import_nlib_name}.nlib\
 -ref_libs $ndm_files\
 -technology $tf_file

  

# ===== read verilog ===== #
read_verilog -library ${design}_${01_import_nlib_name}.nlib -design ${design} -top $design $import_netlists

# ===== initialization ===== #
source ${WORK_SCRIPTS_DIR}/place_initialization_settings.tcl
### load upf file

set_app_options -name mv.upf.enable_golden_upf -value true
reset_upf

load_upf $golden_upf_file

commit_upf

# ===== connect power/grid ===== #
connect_pg_net -automatic

# ===== save design ===== #
save_block
save_lib

# ===== exit ===== #
print_message_info

###### reports and logs were passed by 00_initial.tcl ######

puts "Start Time:"
set start_time [now_time]
puts $start_time

# make dir for logs
set run_log ${log_dir}/$start_time/run
file mkdir $run_log

set opt_dir ${log_dir}/$start_time/place_opt
file mkdir $opt_dir

# file copy scripts/02_floorplan.tcl $run_log/floorpan.tcl

# nlib
###### HERE OUTPUT ######
set temp_ndm_path "${temp_dir}/${design}_${02_floorplan_nlib_name}.nlib"
set temp_ndm ${design}_${02_floorplan_nlib_name}.nlib

write_id_file $temp_ndm

copy_lib -from_lib ${nlib_dir}/${design}_${02_floorplan_before_nlib}.nlib -to_lib $temp_ndm_path -force
echo "$start_time" > $temp_ndm_path/tag
echo "$msg" >> $temp_ndm_path/tag

# set used max cpu cores
set_host_options -max_cores 96

redirect -tee $run_log/floorplan_run.log {
    # ========== Create floorplan in ICC2 ========== #
    
    # ===== make database ===== #
    current_lib $temp_ndm
    open_block $temp_ndm:${design}.design

    # ===== create floorplan ===== #
    puts "\n-------------------floorpaln-----------------------------------"
    initialize_floorplan -boundary $core_size\
                         -core_offset $core_offset\
                         -use_site_row
    #-keep_all 

    # ===== place ports ===== #
    ### constraints
    source ${WORK_SCRIPTS_DIR}/place_place_ports.tcl

   
    puts "\n-------------------PG net-----------------------------------"
    source ${WORK_SCRIPTS_DIR}/place_gen_pg_net.tcl
    
    puts "\n ----------------- Scenarios -------------------------------"
    source ${WORK_SCRIPTS_DIR}/place_gen_scenarios.tcl

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

}

## opt
puts "\n Satrt place optimize:"
puts "--------------- Step 1------------------------------------------"
redirect -tee $opt_dir/initial_place_to_initial_drc.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_place -to initial_drc
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 2------------------------------------------"
redirect -tee $opt_dir/initial_drc_to_initial_opto.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_drc -to initial_opto
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 3------------------------------------------"
redirect -tee $opt_dir/initial_opto_to_final_place.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_opto -to final_place
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 4------------------------------------------"
redirect -tee $opt_dir/final_place_to_final_opto.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from final_place -to final_opto
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

#write_floorplan -output ${log_dir}/$start_time/floorplan
write_script -output $run_log/wscript

save_block
save_lib
puts "Sucecessfully save ndm.\n MSG: $msg"


# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
