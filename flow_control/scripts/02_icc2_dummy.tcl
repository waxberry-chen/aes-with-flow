source flow_init.tcl
source ../${FLOW_DESIGN_NAME}.${FLOW_TAG}.usrconfig.tcl

# Exit or wait
if {[info exist FLOW_DEBUG] && [string match true $FLOW_DEBUG]} {
	echo "debug mode, pls. manual exit when done."
} else {
	exit
}
