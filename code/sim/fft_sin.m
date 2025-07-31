% 参数设置
f_signal = 16384;        % 信号频率 (Hz)
fs = 1638400;            % 采样频率 (Hz)
duration = 0.01;         % 信号持续时间 (秒)
Vpp = 2;                 % 峰峰值电压 (V)
n_bits = 10;             % 输出位数
voltage_range = [-5, 5]; % ADC电压范围 (V)

% 计算采样点数和时间向量
t = 0:1/fs:duration-1/fs;
N = length(t);

% 生成正弦波信号 (-1V到+1V)
amplitude = Vpp / 2;     % 振幅1V
signal = amplitude * sin(2 * pi * f_signal * t);

% 将信号从[-1,1]V映射到ADC的[-5,5]V范围
% 这里实际上不需要映射，因为信号已经在ADC范围内
% 直接进行量化即可

% 将电压信号量化为10位无符号整数 (0-1023)
max_value = 2^n_bits - 1;  % 1023
quantized_signal = round((signal - voltage_range(1)) / (voltage_range(2) - voltage_range(1)) * max_value);

% 确保值在有效范围内 (0-1023)
quantized_signal(quantized_signal < 0) = 0;
quantized_signal(quantized_signal > max_value) = max_value;

% 转换为10位无符号二进制字符串
binary_output = dec2bin(quantized_signal, n_bits);

% 保存二进制结果到文件
filename = 'sampled_data_binary.txt';
fid = fopen(filename, 'w');
for i = 1:N
    fprintf(fid, '%s\n', binary_output(i,:));
end
fclose(fid);

% 保存十进制结果到文件（可选）
filename_dec = 'sampled_data_decimal.txt';
writematrix(quantized_signal', filename_dec);

disp(['二进制采样结果已保存到文件: ', filename]);
disp(['十进制采样结果已保存到文件: ', filename_dec]);

% 显示部分结果
disp('前10个采样点的二进制输出:');
disp(binary_output(1:10, :));

% 绘制信号
figure;
subplot(3,1,1);
plot(t(1:100), signal(1:100));
title('原始模拟信号 (前100个采样点)');
xlabel('时间 (s)');
ylabel('电压 (V)');
ylim([-5.5 5.5]);
grid on;

subplot(3,1,2);
plot(t(1:100), (quantized_signal(1:100)/max_value)*(voltage_range(2)-voltage_range(1))+voltage_range(1));
title('重建的模拟信号 (前100个采样点)');
xlabel('时间 (s)');
ylabel('电压 (V)');
ylim([-5.5 5.5]);
grid on;

subplot(3,1,3);
stem(t(1:100), quantized_signal(1:100));
title('量化后的数字信号 (前100个采样点)');
xlabel('时间 (s)');
ylabel('数字值');
grid on;

%%
% 文件路径
file_path = 'J:\vivado\project\ti\2025G\code\sim\sampled_data_binary.txt';

% 读取二进制数据
fid = fopen(file_path, 'r');
binary_data = textscan(fid, '%s');
fclose(fid);
binary_data = binary_data{1};

% 将二进制字符串转换为十进制数值
decimal_data = zeros(length(binary_data), 1);
for i = 1:length(binary_data)
    decimal_data(i) = bin2dec(binary_data{i});
end

% 显示原始波形
figure;
plot(decimal_data);
title('原始波形');
xlabel('采样点');
ylabel('幅值');
grid on;

% 进行快速傅里叶变换
N = length(decimal_data);
fft_result = fft(decimal_data)/N;

% 显示FFT幅度谱
f = (0:N-1)*(1/N);
figure;
plot(f(1:N/2), abs(fft_result(1:N/2)));
title('FFT幅度谱');
xlabel('归一化频率');
ylabel('幅度');
grid on;

% 提取实部和虚部
real_part = real(fft_result);
imag_part = imag(fft_result);

% 将实部和虚部转换为10位二进制字符串
real_binary = cell(N, 1);
imag_binary = cell(N, 1);
for i = 1:N
    % 处理实部
    real_val = real_part(i);
    if real_val >= 0
        real_binary{i} = dec2bin(round(real_val * 1023), 10);
    else
        % 对于负数，使用补码表示
        real_binary{i} = dec2bin(1024 + round(real_val * 1023), 10);
    end
    
    % 处理虚部
    imag_val = imag_part(i);
    if imag_val >= 0
        imag_binary{i} = dec2bin(round(imag_val * 1023), 10);
    else
        % 对于负数，使用补码表示
        imag_binary{i} = dec2bin(1024 + round(imag_val * 1023), 10);
    end
end

% 保存实部和虚部到不同的txt文件
fid_real = fopen('fft_real_part.txt', 'w');
fid_imag = fopen('fft_imag_part.txt', 'w');

for i = 1:N
    fprintf(fid_real, '%s\n', real_binary{i});
    fprintf(fid_imag, '%s\n', imag_binary{i});
end

fclose(fid_real);
fclose(fid_imag);

disp('处理完成，结果已保存为fft_real_part.txt和fft_imag_part.txt');

