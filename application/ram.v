`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/07 17:48:03
// Design Name: 
// Module Name: vga_driver
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

module ram(
    input clk,
    input ena,
    input wena,
    input [31:0] addr,
    input [15:0] data_in,
    output reg [15:0] data_out
    );
parameter  ram_size=20'd100000;//307200
    reg [15:0] RAM [ram_size:0];
    always @(posedge clk)
        begin
            if(ena)
                begin
                    if(wena)
                        RAM[addr]<=data_in;
                end
            else
                RAM[addr]<=RAM[addr];
        end
    always @(*)
        begin
            if(ena&&~wena)begin
                 data_out<=RAM[addr];        
             end  
            else
                data_out<=16'dz;     
        end
endmodule