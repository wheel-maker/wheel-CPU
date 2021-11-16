`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/21 06:59:01
// Design Name: 
// Module Name: sccomp_dataflow
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


module sccomp_dataflow(
    input clk_in,
    input reset,
    output [31:0] inst,
    output [31:0] pc
    //output [7:0] display7_seg,
    //output [7:0] display7_sel
    );
    
    wire cs=1'd1;
    wire d_e;
    wire d_we;
    wire [31:0] alu_out;
    wire [31:0] dm_in;
    wire [31:0] dm_out;
    wire [31:0] ir_in;
    
    //wire clk_out;
    
    //wire [31:0] inst;
    wire [31:0] pc_out;
    
    //pll pll_clk(clk_in,clk_out);
    
    CPU54 sccpu(clk_in,reset,1'b1,ir_in,dm_out,d_e,d_we,alu_out,dm_in,pc_out);
    
    //IMEM和DMEM
    imem imem((pc_out-32'h00400000)>>2,ir_in);
    //MEM #(32'h00400000)imem(clk_in,1'b1,1'b0,pc_out,,ir_in);
    MEM #(32'h10010000)dmem(clk_in,d_e,d_we,alu_out,dm_in,dm_out);
    
    // 七段数码管显示
    //seg7x16 display7(clk_in,reset,cs,pc_out,display7_seg,display7_sel);
    
    assign pc=pc_out;      // 对应测试文件pc的输出需要减去00400000
    assign inst=sccpu.ir_out;

endmodule
