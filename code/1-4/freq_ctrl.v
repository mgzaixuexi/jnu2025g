`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 14:56:22
// Design Name: 
// Module Name: freq_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module freq_ctrl(
	input				clk_40_96m	,
	input				clk_50m		,
    input				rst_n   	,
	input	[1:0]		key         ,
    output	signed [9:0]da_data		,
	output	[5:0]		freq			//Êä³öÕýÏÒ²¨ÆµÂÊ£¬freq*100
    );
	
reg [5:0] freq_ctrl_t1;
reg [5:0] freq_ctrl_t2;
	
assign freq = freq_ctrl_t1;
	
dds_compiler_0 u_dds_compiler_0 (
  .aclk(clk_40_96m),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata((freq_ctrl_t1*10+freq_ctrl_t2)),    // input wire [23 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(da_data)        // output wire [15 : 0] m_axis_data_tdata
);


always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		freq_ctrl_t2 <= 0;
	else 
		freq_ctrl_t2 <= (freq_ctrl_t1+ 2) >> 2;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		freq_ctrl_t1 <= 6'd1;
	else if(~key[0])
		if(freq_ctrl_t1 == 1)
			freq_ctrl_t1 <= 30;
		else
			freq_ctrl_t1 <= freq_ctrl_t1 - 1'd1;
	else if(~key[1])
		if(freq_ctrl_t1 == 30)
			freq_ctrl_t1 <= 1;
		else
			freq_ctrl_t1 <= freq_ctrl_t1 + 1'd1;
	else 
		freq_ctrl_t1 <= freq_ctrl_t1;
	
	
endmodule
