#####set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets D0_clk_50m_xout/inst/clk_in1_clk_50MHz_Xout] 
# 在.xdc文件中添加以下约束

# 在 XDC 约束文件中修改为 3.3V 标准
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
# 时钟定义（根据实际频率调整）
create_clock -period 20.000 -name sys_clk [get_ports sys_clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets u_clk_wiz_0/inst/clk_in1_clk_wiz_0]

# 设置时钟不确定性
set_clock_uncertainty 0.500 [get_clocks sys_clk]

set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports sys_clk]
 
set_property -dict {PACKAGE_PIN AD19 IOSTANDARD LVCMOS33} [get_ports sys_rst_n]

set_property -dict {PACKAGE_PIN AF20 IOSTANDARD LVCMOS33} [get_ports key[0]]
set_property -dict {PACKAGE_PIN AE20 IOSTANDARD LVCMOS33} [get_ports key[1]]
set_property -dict {PACKAGE_PIN AE21 IOSTANDARD LVCMOS33} [get_ports key[2]]

set_property -dict {PACKAGE_PIN W14  IOSTANDARD LVCMOS33} [get_ports seg_sel[0]]
set_property -dict {PACKAGE_PIN W15  IOSTANDARD LVCMOS33} [get_ports seg_sel[1]]
set_property -dict {PACKAGE_PIN Y15  IOSTANDARD LVCMOS33} [get_ports seg_sel[2]]
set_property -dict {PACKAGE_PIN AC16 IOSTANDARD LVCMOS33} [get_ports seg_sel[3]]
set_property -dict {PACKAGE_PIN AF22 IOSTANDARD LVCMOS33} [get_ports seg_sel[4]]  

set_property -dict {PACKAGE_PIN U14  IOSTANDARD LVCMOS33} [get_ports seg_led[0]]
set_property -dict {PACKAGE_PIN R16  IOSTANDARD LVCMOS33} [get_ports seg_led[1]]
set_property -dict {PACKAGE_PIN N16  IOSTANDARD LVCMOS33} [get_ports seg_led[2]]
set_property -dict {PACKAGE_PIN U15  IOSTANDARD LVCMOS33} [get_ports seg_led[3]]
set_property -dict {PACKAGE_PIN T14  IOSTANDARD LVCMOS33} [get_ports seg_led[4]] 
set_property -dict {PACKAGE_PIN T15  IOSTANDARD LVCMOS33} [get_ports seg_led[5]]
set_property -dict {PACKAGE_PIN V14  IOSTANDARD LVCMOS33} [get_ports seg_led[6]]
set_property -dict {PACKAGE_PIN P16  IOSTANDARD LVCMOS33} [get_ports seg_led[7]] 

####------DAC J1
set_property -dict {PACKAGE_PIN B1  IOSTANDARD LVCMOS33} [get_ports da_clk]
set_property -dict {PACKAGE_PIN F7  IOSTANDARD LVCMOS33} [get_ports da_data[0]]
set_property -dict {PACKAGE_PIN D6  IOSTANDARD LVCMOS33} [get_ports da_data[1]]
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [get_ports da_data[2]]
set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS33} [get_ports da_data[3]]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports da_data[4]] 
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports da_data[5]]
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports da_data[6]]
set_property -dict {PACKAGE_PIN C3  IOSTANDARD LVCMOS33} [get_ports da_data[7]]  
set_property -dict {PACKAGE_PIN A2  IOSTANDARD LVCMOS33} [get_ports da_data[8]]
set_property -dict {PACKAGE_PIN B2  IOSTANDARD LVCMOS33} [get_ports da_data[9]]


#-----------------LCD DISPLAY [23:0]= {R,G,B}
set_property -dict {PACKAGE_PIN AB24  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[0]}]
set_property -dict {PACKAGE_PIN AA23  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[1]}]
set_property -dict {PACKAGE_PIN AA22  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[2]}]
set_property -dict {PACKAGE_PIN Y23   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[3]}]
set_property -dict {PACKAGE_PIN W24   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[4]}]
set_property -dict {PACKAGE_PIN U22   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[5]}]
set_property -dict {PACKAGE_PIN W23   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[6]}]
set_property -dict {PACKAGE_PIN V24   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[7]}]

set_property -dict {PACKAGE_PIN AA19  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[8]}]
set_property -dict {PACKAGE_PIN Y18   IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[9]}]
set_property -dict {PACKAGE_PIN AC21  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[10]}]
set_property -dict {PACKAGE_PIN AC22  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[11]}]
set_property -dict {PACKAGE_PIN AC23  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[12]}]
set_property -dict {PACKAGE_PIN AC24  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[13]}]
set_property -dict {PACKAGE_PIN AB22  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[14]}]
set_property -dict {PACKAGE_PIN AB25  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[15]}]

set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[16]}]
set_property -dict {PACKAGE_PIN AA17 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[17]}]
set_property -dict {PACKAGE_PIN AA18 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[18]}]
set_property -dict {PACKAGE_PIN AB19 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[19]}]
set_property -dict {PACKAGE_PIN AC19 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[20]}]
set_property -dict {PACKAGE_PIN AB20 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[21]}]
set_property -dict {PACKAGE_PIN AA20 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[22]}]
set_property -dict {PACKAGE_PIN AD21 IOSTANDARD LVCMOS33} [get_ports {lcd_rgb[23]}]

set_property -dict {PACKAGE_PIN T24  IOSTANDARD LVCMOS33} [get_ports lcd_hs]
set_property -dict {PACKAGE_PIN R23  IOSTANDARD LVCMOS33} [get_ports lcd_vs]
set_property -dict {PACKAGE_PIN P24  IOSTANDARD LVCMOS33} [get_ports lcd_de]
set_property -dict {PACKAGE_PIN P23  IOSTANDARD LVCMOS33} [get_ports lcd_bl]
set_property -dict {PACKAGE_PIN U24  IOSTANDARD LVCMOS33} [get_ports lcd_clk]
set_property -dict {PACKAGE_PIN L20  IOSTANDARD LVCMOS33} [get_ports lcd_rst_n]

#LCD TOUCH
set_property -dict {PACKAGE_PIN L23 IOSTANDARD LVCMOS33} [get_ports touch_scl]
set_property -dict {PACKAGE_PIN M24 IOSTANDARD LVCMOS33} [get_ports touch_sda]
set_property -dict {PACKAGE_PIN L22 IOSTANDARD LVCMOS33} [get_ports touch_int]
set_property -dict {PACKAGE_PIN N24 IOSTANDARD LVCMOS33} [get_ports touch_rst_n]
