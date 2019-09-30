-- rightmost slider switches
set_property PACKAGE_PIN G15 [get_ports {UD}]
set_property IOSTANDARD LVCMOS33 [get_ports {UD}]

-- LEDs
set_property PACKAGE_PIN D18 [get_ports {Y[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[3]}]
set_property PACKAGE_PIN G14 [get_ports {Y[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[2]}]
set_property PACKAGE_PIN M15 [get_ports {Y[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[1]}]
set_property PACKAGE_PIN M14 [get_ports {Y[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Y[0]}]

-- rightmost pushbutton
set_property PACKAGE_PIN K18 [get_ports {R}]
set_property IOSTANDARD LVCMOS33 [get_ports {R}]

-- clock
set_property PACKAGE_PIN K17 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]