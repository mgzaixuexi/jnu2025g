module ifft_8point (
    input clk,
    input reset,
    // 输入实部（8个32位数据分开定义）
    input [31:0] X_real_0, X_real_1, X_real_2, X_real_3,
    input [31:0] X_real_4, X_real_5, X_real_6, X_real_7,
    // 输入虚部（8个32位数据分开定义）
    input [31:0] X_imag_0, X_imag_1, X_imag_2, X_imag_3,
    input [31:0] X_imag_4, X_imag_5, X_imag_6, X_imag_7,
    // 输出实部（8个32位数据分开定义）
    output reg [31:0] x_real_0, x_real_1, x_real_2, x_real_3,
    output reg [31:0] x_real_4, x_real_5, x_real_6, x_real_7,
    // 输出虚部（8个32位数据分开定义）
    output reg [31:0] x_imag_0, x_imag_1, x_imag_2, x_imag_3,
    output reg [31:0] x_imag_4, x_imag_5, x_imag_6, x_imag_7,
    output reg done
);

// 旋转因子表(W_N^k = e^(j2πk/N))
// 实部和虚部预先计算好，Q16格式定点数
parameter [15:0] W8_0_real = 16'h7FFF;  // W_8^0 = 1.0
parameter [15:0] W8_0_imag = 16'h0000;
parameter [15:0] W8_1_real = 16'h5A82;  // W_8^1 = cos(π/4) ≈ 0.7071
parameter [15:0] W8_1_imag = 16'hA57E;  // W_8^1 = -sin(π/4) ≈ -0.7071
parameter [15:0] W8_2_real = 16'h0000;  // W_8^2 = 0.0
parameter [15:0] W8_2_imag = 16'h8000;  // W_8^2 = -1.0
parameter [15:0] W8_3_real = 16'hA57E;  // W_8^3 = -cos(π/4) ≈ -0.7071
parameter [15:0] W8_3_imag = 16'hA57E;  // W_8^3 = -sin(π/4) ≈ -0.7071

// 位反转函数
function [2:0] bit_reverse;
    input [2:0] index;
    begin
        bit_reverse = {index[0], index[1], index[2]};
    end
endfunction

// 中间寄存器（不使用二维数组）
reg [31:0] stage0_real_0, stage0_real_1, stage0_real_2, stage0_real_3;
reg [31:0] stage0_real_4, stage0_real_5, stage0_real_6, stage0_real_7;
reg [31:0] stage0_imag_0, stage0_imag_1, stage0_imag_2, stage0_imag_3;
reg [31:0] stage0_imag_4, stage0_imag_5, stage0_imag_6, stage0_imag_7;

reg [31:0] stage1_real_0, stage1_real_1, stage1_real_2, stage1_real_3;
reg [31:0] stage1_real_4, stage1_real_5, stage1_real_6, stage1_real_7;
reg [31:0] stage1_imag_0, stage1_imag_1, stage1_imag_2, stage1_imag_3;
reg [31:0] stage1_imag_4, stage1_imag_5, stage1_imag_6, stage1_imag_7;

reg [31:0] stage2_real_0, stage2_real_1, stage2_real_2, stage2_real_3;
reg [31:0] stage2_real_4, stage2_real_5, stage2_real_6, stage2_real_7;
reg [31:0] stage2_imag_0, stage2_imag_1, stage2_imag_2, stage2_imag_3;
reg [31:0] stage2_imag_4, stage2_imag_5, stage2_imag_6, stage2_imag_7;

reg [31:0] stage3_real_0, stage3_real_1, stage3_real_2, stage3_real_3;
reg [31:0] stage3_real_4, stage3_real_5, stage3_real_6, stage3_real_7;
reg [31:0] stage3_imag_0, stage3_imag_1, stage3_imag_2, stage3_imag_3;
reg [31:0] stage3_imag_4, stage3_imag_5, stage3_imag_6, stage3_imag_7;

reg [2:0] stage_count;

// 状态机定义
parameter IDLE = 2'b00;
parameter BIT_REVERSE = 2'b01;
parameter PROCESSING = 2'b10;
parameter NORMALIZE = 2'b11;

reg [1:0] state;

// 复数乘法结果暂存
reg [31:0] prod_real, prod_imag;

// 复数乘法任务
task complex_multiply;
    input [15:0] a_real, a_imag;
    input [31:0] b_real, b_imag;
    begin
        // 实部: a_real*b_real - a_imag*b_imag
        prod_real = ((a_real * b_real) - (a_imag * b_imag)) >>> 15;
        // 虚部: a_real*b_imag + a_imag*b_real
        prod_imag = ((a_real * b_imag) + (a_imag * b_real)) >>> 15;
    end
endtask

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        done <= 0;
        stage_count <= 0;
    end else begin
        case (state)
            IDLE: begin
                // 初始化输入数据(位反转重排)
                case (bit_reverse(3'b000))
                    3'b000: begin stage0_real_0 <= X_real_0; stage0_imag_0 <= X_imag_0; end
                    3'b001: begin stage0_real_1 <= X_real_0; stage0_imag_1 <= X_imag_0; end
                    3'b010: begin stage0_real_2 <= X_real_0; stage0_imag_2 <= X_imag_0; end
                    3'b011: begin stage0_real_3 <= X_real_0; stage0_imag_3 <= X_imag_0; end
                    3'b100: begin stage0_real_4 <= X_real_0; stage0_imag_4 <= X_imag_0; end
                    3'b101: begin stage0_real_5 <= X_real_0; stage0_imag_5 <= X_imag_0; end
                    3'b110: begin stage0_real_6 <= X_real_0; stage0_imag_6 <= X_imag_0; end
                    3'b111: begin stage0_real_7 <= X_real_0; stage0_imag_7 <= X_imag_0; end
                endcase
                // 对其他输入重复类似操作...
                // 这里简化为示例，实际需要为每个输入X_real_1到X_real_7做同样处理
                state <= BIT_REVERSE;
                stage_count <= 1;
            end
            
            BIT_REVERSE: begin
                state <= PROCESSING;
            end
            
            PROCESSING: begin
                // 三级蝶形运算(log2(8)=3)
                if (stage_count == 1) begin
                    // 第一级蝶形运算（间隔1）
                    // 蝶形单元0和1
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage0_real_1, stage0_imag_1);
                    stage1_real_0 = stage0_real_0 + prod_real;
                    stage1_imag_0 = stage0_imag_0 + prod_imag;
                    stage1_real_1 = stage0_real_0 - prod_real;
                    stage1_imag_1 = stage0_imag_0 - prod_imag;
                    
                    // 蝶形单元2和3
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage0_real_3, stage0_imag_3);
                    stage1_real_2 = stage0_real_2 + prod_real;
                    stage1_imag_2 = stage0_imag_2 + prod_imag;
                    stage1_real_3 = stage0_real_2 - prod_real;
                    stage1_imag_3 = stage0_imag_2 - prod_imag;
                    
                    // 蝶形单元4和5
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage0_real_5, stage0_imag_5);
                    stage1_real_4 = stage0_real_4 + prod_real;
                    stage1_imag_4 = stage0_imag_4 + prod_imag;
                    stage1_real_5 = stage0_real_4 - prod_real;
                    stage1_imag_5 = stage0_imag_4 - prod_imag;
                    
                    // 蝶形单元6和7
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage0_real_7, stage0_imag_7);
                    stage1_real_6 = stage0_real_6 + prod_real;
                    stage1_imag_6 = stage0_imag_6 + prod_imag;
                    stage1_real_7 = stage0_real_6 - prod_real;
                    stage1_imag_7 = stage0_imag_6 - prod_imag;
                    
                    stage_count <= 2;
                end
                else if (stage_count == 2) begin
                    // 第二级蝶形运算（间隔2）
                    // 蝶形单元0和2
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage1_real_2, stage1_imag_2);
                    stage2_real_0 = stage1_real_0 + prod_real;
                    stage2_imag_0 = stage1_imag_0 + prod_imag;
                    stage2_real_2 = stage1_real_0 - prod_real;
                    stage2_imag_2 = stage1_imag_0 - prod_imag;
                    
                    // 蝶形单元1和3
                    complex_multiply(W8_2_real, W8_2_imag, 
                                   stage1_real_3, stage1_imag_3);
                    stage2_real_1 = stage1_real_1 + prod_real;
                    stage2_imag_1 = stage1_imag_1 + prod_imag;
                    stage2_real_3 = stage1_real_1 - prod_real;
                    stage2_imag_3 = stage1_imag_1 - prod_imag;
                    
                    // 蝶形单元4和6
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage1_real_6, stage1_imag_6);
                    stage2_real_4 = stage1_real_4 + prod_real;
                    stage2_imag_4 = stage1_imag_4 + prod_imag;
                    stage2_real_6 = stage1_real_4 - prod_real;
                    stage2_imag_6 = stage1_imag_4 - prod_imag;
                    
                    // 蝶形单元5和7
                    complex_multiply(W8_2_real, W8_2_imag, 
                                   stage1_real_7, stage1_imag_7);
                    stage2_real_5 = stage1_real_5 + prod_real;
                    stage2_imag_5 = stage1_imag_5 + prod_imag;
                    stage2_real_7 = stage1_real_5 - prod_real;
                    stage2_imag_7 = stage1_imag_5 - prod_imag;
                    
                    stage_count <= 3;
                end
                else if (stage_count == 3) begin
                    // 第三级蝶形运算（间隔4）
                    // 蝶形单元0和4
                    complex_multiply(W8_0_real, W8_0_imag, 
                                   stage2_real_4, stage2_imag_4);
                    stage3_real_0 = stage2_real_0 + prod_real;
                    stage3_imag_0 = stage2_imag_0 + prod_imag;
                    stage3_real_4 = stage2_real_0 - prod_real;
                    stage3_imag_4 = stage2_imag_0 - prod_imag;
                    
                    // 蝶形单元1和5
                    complex_multiply(W8_1_real, W8_1_imag, 
                                   stage2_real_5, stage2_imag_5);
                    stage3_real_1 = stage2_real_1 + prod_real;
                    stage3_imag_1 = stage2_imag_1 + prod_imag;
                    stage3_real_5 = stage2_real_1 - prod_real;
                    stage3_imag_5 = stage2_imag_1 - prod_imag;
                    
                    // 蝶形单元2和6
                    complex_multiply(W8_2_real, W8_2_imag, 
                                   stage2_real_6, stage2_imag_6);
                    stage3_real_2 = stage2_real_2 + prod_real;
                    stage3_imag_2 = stage2_imag_2 + prod_imag;
                    stage3_real_6 = stage2_real_2 - prod_real;
                    stage3_imag_6 = stage2_imag_2 - prod_imag;
                    
                    // 蝶形单元3和7
                    complex_multiply(W8_3_real, W8_3_imag, 
                                   stage2_real_7, stage2_imag_7);
                    stage3_real_3 = stage2_real_3 + prod_real;
                    stage3_imag_3 = stage2_imag_3 + prod_imag;
                    stage3_real_7 = stage2_real_3 - prod_real;
                    stage3_imag_7 = stage2_imag_3 - prod_imag;
                    
                    state <= NORMALIZE;
                end
            end
            
            NORMALIZE: begin
                // 归一化处理(除以8)
                x_real_0 <= stage3_real_0 >>> 3;
                x_imag_0 <= stage3_imag_0 >>> 3;
                x_real_1 <= stage3_real_1 >>> 3;
                x_imag_1 <= stage3_imag_1 >>> 3;
                x_real_2 <= stage3_real_2 >>> 3;
                x_imag_2 <= stage3_imag_2 >>> 3;
                x_real_3 <= stage3_real_3 >>> 3;
                x_imag_3 <= stage3_imag_3 >>> 3;
                x_real_4 <= stage3_real_4 >>> 3;
                x_imag_4 <= stage3_imag_4 >>> 3;
                x_real_5 <= stage3_real_5 >>> 3;
                x_imag_5 <= stage3_imag_5 >>> 3;
                x_real_6 <= stage3_real_6 >>> 3;
                x_imag_6 <= stage3_imag_6 >>> 3;
                x_real_7 <= stage3_real_7 >>> 3;
                x_imag_7 <= stage3_imag_7 >>> 3;
                
                done <= 1;
                state <= IDLE;
            end
        endcase
    end
end

endmodule