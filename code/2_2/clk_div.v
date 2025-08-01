`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/31 10:47:50
// Design Name: 
// Module Name: clk_div
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


module clk_div(
	input			clk_8_192m			,
	input			clk_8_192m_90deg	,
	input			clk_65_536m			,
	input			rst_n               ,
	output			clk_1_6384m			,
	output			clk_6_5536m		
    );
	
wire clk_16_384m;
reg clk_6_5536m_t;
reg clk_16_384m_t;

reg clk_1_6384m_t;
reg [2:0] clk_cnt;
reg [2:0] clk_cnt1;

always @(*)
	clk_16_384m_t = clk_8_192m_90deg + clk_8_192m;

BUFG BUFG_inst1 (
      .O(clk_16_384m), // 1-bit output: Clock output
      .I(clk_16_384m_t)  // 1-bit input: Clock input
   );
   
always @(posedge clk_65_536m or negedge rst_n)
	if(~rst_n)
		clk_cnt1 <= 0;
	else if(clk_cnt1 >= 5 - 1)
		clk_cnt1 <= 0;
	else 
		clk_cnt1 <= clk_cnt1 + 1'b1;
   
always @(posedge clk_65_536m or negedge rst_n)
	if(~rst_n)
		clk_6_5536m_t <= 0;
	else if(clk_cnt1 >= 5 - 1)
		clk_6_5536m_t <= ~clk_6_5536m_t;
	else 
		clk_6_5536m_t <= clk_6_5536m_t;
   
always @(posedge clk_16_384m or negedge rst_n)
	if(~rst_n)
		clk_cnt <= 0;
	else if(clk_cnt >= 5 - 1)
		clk_cnt <= 0;
	else 
		clk_cnt <= clk_cnt + 1'b1;

always @(posedge clk_16_384m or negedge rst_n)
	if(~rst_n)
		clk_1_6384m_t <= 0;
	else if(clk_cnt >= 5 - 1)
		clk_1_6384m_t <= ~clk_1_6384m_t;
	else 
		clk_1_6384m_t <= clk_1_6384m_t;
		
BUFG BUFG_inst2 (
      .O(clk_1_6384m), // 1-bit output: Clock output
      .I(clk_1_6384m_t)  // 1-bit input: Clock input
   );
   
BUFG BUFG_inst3 (
      .O(clk_6_5536m), // 1-bit output: Clock output
      .I(clk_6_5536m_t)  // 1-bit input: Clock input
   );
   
endmodule
