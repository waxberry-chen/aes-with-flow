source ${WORK_SCRIPTS_DIR}/place_initial.tcl
source ${WORK_SCRIPTS_DIR}/place_function.tcl

# source ${WORK_SCRIPTS_DIR}/0p5_lm_ndm.tcl

set check_time [now_time]
set lm_log ${log_dir}/${check_time}#lm_check
file mkdir $lm_log
append search_path " $db_search_path"
puts "--------------------------------------------------------------"
puts "Remove files of current worspace "
puts "--------------------------------------------------------------"

#remove_lib [get_lib]
puts "--------------------------------------------------------------"
puts "create_workspace"
puts "--------------------------------------------------------------"

if {[string equal [current_workspace] $design ] ==0 } {
create_workspace  $design \
	-technology $tf_file\
	-flow $flow_type
}
puts "--------------------------------------------------------------"
puts "Read files "
puts "--------------------------------------------------------------"
redirect -tee $lm_log/read.log {	
	if {[string equal $flow_type aggregate ]} {
		foreach f $ref_physical_ndm {
			read_ndm $f
		}
		
	} else {
		read_db $db_files
		read_lef $lef_files
	}
}

puts "--------------------------------------------------------------"
puts "check workspace "
puts "--------------------------------------------------------------"


redirect -tee $lm_log/check_outpus.log {
	check_workspace -details all -allow_missing
}
puts "--------------------------------------------------------------"
puts "Save"
puts "--------------------------------------------------------------"

commit_workspace -output $ndm_dir/${design}_${user_define_name}.ndm
quit!