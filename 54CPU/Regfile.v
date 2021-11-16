`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 10:03:49
// Design Name: 
// Module Name: Regfile
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


module Regfiles(
    input clk,                  // 时钟下降沿写入数据
    input rst,                  // 异步复位信号，高电平有效
    input we,                   // 寄存器读写有效信号，高电平写
    
    input [4:0] rsc,            // 读数据地址1
    input [4:0] rtc,            // 读数据地址2
    input [4:0] rdc,            // 写数据地址
    input [31:0] rd,            // 时钟下降沿写数据
    output reg [31:0] rs,       // 数据输出1
    output reg [31:0] rt        // 数据输出2
    );
    reg [31:0] array_reg [31:0];
    integer i;
    always @(*)begin
        if(rst==1)
            for(i=0;i<32;i=i+1) array_reg[i]=32'd0;
        else begin
             rs=array_reg[rsc];   
             rt=array_reg[rtc];  
        end
    end
    
    always @(negedge clk) begin
        if(we==1'b1&&rdc)                // 时钟下降沿写入数据
            array_reg[rdc]=rd;
    end
endmodule
