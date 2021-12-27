create_clock -add -name clk -period 20.00 -waveform {0 10} [get_ports { CLOCK_50 }];

set_property CFGBVS VCCO                        			[current_design]
set_property CONFIG_VOLTAGE 3.3                 			[current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 			 	[current_design]
set_property BITSTREAM.General.UnconstrainedPins {Allow}	[current_design]

set_property IOSTANDARD LVCMOS33 	[get_ports CLOCK_50]
set_property PACKAGE_PIN F22 		[get_ports CLOCK_50]

#============================================================
# VGA
#============================================================
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_B[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_G[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_R[3]}]

set_property PACKAGE_PIN P23 [get_ports {VGA_R[7]}]
set_property PACKAGE_PIN P25 [get_ports {VGA_R[6]}]
set_property PACKAGE_PIN N26 [get_ports {VGA_R[5]}]
set_property PACKAGE_PIN N23 [get_ports {VGA_R[4]}]
set_property PACKAGE_PIN M26 [get_ports {VGA_R[3]}]

set_property PACKAGE_PIN T22 [get_ports {VGA_G[7]}]
set_property PACKAGE_PIN U25 [get_ports {VGA_G[6]}]
set_property PACKAGE_PIN R22 [get_ports {VGA_G[5]}]
set_property PACKAGE_PIN T23 [get_ports {VGA_G[4]}]
set_property PACKAGE_PIN R23 [get_ports {VGA_G[3]}]
set_property PACKAGE_PIN R25 [get_ports {VGA_G[2]}]

set_property PACKAGE_PIN V26 [get_ports {VGA_B[7]}]
set_property PACKAGE_PIN U26 [get_ports {VGA_B[6]}]
set_property PACKAGE_PIN V24 [get_ports {VGA_B[5]}]
set_property PACKAGE_PIN V23 [get_ports {VGA_B[4]}]
set_property PACKAGE_PIN U24 [get_ports {VGA_B[3]}]

set_property PACKAGE_PIN W26 [get_ports VGA_HS]
set_property PACKAGE_PIN W25 [get_ports VGA_VS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]


#============================================================
# Keys
#============================================================

set_property IOSTANDARD LVCMOS33 [get_ports {KEY[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {KEY[3]}]
set_property PACKAGE_PIN AD21 	[get_ports {KEY[0]}]
set_property PACKAGE_PIN B20 	[get_ports {KEY[1]}]
set_property PACKAGE_PIN A20 	[get_ports {KEY[2]}]
set_property PACKAGE_PIN C19 	[get_ports {KEY[3]}]


#============================================================
# Leds
#============================================================

set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDR[4]}]

set_property PACKAGE_PIN A18 	[get_ports {LEDR[0]}]
set_property PACKAGE_PIN A19 	[get_ports {LEDR[1]}]
set_property PACKAGE_PIN C17 	[get_ports {LEDR[2]}]
set_property PACKAGE_PIN C18 	[get_ports {LEDR[3]}]
set_property PACKAGE_PIN E18 	[get_ports {LEDR[4]}]
