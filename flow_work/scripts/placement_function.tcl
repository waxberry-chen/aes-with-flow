################################################
## Create by: mxw
## Use thise file to define proc function
################################################

set id_file_path "${FLOW_STEP_OUTPUT_DIR}/ID_file"
set temp_file_path  "${FLOW_STEP_OUTPUT_DIR}/ID_file.temp"
set temp_ndm_dir "${FLOW_STEP_OUTPUT_DIR}"
###############################
### Get Time
###############################

proc now_time {} {
    return [clock format [clock seconds] -format "%Y-%m-%d#%H-%M-%S"]
}


####################################
# grep string frome file
####################################
proc tgrep {filename pattern} {
    set f [open $filename r]
    while {![eof $f ]} {
        [gets $f line]
        if {[regexp $pattern $line]} {
        puts  $line 
        }
    }
    close $f
}

####################################
## get command options
## command donot surpport\
## positional parameters
####################################

proc get_args {all_args options_list} {
    set num_args [llength $all_args]
    for {set i 0} {$i< $num_args} {incr i} {
        set arg [lindex $all_args $i];
        switch -glob $arg {
            "[lindex $options_list 1]" {
                incr i
                if {$i >= $num_args} {
                    error "-p1 without number"
                }
                set options(-p1) [lindex $all_args $i]
            }
            "-p2" {
                incr i
                if {$i >= $num_args} {
                    error "-p2 without number"
                }
                set options(-p2) [lindex $args $i]
            }
            default {
                puts "illegal parameter $arg"
            }

        }
    }
}

## sub proc for command which needs options(must with one parameter) / no positional options
proc get_options {all_args options_list options} {
    upvar $options command_options
    set num_args [llength $all_args]
    set pras ""
    foreach option $options_list {
        set i 0
        set get_option 0
        foreach a $all_args {
            if { [regexp -- $option $a] } {
                set get_option 1
                if {$i < $num_args - 1} {
                    set p [lindex $all_args [expr $i+1]]
                    #echo "p:$p"
                    if {![regexp {^-[a-z0-9]+} $p]} { 
                        set command_options($option) $p 
                    } else { 
                        error "option $option has no parameter"
                    }   
                } else {
                    error "option $option with no parameter"
                }
            }
            incr i
        }
        if { !$get_option} {
            error "need option $option "
        }
    }    
}

####################################
## print information match types: 
## warning error info violation 
## pg_net placement timing power
## his command donot surpport\
## positional parameters
####################################

proc echo_line {args} {
    array set options {}
    get_options $args {-file -type_list} options
    set fileid [open $options(-file) r]
    set error_flag 0
    while {![eof $fileid]} {
        gets $fileid str_line
        #echo $str_line
        if {$error_flag} {
            echo "error break in proc: echo_line"
            break
        }
        set line_echo_flag 0
        if {[regexp {^={3}} $str_line]} {
            echo "\n"
            echo $str_line
            echo "\n"
            set line_echo_flag 1
        } elseif {[regexp -- {(-{5})|(\*{5})|(^[0-9a-zA-Z]+$)} $str_line]} {
            echo $str_line
            set line_echo_flag 1
        }
        foreach type $options(-type_list) {
            if {$line_echo_flag} { break}
            switch -- $type {
                "warning" {
                    if {[sgrep -string $str_line \
                               -pattern {^(warning:)|^(WARNING:)|^(Warning:)}]\
                        } {break}
                }
                "error" {
                    if {[sgrep -string $str_line -pattern {^(error:)|^(ERROR:)|^(Error:)}]} {break}
                }
                "info" {
                    if {[sgrep -string $str_line -pattern {^(info:)|^(Info:)|^(INFO:)|^(Informations:)|^(Information:)}]} {break}    
                }
                "violation" {
                    if {[sgrep -string $str_line -pattern {( violation)|(violated)|(VIOLATED)|(VIOLATION)|( -[0-9]+)|(Violating)|( Violations)}]} {break}
                }
                "pg_net" {
                    if {[sgrep -string $str_line -pattern {([e E]rror[s]?)|([s S]pacing)|([s S]hort[s]?)|([f F]loating)|([o O]verlap)}]} {break} 
                }
                "placement" {
                    if {[sgrep -string $str_line -pattern {(Ratio:)|(placed outside)|(^ +category)}]} {break}   
                }
                "timing" {
                    if {[ sgrep -string $str_line -pattern {(Point)|(Startpoint)|(Endpoint)|(Mode)|(Corner)|(Scenario[s]?)|\
                    (Design)|(Path)|(^Timing)|(Cell)|(Area)|(Constraint)|(Context)} ]\
                    } {break }  
                }
                "power" {
                    if {[sgrep -string $str_line -pattern {(^Power)}]} {break} 
                }
                default {
                    echo "error type $type"
                    set error_flag 1
                    break
                }
            }
        }
        
    }
    close $fileid
}

####################################
## if string match pattern 
## then echo the string 
## his command donot surpport\
## positional parameters
####################################
proc sgrep {args} {
    array set options {}
    get_options $args {-string -pattern} options
    if {[regexp $options(-pattern) $options(-string) ]} {
        echo $options(-string)
        return 1
    } else {
        return 0
    }
}


##############################
## ID_file setting:
## read_id_file
## write_id_file
## delete_id
## delete_ndm
## delete_log_reports
## For  temp nlib 
##############################
proc read_id_file { id } {
    global id_file_path 
    set id_file [open $id_file_path r]
    set id_pattern "^${id}:"
    while {![eof $id_file]} {
        gets $id_file line
        if {[regexp ($id_pattern) $line]} {
            regexp "($id_pattern)(.*.nlib)" $line full id ndm
            set return_ndm_file $ndm
            close $id_file
            return $return_ndm_file
        }
    }
    close $id_file
    return 0
    
}

proc write_id_file { ndm } {
    global id_file_path 
    set id_file [open $id_file_path r]
    set id_pattern {^[0-9]+}
    set id_list ""
    while {![eof $id_file]} {
        gets $id_file line
        if {[regexp ($id_pattern) $line]} {
            regexp "(${id_pattern}):(.*.nlib)" $line full id id_ndm
            append id_list " $id"
        }
    }
    close $id_file
    #echo $id_list
    set id_file_w [open $id_file_path a]
    set max_id 0
    foreach a $id_list {
        if {$a > $max_id} {
            set max_id $a
        }
    }
    set new_id [expr ${max_id}+1]
    puts $id_file_w "${new_id}:$ndm"
    close $id_file_w
}

proc delete_id {id} {
    global id_file_path 
    set id_file [open $id_file_path r]
    global temp_file_path 
    set temp_file [open $temp_file_path w]
    
    set id_pattern "^${id}:"

    while {![eof $id_file]} {
        gets $id_file line
       
        if {![regexp $id_pattern $line]} {
            
            if {[regexp {(^[0-9]+):(.*.nlib)} $line match line_id line_ndm] } {
                if {$line_id > $id} {
                #echo $line
                set new_id [expr ${line_id}-1]
                #echo $new_id
                puts $temp_file "${new_id}:${line_ndm}"
                } else {
                puts $temp_file "${line_id}:${line_ndm}"
                }
            }
        }
    }
    close $id_file
    close $temp_file
    file delete -force $id_file_path
    file rename -force $temp_file_path $id_file_path
}

proc delete_ndm { id } {
    if {$id == 0} {error "can't delete initial string"}
    global temp_ndm_dir 
    global id_file_path 

    set id_pattern "^${id}"

    set id_file [open $id_file_path r]
    set ndm_name ""

    set find_flag 0

    while {![eof $id_file]} {
        gets $id_file line
        echo $line
        if {[regexp "($id_pattern):(.*.nlib)" $line match line_id line_ndm]} {
            set ndm_name $line_ndm
            echo find
            set find_flag 1
        }
    }

    if {!$find_flag} {
        error "cant find id $id in ID_file"
        return 0
    }

    file delete -force $temp_ndm_dir/$ndm_name
    delete_log_reports $ndm_name
    delete_id $id
    return 1
}

proc delete_log_reports {ndm} {
    set logs [glob -nocomplain log/*]
    set reports [glob -nocomplain reports/*]

    set match_flag [regexp {^(.+)#([0-9]+-[0-9]+-[0-9]+#[0-9]+-[0-9]+-[0-9]+).nlib}\
     $ndm match design start_time]

    if {$match_flag} {
        foreach log $logs {
            if {[regexp $start_time $log]} {
                file delete -force $log
                echo "successfully delete dir: $log"
            }
        }
        foreach report $reports {
            if {[regexp $start_time $report]} {
                file delete -force  $report
                echo "successfully delete dir: $report"
            }
        }
        return 1
    } else {
        error "bad ndm file name"
        return 0
    }
}

####################################
## icc2 path extract 
## 
## 
## 
####################################