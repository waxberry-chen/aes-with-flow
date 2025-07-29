### initialization settings for icc2
## time unit
set_user_units -type time -value 1ns

set_attribute [get_site_defs unit] symmetry Y
set_attribute [get_site_defs unit] is_default true

##Specify the routing layers by using the layer names from the technology file
set_attribute [get_layers {M1 M2 M3 M5 M7 TM1}] routing_direction vertical 
set_attribute [get_layers {M4 M6 M8 TM2}] routing_direction horizontal
get_attribute [get_layers *M?] routing_direction

set_ignored_layers -min_routing_layer M1 -max_routing_layer M8
set_message_info -id LGL-003 -limit 10
