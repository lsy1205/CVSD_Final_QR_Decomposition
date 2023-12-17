set_clock_latency -source -early -max -rise  -0.829098 [get_ports {i_clk}] -clock i_clk 
set_clock_latency -source -early -max -fall  -0.874405 [get_ports {i_clk}] -clock i_clk 
set_clock_latency -source -late -max -rise  -0.829098 [get_ports {i_clk}] -clock i_clk 
set_clock_latency -source -late -max -fall  -0.874405 [get_ports {i_clk}] -clock i_clk 
