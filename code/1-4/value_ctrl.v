`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/27 14:50:55
// Design Name: 
// Module Name: ram_wr_ctrl
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

module value_ctrl
(
	input 			 	 clk,//fft时钟
	input			 	 rst_n,//复位，接（rst_n&key）key是启动键 
	input                key1,
	input                key2,
	output reg [4:0]	 out_value
);

reg key_d0;
reg key_d1;
reg key1_d0;
reg key1_d1;

wire start1;
wire start2;

assign start1 = ~key_d0 & key_d1 ;//下降沿 
assign start2 = ~key1_d0 & key1_d1 ;//下降沿�?��?

always @(posedge clk or negedge  rst_n)begin
	if(~rst_n)begin
		key_d0 <= 1;
		key_d1 <= 1;
	end
	else begin
		key_d0 <= key1;
		key_d1 <= key_d0;
	end
end

always @(posedge clk or negedge  rst_n)begin
	if(~rst_n)begin
		key1_d0 <= 1;
		key1_d1 <= 1;
	end
	else begin
		key1_d0 <= key2;
		key1_d1 <= key1_d0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		out_value <= 5'd10;
	else 
    begin if(start1)
    begin
        if(out_value>=5'd20) out_value <= 5'd10;
        else out_value <= out_value+1;
    end
	else if(start2)
    begin
        if(out_value<=5'd10) out_value <= 5'd20;
        else out_value <= out_value-1;
    end
    else out_value<=out_value;
    end
end


	

		
endmodule
	
	