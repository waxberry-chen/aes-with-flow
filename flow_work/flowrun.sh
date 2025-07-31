# Flowrun initialize
FLOWRUN_PATH="$PWD/../flow_control"
export PATH="$PATH:$FLOWRUN_PATH"

# Check
if [ -f "$FLOWRUN_PATH/flowrun" ]; then
    chmod +x "$FLOWRUN_PATH/flowrun"
    echo "INFO: flowrun has been activated"
else
    echo "ERROR: flowwrun can not be found in '$FLOWRUN_PATH'"
fi
