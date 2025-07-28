#===========route aes============#
set design "aes_128"
set current_step "05_route"
set before_step "04_clockopt"

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
