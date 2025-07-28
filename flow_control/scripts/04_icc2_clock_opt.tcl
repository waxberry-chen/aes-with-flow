#============clockopt for aes============#
set design ${FLOW_DESIGN_NAME}
set current_step ${FLOW_STEP_NAME}
set before_step ${FLOW_PRESTEP_NAME}

set_host_options -max_cores ${FLOW_CORE_NUM}
###initial setting

set nlib_dir ${FLOW_STEP_OUTPUT_DIR}

###database
file mkdir $nlib_dir
file delete -force $nlib_dir/${design}_${current_step}.nlib
copy_lib -from_lib ${nlib_dir}/${design}_${before_step}.nlib -to_lib ${nlib_dir}/${design}_${current_step}.nlib -force
current_lib ${design}_${current_step}.nlib
open_block ${design}_${current_step}.nlib:${design}.design

###initialize


###scenarios 
source ./constrains/clkopt_scenarios.tcl


set_propagated_clock [get_clocks -filter "is_virtual == false"]


###set layers
set_ignored_layers -min_routing_layer M1 -max_routing_layer M8


set_attribute -name routing_direction -value vertical [get_layer ALPA]

###set tie lib


###set hold fix lib
set hold_fix_lib_list "*/DEL*_8TR40 */CLKBUF*"
set hold_fix_lib [get_lib_cells $hold_fix_lib_list]
set_dont_touch $hold_fix_lib false
set_attribute $hold_fix_lib dont_use false
set_lib_cell_purpose -exclude hold [get_lib_cells */*]
set_lib_cell_purpose -include hold $hold_fix_lib

###set cts lib
set ctscelllist "aes_128/INV*_8TR40 */CLKBUF*"
set CTS_cells [get_lib_cells $ctscelllist]
set_dont_touch $CTS_cells false
set_attribute $CTS_cells dont_use false
set_lib_cell_purpose -exclude cts [get_lib_cells */*] 
set_lib_cell_purpose -include cts $CTS_cells

###clockopt app option
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name clock_opt.hold.effort -value high
set_app_options -name clock_opt.place.effort -value high
set_app_options -name opt.dft.clock_aware_scan_reorder -value true

###prefix
set_app_options -name cts.common.user_instance_name_prefix -value CTS_
set_app_options -name opt.common.user_instance_name_prefix -value CLKOPT_

###run
clock_opt -from final_opto -to final_opto

###connect pg
connect_pg_net -automatic

###save
save_block -force
save_lib


print_message_info
