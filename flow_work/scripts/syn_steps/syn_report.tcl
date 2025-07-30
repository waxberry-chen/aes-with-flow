# ==============================================================================
# file:    [report.tcl]
# author:  [cjy]
# created: [2025-06-13]
# lastest: [2025-06-13]
# version: [1.0.0]
# about:   [This file is to generate report for every step for contrainting , 
#           excluding check_design, timing, area and so on]
# ==============================================================================

set maxpaths 10
set nworst 5

#only save the lastest report
if {[file exists "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"]} {
    file delete "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
    puts "Old report file '${FLOW_STEP_REPORTS_DIR}/${rpt_file}' deleted."
}


echo "============================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "==========     Design Synthesis Report Start     ===========" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "============================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 


# 1. Check Design Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Check Design Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
check_design >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Check Design Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 2. Area Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Area Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_area >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Area Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 3. Design Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Design Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_design >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Design Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"  

# 4. Cell Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Cell Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_cell >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Cell Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 5. Reference Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Reference Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_reference >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Reference Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 6. Port Report (Verbose)
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Port Report (Verbose) -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_port -verbose >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Port Report (Verbose) ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 7. Net Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Net Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_net >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Net Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 8. Compile Options Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Compile Options Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_compile_options >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Compile Options Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 9. Constraint Report (All Violators, Verbose)
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Constraint Report  -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_constraint -all_violators -verbose >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Constraint Report  ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 10. Timing Report (End Path)
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Timing Report (End Path) -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_timing -path end >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Timing Report (End Path) ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 11. Timing Report (Max Paths)
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of Timing Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_timing -max_paths $maxpaths -nworst $nworst >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of Timing Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# 12. QoR Report
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- Start of QoR Report -------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
report_qor >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "------------------- End of QoR Report ---------------------" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 
echo "" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}" 

# --- 报告生成结束 ---
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "==================== Design Synthesis Report End ====================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"
echo "=====================================================================" >> "${FLOW_STEP_REPORTS_DIR}/${rpt_file}"