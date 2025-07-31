`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/21 16:07:20
// Design Name: 
// Module Name: key_debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lcd_key_ctrl(
    input clk,
    input rst_n,
    input [8:0] lcd_key,
    output reg [8:0] lcd_key_value
    );


reg [8:0] lcd_key_d0;
reg [8:0] lcd_key_d1;
wire lcd_key_valid;
assign lcd_key_valid = (|lcd_key_d0) & (~(|lcd_key_d1));

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) 
    begin 
        lcd_key_d0<=9'd0;
        lcd_key_d1<=9'd0;
    end
    else 
        lcd_key_d0 <= lcd_key;
        lcd_key_d1 <= lcd_key_d0;
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) lcd_key_value <= 9'b111111111;
    else 
    begin
        if(lcd_key_valid)
            lcd_key_value <= ~lcd_key;
        else
            lcd_key_value <= 9'b111111111;
    end
end
    
endmodule
