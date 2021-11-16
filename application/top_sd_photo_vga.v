
module top_sd_photo_vga(
    input                 sys_clk     ,  //系统时钟
    input                 sys_rst_n   ,  //系统复位，低电平有效
                          
    //SD卡接口               
    input                 sd_miso     ,  
    output                sd_clk      ,  
    output                sd_cs       ,  
    output                sd_mosi     ,  
    
    //VGA接口                          
    output                vga_hang      ,  //行同步信号
    output                vga_chang      ,  //场同步信号
    output        [11:0]  vga_rgb        //红绿蓝三原色输出     
    );


//时钟分频模块，产生25MHZ的时钟
wire clk_25m;
divider div_vga(sys_clk,sys_rst_n,clk_25m);

wire sd_init_done;
wire rd_busy;
wire rd_val_en;
wire [15:0] rd_val_data;
wire [15:0] data_out;

wire rd_start_en;
wire [31:0] rd_sec_addr;
wire [15:0] data_in;
wire [11:0] color_data;

wire ena;
wire wena;
wire [31:0] ram_addr;


sd_vga_control control(
    .sys_clk    (clk_25m),
    .sys_rst_n   (sys_rst_n),
    
    .sd_init_done    (sd_init_done),
    .rd_busy        (rd_busy),
    .rd_val_en       (rd_val_en),
    .rd_val_data   (rd_val_data),
    
    .data_out   (data_out),
    
    .rd_start_en     (rd_start_en),
    .rd_sec_addr        (rd_sec_addr),
    .data_in           (data_in),
    .color_data        (color_data),
    
    .ena               (ena),
    .wena              (wena),
    .ram_addr          (ram_addr)
    );

/*blk_mem_gen_0 ramIP(
     .clka    (clk_25m),
     .ena    (ena),
     .wea    (wena),
     .addra  (ram_addr),
     .dina   (data_in),
     .douta  (data_out)
);*/

ram temp(
    .clk   (clk_25m),
    .ena    (ena),
    .wena   (wena),
    .addr   (ram_addr),
    .data_in (data_in),
    .data_out (data_out)
);

//SD卡的读写控制模块
sd_ctrl_top u_sd_ctrl_top(
    .clk_ref           (clk_25m),
    .clk_ref_180deg    (~clk_25m),
    .rst_n             (sys_rst_n),
    //SD卡接口
    .sd_miso           (sd_miso),
    .sd_clk            (sd_clk),
    .sd_cs             (sd_cs),
    .sd_mosi           (sd_mosi),
    //用户读SD卡接口
    .rd_start_en       (rd_start_en),
    .rd_sec_addr       (rd_sec_addr),
    .rd_busy           (rd_busy),
    .rd_val_en         (rd_val_en),
    .rd_val_data       (rd_val_data),    
    
    .sd_init_done      (sd_init_done)
    );  

//VGA驱动模块
vga_driver u_vga_driver(
    .vga_clk        (clk_25m),    
    .sys_rst      (sys_rst_n),    

    .vga_hang         (vga_hang),       
    .vga_chang         (vga_chang),       
    .vga_rgb        (vga_rgb),      
    
    .color_data     (color_data)
    ); 

endmodule