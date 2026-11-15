create_clock -name wclk -period 10.0 [get_ports wclk]
create_clock -name rclk -period 27.0 [get_ports rclk]
set_clock_groups -asynchronous -group [get_clocks wclk] -group [get_clocks rclk]

set_max_delay 10.0 -ignore_clock_latency -from [get_clocks wclk] -to [get_clocks rclk]
set_max_delay 10.0 -ignore_clock_latency -from [get_clocks rclk] -to [get_clocks wclk]
