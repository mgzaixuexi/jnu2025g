//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//�?术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料�?
//版权�?有，盗版必究�?
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           top_lcd_touch
// Created by:          正点原子
// Created date:        2023�?5�?24�?14:17:02
// Version:             V1.0
// Descriptions:        LCD触摸屏实验顶层模�?
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module top_lcd_touch(
    //时钟和复位接�?
    input            sys_clk    ,  //系统时钟信号
    input            sys_rst_n  ,  //系统复位信号

    //output            ad_otr,
    output            ad_clk,
    input   [7:0]    ad_data,

	output [5:0] seg_sel,
	output [7:0] seg_led,

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

//wire define
wire  [15:0]  lcd_id     ;      //LCD屏ID
wire  [31:0]  data       ;      //触摸点坐�?


//*****************************************************
//**                    main code
//*****************************************************                                       
clk_wiz_0 u_clk_div( 
    .clk_out1(ad_clk),
    //.reset(sys_rst_n),
    .clk_in1(sys_clk)
  );
//触摸驱动顶层模块    
touch_top  u_touch_top(
    .clk            (sys_clk    ),
    .rst_n          (sys_rst_n  ),

    .touch_rst_n    (touch_rst_n),
    .touch_int      (touch_int  ),
    .touch_scl      (touch_scl  ),
    .touch_sda      (touch_sda  ),
    
    .lcd_id         (lcd_id     ),
    .data           (data       )
);
      
//例化LCD显示模块
lcd_rgb_char  u_lcd_rgb_char
(
   .sys_clk         (sys_clk  ),
   .sys_rst_n       (sys_rst_n),
   .ad_clk          (ad_clk  ),
   .ad_data         (ad_data  ),
   .data            (data     ),
	.seg_sel        (seg_sel),
    .seg_led        (seg_led),   
   //RGB LCD接口 
   .lcd_id          (lcd_id   ),
   .lcd_hs          (lcd_hs   ),
   .lcd_vs          (lcd_vs   ),
   .lcd_de          (lcd_de   ),
   .lcd_rgb         (lcd_rgb  ),
   .lcd_bl          (lcd_bl   ),
   .lcd_rst_n       (lcd_rst_n),
   .lcd_clk         (lcd_clk  )
);



endmodule 