`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 16:18:40
// Design Name: 
// Module Name: tb_1_34
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


module tb_1_34(

    );
	
reg 			sys_clk	        ;
reg 			sys_rst_n       ;
reg [2:0]		key             ;
wire				da_clk      ;
wire	[9:0]		da_data     ;
wire	[4:0]  seg_sel          ;
wire	[7:0]  seg_led          ;

initial begin
	sys_clk = 0;
	forever #10 sys_clk = ~sys_clk ;
end

initial begin
	sys_rst_n=0;
	key = 3'b111;
	#100 sys_rst_n = 1;
end
	
top u_top(
	.sys_clk	(sys_clk),
	.sys_rst_n  (sys_rst_n),
	.key        (key),
	.da_clk     (da_clk),
	.da_data    (da_data),
	.seg_sel	(seg_sel),
	.seg_led    (seg_led)
);	
endmodule
