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
	input          sys_clk,        // ϵͳʱ��
	input          sys_rst_n,      // ϵͳ��λ
	input  [2:0]   key,           // �������� [0:����, 1:ģʽѡ��, 2:����]
	
	// ADC�ӿ�
	input  [9:0]   ad_data,       // ADC��������(10λ)
	input          ad_otr,        // ADC�����ѹ�������̱��?
	output		   ad_clk,
	
	output reg [3:0]   led,
	
	// DA�ӿ�
	output         da_clk1,        // DAC����ʱ��
	output [9:0]   da_data1,       // DAC�������?10λ)
	output         da_clk2,  
	output [9:0]   da_data2,
	
	// ����ܽӿ�?
	output [4:0]   seg_sel,       // �����λ�?
	output [7:0]   seg_led        // ����ܶ��?
    );
	
wire clk_32m;
wire clk_50m;
wire clk_40_96m;
wire clk_1_6384m;
wire clk_8_192m;	
wire clk_8_192m_90deg;
wire clk_65_536m;
wire clk_6_5536m;
wire clk_500m;
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
assign da_clk1 = clk_6_5536m;
assign ad_clk = clk_1_6384m;
assign da_data1 = da_data_t + 512;
assign da_clk2 = clk_1_6384m;

clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk_32m),     // output clk_out1
    .clk_out2(clk_50m),     // output clk_out2
	.clk_out3(clk_500m),     // output clk_out3
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

// ��������ģ��
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
); 

freq_ctrl_2 u_freq_ctrl_2(
	.clk_6_5536m(clk_6_5536m),
	.clk_50m(clk_50m),
    .rst_n (rst_n),
	.learn_en(learn_en),
	.next_freq(next_freq),
    .da_data(da_data_t),
	.freq_ctrl_t1(freq)			//������Ҳ�Ƶ�ʣ�freq*200
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

wire ram_rd_valid;

ram_2800x16 ram_real (
  .clka(clk_1_6384m),    // input wire clka
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [11 : 0] addra
  .dina(wr_real),    // input wire [15 : 0] dina
  .clkb(clk_1_6384m),    // input wire clkb
  .addrb(real_addr),  // input wire [11 : 0] addrb
  .doutb(rd_real),  // output wire [15 : 0] doutb
  .enb(ram_rd_valid)
);

ram_2800x16 ram_imag (
  .clka(clk_1_6384m),    // input wire clka
  .wea(wr_en),      // input wire [0 : 0] wea
  .addra(wr_addr),  // input wire [11 : 0] addra
  .dina(wr_imag),    // input wire [15 : 0] dina
  .clkb(clk_1_6384m),    // input wire clkb
  .addrb(imag_addr),  // input wire [11 : 0] addrb
  .doutb(rd_imag),  // output wire [15 : 0] doutb
  .enb(ram_rd_valid)
);//有ram_rd_valid指导读出，现在只需要让ram读完之后地址回到第一�?�?位�?

// �������ʾģ��?
seg_led u_seg_led(
    .sys_clk(clk_50m),
    .sys_rst_n(rst_n),
	.num1(filter_type),
	.num2(modulus_data_t1),
	.learn_done(learn_done),
    .seg_sel(seg_sel),
    .seg_led(seg_led)
);

//wire [12:0] fft_index;
ifft u_ifft(
    .calcu_clk(clk_500m),     //希望能比fft时钟快五倍，这样可以保证计算结果不会落后于fft计算�?
    .sys_rst_n(rst_n),   
    .fft_clk(clk_1_6384m),           //以防万一保证fft_clk一样。也跟读地址的时钟一样�? 
    .ad_data(ad_data),   
    .ram_add_real(rd_real),        
    .ram_add_img(rd_imag),      
    .ifft_start(learn_done),
    .ram_rd_valid(ram_rd_valid),//控制开始读地址�?
    //.fft_index(fft_index),
    .real_addr(real_addr),
    .imag_addr(imag_addr),
    .da_data(da_data2)    

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
