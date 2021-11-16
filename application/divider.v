`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 17:48:56
// Design Name: 
// Module Name: divider
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

module divider(
    input sys_clk,
    input sys_rst,
    output reg div_clk
);
//分频计数，将100MHZ的时钟分频为25MHZ
parameter DIV_NUM=1;
reg [2:0] counts;
initial
    div_clk<=1'b0;
always @(posedge sys_clk or negedge sys_rst) begin
    if(!sys_rst) begin
        counts<=0;
        div_clk<=0;
    end
    else begin
        if(counts<DIV_NUM)
            counts<=counts+1;
        else  begin
            counts<=0;
            div_clk<=~div_clk;
        end
    end
end
endmodule