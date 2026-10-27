
module adc(
    input               clk            ,
    input               rst            ,
//
    output reg [7:0]    adc_data        ,
    output              scl             ,
    inout               sda             
    );
    
    reg [15:0] cnt;
    reg iic_start;
    reg iic_rw_flag;
    
    wire [7:0] adc_data_reg;
    wire [15:0] iic_rdata;
    wire iic_rdata_valid;
     always@(posedge clk,negedge rst)begin 
        if(!rst) cnt<=0;
        else if(cnt == 16'd50_000 - 1) 
            cnt<=0;
        else cnt<=cnt+1;
    end
    
    always@(posedge clk,negedge rst) begin 
        if(!rst) {iic_start,iic_rw_flag}<=0;
        else if(cnt == 16'd50_000 - 1) 
            {iic_start,iic_rw_flag}<={1'b1,1'b1};
        else {iic_start,iic_rw_flag}<=0;
    end
    
    assign adc_data_reg = iic_rdata[11:4];
    
    always@(posedge clk,negedge rst) begin 
        if(!rst) adc_data<=0;
        else if(iic_rdata_valid)
            adc_data<=adc_data_reg;
    end
    
    iic_drive
#(
   .P_SYS_CLK        (28'd50_000_000),  //系统时钟频率
   .P_IIC_SCL        (28'd125_000   ),  //IIC SCL时钟频率 
   .P_DEVICE_ADDR    (7 'b1010_100  ),  //IIC从设备 器件地址(电位器器件地址:1010_100)
   .P_ADDR_BYTE_NUM  (8 'd1         )   ,  //IIC从设备 数据地址字节数
   .P_DATA_BYTE_NUM  (8 'd2         )    //IIC 1 次操作 传输数据字节数
)   IIC_2   
(
    .iic_clk             (clk)         ,
    .iic_rst             (rst)         ,
//II.                    ()
    .iic_start           (iic_start)         ,   //读写操作开始信号     0:     1:开始
    .iic_ready           ()         ,   //设备忙、闲指示信号   0:繁忙  1:空闲
    .iic_rw_flag         (iic_rw_flag)         ,   //读写标志信号         0:写    1：读 
//II.                    ()
    .iic_word_addr       ()         ,   //读写的数据地址       
    .iic_wdata           ()         ,   //写的数据 (先写高字节数据的高位)   
//II.                    ()
    .iic_rdata           (iic_rdata)         ,   //读的数据 (先读高字节数据的高位) 
    .iic_rdata_valid     (iic_rdata_valid)         ,   //读数据有效信号       0:无效    1:有效
//II.                    ()
    .iic_ack_error       ()         ,   //应答失败信号         0:应答正常 1:应答失败
//II.                    ()
    .iic_scl             (scl)         ,   //IIC SCL 
    .iic_sda             (sda)             //IIC SDA
);

endmodule
