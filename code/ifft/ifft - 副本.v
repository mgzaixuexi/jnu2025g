module ifft(
    input          sys_clk,        // 系统时钟
    input          sys_rst_n,      // 系统复位
    input      [8:0]     key,        // 按键输入 
    input     fft_clk,           

    // AD接口
    input [9:0]  ad_data,       // ADC数据输出(10位)
    input          ram_add_real,        
    input          ram_add_img,      

    output  [9:0]  da_data       // DAC数据输出(10位)

);

//*********************************************
// FFT spectrum
//********************************************* 
// FFT输入接口（驱动信号改为reg�?
wire       fft_s_data_tvalid; // 数据有效
wire       fft_s_data_tlast;  // 数据结束标志
// FFT输出接口（保持为wire�?
wire  fft_imag,fft_real;
wire       fft_s_data_tready; // FFT准备好接收数�?
//wire [47:0] fft_m_data_tdata; // 频谱输出数据
wire        fft_m_data_tvalid;
// 配置接口
reg [7:0]  fft_s_config_tdata;
reg        fft_s_config_tvalid;
wire       fft_s_config_tready;
wire  event_frame_started, event_tlast_unexpected , event_tlast_missing, event_data_in_channel_halt;
wire  event_status_channel_halt, event_data_out_channel_halt;


xfft_0 D2_xfft (
  .aclk(fft_clk),                      
  .aresetn(rst_n), 
  .s_axis_config_tdata (8'b1),          // 1: FFT  0: IFFT
  .s_axis_config_tvalid(1'b1),                 
  .s_axis_config_tready(fft_s_config_tready),  
                
  .s_axis_data_tdata   ({16'b0, ad_data}),                        
  .s_axis_data_tvalid  (1'b1),               
  .s_axis_data_tready  (fft_s_data_tready),                 
  .s_axis_data_tlast   (fft_s_data_tlast),                
  
  .m_axis_data_tdata  ({fft_imag,  fft_real}),  
  .m_axis_data_tuser  (m_axis_data_tuser), 
  .m_axis_data_tready (1),                     
  .m_axis_data_tvalid (fft_m_data_tvalid),  
  .m_axis_data_tlast  (m_axis_data_tlast),  
   
  .m_axis_status_tdata(),              
  .m_axis_status_tvalid(),              
  .m_axis_status_tready(1'b1),                
  
  .event_frame_started(event_frame_started),                 
  .event_tlast_unexpected(event_tlast_unexpected),             
  .event_tlast_missing(event_tlast_missing), 
  .event_status_channel_halt(event_status_channel_halt),                 
  .event_data_in_channel_halt(event_data_in_channel_halt),
  .event_data_out_channel_halt(event_data_out_channel_halt)          
  );

//calculate. ip












//*********************************************
// IFFT wave
//********************************************* 	  



endmodule