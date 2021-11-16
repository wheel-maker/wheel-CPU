`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 08:17:50
// Design Name: 
// Module Name: MUX4
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


module HalfOrByte(
    input [31:0] data,
    input [31:0] addr,
    input [1:0] s,
    output [31:0] z
    );
    parameter pos=32'h10010000;
    wire [7:0] sb_data;
    wire [15:0] sh_data;
    wire [1:0] option;
    assign option=addr-pos;
    assign sb_data=option[1]?(option[0]?data[31:24]:data[23:16]):(option[0]?data[15:8]:data[7:0]);
    assign sh_data=option[1]?data[31:16]:data[15:0];
    assign z=s[1]?(s[0]?{16'd0,sh_data}:{{16{sh_data[15]}},sh_data[15:0]}):
                  (s[0]?{24'd0,sb_data[7:0]}:{{24{sb_data[7]}},sb_data[7:0]});
endmodule
