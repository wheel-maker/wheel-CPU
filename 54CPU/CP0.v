`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/06/26 09:15:17
// Design Name: 
// Module Name: CP0
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


module CP0(
    input clk,
    input rst,
    input mfc0,
    input mtc0,
    input [31:0] pc,
    input [4:0] Rd,
    input [31:0] wdata,
    input exception,
    input eret,
    input [1:0] cause,
    output [31:0] rdata,
    output [31:0] status,
    output [31:0] exc_addr
    );
    reg [31:0] cp0_regfiles [31:0];
    
    reg [31:0] shift;
    
    // status寄存器输出
    assign status=cp0_regfiles[12];
    // epc寄存器输出
    assign exc_addr=cp0_regfiles[14]+32'd4;
    // mfc0读取寄存器Rd的值
    assign rdata=mfc0?cp0_regfiles[Rd]:rdata;
    
    always @(negedge clk or posedge rst) begin
        if(rst) begin
            cp0_regfiles[12]=0;
            cp0_regfiles[13]=0;
            cp0_regfiles[14]=0;
        end
        else begin 
            if(mtc0)                                            // mtc0信号有效，将数据wdata写入寄存器Rd中
                cp0_regfiles[Rd]=wdata;

            case({exception,eret})
                2'b01:                                          // eret信号有效，开中断，右移5位
                    cp0_regfiles[12]=status>>5;
                2'b10:  begin                                     
                    cp0_regfiles[12]=status<<5;                 // exception信号有效，关中断，左移5位
                    cp0_regfiles[14]=pc;                        // 将pc+4写入epc寄存器中
                    cp0_regfiles[13][6:2]={2'd01,cause[1],1'd0,cause[0]};                // 将cause值写入cause寄存器的【6：2】位
                end
                default:
                    cp0_regfiles[12]=cp0_regfiles[12];
            endcase
        end
            
    end
    
endmodule
