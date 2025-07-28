#---------------------------------------
#flow config file
#defaults
#revision 1.0
#---------------------------------------


#---------------------------------------
#step settings:stepnum stepname toolname toolscript predecessor runmode(only serial now)
set FLOW_STEPS " \
step1: syn dc_shell ../../flow_control/scripts/01_dc_syn.tcl ../global_input serial \
step2: place icc2_shell ../../flow_control/scripts/02_icc2_place.tcl ./results/syn_${FLOW_TAG}/output serial \
step3: clock icc2_shell ../../flow_control/scripts/03_icc2_clock.tcl ./results/place_${FLOW_TAG}/output serial \
step4: clockopt icc2_shell ../../flow_control/scripts/04_icc2_clock_opt.tcl ./results/clock_${FLOW_TAG}/output serial \
step5: route icc2_shell ../../flow_control/scripts/05_icc2_route.tcl ./results/clockopt_${FLOW_TAG}/output serial \
step6: routeopt icc2_shell ../../flow_control/scripts/06_icc2_routeopt.tcl ./results/route_${FLOW_TAG}/output serial \
"

#---------------------------------------
#parm settints
set FLOW_CORE_NUM 8
set FLOW_INCOMING_DIR "../incoming"


#dc syn
set FLOW_PRE_ELAB_SCRIPT "./scripts/pre_elab.tcl"
set FLOW_POST_ELAB_SCRIPT "./scripts/post_elab.tcl"


#dc syn scan
set FLOW_PRE_SCAN_SCRIPT "./scripts/pre_scan.tcl"
set FLOW_POST_SCAN_SCRIPT "./scripts/post_scan.tcl"



#innovus pr outline
set FLOW_PRE_OUTLINE_SCRIPT "./scripts/pre_outline.tcl"
set FLOW_POST_OUTLINE_SCRIPT "./scripts/post_outline.tcl"

#innovus pr placemacro
set FLOW_PRE_PLACEMACRO_SCRIPT "./scripts/pre_placemacro.tcl"
set FLOW_POST_PLACEMACRO_SCRIPT "./scripts/post_placemacro.tcl"


#innovus pr assignport
set FLOW_PRE_ASSIGNPORT_SCRIPT "./scripts/pre_assignport.tcl"
set FLOW_POST_ASSIGNPORT_SCRIPT "./scripts/post_assignport.tcl"


#innovus routing layer
set FLOW_MAX_ROUTING_LAYER 10

#innovus ccopt
set FLOW_PRE_CCOPT_SCRIPT "./scripts/pre_ccopt.tcl"
set FLOW_POST_CCOPT_SCRIPT "./scripts/post_ccopt.tcl"


#pt scenario
set FLOW_PBA_MODE "path";#exhaustive


