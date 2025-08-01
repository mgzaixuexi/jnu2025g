`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/30 19:23:29
// Design Name: 
// Module Name: top
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


module top(
	input          sys_clk,        // 系统时钟
	input          sys_rst_n,      // 系统复位
	input  [2:0]   key,           // 按键输入 [0:启动, 1:模式选择, 2:保留]
	
	// ADC接口
	input  [9:0]   ad_data,       // ADC数据输入(10位)
	input          ad_otr,        // ADC输入电压超过量程标志
	output		   ad_clk,
	
	output reg [3:0]   led,
	
	// DA接口
	output         da_clk,        // DAC驱动时钟
	output [9:0]   da_data,       // DAC数据输出(10位)
	
	// 数码管接口
	output [4:0]   seg_sel,       // 数码管位选
	output [7:0]   seg_led        // 数码管段选
    );
	
wire clk_32m;
wire clk_50m;
wire clk_40_96m;
wire clk_1_6384m;
wire clk_8_192m;	
wire clk_8_192m_90deg;
wire clk_65_536m;
wire clk_6_5536m;
wire locked1;
wire locked2;
wire locked3;
wire rst_n;
wire fft_valid;
wire [2:0] key_value;
wire learn_en;
wire next_freq;
wire [15:0] freq;
wire [9:0] da_data_t;

assign rst_n = sys_rst_n & locked1 & locked2 & locked3;
assign da_clk = clk_40_96m;
assign ad_clk = clk_1_6384m;
assign da_data = da_data_t + 512;

clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk_32m),     // output clk_out1
    .clk_out2(clk_50m),     // output clk_out2
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked1),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1

clk_wiz_1 u_clk_wiz_1
   (
    // Clock out ports
    .clk_out1(clk_40_96m),     // output clk_out1
	.clk_out2(clk_8_192m),     // output clk_out2
	.clk_out3(clk_8_192m_90deg),     // output clk_out2
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_32m));      // input clk_in1
	
  clk_wiz_2 u_clk_wiz_2
   (
    // Clock out ports
    .clk_out1(clk_65_536m),     // output clk_out1
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked3),       // output locked
   // Clock in ports
    .clk_in1(clk_32m));      // input clk_in1
	
// 按键防抖模块
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
); 

freq_ctrl u_freq_ctrl(
	.clk_6_5536m(clk_6_5536m),
	.clk_40_96m(clk_40_96m),
	.clk_50m(clk_50m),
    .rst_n (rst_n),
	.key(key_value[1:0]),
	.learn_en(learn_en),
	.next_freq(next_freq),
    .da_data(da_data_t),
	.freq_ctrl_t1(freq)			//输出正弦波频率，freq*100
    );

clk_div u_clk_div(
	.clk_8_192m			(clk_8_192m),
    .clk_8_192m_90deg   (clk_8_192m_90deg),
	.clk_65_536m		(clk_65_536m),
    .rst_n              (rst_n),
    .clk_1_6384m        (clk_1_6384m),
	.clk_6_5536m		(clk_6_5536m)
);

wire fft_axis_config_tready;
wire fft_axis_data_tready;
wire [31:0] fft_m_data_tdata;
wire fft_m_data_tvalid;
wire [23:0] fft_axis_data_tuser;
wire [7:0] blk_exp;	
wire [15:0] fft_index;

assign blk_exp = fft_axis_data_tuser[23:16];
assign fft_index = fft_axis_data_tuser[15:0];

xfft_0 u_xfft_0 (
  .aclk(clk_1_6384m),                                                // input wire aclk
  .aresetn(fft_valid & rst_n),                                          // input wire aresetn
  .s_axis_config_tdata(8'd1),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(fft_axis_config_tready),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata({22'b0,ad_data[9:0]}),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(1'b1),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(fft_axis_data_tready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(0),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(fft_m_data_tdata),                      // output wire [31 : 0] m_axis_data_tdata
  .m_axis_data_tuser(fft_axis_data_tuser),                      // output wire [23 : 0] m_axis_data_tuser
  .m_axis_data_tvalid(fft_m_data_tvalid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(),                      // output wire m_axis_data_tlast
  
  .m_axis_status_tdata(),                  // output wire [7 : 0] m_axis_status_tdata
  .m_axis_status_tvalid(),                // output wire m_axis_status_tvalid
  .m_axis_status_tready(1'b0),                // input wire m_axis_status_tready
  
  .event_frame_started(),                  // output wire event_frame_started
  .event_tlast_unexpected(),            // output wire event_tlast_unexpected
  .event_tlast_missing(),                  // output wire event_tlast_missing
  .event_status_channel_halt(),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt()  // output wire event_data_out_channel_halt
);

/* xfft_0 u_xfft_0 (
  .aclk(clk_1_6384m),                                                // input wire aclk
  .aresetn(fft_valid & rst_n),                                          // input wire aresetn
  .s_axis_config_tdata(8'd1),                  // input wire [7 : 0] s_axis_config_tdata
  .s_axis_config_tvalid(1'b1),                // input wire s_axis_config_tvalid
  .s_axis_config_tready(fft_axis_config_tready),                // output wire s_axis_config_tready
  
  .s_axis_data_tdata({22'b0,ad_data}),                      // input wire [31 : 0] s_axis_data_tdata
  .s_axis_data_tvalid(1'b1),                    // input wire s_axis_data_tvalid
  .s_axis_data_tready(fft_axis_data_tready),                    // output wire s_axis_data_tready
  .s_axis_data_tlast(fft_axis_data_tlast),                      // input wire s_axis_data_tlast
  
  .m_axis_data_tdata(fft_m_data_tdata),                      // output wire [63 : 0] m_axis_data_tdata
  .m_axis_data_tuser(),                      // output wire [15 : 0] m_axis_data_tuser
  .m_axis_data_tvalid(fft_m_data_tvalid),                    // output wire m_axis_data_tvalid
  .m_axis_data_tready(1'b1),                    // input wire m_axis_data_tready
  .m_axis_data_tlast(),                      // output wire m_axis_data_tlast
  
  .event_frame_started(),                  // output wire event_frame_started
  .event_tlast_unexpected(),            // output wire event_tlast_unexpected
  .event_tlast_missing(),                  // output wire event_tlast_missing
  .event_status_channel_halt(),      // output wire event_status_channel_halt
  .event_data_in_channel_halt(),    // output wire event_data_in_channel_halt
  .event_data_out_channel_halt()  // output wire event_data_out_channel_halt
); */

wire 		wr_en		   	;
wire [15:0]	wr_real	   		;
wire [15:0]	wr_imag	   		;
wire [11:0]	wr_addr	   		;
wire [2:0]	filter_type		;
wire 		learn_done    	; 
wire [15:0]	rd_real	   		;
wire [15:0]	rd_imag	   		;
wire [11:0]	real_addr	   	;
wire [11:0]	imag_addr	   	;
wire [15:0]	modulus_data_t1;	

learn_ctrl u_learn_ctrl(
	.clk_50m		(clk_50m),
	.clk_1_6384m	(clk_1_6384m),
    .rst_n   	    (rst_n),
    .key            (key_value[2]),
    .fft_real	    (fft_m_data_tdata[15:0]),
    .fft_imag	    (fft_m_data_tdata[31:16]),
    .source_valid   (fft_m_data_tvalid),
    .freq		    (freq),
    //.fft_index	    (fft_index),
    .blk_exp		(blk_exp),
    .learn_en	    (learn_en),
    .next_freq	    (next_freq),
    .fft_valid	    (fft_valid),
    .wr_en		    (wr_en),
    .wr_real		(wr_real),
    .wr_imag		(wr_imag),
    .wr_addr		(wr_addr),
    .filter_type	(filter_type),
    .learn_done	    (learn_done),
	.modulus_data_t1(modulus_data_t1)
);

/* ram_2800x16 ram_real (
  .clka(clk_1_6384m),    // input wire clka
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [11 : 0] addra
  .dina(wr_real),    // input wire [15 : 0] dina
  .clkb(clk_50m),    // input wire clkb
  .addrb(real_addr),  // input wire [11 : 0] addrb
  .doutb(rd_real)  // output wire [15 : 0] doutb
);

ram_2800x16 ram_imag (
  .clka(clk_1_6384m),    // input wire clka
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [11 : 0] addra
  .dina(wr_imag),    // input wire [15 : 0] dina
  .clkb(clk_50m),    // input wire clkb
  .addrb(imag_addr),  // input wire [11 : 0] addrb
  .doutb(rd_imag)  // output wire [15 : 0] doutb
); */

// 数码管显示模块
seg_led u_seg_led(
    .sys_clk(clk_50m),
    .sys_rst_n(rst_n),
	.num1(filter_type),
	.num2(modulus_data_t1),
	.learn_done(learn_done),
    .seg_sel(seg_sel),
    .seg_led(seg_led)
);

always @(posedge clk_50m or negedge rst_n)
	if(~rst_n)
		led <= 0;
	else 
		case(filter_type)
			3'd1:	led <= 4'b0001;
			3'd2:	led <= 4'b0010;
			3'd3:	led <= 4'b0100;
			3'd4:	led <= 4'b1000;
			default:led <= 4'b0000;
		endcase

endmodule
