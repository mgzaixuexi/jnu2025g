`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/31 10:13:17
// Design Name: 
// Module Name: learn_ctrl
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


module learn_ctrl(
	input						clk_50m		,
	input						clk_1_6384m	,
	input						rst_n   	,
	input						key         ,
	input 		signed	[23:0]	fft_real	,
	input 		signed	[23:0]	fft_imag	,
	input 						source_valid,
	input				[15:0]	freq		,
	input						fft_tready	,
	output	reg					learn_en	,
	output	reg					next_freq	,
	output	reg					fft_valid	,
	output	reg					wr_en		,
	output	reg	signed	[23:0]	wr_real		,
	output	reg signed	[23:0]	wr_imag		,
	output	reg 		[11:0]	wr_addr		,
	output				[23:0]	data_modulus,
	output 				[11:0]	modulus_addr,
	output	reg					modulus_wren,
	output	reg					learn_done		//有上升沿说明学习完毕（实部虚部写入完毕）
    );
	
localparam	idle	=	4'b0001;
localparam	setup	=	4'b0010;	
localparam	delay	=	4'b0100;	
localparam	write	=	4'b1000;

parameter index_max 	= 2751;	
parameter delay_value	= 50_000 * 3 - 3;
	
reg [12:0] 	fft_index;
reg [3:0]	state;
reg	[3:0]	next_state;
reg	[4:0]	flag;
reg	[17:0]	delay_cnt;
reg signed [47:0] source_data;

reg key_d0;
reg key_d1;
reg modulus_valid_d0;
reg modulus_valid_d1;

wire start;
wire modulus_valid;

assign start = key_d0 & ~key_d1;
assign modulus_addr = wr_addr - 1'b1;

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		delay_cnt <= 0;
	else if(state == delay)
		if(delay_cnt >= delay_value)
			delay_cnt <= delay_cnt;
		else 
			delay_cnt <= delay_cnt + 1'b1;
	else 
		delay_cnt <= 0;

always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)
		fft_index <= 0;
	else if(source_valid)
		if(fft_index >= index_max + 3)
			fft_index <= fft_index;
		else 
			fft_index <= fft_index + 1'b1;
	else 
		fft_index <= 0;
		
always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)begin
		key_d0 <= 0;
		key_d1 <= 0;
		modulus_valid_d0 <= 0;
		modulus_valid_d1 <= 0;
		end
	else begin	
		key_d0 <= key; 
	    key_d1 <= key_d0;
		modulus_valid_d0 <= modulus_valid;
		modulus_valid_d1 <= modulus_valid_d0;
		end
	
always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)
		learn_en <= 0;
	else if(state != idle)
		learn_en <= 1;
	else 
		learn_en <= 0;
		
//三段式状态机
always @(posedge clk_50m or negedge  rst_n)
	if(~rst_n)
		state <= idle;
	else 
		state <= next_state;

always @(*) begin
    case(state)
		idle:	if(start)
					next_state = setup;
				else 
					next_state = idle;
		setup:	if(freq >= index_max)
					next_state = idle;
				else if(flag[0])
					next_state = delay;
				else 
					next_state = setup;
		delay:	if(flag[1])
					next_state = write;
				else 
					next_state = delay;
		write:	if(flag[4])
		        	next_state = setup;
		        else 
		        	next_state = write;
		default:next_state = idle;
	endcase
	end

always @(posedge clk_1_6384m or negedge  rst_n)
	if(~rst_n)begin
		next_freq	<= 0;
		fft_valid	<= 0;
		wr_en		<= 0;
		wr_real		<= 0;
		wr_imag		<= 0;
		wr_addr		<= 0;
		learn_done	<= 1;
		flag		<= 5'b10000;
		end
	else 
		case(state)
			idle:	begin
					next_freq	<= 0;
			        fft_valid	<= 0;
			        wr_en		<= 0;
			        wr_real		<= 0;
			        wr_imag		<= 0;
			        wr_addr		<= 0;
            		learn_done	<= 1;
					flag		<= 5'b10000;
            		end
            setup:	begin
					learn_done	<= 0;
					next_freq <= 1;
					fft_valid <= 0;
					wr_en <= 0;
					flag <= {flag[3:0],flag[4]};
            		end
            delay:	begin
					if(delay_cnt >= delay_value)begin
						fft_valid <= 1;
						flag <= {flag[3:0],flag[4]};
						end
					else begin
						fft_valid <= fft_valid;
						flag <= flag;
						end
            		end
            write:	begin
					next_freq <= 0;
					if(fft_index  == freq)begin
						wr_en <= 1;
						wr_real <= fft_real;
						wr_imag <= fft_imag;
						flag <= {flag[3:0],flag[4]};
						end
					else begin
						wr_en <= wr_en;
						wr_real <= wr_real;
						wr_imag <= wr_imag;
						end
					if(flag[2])
						flag <= {flag[3:0],flag[4]};
					else if(flag[3])begin
						flag <= {flag[3:0],flag[4]};
						wr_addr <= wr_addr + 1'b1;
						end
					else 
						wr_addr <= wr_addr ;
					end 
		    default:begin
					next_freq	<= 0;
			        fft_valid	<= 0;
			        wr_en		<= 0;
			        wr_real		<= 0;
			        wr_imag		<= 0;
			        wr_addr		<= 0;
            		learn_done	<= 0;
					flag		<= 4'b1000;
            		end
		endcase


		
always @(posedge clk_1_6384m or negedge rst_n) 
    if (!rst_n) 
		source_data <= 0;
	else if(flag[2])
		source_data <= wr_imag * wr_imag + wr_real * wr_real;
	else 
		source_data <= source_data;
		
cordic_0 u_cordic_0 (
  .aclk(clk_1_6384m),                                        // input wire aclk
  .s_axis_cartesian_tvalid(flag[3]),  // input wire s_axis_cartesian_tvalid
  .s_axis_cartesian_tdata(source_data),    // input wire [47 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(modulus_valid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(data_modulus)              // output wire [31 : 0] m_axis_dout_tdata
);

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		modulus_wren <= 0;
	else if(~modulus_valid_d1 & modulus_valid_d0)
		modulus_wren <= 1;
	else if(~modulus_valid_d0 & modulus_valid_d1)
		modulus_wren <= 0;
	else 
		modulus_wren <= modulus_wren;
		
endmodule
