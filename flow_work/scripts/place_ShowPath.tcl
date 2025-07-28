source scripts/function.tcl
source scripts/var_setting.tcl

#set file_path "/15T/Projects/mxw/AES/aes/icc2/floorplan/work_dir/Route_nlib_path.rpt"
#if {[file exists $file_path]} {
#    set fileid [open $file_path r]
#} else {
#    error "error file path"
#}
set temp_file_dir "work_dir"
set temp_file "${temp_file_dir}/showpath_temp_file"
file mkdir $temp_file_dir
redirect -tee $temp_file {
    report_timing -from $start_point -to $end_point -nets
}
set fileid [open $temp_file r]

set cells ""
set cell_pattern {^ +(.*)/. (\(.*\))}
set nets ""
set net_pattern {^ +(.*) (\(net\))}
set start_point 0
set start_pattern {^( +Point +Fanout +Incr +Path)}
set end_pattern {^( +slack +\(.*\))}
echo "----------------------------------------------------------------"
while {![eof $fileid]} {
    gets $fileid line
    if {!$start_point && [regexp $start_pattern $line ]} { set start_point 1}
    if {$start_point && [regexp $end_pattern $line ]} { set start_point 0}
    if {[regexp $cell_pattern $line match cell frame]&& $start_point} {
        echo "cell match:$match"
        lappend cells $cell
    } elseif {[regexp $net_pattern $line match net type]&& $start_point} {
        lappend nets $net
        echo "net match:$match"
    }
}
close $fileid
file delete $temp_file
#echo $cells
#echo $nets
set col_nets [get_nets $nets]
set col_cells [get_cells $cells]

set all_obj [add_to_collection $col_nets $col_cells ]
echo "----------------------------------------------------------------"
foreach net $nets {
    # Loop body
    set type_string [get_attribute $net object_class]
    if {[string equal $type_string "net"]} {
        set net_shapes [get_shapes -of_objects $net]
        set lengthes [get_attribute $net_shapes length]
        set net_length 0
        foreach l $lengthes {
            set net_length [expr ${net_length}+${l}]
        }
        echo "length of $net : $net_length"
    }
}
echo "----------------------------------------------------------------"
echo "nets and cells :[get_object_name $all_obj] "
change_selection $all_obj
gui_change_highlight -remove -all_colors
gui_change_highlight -add -color red -collection $all_obj
