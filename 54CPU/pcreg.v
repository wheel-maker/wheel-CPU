`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 09:25:24
// Design Name: 
// Module Name: pcreg
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


module PCreg(
    input clk,
    input rst,
    input busy,
    input ena,
    input [31:0] data_in,              
    output [31:0] data_out
    );
    reg [31:0] pc;

    assign data_out=pc;            // 任何时刻都可以读取pc中的数据
    
    always @(negedge clk or posedge rst)        // 时钟下降沿写入
        if(rst) pc=32'h00400000;
        else if(ena&&~busy) pc=data_in;
endmodule
