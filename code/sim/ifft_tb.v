`timescale 1ns / 1ps

module ifft_tb;

// 输入信号
reg sys_clk;        // 系统时钟
reg sys_rst_n;      // 系统复位
reg [8:0] key;      // 按键输入 
reg fft_clk;        // FFT时钟，163840Hz，

// AD接口
reg [9:0] ad_data;  // ADC数据输入(10位)
reg ram_add_real;        
reg ram_add_img;      

// 输出信号
wire [9:0] da_data; // DAC数据输出(10位)

// 实例化被测模块
ifft u_ifft (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .key(key),
    .fft_clk(fft_clk),
    .ad_data(ad_data),
    .ram_add_real(16'd100),
    .ram_add_img(16'd200),
    .da_data(da_data)
);

// 生成系统时钟（假设50MHz）
initial begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk;  // 20ns周期
end

// 生成FFT时钟（假设163840Hz）
initial begin
    fft_clk = 0;
    forever #305 fft_clk = ~fft_clk;  // 610ns周期,163840Hz
end


// 读取文件中的数据
reg [9:0] mem [0:4095];  // 存储输入数据
integer i;
reg file_loaded = 0;      // 文件加载完成标志

initial begin
    // 初始化
    sys_rst_n = 0;
    key = 0;
    ram_add_real = 0;
    ram_add_img = 0;
    ad_data = 0;

    // 复位
    #100;
    sys_rst_n = 1;

    // 读取数据文件
    $readmemb("J:/vivado/project/ti/2025G/code/sim/sampled_data_binary.txt", mem);
    file_loaded = 1;     // 文件加载完成标志
    
    // 等待文件加载完成
    #10;
    
    // 循环发送数据
    if(file_loaded) begin
        for (i = 0; i < 4096; ) begin
            @(posedge fft_clk);
            ad_data <= mem[i];
            i <= (i < 199) ? i + 1 : 0;
        end
    end
    
    // 等待FFT处理完成（根据实际情况调整延时）
    #2000000;
    $finish;
end

endmodule