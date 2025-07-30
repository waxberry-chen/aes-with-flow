source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

source ${WORK_SCRIPTS_DIR}/icc2_function.tcl

##########
set design ${FLOW_DESIGN_NAME}
set current_step ${FLOW_STEP_NAME}
set before_step ${FLOW_PRESTEP_NAME}

set_host_options -max_cores ${FLOW_CORE_NUM}
###initial setting

set nlib_dir ${FLOW_STEP_OUTPUT_DIR}

###database
file delete -force $nlib_dir/${design}_${current_step}.nlib
copy_lib -from_lib ${FLOW_PREDECESSOR_DIR}/${design}_${before_step}.nlib -to_lib ${nlib_dir}/${design}_${current_step}.nlib -force
current_lib ${design}_${current_step}.nlib
open_block ${design}_${current_step}.nlib:${design}.design
##########

source ${WORK_SCRIPTS_DIR}/place_settings/place_init.tcl

puts "Start Time:"
set start_time [now_time]
puts $start_time

# make dir for logs
set run_log ${FLOW_STEP_LOG_DIR}/$start_time/run
file mkdir $run_log

set opt_log ${FLOW_STEP_LOG_DIR}/$start_time/place_opt
file mkdir $opt_log

# ## opt
puts "\n Satrt place optimize:"
puts "--------------- Step 1------------------------------------------"
redirect -tee $opt_log/initial_place_to_initial_drc.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_place -to initial_drc
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 2------------------------------------------"
redirect -tee $opt_log/initial_drc_to_initial_opto.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_drc -to initial_opto
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 3------------------------------------------"
redirect -tee $opt_log/initial_opto_to_final_place.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from initial_opto -to final_place
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

puts "\n--------------- Step 4------------------------------------------"
redirect -tee $opt_log/final_place_to_final_opto.log {
    echo " Start Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
    place_opt -from final_place -to final_opto
    echo " Finish Time : [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"] "
}

#write_floorplan -output ${log_dir}/$start_time/floorplan

save_block
save_lib

##### Dump executed commands #####
write_script -output ${FLOW_STEP_DIR}/wscript

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
