open_hw
connect_hw_server
create_hw_target flash_afcv3
open_hw_target

create_hw_device -part xc7k325t
set_property PROGRAM.FILE build/zxmarcos_huedeon_huedeon_0.0.1/qmtech_xc7k325t_ddr3-vivado/zxmarcos_huedeon_huedeon_0.0.1.bit [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
write_hw_svf "build/zxmarcos_huedeon_huedeon_0.0.1/qmtech_xc7k325t_ddr3-vivado/zxmarcos_huedeon_huedeon_0.0.1.svf"

close_hw_target
exit
