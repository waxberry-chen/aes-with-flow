#==============routeopt aes=============#
set design "aes_128"
set current_step "06_routeopt"
set before_step "05_route"

###initial setting

set nlib_dir "./nlib"

###database
file mkdir $nlib_dir
file delete -force $nlib_dir/${design}_${current_step}.nlib
copy_lib -from_lib ${nlib_dir}/${design}_${before_step}.nlib -to_lib ${nlib_dir}/${design}_${current_step}.nlib -force
current_lib ${design}_${current_step}.nlib
open_block ${design}_${current_step}.nlib:${design}.design

###initialize


###scenarios 
source ./constrains/route_scenarios.tcl

set_propagated_clock [get_clocks -filter "is_virtual == false"]



###set layers
set_ignored_layers -min_routing_layer M1 -max_routing_layer M8


set_attribute -name routing_direction -value vertical [get_layer ALPA]

### route app options
# global route
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.global.effort_level -value high
set_app_options -name route.global.timing_driven_effort_level -value high

# track assignment
set_app_options -name route.track.crosstalk_driven -value true
set_app_options -name route.track.timing_driven -value true

# detail route
set_app_options -name route.detail.antenna -value true
set_app_options -name route.detail.antenna_fixing_preference -value use_diodes
set_app_options -name route.detail.diode_libcell_names -value */ANTENNA_LVT
set_app_options -name route.detail.timing_driven -value true
#set_app_options -name route.detail.save_after_iterations -value 2

### update design latency
compute_clock_latency -verbose

### routeopt app options
set_app_options -name route_opt.flow.enable_ccd -value true
set_app_options -name route_opt.flow.enable_ccd_clock_drc_fixing -value auto
set_app_options -name route_opt.flow.enable_clock_power_recovery -value false
#set_app_options -name route_opt.flow.enable_irdrivenopt -value false
#set_app_options -name route_opt.flow.enable_power -value true
set_app_options -name time.si_enable_analysis -value true

set_app_options -name opt.common.user_instance_name_prefix -value "Ropt_"
###run
route_opt -xtalk_reduction
route_opt -xtalk_reduction
route_opt -xtalk_reduction

###connect
connect_pg_net -all_blocks -automatic

###save
save_block
save_lib

print_message_info
