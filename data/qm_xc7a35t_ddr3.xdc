create_clock -add -name clk -period 20.00 -waveform {0 5} [get_ports { CLOCK_50 }];


set_property IOSTANDARD LVCMOS33 [get_ports CLOCK_50]
set_property PACKAGE_PIN N11 [get_ports CLOCK_50]

#============================================================
# VGA
#============================================================
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[0]}]
set_property PACKAGE_PIN L4 [get_ports {VGA_R[4]}]
set_property PACKAGE_PIN K2 [get_ports {VGA_R[3]}]
set_property PACKAGE_PIN N3 [get_ports {VGA_R[2]}]
set_property PACKAGE_PIN M4 [get_ports {VGA_R[1]}]
set_property PACKAGE_PIN N2 [get_ports {VGA_R[0]}]
set_property PACKAGE_PIN H5 [get_ports {VGA_G[5]}]
set_property PACKAGE_PIN L2 [get_ports {VGA_G[4]}]
set_property PACKAGE_PIN J3 [get_ports {VGA_G[3]}]
set_property PACKAGE_PIN H4 [get_ports {VGA_G[2]}]
set_property PACKAGE_PIN H3 [get_ports {VGA_G[1]}]
set_property PACKAGE_PIN K3 [get_ports {VGA_G[0]}]
set_property PACKAGE_PIN H1 [get_ports {VGA_B[4]}]
set_property PACKAGE_PIN H2 [get_ports {VGA_B[3]}]
set_property PACKAGE_PIN J1 [get_ports {VGA_B[2]}]
set_property PACKAGE_PIN K1 [get_ports {VGA_B[1]}]
set_property PACKAGE_PIN L3 [get_ports {VGA_B[0]}]
set_property PACKAGE_PIN G1 [get_ports VGA_HS]
set_property PACKAGE_PIN G2 [get_ports VGA_VS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]


#============================================================
# Keys
#============================================================

set_property IOSTANDARD LVCMOS33 [get_ports {KEY[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[3]}]
set_property PACKAGE_PIN B7 [get_ports {KEY[0]}]
set_property PACKAGE_PIN M6 [get_ports {KEY[1]}]
set_property PACKAGE_PIN N6 [get_ports {KEY[2]}]
set_property PACKAGE_PIN R5 [get_ports {KEY[3]}]


#============================================================
# Leds
#============================================================

set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[4]}]
set_property PACKAGE_PIN R6 [get_ports {LEDR[0]}]
set_property PACKAGE_PIN T5 [get_ports {LEDR[1]}]
set_property PACKAGE_PIN R7 [get_ports {LEDR[2]}]
set_property PACKAGE_PIN T7 [get_ports {LEDR[3]}]
set_property PACKAGE_PIN R8 [get_ports {LEDR[4]}]

set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
