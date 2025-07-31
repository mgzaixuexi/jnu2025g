%%
%%
f = [100, 1000, 3000];  % 测试频率点
Au = calculate_Au(f);    % 调用函数计算
disp(Au);                % 显示结果

%%
% 定义频率范围和步长
f_start = 1e3;      % 起始频率 1kHz
f_end = 50e3;       % 终止频率 50kHz
f_step = 200;       % 步长 200Hz

% 生成频率点
f = f_start:f_step:f_end;

% 计算滤波后的 Au
Au = calculate_Au(f);

% 绘制 Au 随频率变化的波形
figure;
plot(f, Au);
xlabel('Frequency (Hz)');
ylabel('Au');
title('Filter Response (Au vs Frequency)');
grid on;
%%
% 频率范围设置
f_start = 100;
f_end = 3000;
f_step = 100;  % 可以根据需要调整步长
f = f_start:f_step:f_end;

% 计算Au值
Au = calculate_Au(f);

% 计算倒数 (1/Au)，乘以1024并取整
scaled_values = round( (1 ./ Au) * 1024 );

% 确保值在合理范围内（0-2047，11位无符号）
scaled_values = max(0, min(2047, scaled_values));

% 创建COE文件
filename = 'Au_inverse_11bit.coe';
fid = fopen(filename, 'w');

% 写入COE文件头
fprintf(fid, 'memory_initialization_radix=2;\n');
fprintf(fid, 'memory_initialization_vector=\n');

% 写入数据（11位二进制）
for i = 1:length(scaled_values)
    binary_str = dec2bin(scaled_values(i), 11); % 固定11位宽度
    
    % 最后一个数据项用分号结尾，其余用逗号
    if i == length(scaled_values)
        fprintf(fid, '%s;\n', binary_str);
    else
        fprintf(fid, '%s,\n', binary_str);
    end
end

fclose(fid);
disp(['COE文件已生成: ', filename]);