`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/09 09:12:15
// Design Name: 
// Module Name: sd_vga_control
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


module sd_vga_control(
    input sys_clk,
    input sys_rst_n,
    
    input sd_init_done,
    input rd_busy,
    input rd_val_en,
    input [15:0] rd_val_data,
    
    input [15:0] data_out,
    output reg rd_start_en,
    output reg [31:0] rd_sec_addr,
    output reg [15:0] data_in,
    output reg [11:0] color_data,
    
    output reg ena,
    output reg wena,
    output reg [31:0] ram_addr
    );
  
    parameter PHOTO_SECCTION_ADDR0 = 32'd18688;  //第一张图片扇区起始地址 
    //图片大小为640*480，每次读取512字节，需要1200次读取
    parameter  RD_SECTION_NUM  = 11'd1200    ;  //从SD卡中读图片需要的次数  
    //从ram中一次读取16位，共需要1200次读取
    parameter  RD_RAM_NUM=11'd1200;             //从ram中读取数据的次数
  
    //状态机第一步：状态空间
    parameter power_wait =4'b0001;
    parameter read_sd    =4'b0010;
    parameter vga_out    =4'b0100;
    parameter vga_delay  =4'b1000;

    
    //采集rd_busy信号的下降沿
    wire neg_busy;
    reg rd_busy_d0;
    reg rd_busy_d1;
    assign neg_busy=rd_busy_d1&&(~rd_busy_d0);
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            rd_busy_d0<=1'b0;
            rd_busy_d1<=1'b0;
        end
        else begin
            rd_busy_d0<=rd_busy;
            rd_busy_d1<=rd_busy_d0;
        end
    end
    
    //采集rd_val_en的上升沿
    wire pos_rd_en;
    reg rd_en_d0;
    reg rd_en_d1;
    assign pos_rd_en=(~rd_en_d1)&& rd_busy_d0;
        always @(posedge sys_clk or negedge sys_rst_n)begin
            if(!sys_rst_n)begin
                rd_en_d0<=1'b0;
                rd_en_d1<=1'b0;
            end
            else begin
                rd_en_d0<=rd_val_en;
                rd_en_d1<=rd_en_d0;
            end
        end
    
    
    reg [3:0] cur_state;
    reg [3:0] next_state;
    
    
    //状态机第二步：状态跳转
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            cur_state<=power_wait;
        else
            cur_state<=next_state;
    end



    reg vga_en;
    reg sd_rd_finish;
    reg [11:0] rd_sec_cnt;
    reg [25:0] delay_cnt;
    
    
    //状态机第三步：状态转换
    always @(*) begin
        next_state<=power_wait;
        case(cur_state)
            power_wait:begin
                if(sd_init_done)
                    next_state<=read_sd;
                else
                    next_state<=power_wait;
            end
            read_sd:begin
                if(sd_rd_finish)
                    next_state<=vga_out;
                else
                    next_state<=read_sd;          
            end
            vga_out:
                if(rd_sec_cnt == RD_SECTION_NUM - 11'b1)
                    next_state<=vga_delay;   
                else
                    next_state<=vga_out;

            vga_delay:begin
                if(delay_cnt==26'd25000000-26'd1)
                    next_state<=read_sd;
                else
                    next_state<=vga_delay;

            end
            default:
                next_state<=power_wait;
        endcase
    end
    
    
    //状态机第四段：状态下的响应
    reg [11:0] rd_ram_cnt;
    reg [2:0] pos_rd_en_cnt;
    always @(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n) 
        begin
            rd_start_en<=1'b0;
            rd_sec_addr <= PHOTO_SECCTION_ADDR0;
            ena<=1'b0;
            wena<=1'b0;
            ram_addr<=32'd0;
            vga_en<=1'b0;
            rd_ram_cnt<=12'd0;
            rd_sec_cnt <= 12'd0;
            sd_rd_finish<=1'b0;
            delay_cnt<=26'd0;
            pos_rd_en_cnt<=3'd0;
        end
        else begin
            case(cur_state)
                power_wait:begin
                    rd_start_en<=1'b0;                           //SD卡读取信号初始化为0
                    rd_sec_addr <= PHOTO_SECCTION_ADDR0;         //SD卡读取数据的初始地址
                    //ram信号的初始化
                    ena<=1'b0;
                    wena<=1'b0;                                 
                    ram_addr<=32'd0;
                    //vga使能信号初始化
                    vga_en<=1'b0;
                    pos_rd_en_cnt<=3'd0;
                    
                end
               
                read_sd:begin
                       
                       //ram写入数据信号
                       wena<=1'b1;
                       if(pos_rd_en)begin
                           
                           if(pos_rd_en_cnt<=3'd2)
                               pos_rd_en_cnt<=pos_rd_en_cnt+3'd1;
                            else begin
                                pos_rd_en_cnt<=3'd0;
                                ram_addr<=ram_addr+32'd1;
                            end

                           ena<=1'b1;
                       end
                       else 
                           ena<=1'b0;

                        if(neg_busy)begin
                            rd_start_en<=1'b0;
                            rd_sec_cnt <= rd_sec_cnt + 11'd1;
                            rd_sec_addr<=rd_sec_addr+32'd1;
                            if(rd_sec_cnt == RD_SECTION_NUM - 11'b1) begin 
                                rd_sec_cnt <= 11'd0;
                                sd_rd_finish<=1'b1;
                                ram_addr<=32'd0;
                            end
                            else
                                sd_rd_finish<=1'b0; 
                        end
                        else
                            rd_start_en<=1'b1;


                       //vga显示信号
                       vga_en<=1'b0;
                                 
                end       
               
               vga_out:begin 
                   rd_start_en<=1'b0;
                   //ram读取数据
                   ena<=1'b1;
                   wena<=1'b0;
                   
                    //vga输出数据
                   vga_en<=1'b1;
                   rd_ram_cnt<=rd_ram_cnt+12'd1;
                   if(pos_rd_en_cnt<=3'd2)
                        pos_rd_en_cnt<=pos_rd_en_cnt+3'd1;
                    else begin
                        ram_addr<=ram_addr+32'd1;
                        pos_rd_en_cnt<=3'd0;
                    end

                   if(rd_ram_cnt==RD_RAM_NUM-32'd1) begin
                       rd_ram_cnt<=12'd0;
                       ram_addr<=32'd0;
                   end
               end

               vga_delay:begin
                   
                   if(delay_cnt==26'd25000000-26'd1)
                       delay_cnt<=26'd0;
                    else
                       delay_cnt<=delay_cnt+26'd1;
               end

               default:;
               
            endcase
        end
    
    end
    
//下降沿发送数据
always @(negedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin 
        data_in<=16'd0;
    end
    else begin
    if(ena && wena)begin
        data_in<=rd_val_data;
    end
    else begin 
        data_in<=16'd0;
    end
    end
end 
//下降沿发送vga数据
always @(negedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin 
        color_data<=12'd0;
    end
    else begin
    if(vga_en)begin
        color_data[11:8]<=data_out[15:12];
        color_data[7:4]<=data_out[10:7];
        color_data[3:0]<=data_out[4:1];
    end
    else begin 
        color_data<=12'd0;
    end
    end
end
   

endmodule
