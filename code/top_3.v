module top(
    input          sys_clk,        // 系统时钟
    input          sys_rst_n,      // 系统复位
    input  [2:0]   key,           // 按键输入 

    // DA接口
    output         da_clk,        // DAC驱动时钟
    output [9:0]  da_data,       // DAC数据输出(10位)

    // 数码管接口
    output [4:0]  seg_sel,       // 数码管位选
    output [7:0]  seg_led        // 数码管段选
);

wire clk_50m;
wire clk_32m;
wire clk_40_96m;
wire clk_100m;
wire locked1,locked2;
wire rst_n;
assign rst_n = sys_rst_n & locked1 & locked2;
assign da_clk = clk_40_96m;

reg [9:0]value_in;
reg [4:0]freq_in;
reg [9:0]value_out;

wire [4:0] rd_addr;  //100Hz-3kHz  步长为100Hz 1-30
wire [10:0]rd_data;

wire [4:0]out_value;  //1-2v 步长为0.1v 增大十倍 10-20 步长为1

wire [2:0] key_value;


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



// 按键防抖模块
key_debounce u_key_debounce(
    .clk(clk_50m),
    .rst_n(rst_n),
    .key(key),
    .key_value(key_value)
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
    .key1(key_value[2]),
    .key2(),
    .out_value(out_value)  //[4:0]
);

wire signed [5:0]out_value_t;
wire signed [25:0]in_value_t;
wire signed [9:0]da_data_t;
wire signed [11:0]  rd_data_t;
wire signed [10:0]da_data_sign;


assign rd_data_t = {1'd0,rd_data};
assign out_value_t = {1'd0,out_value};
assign in_value_t = out_value_t * rd_data_t * da_data_t/100 ;
assign da_data_sign = (in_value_t>>>10)+512;  //需要输入的电压峰峰值 单位:v
assign da_data = da_data_sign[9:0];


seg_led u_seg_led(
    . sys_clk(clk_50m),//系统时钟
	. sys_rst_n(rst_n),
	. num1(rd_addr),
	. num2(out_value),
	. num3(),
	. seg_sel(seg_sel),
	. seg_led(seg_led)
);



freq_ctrl u_freq_ctrl(
	.clk_40_96m(clk_40_96m),
	.clk_50m(clk_50m),
    .rst_n (rst_n),
	.key(key_value[1:0]),
    .da_data(da_data_t),
	.freq(rd_addr)			//输出正弦波频率，freq*100
    );

ila_0 u_ila_0 (
	.clk(clk_50m), // input wire clk


	.probe0(rd_data) // input wire [10:0] probe0

);
endmodule