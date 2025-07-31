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
	input			rst_n               ,
	output			clk_1_6384m
    );
	
wire clk_16_384m;
wire clk_16_384m_t;

reg clk_1_6384m_t;
reg [2:0] clk_cnt;

assign clk_16_384m_t = clk_8_192m + clk_8_192m_90deg;

BUFG BUFG_inst1 (
      .O(clk_16_384m), // 1-bit output: Clock output
      .I(clk_16_384m_t)  // 1-bit input: Clock input
   );
   
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
   
endmodule
