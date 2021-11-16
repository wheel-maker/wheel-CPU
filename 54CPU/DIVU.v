`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 21:00:05
// Design Name: 
// Module Name: DIVU
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


module DIVU(
    input [31:0] dividend,
    input [31:0] divisor,
    input start,
    input clock,
    input reset,
    output [31:0] q,
    output [31:0] r,
    output reg busy
    );
    parameter N=32; 
    wire ready;
    reg [4:0] count;
    reg [N-1:0] reg_q;
    reg [N-1:0] reg_r;
    reg [N-1:0] reg_b;
    reg busy2,r_sign;
    assign ready=~busy&busy2;
    
    wire [N:0] sub_add; //异步的加法器，当r_sign为0，即上次结果为正，本次进行减法，否则进行加法；
    
    assign sub_add=r_sign?({reg_r,q[N-1]}+{1'b0,reg_b}):({reg_r,q[N-1]}-{1'b0,reg_b});
    
    assign r=r_sign?reg_r+reg_b:reg_r;     //最后一步结果需要恢复余数
    
    assign q=reg_q;
    
    always @(posedge clock or posedge reset) begin
        if(reset) begin
            count<=5'b0;
            busy<=0;
            busy2<=0;    //保证复位的时候没有输出
        end else begin
            busy2<=busy;
            if(start&&~busy) begin
                reg_r<={N{1'b0}};   //reg_r中存放的是被除数的高32位，运算后的结果为余数
                r_sign<=0;      //r_sign表示运算结果的符号
                reg_q<=dividend;//reg_q存放的是被除数的低32位，每次左移将最高位加入到reg_r的最低位参与运算，然后reg_q的最低位使用商来填补
                reg_b<=divisor; //reg_b存放的是除数，用于计算
                count<=5'b0;
                busy<=1'b1;
            end else if(busy) begin
                reg_r<=sub_add[N-1:0]; //每次将余数存放入reg_r
                r_sign<=sub_add[N];  //将运算结果的正负赋值给r_sign，从而通过assign语句异步计算出下一步的值
                reg_q<={reg_q[N-2:0],~sub_add[N]}; //将被除数的低32位左移，给商空出位置
                count<=count+6'b1;
                if(count==5'd31) busy<=0;
            end
        end
    end
    
endmodule
