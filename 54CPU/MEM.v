`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 09:40:31
// Design Name: 
// Module Name: IMEM
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


module MEM(
    input clk,
    input ena,                          // ʹ���źţ��ߵ�ƽ��Ч
    input wena,                         // ��д�źţ��ߵ�ƽд���͵�ƽ��
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
    );
    parameter pos=32'h00400000;
    reg [31:0] RAM [2**9-1:0];          // Mars��text�ĵ�ַ��Ԫ��0x00400000��0x004001ff��data�ĵ�ַ��Ԫ��0x10010000��0x100101ff,��Ϊ2^9�ֽ�;
    
    always @(negedge clk) begin         // ʱ���½���д������
        if(ena&wena) begin
            RAM[(addr-pos)/4]<=data_in;
        end
    end
    
    assign data_out=ena?RAM[(addr-pos)/4]:data_out;    // ʹ���ź���Ч���ɶ�������
    
endmodule
