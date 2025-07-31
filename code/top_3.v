module top(
    input          sys_clk,        // 系统时钟
    input          sys_rst_n,      // 系统复位
    input  [2:0]   key,           // 按键输入 

    // DA接口
    output         da_clk,        // DAC驱动时钟
    output [9:0]  da_data,       // DAC数据输出(10位)

    // 数码管接口
    output [4:0]  seg_sel,       // 数码管位选
    output [7:0]  seg_led,        // 数码管段选

    //TOUCH 接口                  
    inout            touch_sda  ,  //TOUCH IIC数据
    output           touch_scl  ,  //TOUCH IIC时钟
    inout            touch_int  ,  //TOUCH INT信号
    output           touch_rst_n,  //TOUCH 复位信号
    //RGB LCD接口                 
    output           lcd_de     ,  //LCD 数据使能信号
    output           lcd_hs     ,  //LCD 行同步信�?
    output           lcd_vs     ,  //LCD 场同步信�?
    output           lcd_bl     ,  //LCD 背光控制信号
    output           lcd_clk    ,  //LCD 像素时钟
    output           lcd_rst_n  ,  //LCD 复位
    inout    [23:0]  lcd_rgb       //LCD RGB颜色数据
);




wire clk_50m;
wire clk_32m;
wire clk_40_96m;
wire clk_40_96m_90deg;
wire clk_81_92m;
wire clk_81_92m_t;
wire clk_100m;
wire locked1,locked2;
wire rst_n;
assign rst_n = sys_rst_n & locked1 & locked2;
assign da_clk = clk_81_92m;

wire freq_valid,value_valid;

reg [9:0]value_in;
reg [4:0]freq_in;
reg [9:0]value_out;

wire [4:0] rd_addr;  //100Hz-3kHz  步长为100Hz 1-30
wire [10:0]rd_data;

wire [4:0]out_value;  //1-2v 步长为0.1v 增大十倍 10-20 步长为1

wire [2:0] key_value;

assign clk_81_92m_t = clk_40_96m_90deg + clk_40_96m;
 clk_wiz_0 u_clk_wiz_0
   (
    // Clock out ports
    .clk_out1(clk_50m),     // output clk_out1
    .clk_out2(clk_32m),
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked1),       // output locked
   // Clock in ports
    .clk_in1(sys_clk));      // input clk_in1
    
     clk_wiz_1 u_clk_wiz_1
   (
    // Clock out ports
    .clk_out1(clk_40_96m),     // output clk_out1
    .clk_out2(clk_40_96m_90deg),
    // Status and control signals
    .reset(~sys_rst_n), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_32m));      // input clk_in1

rom_30x11b u_rom_30x11b (
  .clka(clk_50m),    // input wire clka
  .addra(rd_addr-1),  // input wire [4 : 0] addra
  .douta(rd_data)  // output wire [10 : 0] douta
);

 BUFG BUFG_inst (
      .O(clk_81_92m), // 1-bit output: Clock output
      .I(clk_81_92m_t)  // 1-bit input: Clock input
   );

// 按键防抖模块
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
);

wire [8:0]lcd_key;
wire [8:0]lcd_key_value;

top_lcd_touch u_top_lcd_touch(
    //时钟和复位接�?
    .sys_clk  (clk_50m)  ,  //系统时钟信号
    .sys_rst_n (rst_n) ,  //系统复位信号

    //output            ad_otr,
    .ad_clk(),
    .ad_data(8'd0),

	.seg_sel(),
	.seg_led(),

    //TOUCH 接口                  
    .touch_sda(touch_sda) ,  //TOUCH IIC数据
    .touch_scl(touch_scl),  //TOUCH IIC时钟
    .touch_int(touch_int),  //TOUCH INT信号
    .touch_rst_n(touch_rst_n),  //TOUCH 复位信号
    //RGB LCD接口                 
    .lcd_de(lcd_de)  ,  //LCD 数据使能信号
    .lcd_hs(lcd_hs),  //LCD 行同步信�?
    .lcd_vs(lcd_vs),  //LCD 场同步信�?
    .lcd_bl(lcd_bl),  //LCD 背光控制信号
    .lcd_clk(lcd_clk),  //LCD 像素时钟
    .lcd_rst_n(lcd_rst_n),  //LCD 复位
    .lcd_rgb(lcd_rgb),   //LCD RGB颜色数据
    .data_out(lcd_key)
);

lcd_key_ctrl u_lcd_key_ctrl(
    . clk(clk_50m),
    . rst_n(rst_n),
    .  lcd_key(lcd_key),
    .  lcd_key_value(lcd_key_value)
);


// rom_ctrl u_rom_ctrl(
//     .clk(clk_50m),
//     .rst_n(rst_n),
//     .key1(key_value[0]),
//     .key2(key_value[1]),
//     .rd_addr(rd_addr)
// );

value_ctrl u_value_ctrl(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key1(lcd_key_value[3]),
    .key2(lcd_key_value[5]),
    .out_value(out_value)  //[4:0]
);

wire signed [5:0]out_value_t;
wire signed [25:0]in_value_t;
wire signed [9:0]da_data_t;
wire signed [11:0]  rd_data_t;
wire signed [10:0] da_data_sign;
wire signed [17:0] mult1;
wire signed [27:0]mult2;
wire signed [39:0]divi1;
mult_gen_0 u_mult_gen_0 (
  .CLK(clk_81_92m),  // input wire CLK
  .A(out_value_t),      // input wire [5 : 0] A
  .B(rd_data_t),      // input wire [11 : 0] B
  .P(mult1)      // output wire [17 : 0] P
);

mult_gen_1 u_mult_gen_1 (
  .CLK(clk_81_92m),  // input wire CLK
  .A(mult1),      // input wire [17 : 0] A
  .B(da_data_t),      // input wire [9 : 0] B
  .P(mult2)      // output wire [27 : 0] P
);

div_gen_0 u_div_gen_0 (
  .aclk(clk_81_92m),                                      // input wire aclk
  .s_axis_divisor_tvalid(1),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tdata({1'd0,7'd100}),      // input wire [7 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(1),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tdata(mult2),    // input wire [31 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(divi1)            // output wire [39 : 0] m_axis_dout_tdata
);

assign rd_data_t = {1'd0,rd_data};
assign out_value_t = {1'd0,out_value};
// assign in_value_t = out_value_t * rd_data_t * da_data_t/100 ;
assign da_data_sign = (divi1[35:8]>>>10)+512;  //需要输入的电压峰峰值 单位:v
assign da_data = da_data_sign[9:0];


seg_led u_seg_led(
    . sys_clk(clk_50m),//系统时钟
	. sys_rst_n(rst_n),
	. num1(rd_addr),
	. num2(out_value),
	. num3(lcd_key[0]),
	. seg_sel(seg_sel),
	. seg_led(seg_led)
);



freq_ctrl u_freq_ctrl(
	.clk_40_96m(clk_40_96m),
	.clk_50m(clk_50m),
    .rst_n (rst_n),
	.key({lcd_key_value[0],lcd_key_value[2]}),
    .da_data(da_data_t),
	.freq(rd_addr)			//输出正弦波频率，freq*100
    );

ila_0 u_ila_0 (
	.clk(clk_50m), // input wire clk


	.probe0(lcd_key) // input wire [10:0] probe0

);
endmodule