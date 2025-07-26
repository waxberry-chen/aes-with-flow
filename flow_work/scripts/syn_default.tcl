# set some attributes to avoid warning 
set_host_options -max_cores ${FLOW_CORE_NUM}
set verilogout_no_tri true
set_fix_multiple_port_nets -all -buffer_constants


# define the system clock period,300MHz
#set CLK_PERIOD 1.60
set CLK_PERIOD 3.33

# define the timing budget
set INPUT_BUDGET 0.6
set OUTPUT_BUDGET 0.6

#set the clock attributes 
set CLOCK_UNCERTAINTY 0.3
set TRANSITION 0.1
set LATENCY 0
set SOURCE_LATENCY 0

#set the clock attributes 
#set CLOCK_UNCERTAINTY 0.3
#set TRANSITION 0.1
#set LATENCY 2.4
#set SOURCE_LATENCY 1.2

#create the real clock if clk port is found
if {[sizeof_collection [get_ports clk]] > 0} {
    set CLK_NAME clk
    create_clock -period $CLK_PERIOD [get_ports $CLK_NAME]
}

#create the vitual clock if clock port is not found
if {[sizeof_collection [get_ports clk]] == 0} {
    set CLK_NAME vclk
    create_clock -period $CLK_PERIOD -name $CLK_NAME

}

#set ideal net attribute for clk port to avoid warning and constraint
# set_dont_touch clk

# Apply default drive strengths and typical loads
set ALL_INP_EXC_CLK [remove_from_collection [all_inputs] [get_ports $CLK_NAME]]
set MAX_INPUT_LOAD [expr {[load_of $CORNER_LIB_NAME/AND2V1_8TR40/A1]} * 10]; #a typical Velocity AND2V1
set_load [expr {$MAX_INPUT_LOAD * 3}] [all_outputs]
set_driving_cell -no_design_rule -lib_cell INV4_8TR40 $ALL_INP_EXC_CLK
set_drive 0 $CLK_NAME ; #infinite clk driving strength



# Apply default delay timing constraint fot modules 
set_input_delay  [expr {$CLK_PERIOD * $INPUT_BUDGET}] $ALL_INP_EXC_CLK -clock $CLK_NAME
set_output_delay [expr {$CLK_PERIOD * $OUTPUT_BUDGET}] [all_outputs] -clock $CLK_NAME
set_clock_uncertainty -setup $CLOCK_UNCERTAINTY $CLK_NAME
set_clock_transition -max $TRANSITION $CLK_NAME
set_clock_latency -source -max $SOURCE_LATENCY $CLK_NAME
set_clock_latency  -max $LATENCY $CLK_NAME

# set default operating conditions
if {[regexp {rvt_(.*)_basic} $CORNER_LIB_NAME match result]} {
    set current_operating_condition $result  
}
set_operating_conditions $current_operating_condition

# Turn on auto wire load selection
# (library must support this feature)
#set auto_wire_load_selection true

##Specify the routing layers by using the layer names from the technology file
set_preferred_routing_direction -layers {M1 M2 M3 M5 M7 TM1 ALPA} -direction v
set_preferred_routing_direction -layers {M4 M6 M8 TM2} -direction h