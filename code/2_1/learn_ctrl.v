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
	input 		signed	[15:0]	fft_real	,
	input 		signed	[15:0]	fft_imag	,
	input 						source_valid,
	input				[15:0]	freq		,
	//input				[15:0]	fft_index	,
	input				[7:0]	blk_exp		,	//缩小倍数，2^blk_exp
	output	reg					learn_en	,
	output	reg					next_freq	,
	output	reg					fft_valid	,
	output	reg					wr_en		,
	output	reg	signed	[15:0]	wr_real		,
	output	reg signed	[15:0]	wr_imag		,
	output	reg 		[11:0]	wr_addr		,
	output 	reg			[2:0]	filter_type	,
	output	reg					learn_done	,	//有上升沿说明学习完毕（实部虚部写入完毕）
	output				[15:0]	modulus_data_t1
    );
	
localparam	idle	=	4'b0001;
localparam	setup	=	4'b0010;	
localparam	delay	=	4'b0100;	
localparam	write	=	4'b1000;

parameter index_max 	= 16'd2751;	
parameter delay_value	= 50_000 * 3 - 3;
parameter blk_exp_norm	= 8;
parameter compare_num	= 250;
	
reg [3:0]	state;
reg	[3:0]	next_state;
reg	[4:0]	flag;
reg [3:0]	move_point;
reg	[17:0]	delay_cnt;
reg signed [31:0] source_data;
reg [15:0] fft_index;

reg key_d0;
reg key_d1;
reg modulus_valid_d0;
reg modulus_valid_d1;

wire start;
wire modulus_valid;
wire [11:0] modulus_index;
wire [15:0] data_modulus;

assign start = key_d0 & ~key_d1;
assign modulus_index = wr_addr - 1'b1;

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
		fft_index <= fft_index + 1'b1;
	else 
		fft_index <= 0;
	
always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)
		move_point <= 0;
	else if(source_valid)
		if(blk_exp == blk_exp_norm)
			move_point <= 0;
		else if(blk_exp > blk_exp_norm)
			move_point <= blk_exp - blk_exp_norm ;
		else if(blk_exp < blk_exp_norm)
			move_point <= blk_exp_norm - blk_exp ;
		else 
			move_point <= move_point;
	else 
		move_point <= move_point;
		
always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)begin
		key_d0 <= 1;
		key_d1 <= 1;
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
always @(posedge clk_1_6384m or negedge  rst_n)
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
		default:next_state = setup;
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
					if(flag[0])
						flag <= flag;
					else 						
						flag <= {flag[3:0],flag[4]};
					wr_real <= wr_real;
					wr_imag <= wr_imag;
            		end
            delay:	begin
					learn_done <= 0;
					wr_en <= 0;
					next_freq <= 1;
					wr_real <= wr_real;
					wr_imag <= wr_imag;
					if(delay_cnt >= delay_value && (~flag[1]))begin
						fft_valid <= 1;
						flag <= {flag[3:0],flag[4]};
						end
					else begin
						fft_valid <= fft_valid;
						flag <= flag;
						end
					end
            write:	begin
					fft_valid <= 1;
					next_freq <= 0;
					learn_done <= 0;
					if(source_valid)
						if(fft_index  == freq)begin
							wr_en <= 1;							
							flag <= {flag[3:0],flag[4]};
							if(blk_exp > blk_exp_norm)begin
								wr_real <= (fft_real <<< move_point);
								wr_imag <= (fft_imag <<< move_point);
								end
							else if(blk_exp < blk_exp_norm)begin
								wr_real <= (fft_real >>> move_point);
							    wr_imag <= (fft_imag >>> move_point);
								end
							else begin
								wr_real <= fft_real ;
							    wr_imag <= fft_imag ;
								end
							end
						else begin
							wr_en <= wr_en;
							wr_real <= wr_real;
							wr_imag <= wr_imag;
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
					flag		<= 5'b10000;
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
  .s_axis_cartesian_tdata(source_data),    // input wire [31 : 0] s_axis_cartesian_tdata
  .m_axis_dout_tvalid(modulus_valid),            // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(data_modulus)              // output wire [23 : 0] m_axis_dout_tdata
);


reg [15:0] 	modulus_data_t;
reg 		rising_edge	;
reg 		downing_edge;
reg	[11:0]	rise_index	;
reg	[11:0]	down_index	;

assign modulus_data_t1 = data_modulus;
		
always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)begin
		modulus_data_t	<= 0;
		rising_edge		<= 0;
		downing_edge	<= 0;
		rise_index		<= 0;
		down_index		<= 0;
		end
	else if(~modulus_valid_d1 & modulus_valid_d0)
		if(modulus_index  == 0)begin
			modulus_data_t <= data_modulus;
			/* rising_edge		<= rising_edge	   ;
			downing_edge	<= downing_edge    ;
			rise_index		<= rise_index	   ;
			down_index		<= down_index	   ; */
			end
		else if(data_modulus > modulus_data_t)
			if((data_modulus - modulus_data_t) >= compare_num)begin
				rising_edge <= 1;
				modulus_data_t <= data_modulus;
				rise_index <= modulus_index;
				end
			else begin	
				rising_edge <= rising_edge;
			    modulus_data_t <= modulus_data_t;
			    rise_index <= rise_index;
				end
		else if(data_modulus < modulus_data_t)
			if((modulus_data_t - data_modulus) >= compare_num)begin
				downing_edge <= 1;	
				modulus_data_t <= data_modulus;
				down_index <= modulus_index;
				end
			else begin
				downing_edge <= downing_edge;
				modulus_data_t <= modulus_data_t;
				down_index <= down_index;
				end
		else begin
			modulus_data_t	<= modulus_data_t  ;
			rising_edge		<= rising_edge	   ;
			downing_edge	<= downing_edge    ;
			rise_index		<= rise_index	   ;
			down_index		<= down_index	   ;
			end
	else begin
		modulus_data_t	<= modulus_data_t  ;
	    rising_edge		<= rising_edge	   ;
	    downing_edge	<= downing_edge    ;
	    filter_type 	<= filter_type     ;
	    rise_index		<= rise_index	   ;
	    down_index		<= down_index	   ;
	    end
		
always @(posedge clk_1_6384m or negedge rst_n)
	if(~rst_n)	
		filter_type <= 0;
	else if((~modulus_valid_d0 & modulus_valid_d1) && (state == idle))
		if(rising_edge & downing_edge)
			if(rise_index > down_index)
				filter_type <= 3'd4;
			else 
				filter_type <= 3'd3;
		else if(downing_edge)
			filter_type <= 3'd2;
		else if(rising_edge)
			filter_type <= 3'd1;
		else 
			filter_type <= 3'd6;
	else 
		filter_type <= filter_type;
			
endmodule
