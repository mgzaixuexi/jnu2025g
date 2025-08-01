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
	input					clk_40_96m	,
	input					clk_50m		,
    input					rst_n   	,
	input	[1:0]			key         ,
	input					learn_en	,
	input					next_freq	,
    output	signed [9:0]	da_data		,
	output	reg	   [15:0]	freq_ctrl_t1					//Êä³öÕýÏÒ²¨ÆµÂÊ£¬freq*100
    );
	
localparam norm 	= 2'b01;
localparam learn 	= 2'b10;

reg [15:0] 	freq_ctrl_t0;	
reg [15:0] 	freq_ctrl_t2;
reg 		learn_en_d0;
reg			learn_en_d1;
reg			next_freq_d0;
reg			next_freq_d1;
reg [1:0] 	state;
reg [1:0] 	next_state;
reg 		flag;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		learn_en_d0 <= 0;
	    learn_en_d1 <= 0;
		next_freq_d0 <= 0;
	    next_freq_d1 <= 0;
		end
	else begin
		learn_en_d0 <= learn_en;
	    learn_en_d1 <= learn_en_d0;
		next_freq_d0 <= next_freq;
		next_freq_d1 <= next_freq_d0;
		end
		
dds_compiler_0 u_dds_compiler_0 (
  .aclk(clk_40_96m),                                  // input wire aclk
  .s_axis_config_tvalid(1'b1),  // input wire s_axis_config_tvalid
  .s_axis_config_tdata((freq_ctrl_t1*10 + freq_ctrl_t2)),    // input wire [23 : 0] s_axis_config_tdata
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
		freq_ctrl_t2 <= 0;
	else 
		freq_ctrl_t2 <= (freq_ctrl_t1+ 2) >> 2;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		flag <= 0;
		freq_ctrl_t1 <= 16'd1;
		freq_ctrl_t0 <= 0;
		end
	else 
		case(state)
			norm:	begin
					flag <= 0;
					if(~key[0])
			        	if(freq_ctrl_t1 == 1)
			        		freq_ctrl_t1 <= 30;
			        	else if(freq_ctrl_t1 > 30)
							case(freq_ctrl_t1)
								16'd15000:	freq_ctrl_t1 <= 16'd30;
								16'd30000:	freq_ctrl_t1 <= 16'd15000;
						    	16'd45000:	freq_ctrl_t1 <= 16'd30000;
						    	default: freq_ctrl_t1 <= 16'd45000;
						    endcase
						else 
			        		freq_ctrl_t1 <= freq_ctrl_t1 - 1'd1;
			        else if(~key[1])
			        	if(freq_ctrl_t1 >= 30)
							case(freq_ctrl_t1)
								16'd30: 	freq_ctrl_t1 <= 16'd15000;
								16'd15000:	freq_ctrl_t1 <= 16'd30000;
								16'd30000:	freq_ctrl_t1 <= 16'd45000;
								16'd45000:	freq_ctrl_t1 <= freq_ctrl_t1;
								default: freq_ctrl_t1 <= 30;
							endcase
			        	else
			        		freq_ctrl_t1 <= freq_ctrl_t1 + 1'd1;
			        else 
			        	freq_ctrl_t1 <= freq_ctrl_t1;
					if(~learn_en_d1 & learn_en_d0)
						freq_ctrl_t0 <= freq_ctrl_t1;
					end
			learn:	begin
					if(~flag) begin
						flag <= 1;
						freq_ctrl_t1 <= 10;
						end
					else 
						flag <= flag;
					if(~next_freq_d1 & next_freq_d0)
						freq_ctrl_t1 <= freq_ctrl_t1 + 16'd2;
					if(~learn_en_d0 & learn_en_d1)
						freq_ctrl_t1 <= freq_ctrl_t0;
					end
			default:begin
					flag <= 0;
			        freq_ctrl_t1 <= 16'd1;
					freq_ctrl_t0 <= freq_ctrl_t0;
			        end
		endcase
endmodule
