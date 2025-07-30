puts "--- rail ---"
    ## basic pattern
    create_pg_std_cell_conn_pattern pattern_pg_rail -layers {M2} -rail_width {@w} -parameters {w}
    set_pg_strategy strategy_pg_rail -voltage_areas DEFAULT_VA -pattern "{ name : pattern_pg_rail } {nets : VDD VSS } {parameters: 0.07}"

    compile_pg -strategies {strategy_pg_rail} -tag pg_rail

puts "\n--- stripe ---"
    ## stripe pattern
    create_pg_wire_pattern pattern_wire_based_on_track -direction @d -layer @l -width @w -spacing @s -pitch @p -parameters {d l w s p } -track_alignment track
    ### M6
    create_pg_composite_pattern pattern_core_m6_mesh -nets {VDD VSS} -add_patterns {{{pattern: pattern_wire_based_on_track} {nets: VDD VSS} {parameters:{vertical M6 0.380 0.380 6.65 }} {offset : 0 } }}

    set_pg_strategy strategy_m6_mesh -voltage_areas DEFAULT_VA -pattern "{ name : pattern_core_m6_mesh } {nets : VDD VSS } "

    ### M7
    create_pg_composite_pattern pattern_core_m7_mesh -nets {VDD VSS} -add_patterns {{{pattern: pattern_wire_based_on_track} {nets: VDD VSS} {parameters:{horizontal M7 0.64 1.12 4.48}}{offset : 0 } }}

    set_pg_strategy strategy_m7_mesh -voltage_areas DEFAULT_VA -pattern "{ name : pattern_core_m7_mesh } {nets : VDD VSS } "

    ### M8
    create_pg_composite_pattern pattern_core_m8_mesh -nets {VDD VSS} -add_patterns {{{pattern: pattern_wire_based_on_track} {nets: VDD VSS} {parameters:{vertical M8 0.760 0.76 6.65 }} {offset : 0 } }}

    set_pg_strategy strategy_m8_mesh -voltage_areas DEFAULT_VA -pattern "{ name : pattern_core_m8_mesh } {nets : VDD VSS } "

    ### TM1
    create_pg_composite_pattern pattern_tm1_mesh -nets {VDD VSS} -add_patterns {{{pattern: pattern_wire_based_on_track} {nets: VDD VSS} {parameters:{horizontal TM1 0.76 0.76 7.22 }} {offset : 0 } }}
    set_pg_strategy strategy_tm1_mesh  -pattern "{ name : pattern_tm1_mesh } {nets : VDD VSS } " -design_boundary


    ### TM2
    create_pg_composite_pattern pattern_tm2_mesh -nets {VDD VSS} -add_patterns {{{pattern: pattern_wire_based_on_track} {nets: VDD VSS } {parameters:{verticall TM2 0.760 0.760 7.22 }} {offset : 0 } }}
    set_pg_strategy strategy_tm2_mesh  -pattern "{ name : pattern_tm2_mesh } {nets : VDD VSS  } " -design_boundary

    puts "\n--- VIA ---"
    ## VIA Rules
    set_pg_via_master_rule M6toM2 -contact_code {VIA2F VIA3F VIA4F VIA5F}
    set_pg_strategy_via_rule via_pg_rule -via_rule {\
    {{{strategies:strategy_tm2_mesh}{layers:TM2}}{{strategies:strategy_tm1_mesh}{layers:TM1}}{via_master:default}}\
    {{{strategies:strategy_tm1_mesh}{layers:TM1}}{{strategies:strategy_m8_mesh} {layers:M8}}{via_master:default}}\
    {{{strategies:strategy_m8_mesh} {layers:M8}}{{strategies:strategy_m7_mesh}  {layers:M7}}{via_master:default}}\
    {{{strategies:strategy_m7_mesh} {layers:M7}}{{strategies:strategy_m6_mesh}  {layers:M6}}{via_master:default}}\
    {{existing:std_conn}                        {{strategies:strategy_m6_mesh}  {layers:M6}}{via_master:default}}\
    {{intersection:adjacent}{via_master:default}}\
    }
    
puts "\n --- compile ---"
    ### compile
puts    [compile_pg -strategies {strategy_m6_mesh strategy_m7_mesh \
                                 strategy_m8_mesh strategy_tm1_mesh \
                                 strategy_tm2_mesh } \
                    -tag pg_stripes \
                    -ignore_via_drc \
                    -via_rule {via_pg_rule}]

