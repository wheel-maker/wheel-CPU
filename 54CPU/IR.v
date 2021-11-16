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

    assign data_out=ena?ir:data_out;            // 任何时刻都可以读取pc中的数据
    
    always @(*)        // 时钟上升沿写入
        if(ena) ir=data_in;
endmodule
