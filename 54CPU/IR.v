`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 13:38:29
// Design Name: 
// Module Name: IR
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


module IR(
    input ena,
    input [31:0] data_in,              
    output [31:0] data_out
    );
    reg [31:0] ir;

    assign data_out=ena?ir:data_out;            // �κ�ʱ�̶����Զ�ȡpc�е�����
    
    always @(*)        // ʱ��������д��
        if(ena) ir=data_in;
endmodule
