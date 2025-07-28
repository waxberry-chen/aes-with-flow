remove_individual_pin_constraints

set_individual_pin_constraints -ports [all_inputs] -allowed_layers {M5 M7} -sides 1 -offset {100 600}
set_individual_pin_constraints -ports [all_outputs] -allowed_layers {M5 M7} -sides 3 -offset {100 600}
place_pins -self -ports [get_ports *]