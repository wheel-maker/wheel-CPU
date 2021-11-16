`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 17:48:03
// Design Name: 
// Module Name: vga_driver
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


module vga_driver(
    input vga_clk,
    input sys_rst,
    
    output vga_hang,      //行时序信号
    output vga_chang,    //场时序信号
    output [11:0] vga_rgb,      //vga输出信号
    
    input [11:0] color_data          //输入vga的颜色数据信号
    );
    parameter  H_SYNC   =  10'd96;    //行同步
    parameter  H_BACK   =  10'd48;    //行显示后沿
    parameter  H_DATA   =  10'd640;   //行有效数据
    parameter  H_FRONT  =  10'd16;    //行显示前沿
    parameter  H_CYCLE  =  10'd800;   //行扫描周期
    
    parameter  C_SYNC   =  10'd2;     //场同步
    parameter  C_BACK   =  10'd29;    //场显示后沿
    parameter  C_DATA   =  10'd480;   //场有效数据
    parameter  C_FRONT  =  10'd10;    //场显示前沿
    parameter  C_CYCLE  =  10'd521;   //场扫描周期  

reg [9:0] h_cnt;    
reg [9:0] c_cnt;   


//行同步信号和场同步信号
assign vga_hang=(h_cnt<H_SYNC)?1'b0:1'b1;
assign vga_chang=(c_cnt<C_SYNC)?1'b0:1'b1;

//确定社么时候数据有效
wire data_en;
assign data_en=(h_cnt>=H_SYNC+H_BACK)&&(h_cnt<H_SYNC+H_BACK+H_DATA)
                    &&(c_cnt>=C_SYNC+C_BACK)&&(c_cnt<C_SYNC+C_BACK+C_DATA)
                    ?1'b1:1'b0;

//当数据有效的时候输出数据
assign vga_rgb=data_en?color_data:12'd0;


//行计数器和场计数器依照时钟计数
always @(posedge vga_clk or negedge sys_rst) begin
    if(!sys_rst) begin
        h_cnt<=10'd0;
        c_cnt<=10'd0;
    end
    else begin
        if(h_cnt<H_CYCLE-1'b1)
            h_cnt<=h_cnt+1'b1;
        else begin
            h_cnt<=10'd0;
            if(c_cnt<C_CYCLE-1'b1)
                c_cnt<=c_cnt+1'b1;
            else
                c_cnt<=10'd0;
        end
    end
end 
     
endmodule
