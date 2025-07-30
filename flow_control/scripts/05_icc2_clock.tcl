# ##### we already have #####
# ##### Global Variables #####
# set FLOW_DESIGN_NAME aes_128
# set FLOW_TAG test
# set FLOW_DEBUG false
# set FLOW_SCRIPTS_DIR /home/cym/prj/aes-with-flow/flow_control/scripts
# set WORK_SCRIPTS_DIR ../scripts
# set FLOW_INPUT_DIR ../global_input
# set FLOW_OUTPUT_DIR ../global_output

# ##### Step Variables #####
# set FLOW_STEP_NAME clock
# set FLOW_PRESTEP_NAME place
# set FLOW_PREDECESSOR_DIR ./results/place_${FLOW_TAG}/output
# set FLOW_STEP_DIR results/clock_test
# set FLOW_STEP_OUTPUT_DIR results/clock_test/output
# set FLOW_STEP_LOG_DIR results/clock_test/log
# set FLOW_STEP_REPORTS_DIR results/clock_test/reports
# set FLOW_STEP_BUFFER_DIR results/clock_test/intermedia

source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

#============clock for aes============#
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


###scenarios cts
source ${WORK_SCRIPTS_DIR}/clock_settings/scenarios_cts.tcl

###set routing layers
set_ignored_layers -min_routing_layer M5 -max_routing_layer M8

###set lib cell purpose
#

###set CTS cell
set ctscelllist "aes_128/INV*_8TR40 */CLKBUF*"
set CTS_cells [get_lib_cells $ctscelllist]
set_dont_touch $CTS_cells false
set_attribute $CTS_cells dont_use false
set_lib_cell_purpose -exclude cts [get_lib_cells */*] 
set_lib_cell_purpose -include cts $CTS_cells

set_attribute -name routing_direction -value vertical [get_layer ALPA]
###CTS app option
set_app_options -name time.remove_clock_reconvergence_pessimism -value true
set_app_options -name clock_opt.flow.enable_ccd -value false
set_app_options -name cts.compile.enable_local_skew -value true
set_app_options -name cts.optimize.enable_local_skew -value true
set_app_options -name opt.dft.clock_aware_scan_reorder -value true

###prefix
set_app_options -name cts.common.user_instance_name_prefix -value CTS_

###run
clock_opt -from build_clock -to route_clock

###connect pg
connect_pg_net -automatic

###save
save_block -force
save_lib


print_message_info

##### Dump executed commands #####
write_script -output ${FLOW_STEP_DIR}/wscript

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
