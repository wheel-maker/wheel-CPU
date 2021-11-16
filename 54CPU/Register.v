`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 20:17:23
// Design Name: 
// Module Name: Register
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


module Register(
    input clk,
    input rst,
    input [31:0] data_in,
    input w,
    output [31:0] data_out
    );
    reg [31:0] register;
    always @(negedge clk or posedge rst)
        if(rst)
            register=32'd0;
        else if(w)
            register=data_in;
        else
            register=register;
    assign data_out=register;
    
endmodule
