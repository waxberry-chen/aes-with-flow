#################################################
# Script : icc2lm_ndm							#
# Created by : mxw, cym                         #
# Information: This step makes ndm library for	#
#	following steps								#
#################################################

source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

####################
#     Make ndm     #
####################
source ${WORK_SCRIPTS_DIR}/ndm_settings/ndm_init.tcl
source ${WORK_SCRIPTS_DIR}/icc2_function.tcl

##### Recieve parameters #####
set check_time [now_time]
set lm_log_dir ${FLOW_STEP_LOG_DIR}/${check_time}#lm_check
file mkdir $lm_log_dir
append search_path " ${LOGIC_LIB_PATH}"
#                   ^
# WARNING: DO NOT remove the space #

set tf_file "${TECH_FILE_PATH}/${TECH_FILE}"
#remove_lib [get_lib]

foreach flow_step $ndm_flow_steps ndm_name $ndm_names {
	create_workspace  $flow_step \
	-technology $tf_file\
	-flow $flow_step

	redirect -tee $lm_log_dir/read_${flow_step}.log {	
		if {[string equal $flow_step aggregate ]} {
			foreach f $ref_physical_ndm {
				read_ndm $f
			}
		} else {
			read_db $db_files
			read_lef $lef_files
		}
	}

	redirect -tee $lm_log_dir/check_${flow_step}.log {
	check_workspace -details all -allow_missing
	}
	commit_workspace -output ${FLOW_STEP_OUTPUT_DIR}/${ndm_name}.ndm
}

##### Dump executed commands #####
write_script -output ${FLOW_STEP_DIR}/wscript

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
