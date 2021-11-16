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
    
    // status�Ĵ������
    assign status=cp0_regfiles[12];
    // epc�Ĵ������
    assign exc_addr=cp0_regfiles[14]+32'd4;
    // mfc0��ȡ�Ĵ���Rd��ֵ
    assign rdata=mfc0?cp0_regfiles[Rd]:rdata;
    
    always @(negedge clk or posedge rst) begin
        if(rst) begin
            cp0_regfiles[12]=0;
            cp0_regfiles[13]=0;
            cp0_regfiles[14]=0;
        end
        else begin 
            if(mtc0)                                            // mtc0�ź���Ч��������wdataд��Ĵ���Rd��
                cp0_regfiles[Rd]=wdata;

            case({exception,eret})
                2'b01:                                          // eret�ź���Ч�����жϣ�����5λ
                    cp0_regfiles[12]=status>>5;
                2'b10:  begin                                     
                    cp0_regfiles[12]=status<<5;                 // exception�ź���Ч�����жϣ�����5λ
                    cp0_regfiles[14]=pc;                        // ��pc+4д��epc�Ĵ�����
                    cp0_regfiles[13][6:2]={2'd01,cause[1],1'd0,cause[0]};                // ��causeֵд��cause�Ĵ����ġ�6��2��λ
                end
                default:
                    cp0_regfiles[12]=cp0_regfiles[12];
            endcase
        end
            
    end
    
endmodule
