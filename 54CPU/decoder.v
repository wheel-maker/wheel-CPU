`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 08:32:50
// Design Name: 
// Module Name: decoder
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
/*  
    output30 ADD,
    output29 ADDU,
    output28 SUB,
    output27 SUBU,
    output26 AND,
    output25 OR,
    output24 XOR,
    output23 NOR,
    output22 SLT,
    output21 SLTU,
    output20 SLL,
    output19 SRL,
    output18 SRA,
    output17 SLLV,
    output16 SRLV,
    output15 SRAV,
    output14 JR,
    output13 ADDI,
    output12 ADDIU,
    output11 ANDI,
    output10 ORI,
    output09 XORI,
    output08 LUI,
    output07 LW,
    output06 SW,
    output05 BEQ,
    output04 BNE,
    output03 SLTI,
    output02 SLTIU,
    output01 J,
    output00 JAL,
   */
//////////////////////////////////////////////////////////////////////////////////


module Decoder(
    input [5:0] op,
    input [5:0] func,
    input [4:0] rs,
    output reg [53:0] ins
    );
    always @(*)begin
        case(op)
            6'b000000:
                case(func)
                    6'b100000:ins={53'b0,1'b1};             // ADD
                    6'b100001:ins={50'b0,1'b1,3'b0};        // ADDU
                    6'b100010:ins={27'b0,1'b1,26'b0};        // SUB
                    6'b100011:ins={26'b0,1'b1,27'b0};        // SUBU
                    6'b100100:ins={49'b0,1'b1,4'b0};        // AND
                    6'b100101:ins={39'b0,1'b1,14'b0};        // OR
                    6'b100110:ins={24'b0,1'b1,29'b0};        // XOR
                    6'b100111:ins={40'b0,1'b1,13'b0};        // NOR
                    6'b101010:ins={35'b0,1'b1,18'b0};        // SLT
                    6'b101011:ins={32'b0,1'b1,21'b0};        // SLTU
                    6'b000000:ins={37'b0,1'b1,16'b0};       // SLL
                    6'b000010:ins={29'b0,1'b1,24'b0};       // SRL
                    6'b000011:ins={31'b0,1'b1,22'b0};       // SRA
                    6'b000100:ins={36'b0,1'b1,17'b0};       // SLLV
                    6'b000110:ins={28'b0,1'b1,25'b0};       // SRLV
                    6'b000111:ins={30'b0,1'b1,23'b0};       // SRAV
                    6'b001000:ins={43'b0,1'b1,10'b0};       // JR
                    6'b001001:ins={15'b0,1'b1,38'b0};       // JALR
                    6'b001100:ins={21'b0,1'b1,32'b0};       // SYSCALL
                    6'b001101:ins={22'b0,1'b1,31'b0};       // BREAK
                    6'b110100:ins={19'b0,1'b1,34'b0};       // TEQ
                    6'b010000:ins={8'b0,1'b1,45'b0};       // MFHI
                    6'b010010:ins={7'b0,1'b1,46'b0};       // MFLO
                    6'b010001:ins={6'b0,1'b1,47'b0};       // MTHI
                    6'b010011:ins={5'b0,1'b1,48'b0};       // MTLO
                    6'b011010:ins={4'b0,1'b1,49'b0};       // DIV
                    6'b011011:ins={3'b0,1'b1,50'b0};       // DIVU
                    //6'b011000:ins={2'b0,1'b1,51'b0};       // MULT
                    6'b011001:ins={1'b0,1'b1,52'b0};       // MULTU
                    default:ins=54'd0;
               endcase
           6'b000001:ins={16'b0,1'b1,37'b0};                // BGEZ
           6'b001000:ins={52'b0,1'b1,01'b0};                // ADDI
           6'b001001:ins={51'b0,1'b1,02'b0};                // ADDIU
           6'b001100:ins={48'b0,1'b1,05'b0};                // ANDI
           6'b001101:ins={38'b0,1'b1,15'b0};                // ORI
           6'b001110:ins={24'b1,30'b0};                // XORI
           6'b001111:ins={42'b0,1'b1,11'b0};                // LUI
           6'b100011:ins={41'b0,1'b1,12'b0};                // LW
           6'b101011:ins={25'b0,1'b1,28'b0};                // SW
           6'b000100:ins={47'b0,1'b1,06'b0};                // BEQ
           6'b000101:ins={46'b0,1'b1,07'b0};                // BNE
           6'b001010:ins={34'b0,1'b1,19'b0};                // SLTI
           6'b001011:ins={33'b0,1'b1,20'b0};                // SLTIU
           6'b000010:ins={45'b0,1'b1,08'b0};                // J
           6'b000011:ins={44'b0,1'b1,09'b0};                      // JAL
           6'b010000:
                case(func)
                    6'b011000:ins={20'b0,1'b1,33'b0};       // ERET
                    6'b000000:
                        case(rs)
                            5'b00000:ins={18'b0,1'b1,35'b0};       // MFC0
                            5'b00100:ins={17'b0,1'b1,36'b0};       // MTC0

                        endcase
                endcase
            6'b100100:ins={14'b0,1'b1,39'b0};       // LBU
            6'b100101:ins={13'b0,1'b1,40'b0};       // LHU
            6'b100000:ins={12'b0,1'b1,41'b0};       // LB
            6'b100001:ins={11'b0,1'b1,42'b0};       // LH
            6'b101000:ins={10'b0,1'b1,43'b0};       // SB
            6'b101001:ins={9'b0,1'b1,44'b0};       // SH   
            6'b011100:
                case(func)
                    6'b100000:ins={1'b1,53'b0};         // CLZ
                    6'b000010:ins={2'b0,1'b1,51'b0};    // MUL
                endcase
           default:ins=54'b0;
        endcase
    end
endmodule
