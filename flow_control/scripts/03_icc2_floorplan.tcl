#################################################
# Script : icc2_floorplan						#
# Created by : mxw, cym                         #
# Information: This step makes ndm library for	#
#	following steps								#
#################################################

source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

#########################
#     IMPORT DESIGN     #
#########################
source ${WORK_SCRIPTS_DIR}/floorplan_settings/floorplan_init.tcl
source ${WORK_SCRIPTS_DIR}/icc2_function.tcl

set_host_options -max_cores ${FLOW_CORE_NUM}

# ===== create nlib ===== #

file delete -force ${FLOW_STEP_OUTPUT_DIR}/${nlib_name}

if {[file exist ${target_ndm}]} {puts "INFO: ndm exist"} else { puts "ERROR: cant find ${target_ndm}"}

create_lib ${FLOW_STEP_OUTPUT_DIR}/${nlib_name} \
 -ref_libs ${target_ndm} \
 -technology $tf_file

# ===== read verilog ===== #
read_verilog -library ${nlib_name} -design ${FLOW_DESIGN_NAME} -top ${FLOW_DESIGN_NAME} $import_netlists

# ===== initialization ===== #
source ${WORK_SCRIPTS_DIR}/floorplan_settings/floorplan_settings.tcl
### load upf file

set_app_options -name mv.upf.enable_golden_upf -value true
reset_upf

load_upf $golden_upf_file

commit_upf

# ===== connect power/grid ===== #
connect_pg_net -automatic

# ========== Create floorplan in ICC2 ========== #
# ===== make database ===== #
current_lib ${nlib_name}
open_block ${nlib_name}:${FLOW_DESIGN_NAME}.design
# ===== create floorplan ===== #
puts "\n-------------------floorpaln-----------------------------------"
initialize_floorplan -boundary $core_size\
                     -core_offset $core_offset\
                     -use_site_row
#-keep_all 

# ===== place ports ===== #
### constraints
source ${WORK_SCRIPTS_DIR}/floorplan_settings/floorplan_place_ports.tcl
puts "\n-------------------PG net-----------------------------------"
source ${WORK_SCRIPTS_DIR}/floorplan_settings/floorplan_gen_pg_net.tcl

# ===== save design ===== #
save_block
save_lib

# ===== exit ===== #
print_message_info

##### Dump executed commands #####
write_script -output ${FLOW_STEP_DIR}/wscript

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
