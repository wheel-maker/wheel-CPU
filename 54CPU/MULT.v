`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 20:59:04
// Design Name: 
// Module Name: MULT
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


module MULT(
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    output [63:0] z
    );
    wire [31:0] _a=a[31]?-a:a;
    wire [31:0] _b=b[31]?-b:b;
    wire [63:0] _z;
    MULTU uut(.clk(clk),.reset(reset),.a(_a),.b(_b),.z(_z));       
    assign z=a[31]^b[31]?-_z:_z;
    
endmodule
