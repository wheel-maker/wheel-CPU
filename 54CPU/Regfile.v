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
    input clk,                  // ʱ���½���д������
    input rst,                  // �첽��λ�źţ��ߵ�ƽ��Ч
    input we,                   // �Ĵ�����д��Ч�źţ��ߵ�ƽд
    
    input [4:0] rsc,            // �����ݵ�ַ1
    input [4:0] rtc,            // �����ݵ�ַ2
    input [4:0] rdc,            // д���ݵ�ַ
    input [31:0] rd,            // ʱ���½���д����
    output reg [31:0] rs,       // �������1
    output reg [31:0] rt        // �������2
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
        if(we==1'b1&&rdc)                // ʱ���½���д������
            array_reg[rdc]=rd;
    end
endmodule
