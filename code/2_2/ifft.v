module ifft(
    input          calcu_clk,        // 计算时钟
    input          sys_rst_n,      // 系统复位
    input      [8:0]     key,        // 按键输入 
    input     fft_clk,           

    // AD接口
    input [9:0]  ad_data,       // ADC数据输出(10位)
    input [15:0]      ram_add_real,        
    input [15:0]      ram_add_img,      
    input         ifft_start,//置高之后，开始对输入信号进行fft，然后与ram数据点乘，然后ifft
    output        fft_m_data_tvalid,//置高之后开始进行与ram数据点乘，然后ifft输出结果。
    output  [9:0]  da_data       // DAC数据输出(10位)

);

//*********************************************
// FFT spectrum
//********************************************* 
// FFT输入接口（驱动信号改为reg�?
wire       fft_s_data_tvalid; // 数据有效
wire       fft_s_data_tlast;  // 数据结束标志
// FFT输出接口（保持为wire�?
wire  [15:0] fft_img,fft_real;
wire [31:0] m_axis_data_tdata;
wire       fft_s_data_tready; // FFT准备好接收数�?
wire [31:0] fft_m_data_tdata; // 频谱输出数据
assign fft_real = fft_m_data_tdata[15:0];
assign fft_img = fft_m_data_tdata[31:16];
wire        fft_m_data_tvalid;
// 配置接口
reg [7:0]  fft_s_config_tdata;
reg        fft_s_config_tvalid;
wire       fft_s_config_tready;
wire  event_frame_started, event_tlast_unexpected , event_tlast_missing, event_data_in_channel_halt;
wire  event_status_channel_halt, event_data_out_channel_halt;
wire [20:0] m_axis_data_tuser;
wire [12:0] fft_index;
assign fft_index = m_axis_data_tuser[12:0];

reg ifft_start_prev;  // 用于检测上升沿的寄存器
reg fft_start;        // FFT启动信号
// 检测ifft_start的上升沿并生成fft_start信号
always @(posedge fft_clk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        ifft_start_prev <= 1'b0;
        fft_start <= 1'b0;
    end else begin
        ifft_start_prev <= ifft_start;  // 存储前一个时钟周期的ifft_start值
        
        // 检测上升沿：当前为高电平且前一个时钟周期为低电平
        if (ifft_start && !ifft_start_prev) begin
            fft_start <= 1'b1;          // 在上升沿时启动FFT
        end else begin
            fft_start <= fft_start;          // 保持低电平
        end
    end
end
xfft_0 D2_xfft (
  .aclk(fft_clk),                      
  .aresetn(sys_rst_n), 
  .s_axis_config_tdata (8'b1),          // 1: FFT  0: IFFT
  .s_axis_config_tvalid(1'b1),                 
  .s_axis_config_tready(fft_s_config_tready),  
                
  .s_axis_data_tdata   ({22'b0, ad_data}),                        
  .s_axis_data_tvalid  (fft_start), //需要设置按键。              
  .s_axis_data_tready  (fft_s_data_tready),                 
  .s_axis_data_tlast   (s_axis_data_tlast),                

  .m_axis_data_tdata  (fft_m_data_tdata),  
  .m_axis_data_tuser  (m_axis_data_tuser), 
  .m_axis_data_tready (1'b1),                     
  .m_axis_data_tvalid (fft_m_data_tvalid),  
  .m_axis_data_tlast  (m_axis_data_tlast),  
   
  .m_axis_status_tdata(),              
  .m_axis_status_tvalid(),              
  .m_axis_status_tready(1'b0),                
  
  .event_frame_started(event_frame_started),                 
  .event_tlast_unexpected(event_tlast_unexpected),             
  .event_tlast_missing(event_tlast_missing), 
  .event_status_channel_halt(event_status_channel_halt),                 
  .event_data_in_channel_halt(event_data_in_channel_halt),
  .event_data_out_channel_halt(event_data_out_channel_halt)          
  );

wire [15:0] fft_data_modulus;
wire fft_modulus_valid;
data_modulus u_fft_data_modulus(
	.clk(calcu_clk),
	.rst_n(sys_rst_n),
	//.key(key_value[0]),                       //键控重置，就是题目里的启动键，不是复�?
	//FFT ST接口 
    .source_real(fft_real),   //实部 有符号数 
    .source_imag(fft_img),   //虚部 有符号数 
	.source_eop(),
    .source_valid(fft_m_data_tvalid),  //输出有效信号，FFT变换完成后，此信号置�? 
	.data_modulus(fft_data_modulus),  // 取模结果
	.data_eop(),      // 结果帧结�?
	.data_valid(fft_modulus_valid) 
);
//calculate. ip

wire m_axis_dout_tvalid;
wire [79 : 0] m_axis_dout_tdata;
wire [32:0] ft_img,ft_real;
assign ft_img = m_axis_dout_tdata[72:40];
assign ft_real = m_axis_dout_tdata[32:0];
cmpy_0 u_cmpy_0 (
  .aclk(calcu_clk),                              // input wire aclk
  .s_axis_a_tvalid(1'b1),        // input wire s_axis_a_tvalid
  .s_axis_a_tdata({fft_img,fft_real}),          // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(1'b1),        // input wire s_axis_b_tvalid
  .s_axis_b_tdata({ram_add_img,ram_add_real}),          // input wire [31 : 0] s_axis_b_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),  // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(m_axis_dout_tdata)    // output wire [79 : 0] m_axis_dout_tdata
);




//*********************************************
// IFFT wave
//********************************************* 	  
// IFFT输入接口（驱动信号改为reg�?
wire       ifft_s_data_tvalid; // 数据有效
wire       ifft_s_data_tlast;  // 数据结束标志
// ifft输出接口（保持为wire�?
wire  [31:0] ifft_img,ifft_real;
wire [79:0] im_axis_data_tdata;
assign im_axis_data_tdata = m_axis_dout_tdata;
wire       ifft_s_data_tready; // ifft准备好接收数�?
wire [79:0] ifft_m_data_tdata; // 频谱输出数据
assign ifft_img = ifft_m_data_tdata[72:40];
assign ifft_real = ifft_m_data_tdata[32:0];
wire        ifft_m_data_tvalid;
// 配置接口
reg [7:0]  ifft_s_config_tdata;
reg        ifft_s_config_tvalid;
wire       ifft_s_config_tready;
wire  ievent_frame_started, ievent_tlast_unexpected , ievent_tlast_missing, ievent_data_in_channel_halt;
wire  ievent_status_channel_halt, ievent_data_out_channel_halt;
wire [23:0] im_axis_data_tuser;
wire [12:0] ifft_index;
assign ifft_index = im_axis_data_tuser[12:0];

xfft_1 D3_ifft (
  .aclk(fft_clk),                      
  .aresetn(m_axis_dout_tvalid&sys_rst_n), 
  .s_axis_config_tdata (8'b0),          // 1: FFT  0: IFFT
  .s_axis_config_tvalid(1'b1),                 
  .s_axis_config_tready(ifft_s_config_tready),  
                
  .s_axis_data_tdata   (im_axis_data_tdata),                        
  .s_axis_data_tvalid  (fft_modulus_valid),               
  .s_axis_data_tready  (ifft_s_data_tready),                 
  .s_axis_data_tlast   (is_axis_data_tlast),                

  .m_axis_data_tdata  (ifft_m_data_tdata),  
  .m_axis_data_tuser  (im_axis_data_tuser), 
  .m_axis_data_tready (1'b1),                     
  .m_axis_data_tvalid (ifft_m_data_tvalid),  
  .m_axis_data_tlast  (im_axis_data_tlast),  
   
  .m_axis_status_tdata(),              
  .m_axis_status_tvalid(),              
  .m_axis_status_tready(1'b0),                
  
  .event_frame_started(ievent_frame_started),                 
  .event_tlast_unexpected(ievent_tlast_unexpected),             
  .event_tlast_missing(ievent_tlast_missing), 
  .event_status_channel_halt(ievent_status_channel_halt),                 
  .event_data_in_channel_halt(ievent_data_in_channel_halt),
  .event_data_out_channel_halt(ievent_data_out_channel_halt)          
  );
//assign da_data = ifft_real[22:12];
//仿真
 assign da_data = ifft_real[16:6];
// wire [15:0] ifft_data_modulus;
// wire ifft_modulus_valid;
// data_modulus u_ifft_data_modulus(
// 	.clk(calcu_clk),
// 	.rst_n(sys_rst_n),
// 	//.key(key_value[0]),                       //键控重置，就是题目里的启动键，不是复�?
// 	//FFT ST接口 
//     .source_real(ifft_real),   //实部 有符号数 
//     .source_imag(ifft_img),   //虚部 有符号数 
// 	.source_eop(),
//     .source_valid(1'b1),  //输出有效信号，FFT变换完成后，此信号置�? 
// 	.data_modulus(ifft_data_modulus),  // 取模结果
// 	.data_eop(),      // 结果帧结�?
// 	.data_valid(ifft_modulus_valid) 
// );


endmodule