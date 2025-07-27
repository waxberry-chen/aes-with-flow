# ========== Read design into ICC2 ========== #
source ${WORK_SCRIPTS_DIR}/placement_initial.tcl

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
source scripts/constraints/initialization_settings.tcl
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
quit!
