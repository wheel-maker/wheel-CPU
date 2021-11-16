`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 20:58:15
// Design Name: 
// Module Name: MULTU
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


module MULTU(
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    output [63:0] z
    );
    parameter N=64;
    
    reg [N-1:0] stored1 [N/2-1:0];
    reg [N-1:0] stored2 [N/4-1:0];
    reg [N-1:0] stored3 [N/8-1:0];
    reg [N-1:0] stored4 [N/16-1:0];
    reg [N-1:0] stored5 [N/32-1:0];
    
    genvar j;
    generate               //生成一级存储
        for(j=0;j<N/2;j=j+1) begin:store1_block
            always @(posedge clk) stored1[j]=reset?64'b0:j==0?(b[j]?{32'b0,a}:64'b0):(b[j]?{{(32-j){1'b0}},a,{j{1'b0}}}:64'b0);
        end
    endgenerate
    
    generate               //生成二级存储
        for(j=0;j<N/4;j=j+1) begin:stored2_block
            always @(posedge clk) stored2[j]=reset?64'b0:stored1[j]+stored1[j+N/4];
        end
    endgenerate
    
    generate               //生成三级存储
        for(j=0;j<N/8;j=j+1) begin:stored3_block
            always @(posedge clk) stored3[j]=reset?64'b0:stored2[j]+stored2[j+N/8];
        end
    endgenerate
    
    generate               //生成四级存储
        for(j=0;j<N/16;j=j+1) begin:stored4_block
            always @(posedge clk) stored4[j]=reset?64'b0:stored3[j]+stored3[j+N/16];
        end
    endgenerate
    
    generate               //生成五级存储
        for(j=0;j<N/32;j=j+1) begin:stored5_block
            always @(posedge clk) stored5[j]=reset?64'b0:stored4[j]+stored4[j+N/32];
        end
    endgenerate
    
    assign z=reset?64'b0:stored5[0]+stored5[1];  //得到结果
    
    
    
endmodule
