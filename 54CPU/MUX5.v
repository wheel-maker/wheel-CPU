`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 08:20:46
// Design Name: 
// Module Name: MUX5
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


module StoreDec(
    input [31:0] a,
    input [31:0] b,
    input [31:0] addr,
    input sb,
    input sh,
    output [31:0] z
    );
    parameter pos=32'h10010000;
    wire [7:0] sb_mod;
    wire [15:0] sh_mod;
    wire [1:0] option=(addr-pos);
    assign sb_mod=a[7:0];
    assign sh_mod=a[15:0];
    //assign z=sb^~sh?a:sb?{b[31:8],a[7:0]}:{b[31:16],a[15:0]};         只修改最低八位或者十六位
    //assign z=sb^~sh?a:sb?{{24{1'b0}},a[7:0]}:{{16{1'b0}},a[15:0]};           // 最高位也修改为0
    assign z=sb?(option[1]?(option[0]?{sb_mod,b[23:0]}:{b[31:24],sb_mod,b[15:0]}):(option[0]?{b[31:24],sb_mod,b[7:0]}:{b[31:8],sb_mod})):
        (sh?(option[1]?{sh_mod,b[15:0]}:{b[31:16],sh_mod}):a);
endmodule
