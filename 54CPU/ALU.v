`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 10:47:55
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] aluc,
    output reg [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow
    );
    reg [32:0] u;
    reg signed [31:0]s_r;
    wire signed [31:0]s_a;
    wire signed [31:0]s_b;
    assign s_a=a;
    assign s_b=b;
    always @(*)
    begin
    case(aluc)
    4'd0:
    begin
        r=a+b;
        if(r==0)        //zeroµÄÅÐ¶Ï
            zero=1;
        else
            zero=0;
       u=a+b;          //carryµÄÅÐ¶Ï
       if(u[32]==1)
           carry=1;
       else
           carry=0;
       if(r[31]==1)        //negativeµÄÅÐ¶Ï
           negative=1;
       else
           negative=0;
           overflow=0;
    end
    4'd2:
    begin
        r=a+b;
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        if(r[31]==1)
            negative=1;
        else
            negative=0;
        if((a[31]==1&&b[31]==1&&r[31]==0)||(a[31]==0&&b[31]==0&&r[31]==1))
            overflow=1;
        else
            overflow=0;
    end
    4'd1:
    begin
        r=a-b;
        if(!r)
            zero=1;
        else
            zero=0;
        if(a<b)
            carry=1;
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end   
    4'd3:
    begin
        r=a-b;
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        if((a[31]==0&&b[31]==1&&r[31]==1)||(a[31]==1&&b[31]==0&&r[31]==0))
            overflow=1;
        else
            overflow=0;
    end    
    4'd4:
    begin
        r=a&b;
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd5:
    begin
        r=a|b;
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd6:
    begin
        r=a^b;
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;        
    end
    4'd7:
    begin
        r=~(a|b);
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;
   end
    4'd8:
    begin
        r={b[15:0],16'b0};
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd9:
    begin
        r={b[15:0],16'b0};
        if(!r)
            zero=1;
        else
            zero=0;
        carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd11:
    begin
        r=(s_a<s_b)?1:0;
        if((a^b)==0)
            zero=1;
        else
            zero=0;
        carry=0;
        if(s_a-s_b<0)
            negative=1;
        else
            negative=0;
        overflow=0; 
    end
    4'd10:
    begin
        r=(a<b)?1:0;
        if(a==b)
            zero=1;
        else
            zero=0;
        if(a<b)
            carry=1;
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd12:
    begin
        r=s_b>>>s_a;
        if(!r)
            zero=1;
        else
            zero=0;
        if(a>0)
            carry=b[a-1];
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd13:
    begin
        r=b>>a;
        if(!r)
            zero=1;
        else
            zero=0;
        if(a>0)
            carry=b[a-1];
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd14:
    begin
        r=b<<a;
        if(!r)
            zero=1;
        else
            zero=0;
        if(a>0&&a<32)
            carry=b[32-a];
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end
    4'd15:
    begin
        r=b<<a;
        if(!r)
            zero=1;
        else
            zero=0;
        if(a>0)
            carry=b[a-1];
        else
            carry=0;
        negative=r[31];
        overflow=0;
    end
    default:
        r=a+b;
    endcase
    end
endmodule
