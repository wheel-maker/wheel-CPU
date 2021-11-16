`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 21:01:39
// Design Name: 
// Module Name: DIV_MUL
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


module DIV_MUL(
    input clk,
    input rst,
    input start,
    input [1:0] div_mul,
    input [31:0] a,
    input [31:0] b,
    output [31:0] lo_out,
    output [31:0] hi_out,
    output busy
    );
    wire busyu_out;
    wire busy_out;
    wire [63:0] mult_o;
    wire [63:0] multu_o;
    wire [63:0] div_o;
    wire [63:0] divu_o;
    MULTU multu(clk,rst,a,b,multu_o);
    MULT mult(clk,rst,a,b,mult_o);
    DIVU divu(a,b,start,clk,rst,divu_o[31:0],divu_o[63:32],busyu_out);
    DIV div(a,b,start,clk,rst,div_o[31:0],div_o[63:32],busy_out);
    
    assign busy=start?(div_mul[1]?1'd0:div_mul[0]?busyu_out:busy_out):1'b0;
    assign lo_out=busy?lo_out:(div_mul[1]?(div_mul[0]?multu_o[31:0]:mult_o[31:0]):(div_mul[0]?divu_o[31:0]:div_o[31:0]));
    assign hi_out=busy?hi_out:(div_mul[1]?(div_mul[0]?multu_o[63:32]:mult_o[63:32]):(div_mul[0]?divu_o[63:32]:div_o[63:32]));
endmodule
