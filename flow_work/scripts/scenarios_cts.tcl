set max_trans_clk 0.3
set max_trans_data 0.3
set max_capacitance 200

set sdc_file "./results/syn_${FLOW_TAG}/output/aes_128_final.sdc"

set smic_icc2rc_tech(cmin)       "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_CMIN.tluplus"
set smic_icc2rc_tech(cmax)       "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_CMAX.tluplus"
set smic_icc2rc_tech(typical)       "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_TYP.tluplus"
set smic_itf_tluplus_map         "/15T/Library/Library/SMIC40/SMIC_40nm_LL_HDC40_STD_CELL/SCC40NLL_HDC40_RVT_V0.1/SCC40NLL_HDC40_RVT_V0p1/astro/tluplus/TD-LO40-XS-2001v2R_1PxM_2TM9k_ALPA14.5k/1P10M_2TM/StarRC_40LL_1P10M_2TM_cell.map"

set_ref_libs -remove results/placement_test/intermedia/ndm/aes_128_multi-scenario-merge.ndm
set_ref_libs -add results/place_test/intermedia/ndm/aes_128_multi-scenario-merge.ndm
puts "--- Scenarios ---"
    ## read tluplus RC
    read_parasitic_tech -tlup $smic_icc2rc_tech(cmax) -layermap $smic_itf_tluplus_map -name maxTLU
    read_parasitic_tech -tlup $smic_icc2rc_tech(typical) -layermap $smic_itf_tluplus_map -name normalTLU
    read_parasitic_tech -tlup $smic_icc2rc_tech(cmin) -layermap $smic_itf_tluplus_map -name minTLU
    
    remove_scenarios -all
    remove_modes -all
    remove_corners -all
    ## set scenarios
    create_mode func


    create_corner ff0p99v-40c_cmin
    create_scenario -mode func -corner ff0p99v-40c_cmin -name func_ff0p99v-40c_cmin

    create_corner ss0p81v125c_cmax
    create_scenario -mode func -corner ss0p81v125c_cmax -name func_ss0p81v125c_cmax

    create_corner tt0p90v25c_cnormal
    create_scenario -mode func -corner tt0p90v25c_cnormal -name func_tt0p90v25c_cnormal
    ######################################################
    ## ss
    set selected_scenario func_ss0p81v125c_cmax
    set selected_corner ss0p81v125c_cmax
    current_scenario $selected_scenario
    ## read SDC
    remove_sdc -scenarios $selected_scenario
    source $sdc_file
    puts "\n --- PVT ---"
    ## set PVT
    set_process_number -corners $selected_corner 1.00
    #set_process_label  -corners $selected_corner TYPICAL
    set_voltage -corners $selected_corner -object_list {VDD} 0.81
    set_voltage -corners $selected_corner -object_list {VSS} 0
    set_temperature -corners $selected_corner 125
    ###RC
    set_parasitic_parameters -corners $selected_corner -late_spec maxTLU -early_spec maxTLU


    
    set_max_transition $max_trans_clk clk -scenarios $selected_scenario  -clock_path 
    set_max_transition $max_trans_data clk -scenarios $selected_scenario  -data_path
    set_max_capacitance $max_capacitance clk -scenarios $selected_scenario 

    set_timing_derate -late  1.05 -cell_delay -net_delay
    set_timing_derate -early 0.95 -cell_delay -net_delay
    set_clock_uncertainty 0.300 [get_clocks *]
   
    set_scenario_status $selected_scenario\
     -active false \
     -setup true -hold false \
     -leakage_power false -dynamic_power false\
     -max_transition true \
     -max_capacitance true -min_capacitance true 
  

 
    ######################################################
    ## tt
    set selected_scenario func_tt0p90v25c_cnormal
    set selected_corner tt0p90v25c_cnormal
    current_scenario $selected_scenario

    ## read SDC
    remove_sdc -scenarios $selected_scenario
    source $sdc_file
    puts "\n --- PVT ---"
    ## set PVT
    set_process_number -corners $selected_corner 1.00
    #set_process_label  -corners $selected_corner TYPICAL
    set_voltage -corners $selected_corner -object_list {VDD} 0.90
    set_voltage -corners $selected_corner -object_list {VSS} 0
    set_temperature -corners $selected_corner 25
    ###RC
    set_parasitic_parameters -corners $selected_corner -late_spec normalTLU -early_spec normalTLU

    
    set_max_transition $max_trans_clk clk -scenarios $selected_scenario  -clock_path 
    set_max_transition $max_trans_data clk -scenarios $selected_scenario  -data_path
    set_max_capacitance $max_capacitance clk -scenarios $selected_scenario 

    set_timing_derate -late  1.05 -cell_delay -net_delay
    set_timing_derate -early 0.95 -cell_delay -net_delay
    set_clock_uncertainty 0.300 [get_clocks *]

 
    set_scenario_status $selected_scenario\
     -active true \
     -setup true -hold true \
     -leakage_power false -dynamic_power false\
     -max_transition true \
     -max_capacitance true -min_capacitance true 
    
    ######################################################
    ## ff
    set selected_scenario func_ff0p99v-40c_cmin
    set selected_corner ff0p99v-40c_cmin
    current_scenario $selected_scenario

    puts "\n --- PVT ---"
    ## set PVT
    set_process_number -corners $selected_corner 1.00
    #set_process_label  -corners $selected_corner TYPICAL
    set_voltage -corners $selected_corner -object_list {VDD} 0.99
    set_voltage -corners $selected_corner -object_list {VSS} 0
    set_temperature -corners $selected_corner -40
    ###RC
    set_parasitic_parameters -corners $selected_corner -late_spec minTLU -early_spec minTLU

    ## read SDC
    remove_sdc -scenarios $selected_scenario
    source $sdc_file
    set_max_transition $max_trans_clk clk -scenarios $selected_scenario  -clock_path 
    set_max_transition $max_trans_data clk -scenarios $selected_scenario  -data_path
    set_max_capacitance $max_capacitance clk -scenarios $selected_scenario 

    set_timing_derate -late  1.05 -cell_delay -net_delay
    set_timing_derate -early 0.95 -cell_delay -net_delay
    set_clock_uncertainty 0.300 [get_clocks *]

    set_scenario_status $selected_scenario\
     -active false \
     -setup true -hold false \
     -leakage_power false -dynamic_power false\
     -max_transition true \
     -max_capacitance true -min_capacitance true 
    ## IO delay
    #set input_ports [all_inputs ]
    #set clk_inputs [get_ports [get_attribute [get_clocks ] sources]]
    #set data_inputs [remove_from_col $input_ports $clk_inputs]
    #set output_ports [all_outputs]
    #
    #set_input_delay 0.6 -max $data_inputs
    #set_input_delay 0.4 -min $data_inputs
    #
    #set_output_delay 0.6 -max $output_ports
    #set_output_delay 0.4 -min $output_ports
    #
    #set_driving_cell -lib_cell BUFV8_8TR40 $data_inputs
    #
    #set_load 20 $output_ports

   
