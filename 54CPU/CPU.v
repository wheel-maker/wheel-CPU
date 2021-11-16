`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 13:22:29
// Design Name: 
// Module Name: CPU
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


module CPU54(
    input clk,
    input rst,
    input ena,
    input [31:0] ir_in,
    input [31:0] dm_out,
    output d_e,
    output d_we,
    output [31:0] alu_out,
    output [31:0] dm_in,
    output [31:0] pc_out
    );
    parameter exception_pos=32'd40000000;
    //PC寄存器相关信号
    wire pc_ena;            //控制器输出信号
    reg pc_e;               // 输出给pc的信号
    always @(*)
        pc_e=rst?1'b0:pc_ena;
    wire [31:0] pc_in;
    
    //IMEM相关信号
    wire i_we=1'b0;
    
    //IR寄存器相关信号
    wire [31:0] ir_out;
    
    //指令译码器相关信号
    wire [53:0] ins;
    
    //选择器相关信号
    wire m1;
    wire [1:0] m2;
    wire [1:0] m3;
    wire [1:0] m4;
    wire [2:0] m5;
    wire [1:0] m6;
    wire [1:0] m7;
    wire m8;
    wire m9;
    wire m10;
    wire m11;
    wire [31:0] mux6_out;
    
    //Regfile相关信号
    wire r_we;
    wire [4:0] rdc;  
    wire [31:0] rs;
    wire [31:0] rt;
    wire [31:0] rd;
    
    // ALU相关信号
    wire [3:0] symbol;
    wire [3:0] alu_c;
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    
    
    // NPC相关信号
    wire [31:0] npc_out;
    
    // CP0相关信号
    wire mfc0;
    wire mtc0;
    wire eret;
    wire exception;
    wire [1:0] cause;
    wire [31:0] epc;
    wire [31:0] cp0_out;
    
    // 数据截断处理
    wire [31:0] half_byte;
    
    // 54条新增控制信号
    wire sb;
    wire sh;
    wire lo_w;
    wire hi_w;
    wire [1:0] div_mul;
    wire start;
    wire busy;
    
    // lo和hi寄存器相关信号
    wire [31:0] hi_in;
    wire [31:0] hi_out;
    wire [31:0] hi_data;
    wire [31:0] lo_in;
    wire [31:0] lo_out;
    wire [31:0] lo_data;
    
   // 选择器的输出
   wire [31:0] mux8_out;
   wire [31:0] mux11_out;
   
   // CLZ相关信号
   wire [31:0] clz_out;
   
    //PC寄存器
    PCreg pcreg(clk,rst,busy,pc_e,pc_in,pc_out);
    
    // hi和lo寄存器
    Register lo(clk,rst,lo_in,lo_w,lo_data);
    Register hi(clk,rst,hi_in,hi_w,hi_data);
   
    //MEM imem(clk,ena,i_we,pc_out,32'd0,ir_in);

    
    //IR寄存器
    IR ir(ena,ir_in,ir_out);
    
    //指令译码器
    Decoder ins_dec(ir_out[31:26],ir_out[5:0],ir_out[25:21],ins);
    
    // 选择器
    MUX2_1 mux1(rs,{27'b0,ir_out[10:6]},m1,alu_a);
    MUX4_1 mux2(rs,{npc_out[31:28],ir_out[25:0],2'd0},mux6_out,epc,m2,pc_in);
    MUX4_1 mux3(rt,{{16{ir_out[15]}},ir_out[15:0]},{16'b0,ir_out[15:0]},32'd0,m3,alu_b);
    MUX4_1 mux4(ir_out[20:16],ir_out[15:11],32'd31,32'd31,m4,rdc);
    MUX8_1 mux5(alu_out,dm_out,npc_out,{ir_out[15:0],{16{1'b0}}},cp0_out,lo_out,half_byte,mux11_out,m5,rd);
    MUX4_1 mux6(npc_out,npc_out+{{14{ir_out[15]}},ir_out[15:0],2'd0},npc_out+{{14{ir_out[15]}},ir_out[15:0],2'd0},exception_pos,m6,mux6_out);
    MUX2_1 mux8(lo_data,hi_data,m8,mux8_out);
    MUX2_1 mux9(rs,lo_out,m9,lo_in);
    MUX2_1 mux10(rs,hi_out,m10,hi_in);
    MUX2_1 mux11(mux8_out,clz_out,m11,mux11_out);
    
    // CLZ计算
    CLZ clz(rs,clz_out);
    
    // half or byte of data extend
    HalfOrByte data_dec(dm_out,alu_out,m7,half_byte);
    
    // sb or sh
    StoreDec store_dec(rt,dm_out,alu_out,sb,sh,dm_in);
    
    //ALU
    ALU alu(alu_a,alu_b,alu_c,alu_out,symbol[3],symbol[2],symbol[1],symbol[0]);
   
    //NPC
    NPC npc(pc_out,npc_out);
   
   //Regfiles
    Regfiles cpu_ref(clk,rst,r_we,ir_out[25:21],ir_out[20:16],rdc,rd,rs,rt);
    
    //控制器
    Control control(ins,symbol,pc_ena,r_we,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,alu_c,d_we,d_e,mfc0,mtc0,
        exception,eret,cause,sb,sh,lo_w,hi_w,div_mul,start);
    
    // CP0协处理器
    CP0 cp0(clk,rst,mfc0,mtc0,pc_out,ir_out[15:11],rt,exception,eret,cause,cp0_out,,epc);
    
    // 乘除法器模块
    DIV_MUL div_mult(clk,rst,start,div_mul,rs,rt,lo_out,hi_out,busy);
    
endmodule
