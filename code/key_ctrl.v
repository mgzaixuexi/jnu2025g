module key_ctrl(
	input 	clk,
	input 	rst_n,
	input 	key,
	input 	shutdown,
	output 	reg valid
);

reg key_d0;
reg key_d1;

wire start;

assign start = ~key_d0 & key_d1 ;//下降沿�?��?

always @(posedge clk or negedge  rst_n)begin
	if(~rst_n)begin
		key_d0 <= 1;
		key_d1 <= 1;
	end
	else begin
		key_d0 <= key;
		key_d1 <= key_d0;
	end
end

always @(posedge clk or negedge rst_n)begin
	if(~rst_n)
		valid <= 0;
	else if(start)//按键按下，启动fft
		valid <= 1;
end
endmodule