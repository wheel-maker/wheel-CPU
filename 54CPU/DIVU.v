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
    
    wire [N:0] sub_add; //�첽�ļӷ�������r_signΪ0�����ϴν��Ϊ�������ν��м�����������мӷ���
    
    assign sub_add=r_sign?({reg_r,q[N-1]}+{1'b0,reg_b}):({reg_r,q[N-1]}-{1'b0,reg_b});
    
    assign r=r_sign?reg_r+reg_b:reg_r;     //���һ�������Ҫ�ָ�����
    
    assign q=reg_q;
    
    always @(posedge clock or posedge reset) begin
        if(reset) begin
            count<=5'b0;
            busy<=0;
            busy2<=0;    //��֤��λ��ʱ��û�����
        end else begin
            busy2<=busy;
            if(start&&~busy) begin
                reg_r<={N{1'b0}};   //reg_r�д�ŵ��Ǳ������ĸ�32λ�������Ľ��Ϊ����
                r_sign<=0;      //r_sign��ʾ�������ķ���
                reg_q<=dividend;//reg_q��ŵ��Ǳ������ĵ�32λ��ÿ�����ƽ����λ���뵽reg_r�����λ�������㣬Ȼ��reg_q�����λʹ�������
                reg_b<=divisor; //reg_b��ŵ��ǳ��������ڼ���
                count<=5'b0;
                busy<=1'b1;
            end else if(busy) begin
                reg_r<=sub_add[N-1:0]; //ÿ�ν����������reg_r
                r_sign<=sub_add[N];  //����������������ֵ��r_sign���Ӷ�ͨ��assign����첽�������һ����ֵ
                reg_q<={reg_q[N-2:0],~sub_add[N]}; //���������ĵ�32λ���ƣ����̿ճ�λ��
                count<=count+6'b1;
                if(count==5'd31) busy<=0;
            end
        end
    end
    
endmodule
