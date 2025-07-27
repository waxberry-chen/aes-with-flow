source ${WORK_SCRIPTS_DIR}/placement_initial.tcl
source ${WORK_SCRIPTS_DIR}/placement_function.tcl

if {$mode} {
    set file_id $id
    if {[read_id_file $file_id] != 0} {
        set ndm_name [read_id_file $file_id]
        set nlib "${temp_dir}/$ndm_name"
    } else {
        error "cant find id $file_id in ID_file"
    }
} else {
    set ndm_name $file
    set nlib $ndm_name
}

puts [open_lib $nlib]

set blocks_colection [get_blocks -all]

set block [get_object_name $blocks_colection]

puts [open_block $block]

set cells [get_flat_cells]
set cell_num [sizeof_collection $cells]
set total_area 0
foreach_in_collection cell $cells {
    set height [get_attribute $cell height]
    set width  [get_attribute $cell width]
    set total_area [expr ${total_area}+[expr ${height}*${width}]]
}

set rec_lenght [expr sqrt($total_area/${utilization_ratio})]

redirect -tee -append $log_dir/area {
    echo "-----------------------------------------------------------------"
    echo "Design : $block"
    echo "Total cells : $cell_num"
    echo "Total cell area : $total_area"
    echo "Recommend lenght of square (utilization=${utilization_ratio}):\n $rec_lenght"
}
quit!