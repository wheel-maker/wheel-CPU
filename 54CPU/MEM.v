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
    input ena,                          // 使能信号，高电平有效
    input wena,                         // 读写信号，高电平写，低电平读
    input [31:0] addr,
    input [31:0] data_in,
    output [31:0] data_out
    );
    parameter pos=32'h00400000;
    reg [31:0] RAM [2**9-1:0];          // Mars中text的地址单元从0x00400000到0x004001ff，data的地址单元从0x10010000到0x100101ff,均为2^9字节;
    
    always @(negedge clk) begin         // 时钟下降沿写入数据
        if(ena&wena) begin
            RAM[(addr-pos)/4]<=data_in;
        end
    end
    
    assign data_out=ena?RAM[(addr-pos)/4]:data_out;    // 使能信号有效即可读出数据
    
endmodule
