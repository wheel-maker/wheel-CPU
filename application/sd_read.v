module sd_read(
    input clk,
    input sys_rst,
    
    input sd_miso,
    output reg sd_cs,
    output reg sd_mosi,
    
    input rd_start,              //用户输入，表示是否请求读取数据
    input [31:0] rd_addr,       //表示读取数据的地址
    output reg rd_busy,          
    output reg rd_en,            //表示读取完的16bit数据是否准备就绪
    output reg [15:0] rd_data   
    );


//采集输入信号的上升沿
wire pos_start;
reg rd_start_d1;
reg rd_start_d0;
always @(posedge clk or negedge sys_rst) begin
    if(!sys_rst) begin
        rd_start_d0<=1'b0;
        rd_start_d1<=1'b0;
    end
    else begin
        rd_start_d0<=rd_start;
        rd_start_d1<=rd_start_d0;
    end
end
assign pos_start=(~rd_start_d1)&rd_start_d0;               

//状态机第一段：状态空间
parameter rd_wait   =4'b0001;
parameter rd_cmd    =4'b0010;
parameter rd_recieve=4'b0100;
parameter rd_over   =4'b1000;

//状态机第二段：状态跳转
reg [3:0] cur_state;
reg [3:0] next_state;
always @(posedge clk or negedge sys_rst) begin
    if(!sys_rst)
        cur_state<=rd_wait;
    else
        cur_state<=next_state;
end

//状态机第三段：下一个状态判断，激励信号
reg re_en;      //返回数据是否有效
reg rd_finish;            //接收完成的信号
always @(*) begin
    next_state<=rd_wait;
    case(cur_state)
        rd_wait:begin
            if(pos_start)begin
                next_state<=rd_cmd;
            end
            else
                next_state<=rd_wait;
        end

        rd_cmd:begin
            if(re_en)
                next_state<=rd_recieve;
            else
                next_state<=rd_cmd;
        end

        rd_recieve:begin
            if(rd_finish)
                next_state<=rd_over;
            else
                next_state<=rd_recieve;
        end
        default:
            next_state<=rd_over;
    endcase
end

//状态机第四段：状态下的动作，产生输出信号
reg recieve_flag;
reg [5:0] cmd_cnt;
reg [47:0] cmd_data;
always @(posedge clk or negedge sys_rst) begin
    if(!sys_rst) begin
        sd_cs<=1'b1;
        sd_mosi<=1'b1;
        cmd_data<=48'd0;
        cmd_cnt<=6'd0;
        rd_busy<=1'b0;
        recieve_flag<=1'b0;
    end
    else begin
        case(cur_state)
            rd_wait:begin
                rd_busy<=1'b0;
                sd_cs<=1'b1;
                sd_mosi<=1'b1;
                cmd_data<={8'h51,rd_addr,8'hff};
            end
            rd_cmd:begin
                rd_busy<=1'b1;
                if(cmd_cnt<=6'd47) begin
                    cmd_cnt<=cmd_cnt+6'd1;
                    sd_cs<=1'b0;
                    sd_mosi<=cmd_data[6'd47-cmd_cnt];
                end 
                else begin
                    sd_mosi<=1'b1;
                end
            end

            rd_recieve:begin
                recieve_flag<=1'b1;
                if(rd_finish) begin
                    sd_cs<=1'b1;
                    recieve_flag<=1'b0;
                end
            end

            rd_over:begin
                sd_cs<=1'b1;
                sd_mosi<=1'b1;
            end
            
            default:begin
                sd_cs<=1'b1;
                sd_mosi<=1'b1;
            end
        endcase
    end


end


//接受来自SD卡的返回值
reg re_start;   //返回数据的开始标志
reg [6:0] re_data;  //返回数据的接受器
reg [5:0] re_cnt;    //返回数据的计数器
always @(negedge clk or negedge sys_rst) begin
    if(!sys_rst) begin
        re_en <= 1'b0;
        re_data <= 7'd0;
        re_start <= 1'b0;
        re_cnt <= 6'd0;
    end    
    else begin
        if(sd_miso == 1'b0 && re_start == 1'b0) begin
            re_start <= 1'b1;
        end    
        else if(re_start) begin
            re_data <= {re_data[5:0],sd_miso};
            re_cnt <= re_cnt + 6'd1;
            if(re_cnt == 6'd6) begin
                re_start <= 1'b0;
                re_cnt <= 6'd0;
                re_en <= 1'b1; 
            end                
        end  
        else
            re_en <= 1'b0;        
    end
end 

//接受从SD卡读取到的数据
reg recieve_start;   //接受读取SD卡数据开始的标志
reg [3:0] recieve_bit_cnt;  //以16bit为一个单位的计数器
reg [8:0] recieve_data_cnt;  
reg [15:0] recieve_data_temp; //16bit的接收数据的寄存器
reg read_en;                  //表示16bit数据已经接收完毕，是否准备好发送
always @(negedge clk or negedge sys_rst) begin
    if(!sys_rst) 
    begin
        read_en <= 1'b0;
        recieve_data_temp <= 16'd0;
        recieve_start <= 1'b0;
        recieve_bit_cnt <= 4'd0;
        recieve_data_cnt <= 9'd0;
        rd_finish <= 1'b0;
    end    
    else begin
        read_en <= 1'b0; 
        rd_finish <= 1'b0;
        if(recieve_flag && sd_miso == 1'b0 && recieve_start == 1'b0)    
            recieve_start <= 1'b1;   
        else if(recieve_start) begin
            recieve_bit_cnt <= recieve_bit_cnt + 4'd1;
            recieve_data_temp <= {recieve_data_temp[14:0],sd_miso};
            if(recieve_bit_cnt == 4'd15) begin 
                recieve_data_cnt <= recieve_data_cnt + 9'd1;
                if(recieve_data_cnt <= 9'd255)                        
                    read_en <= 1'b1;  
                else if(recieve_data_cnt == 9'd257) begin   //接收两个字节的CRC校验值
                    recieve_start <= 1'b0;
                    rd_finish <= 1'b1;              //数据接收完成
                    recieve_data_cnt <= 9'd0;               
                    recieve_bit_cnt <= 4'd0;end   
            end                
        end       
        else
            recieve_data_temp <= 15'd0;
    end    
end    

//时钟上升沿输出数据
always @(posedge clk or negedge sys_rst) begin
    if(!sys_rst) begin
        rd_en <= 1'b0;
        rd_data <= 15'd0;
    end
    else begin
        if(read_en) begin
            rd_en <= 1'b1;
            rd_data <= recieve_data_temp;
        end    
        else
            rd_en <= 1'b0;
    end
end


endmodule