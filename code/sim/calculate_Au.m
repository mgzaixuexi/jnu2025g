function Au = calculate_Au(f)
% 计算Au的函数
% 输入参数：
%   f: 频率值（可以是标量或数组）
% 输出：
%   Au: 计算结果

    f0 = 1 / (2 * pi * 1e-4);  % 计算f0
    numerator = 5;              % 分子固定为5
    denominator = sqrt( (1 - (f./f0)).^2 + (3*(f./f0)).^2 );  % 分母计算
    Au = numerator ./ denominator;  % 最终结果
end


