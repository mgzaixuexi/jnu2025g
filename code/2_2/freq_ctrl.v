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


module freq_ctrl_2(
	input					clk_6_5536m	,
	input					clk_50m		,
    input					rst_n   	,
	input					learn_en	,
	input					next_freq	,
    output	signed [9:0]	da_data		,
	output	reg	   [15:0]	freq_ctrl_t1					//Êä³öÕýÏÒ²¨ÆµÂÊ£¬freq*100
    );
	
localparam norm 	= 2'b01;
localparam learn 	= 2'b10;

reg			next_freq_d0;
reg			next_freq_d1;
reg [1:0] 	state;
reg [1:0] 	next_state;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		next_freq_d0 <= 0;
	    next_freq_d1 <= 0;
		end
	else begin
		next_freq_d0 <= next_freq;
		next_freq_d1 <= next_freq_d0;
		end

dds_compiler_0 u_dds_compiler_2 (
  .aclk(clk_6_5536m),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata(freq_ctrl_t1),    // input wire [15 : 0] s_axis_config_tdata
  .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
  .m_axis_data_tdata(da_data)        // output wire [15 : 0] m_axis_data_tdata
);

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		state <= norm;
	else 
		state <= next_state;
		
always @(*)
	case(state)	
		norm:	if(learn_en)
					next_state = learn;
				else 
					next_state = norm;
		learn:	if(~learn_en)
					next_state = norm;
				else 
					next_state = learn;
		default:next_state = norm;
	endcase

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		freq_ctrl_t1 <= 16'd1;
	else 
		case(state)
			norm:	begin
					freq_ctrl_t1 <= 16'd1;
					if(learn_en)
						freq_ctrl_t1 <= 16'd4;
					end
			learn:	if(~next_freq_d1 & next_freq_d0)
						freq_ctrl_t1 <= freq_ctrl_t1 + 16'd1;
					else 
						freq_ctrl_t1 <= freq_ctrl_t1;
			default:freq_ctrl_t1 <= 16'd1;
		endcase
endmodule
