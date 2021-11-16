

module sd_ctrl_top(
    input                clk_ref       ,  
    input                clk_ref_180deg,
    input                rst_n         ,  
    //SD卡接口
    input                sd_miso       ,  
    output               sd_clk        ,  
    output  reg          sd_cs         ,  
    output  reg          sd_mosi       , 
   
    //用户读SD卡接口
    input                rd_start_en   ,  
    input        [31:0]  rd_sec_addr   , 
    output               rd_busy       , 
    output               rd_val_en     , 
    output       [15:0]  rd_val_data   , 
    
    output               sd_init_done     //SD卡初始化完成信号
    );


wire  init_sd_clk   ;  
wire  init_sd_cs    ;  
wire  init_sd_mosi  ;  
wire  rd_sd_cs      ;    
wire  rd_sd_mosi    ;     

assign  sd_clk = (sd_init_done==1'b0)  ?  init_sd_clk  :  clk_ref_180deg;

//SD卡接口信号选择
always @(*) begin
    if(sd_init_done == 1'b0) begin     
        sd_cs = init_sd_cs;
        sd_mosi = init_sd_mosi;
    end       
    else if(rd_busy) begin
        sd_cs = rd_sd_cs;
        sd_mosi = rd_sd_mosi;       
    end    
    else begin
        sd_cs = 1'b1;
        sd_mosi = 1'b1;
    end    
end    

//SD卡初始化
sd_initial u_sd_init(
    .clk            (clk_ref),
    .sys_rst              (rst_n),
    
    .sd_miso            (sd_miso),
    .sd_clk             (init_sd_clk),
    .sd_cs              (init_sd_cs),
    .sd_mosi            (init_sd_mosi),
    
    .sd_initial_done       (sd_init_done)
    );


//SD卡读数据
sd_read uut_sd_read(
    .clk              (clk_ref),
    .sys_rst           (rst_n),
    
    .sd_miso            (sd_miso),
    .sd_cs              (rd_sd_cs),
    .sd_mosi           (rd_sd_mosi),
    
    .rd_start          (rd_start_en),
    .rd_addr           (rd_sec_addr),
    .rd_busy           (rd_busy),
    .rd_en             (rd_val_en),
    .rd_data           (rd_val_data)
);
endmodule