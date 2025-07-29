source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

#===========route aes============#
set design ${FLOW_DESIGN_NAME}
set current_step ${FLOW_STEP_NAME}
set before_step ${FLOW_PRESTEP_NAME}

set_host_options -max_cores ${FLOW_CORE_NUM}
###initial setting

set nlib_dir ${FLOW_STEP_OUTPUT_DIR}


###database
file mkdir $nlib_dir
file delete -force $nlib_dir/${design}_${current_step}.nlib
copy_lib -from_lib ${FLOW_PREDECESSOR_DIR}/${design}_${before_step}.nlib -to_lib ${nlib_dir}/${design}_${current_step}.nlib -force
current_lib ${design}_${current_step}.nlib
open_block ${design}_${current_step}.nlib:${design}.design

###initialize


###scenarios
source ${WORK_SCRIPTS_DIR}/scenarios_route.tcl

set_propagated_clock [get_clocks -filter "is_virtual == false"]

###set layers
set_ignored_layers -min_routing_layer M1 -max_routing_layer M8

set_attribute -name routing_direction -value vertical [get_layer ALPA]

###route app options
set_app_options -name route.global.effort_level -value high
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.timing_driven -value true
set_app_options -name route.track.crosstalk_driven -value true
set_app_options -name route.detail.timing_driven -value true

set_app_options -name route.detail.save_after_iterations -value 30
set_app_options -name route.detail.antenna_fixing_preference -value use_diodes
set_app_options -name route.detail.insert_diodes_during_routing -value true
#set_app_options -name route.common.global_max_layer_mode -value soft
#set_app_options -name route.common.global_min_layer_mode -value soft
set_app_options -name route.detail.diode_libcell_names -value */ANTENNA_RVT
set_app_options -name opt.common.user_instance_name_prefix -value "ROUTE_"
###run route
route_auto

###connect
connect_pg_net -automatic

###save
save_block -force
save_lib


print_message_info

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
