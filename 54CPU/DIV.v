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
 
 wire [N:0] sub_add; //�첽�ļӷ�������r_signΪ0���������ͳ���������ͬ�����м�����������мӷ���
 
 assign sub_add=r_sign?({reg_r,reg_q[N-1]}+{reg_b[N-1],reg_b}):({reg_r,reg_q[N-1]}-{reg_b[N-1],reg_b});
 
 assign r=dividend[N-1]?-r_t:r_t;     //Ϊ��ȷ�������ͱ������ķ���һ�£��������жϣ������һ�£���������ȥ����
 assign r_t=r_sign?reg_r+reg_b:reg_r;
 
 assign q=(dividend[N-1]==divisor[N-1])?reg_q:-reg_q;   //Ϊ��ȷ�������ͱ������ķ���һ�£��������жϣ������һ�£��̼�1,���һ�£����ָ����������һλ����1
 
 always @(posedge clock or posedge reset) begin
     if(reset) begin
         count<=5'b0;
         busy<=0;
     end else begin
         if(start&&~busy) begin
             reg_r<={N{1'b0}};   //reg_r�д�ŵ��Ǳ������ĸ�32λ���ñ������ķ���λ���䣬�����Ľ��Ϊ����
             r_sign<=0;      //r_sign��ʾ�������������ͳ����ķ����Ƿ��෴
             reg_q <=(dividend[N-1]? -dividend:dividend); //reg_q��ŵ��Ǳ������ĵ�32λ��ÿ�����ƽ����λ���뵽reg_r�����λ�������㣬Ȼ��reg_q�����λʹ�������
             reg_b <=(divisor[N-1]? -divisor:divisor); //reg_b��ŵ��ǳ��������ڼ���
             count<=5'b0;
             busy<=1'b1;
         end else if(busy) begin
             reg_r<=sub_add[N-1:0]; //ÿ�ν����������reg_r
             r_sign<=sub_add[N];  //����������������ֵ��r_sign���Ӷ�ͨ��assign����첽�������һ����ֵ
             reg_q<={reg_q[N-2:0],~sub_add[N]}; //���������ĵ�32λ���ƣ����̿ճ�λ��
             count<=count+5'b1;
             if(count==5'd31) busy<=0;
         end
     end
 end
 
endmodule
