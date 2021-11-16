`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 10:53:14
// Design Name: 
// Module Name: Control
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


module Control(
    input [53:0] ins,           // 54位的IR译码器结果
    input [3:0] symbol,         // 4位ALU的标志位
    output pc_ena,
    output R_WE,
    output M1,
    output [1:0] M2,
    output [1:0] M3,
    output [1:0] M4,
    output [2:0] M5,
    output [1:0] M6,
    output [1:0] M7,
    output M8,
    output M9,
    output M10,
    output M11,
    output [3:0] ALUC,
    output D_WE,
    output D_E,
    output mfc0,
    output mtc0,
    output exception,
    output eret,
    output [1:0] cause,
    output sb,
    output sh,
    output lo_w,
    output hi_w,
    output [1:0] div_mul,
    output start
    );
    
    assign pc_ena=1'b1;
    assign R_WE=~((ins[0]&symbol[0])||(ins[1]&symbol[0])||ins[6]||ins[7]||ins[8]||ins[10]||(ins[26]&symbol[0])||ins[28]||ins[31]||ins[32]||ins[33]||ins[34]||ins[36]||ins[37]||ins[43]||ins[44]||ins[47]||ins[48]||ins[49]||ins[50]||ins[52]);
    assign M1=ins[16]||ins[22]||ins[24];
    assign M2[1]=~(ins[8]||ins[9]||ins[10]||ins[38]);
    assign M2[0]=ins[8]||ins[9]||ins[33];
    assign M3[1]=ins[30]||ins[15]||ins[5]||ins[37];
    assign M3[0]=ins[1]||ins[2]||ins[12]||ins[19]||ins[20]||ins[28]||ins[37]||ins[39]||ins[40]||ins[41]||ins[42]||ins[43]||ins[44];
    assign M4[1]=ins[9];
    assign M4[0]=ins[0]||ins[3]||ins[4]||ins[13]||ins[14]||ins[16]||ins[17]||ins[18]||ins[21]||ins[22]||ins[23]||ins[24]||ins[25]||ins[26]||ins[27]||ins[29]||ins[38]||ins[45]||ins[46]||ins[51]||ins[53];
    assign M5[2]=ins[35]||ins[39]||ins[40]||ins[41]||ins[42]||ins[45]||ins[46]||ins[51]||ins[53];
    assign M5[1]=ins[9]||ins[11]||ins[38]||ins[39]||ins[40]||ins[41]||ins[42]||ins[45]||ins[46]||ins[53];
    assign M5[0]=ins[11]||ins[12]||ins[45]||ins[46]||ins[51]||ins[53];
    assign M6[1]=ins[31]||ins[32]||(ins[34]&symbol[3])||(ins[37]&~symbol[1]);
    assign M6[0]=(ins[6]&symbol[3])||(ins[7]&~symbol[3])||ins[31]||ins[32]||(ins[34]&symbol[3]);
    assign M7[1]=ins[40]||ins[42];
    assign M7[0]=ins[39]||ins[40];
    assign M8=ins[45];
    assign M9=ins[49]||ins[50]||ins[52];
    assign M10=ins[49]||ins[50]||ins[52];
    assign M11=ins[53];
    assign ALUC[3]=ins[16]||ins[17]||ins[18]||ins[19]||ins[20]||ins[21]||ins[22]||ins[23]||ins[24]||ins[25];
    assign ALUC[2]=ins[4]||ins[5]||ins[13]||ins[14]||ins[15]||ins[16]||ins[17]||ins[22]||ins[23]||ins[24]||ins[25]||ins[29]||ins[30];
    assign ALUC[1]=ins[0]||ins[1]||ins[12]||ins[13]||ins[16]||ins[17]||ins[18]||ins[19]||ins[20]||ins[21]||ins[26]||ins[28]||ins[29]||ins[30];
    assign ALUC[0]=ins[6]||ins[7]||ins[13]||ins[14]||ins[15]||ins[18]||ins[19]||ins[24]||ins[25]||ins[26]||ins[27]||ins[34]||ins[37];
    assign D_WE=ins[28]||ins[43]||ins[44];
    assign D_E=ins[12]||ins[28]||ins[39]||ins[40]||ins[41]||ins[42]||ins[43]||ins[44];
    assign mfc0=ins[35];
    assign mtc0=ins[36];
    assign exception=ins[31]||ins[32]||(ins[34]&symbol[3]);
    assign eret=ins[33];
    assign cause[1]=ins[34]|ins[53];
    assign cause[0]=ins[31]|ins[34];
    assign sb=ins[43];
    assign sh=ins[44];
    assign lo_w=ins[48]||ins[49]||ins[50]||ins[52]||ins[53];
    assign hi_w=ins[47]||ins[49]||ins[50]||ins[52]||ins[53];
    assign div_mul[1]=ins[51]||ins[52];
    assign div_mul[0]=ins[50]||ins[52];
    assign start=ins[49]||ins[50]||ins[51]||ins[52];
endmodule
