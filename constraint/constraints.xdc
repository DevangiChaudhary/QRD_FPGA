# Clock
create_clock -period 3.610 -name clk [get_ports clk]

# IO standards
set_property IOSTANDARD LVCMOS33 [get_ports {clk start done}]

# Pin assignments (FIXED EXAMPLE — adjust if needed)
set_property PACKAGE_PIN IO_L12P_T1_MRCC_16 [get_ports clk]
set_property PACKAGE_PIN IO_L7P_T1_16       [get_ports start]
set_property PACKAGE_PIN IO_L7N_T1_16       [get_ports done]

# Keep hierarchy (optional)
set_property KEEP_HIERARCHY yes [get_cells ctrl]
set_property KEEP_HIERARCHY yes [get_cells dp]
