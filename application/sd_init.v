
module sd_initial(
    input  clk,  
    input  sys_rst,  
    
    input  sd_miso,  
    output sd_clk,  
    output reg sd_cs,
    output reg sd_mosi, 
    output reg sd_initial_done     //SD卡初始化完成信号
    );

//初始化中需要使用的命令参数
parameter  CMD0={8'h40,8'h00,8'h00,8'h00,8'h00,8'h95};
parameter  CMD8={8'h48,8'h00,8'h00,8'h01,8'haa,8'h87};
parameter  CMD55={8'h77,8'h00,8'h00,8'h00,8'h00,8'hff};  
parameter  ACMD41={8'h69,8'h40,8'h00,8'h00,8'h00,8'hff};

//初始化和超时的时间判断
parameter  INITIAL_WAIT_NUM = 5000;
parameter  OVER_TIME_NUM = 10000;

 //状态机第一段，状态空间                         
parameter  sd_initial_wait= 7'b000_0001; 
parameter  sd_cmd0        = 7'b000_0010;  
parameter  sd_return_wait = 7'b000_0100;  
parameter  sd_cmd8        = 7'b000_1000;  
parameter  sd_cmd55       = 7'b001_0000;  
parameter  sd_acmd41      = 7'b010_0000;  
parameter  st_init_done   = 7'b100_0000;                                    



//由于SD卡的初始化过程需要低频时钟，所以实例化分频器，将时钟分频为250KHz
wire  div_clk;  
divider #(8'd5) clk_init(clk,sys_rst,div_clk);
assign  sd_clk = ~div_clk;         //SD_CLK


//状态机的第二段：状态跳转
reg [6:0] cur_state;
reg [6:0] next_state; 
always @(posedge div_clk or negedge sys_rst) begin
    if(!sys_rst)
        cur_state <= sd_initial_wait;
    else
        cur_state <= next_state;
end



//状态机的第三段：下一个状态判断，产生激励信号
reg  [5:0] send_cmd_cnt;       //发送命令位计数器
reg  [12:0]  first_wait_cnt;    //待机状态计数器

reg  answer_en;                //是否接受响应数据完成
reg  [47:0] return_data;       //接收返回的响应数据

reg  over_time_en;            //超时信号的标志 

always @(*) begin
    next_state = sd_initial_wait;               //初始化下一状态
    case(cur_state)
        sd_initial_wait : begin           //待机状态，需要74个以上时钟周期"酝酿"
            if(first_wait_cnt == INITIAL_WAIT_NUM)          
                next_state = sd_cmd0;
            else
                next_state = sd_initial_wait;
        end 
        sd_cmd0 : begin                         //发送命令CMD0，共48位
            if(send_cmd_cnt == 6'd47)
                next_state = sd_return_wait;
            else
                next_state = sd_cmd0;    
        end               
        sd_return_wait : begin                         //等待SD卡返回R1命令
            if(answer_en) begin                       
                if(return_data[47:40] == 8'h01)         //R1命令返回正确
                    next_state = sd_cmd8;
                else
                    next_state = sd_initial_wait;
            end
            else if(over_time_en)                    //SD卡响应超时
                next_state = sd_initial_wait;
            else
                next_state = sd_return_wait;                                    
        end    
        sd_cmd8 : begin                          //发送CMD8命令
            if(answer_en) begin                           
                if(return_data[19:16] == 4'b0001)       //SD卡返回R7正确
                    next_state = sd_cmd55;
                else
                    next_state = sd_initial_wait;
            end
            else
                next_state = sd_cmd8;            
        end
        sd_cmd55 : begin                        //发送命令CMD55
            if(answer_en) begin                         
                if(return_data[47:40] == 8'h01)         //SD卡返回R1正确
                    next_state = sd_acmd41;
                else
                    next_state = sd_cmd55;    
            end        
            else
                next_state = sd_cmd55;     
        end  
        sd_acmd41 : begin                       //发送命令ACMD41
            if(answer_en) begin                         
                if(return_data[47:40] == 8'h00)         //SD卡返回R1正确
                    next_state = st_init_done;
                else
                    next_state = sd_cmd55;      
            end
            else
                next_state = sd_acmd41;     
        end                
        st_init_done : 
            next_state = st_init_done;               //初始化完成 
        default : 
            next_state = sd_initial_wait;
    endcase
end



//状态机第四段：状态下的动作，产生输出信号
reg  [15:0] over_time_cnt;     //超时计数器

always @(posedge div_clk or negedge sys_rst) begin
    if(!sys_rst) begin
        sd_cs <= 1'b1;
        sd_mosi <= 1'b1;
        sd_initial_done <= 1'b0;
        send_cmd_cnt <= 6'd0;
        over_time_cnt <= 16'd0;
        over_time_en <= 1'b0;
    end
    else begin
        over_time_en <= 1'b0;
        case(cur_state)
            sd_initial_wait : begin                              //待机状态
                sd_cs <= 1'b1;                           
                sd_mosi <= 1'b1;                         
            end 
                
            sd_cmd0 : begin                          //发送CMD0命令
                send_cmd_cnt <= send_cmd_cnt + 6'd1;        
                sd_cs <= 1'b0;                            
                sd_mosi <= CMD0[6'd47 - send_cmd_cnt];    //非阻塞赋值，到第47位
                if(send_cmd_cnt == 6'd47)                  
                    send_cmd_cnt <= 6'd0;                  
            end      
                                                
            sd_return_wait : begin                         //等待返回的R1命令   
                sd_mosi <= 1'b1;             
                if(answer_en)                                //SD卡返回响应信号                
                    sd_cs <= 1'b1;                                      
                over_time_cnt <= over_time_cnt + 1'b1;    
                if(over_time_cnt == OVER_TIME_NUM - 1'b1) begin  //判断是否超时
                    over_time_en <= 1'b1; 
                    over_time_cnt <= 16'd0;  
                end                                      
            end  
                                                     
            sd_cmd8 : begin                          //发送CMD8命令
                if(send_cmd_cnt<=6'd47) begin
                    send_cmd_cnt <= send_cmd_cnt + 6'd1;
                    sd_cs <= 1'b0;
                    sd_mosi <= CMD8[6'd47 - send_cmd_cnt];      
                end
                else begin
                    sd_mosi <= 1'b1;
                    if(answer_en) begin                      //SD卡返回响应信号
                        sd_cs <= 1'b1;
                        send_cmd_cnt <= 6'd0; 
                    end   
                end                                                                   
            end 
            
            sd_cmd55 : begin                         //发送CMD55
                if(send_cmd_cnt<=6'd47) begin
                    send_cmd_cnt <= send_cmd_cnt + 6'd1;
                    sd_cs <= 1'b0;
                    sd_mosi <= CMD55[6'd47 - send_cmd_cnt];       
                end
                else begin
                    sd_mosi <= 1'b1;
                    if(answer_en) begin                      //SD卡返回响应信号
                        sd_cs <= 1'b1;
                        send_cmd_cnt <= 6'd0;     
                    end        
                end                                                                                    
            end
            sd_acmd41 : begin                        //发送ACMD41
                if(send_cmd_cnt <= 6'd47) begin
                    send_cmd_cnt <= send_cmd_cnt + 6'd1;
                    sd_cs <= 1'b0;
                    sd_mosi <= ACMD41[6'd47 - send_cmd_cnt];      
                end
                else begin
                    sd_mosi <= 1'b1;
                    if(answer_en) begin                      //SD卡返回响应信号
                        sd_cs <= 1'b1;
                        send_cmd_cnt <= 6'd0;  
                    end        
                end     
            end
            st_init_done : begin                          //初始化完成
                sd_initial_done <= 1'b1;
                sd_cs <= 1'b1;
                sd_mosi <= 1'b1;
            end
            default : begin
                sd_cs <= 1'b1;
                sd_mosi <= 1'b1;                
            end    
        endcase
    end
end


//待机状态计数器，同步信号
always @(posedge div_clk or negedge sys_rst) begin
    if(!sys_rst) 
        first_wait_cnt <= 13'd0;
    else if(cur_state == sd_initial_wait) begin
        if(first_wait_cnt < INITIAL_WAIT_NUM)
            first_wait_cnt <= first_wait_cnt + 1'b1;                   
    end
    else
        first_wait_cnt <= 13'd0;    
end    

//在时钟下降沿接收sd卡返回的R1，R3或者R7命令
reg  answer_start;             //开始接收响应数据
reg  [5:0] answer_cnt;         //接收响应的计数器
always @(negedge div_clk or negedge sys_rst) begin
    if(!sys_rst) begin
        answer_en <= 1'b0;
        return_data <= 48'd0;
        answer_start <= 1'b0;
        answer_cnt <= 6'd0;
    end    
    else begin
        if(sd_miso == 1'b0 && answer_start == 1'b0) begin    //检测到miso线上的返回信号
            answer_start <= 1'b1;
            return_data <= {return_data[46:0],sd_miso};
            answer_cnt <= answer_cnt + 6'd1;
            answer_en <= 1'b0;
        end    
        else if(answer_start) begin
            return_data <= {return_data[46:0],sd_miso};     
            answer_cnt <= answer_cnt + 6'd1;
            if(answer_cnt == 6'd47) begin
                answer_start <= 1'b0;
                answer_cnt <= 6'd0;
                answer_en <= 1'b1; 
            end                
        end  
        else
            answer_en <= 1'b0;         
    end
end                    


endmodule