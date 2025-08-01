% 参数设置
fs = 1638400;       % 采样频率 (Hz)
f_signal = 16384;   % 信号频率 (Hz)
A = 1;              % 振幅 (V), Vpp = 2V
V_min = -5;         % 最小电压 (V)
V_max = 5;          % 最大电压 (V)
n_bits = 10;        % ADC位数
N_levels = 2^n_bits; % 量化级别数
N = 8192;           % FFT点数

% 生成时间序列
Ts = 1/fs;          % 采样间隔
n = 0:N-1;          % 采样点索引
t = n * Ts;         % 时间向量

% 生成正弦波信号
V = A * sin(2 * pi * f_signal * t);

% ADC量化
LSB = (V_max - V_min) / N_levels;
D = round((V - V_min) / LSB);
D = min(max(D, 0), N_levels - 1);  % 确保在0~1023范围内

% 将数字值转换回电压（用于验证）
V_quantized = D * LSB + V_min;

% 绘制部分信号
figure;
subplot(2,1,1);
plot(t(1:200), V(1:200), 'b', t(1:200), V_quantized(1:200), 'r');
xlabel('Time (s)');
ylabel('Voltage (V)');
legend('Original', 'Quantized');
title('Original vs Quantized Signal');

% FFT分析
D_fft = fft(D, N);
D_fft_mag = abs(D_fft / N);
D_fft_mag_one_sided = D_fft_mag(1:N/2+1);
D_fft_mag_one_sided(2:end-1) = 2 * D_fft_mag_one_sided(2:end-1);

% 频率轴
f_axis = fs * (0:(N/2)) / N;

% 绘制频谱
subplot(2,1,2);
plot(f_axis, D_fft_mag_one_sided);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Single-Sided Amplitude Spectrum of Quantized Signal');
xlim([0, fs/2]);
grid on;
D_reconstructed = ifft(D_fft);
% 绘制重建的时域信号
figure;
plot(t(1:200), D_reconstructed(1:200), 'b');
xlabel('Time (s)');
ylabel('Digital Value');
title('Reconstructed Signal in Time Domain');
grid on;

plot(t(1:200), V_quantized(1:200), 'b');
xlabel('Time (s)');
ylabel('Digital Value');
title('Reconstructed Signal in Time Domain');
grid on;