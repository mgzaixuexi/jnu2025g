`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:35:46 07/30/2024 
// Design Name: 
// Module Name:    seg_led 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seg_led(
    input sys_clk,//系统时钟
	 input sys_rst_n,
	 input [3:0] num1,//接freq_select1，或者说是waveA_freq
	 input [15:0] num2,
	 input	learn_done,
	 output reg [4:0] seg_sel,
	 output reg [7:0]seg_led
    );
	
wire [3:0]	data1;
wire [3:0]	data2;
wire [3:0] data3;	
wire [3:0] data4;	
wire [3:0] data5;	
	
reg [15:0] counter;
reg	learn_done_d0;
reg	learn_done_d1;
reg learn_done_r;

parameter F=50_000;

assign data1 = num2 % 10;
assign data2 = num2 /10 % 10;
assign data3 = num2 /100 % 10;
assign data4 = num2 /1000 % 10;
assign data5 = num2 /10000;

/* always@(posedge sys_clk or negedge sys_rst_n)
    if(!sys_rst_n)
		data3 <= 0;
	else 
		case(num2)
			16'd15000:	data3 <= 4'd1;
			16'd30000:	data3 <= 4'd2;
			16'd45000:	data3 <= 4'd3;
			default:	data3 <= 0;
		endcase */

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) counter<=0;
	 else if(counter<(F-1)) counter<=counter+1;
	 else counter<=0;
end

always@(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)
		learn_done_r <= 0;
	else if(~learn_done_d1 & learn_done_d0)
		learn_done_r <= 1;
	else if(~learn_done_d0 & learn_done_d1)
		learn_done_r <= 0;
	else 
		learn_done_r <= learn_done_r;

always@(posedge sys_clk or negedge sys_rst_n) 
    if(!sys_rst_n)begin
		learn_done_d0 <= 0;
		learn_done_d1 <= 0;
		end
	else begin	
		learn_done_d0 <= learn_done;
		learn_done_d1 <= learn_done_d0;	
		end	

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) seg_sel<=5'b11_110;
	 else if(counter==(F-1)) seg_sel<={seg_sel[3:0],seg_sel[4]};
	 else seg_sel<=seg_sel;
end

always@(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) seg_led<=8'b0;
	 else case(seg_sel)
	 5'b11_110: seg_led<=(~led(data5));
	 5'b11_101:	seg_led<=(~led(data4));
	 5'b11_011:	seg_led<=(~led(data3));
	 5'b10_111:	seg_led<=(~led(data2));
	 5'b01_111: seg_led<=(~led(data1));
	 default: seg_led<=8'b0; 
	 endcase
end

function [7:0]led;
input [3:0]num0;
    case (num0)
    4'h0 : led = 8'b1100_0000; 
    4'h1 : led = 8'b1111_1001; 
    4'h2 : led = 8'b1010_0100; 
    4'h3 : led = 8'b1011_0000;
    4'h4 : led = 8'b1001_1001; 
    4'h5 : led = 8'b1001_0010; 
    4'h6 : led = 8'b1000_0010; 
    4'h7 : led = 8'b1111_1000; 
    4'h8 : led = 8'b1000_0000; 
    4'h9 : led = 8'b1001_0000; 
    default : led = 8'b1111_1111;
    endcase
endfunction

endmodule
