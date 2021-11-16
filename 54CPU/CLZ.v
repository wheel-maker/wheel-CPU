`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/28 20:31:37
// Design Name: 
// Module Name: CLZ
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


module CLZ(
    input [31:0] data_in,
    output [31:0] data_out
    );
    integer i;
    always @(*)
        for(i=32'd31;~data_in[i]&&i;i=i-1)
            begin
            
            end
    assign data_out=i?32'd31-i:(data_in[i]?32'd31-i:32'd32);
endmodule
