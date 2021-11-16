`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 21:00:32
// Design Name: 
// Module Name: DIV
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


module DIV(
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
 reg [4:0] count;
 reg [N-1:0] reg_q;
 reg [N-1:0] reg_r;
 reg [N-1:0] reg_b;
 reg r_sign;
 
 wire [N-1:0] r_t;
 
 wire [N:0] sub_add; //异步的加法器，当r_sign为0，即余数和除数符号相同，进行减法，否则进行加法；
 
 assign sub_add=r_sign?({reg_r,reg_q[N-1]}+{reg_b[N-1],reg_b}):({reg_r,reg_q[N-1]}-{reg_b[N-1],reg_b});
 
 assign r=dividend[N-1]?-r_t:r_t;     //为了确保余数和被除数的符号一致，最后加入判断，如果不一致，则余数减去除数
 assign r_t=r_sign?reg_r+reg_b:reg_r;
 
 assign q=(dividend[N-1]==divisor[N-1])?reg_q:-reg_q;   //为了确保余数和被除数的符号一致，最后加入判断，如果不一致，商加1,如果一致，不恢复余数，最后一位恒商1
 
 always @(posedge clock or posedge reset) begin
     if(reset) begin
         count<=5'b0;
         busy<=0;
     end else begin
         if(start&&~busy) begin
             reg_r<={N{1'b0}};   //reg_r中存放的是被除数的高32位，用被除数的符号位补充，运算后的结果为余数
             r_sign<=0;      //r_sign表示运算结果后余数和除数的符号是否相反
             reg_q <=(dividend[N-1]? -dividend:dividend); //reg_q存放的是被除数的低32位，每次左移将最高位加入到reg_r的最低位参与运算，然后reg_q的最低位使用商来填补
             reg_b <=(divisor[N-1]? -divisor:divisor); //reg_b存放的是除数，用于计算
             count<=5'b0;
             busy<=1'b1;
         end else if(busy) begin
             reg_r<=sub_add[N-1:0]; //每次将余数存放入reg_r
             r_sign<=sub_add[N];  //将运算结果的正负赋值给r_sign，从而通过assign语句异步计算出下一步的值
             reg_q<={reg_q[N-2:0],~sub_add[N]}; //将被除数的低32位左移，给商空出位置
             count<=count+5'b1;
             if(count==5'd31) busy<=0;
         end
     end
 end
 
endmodule
