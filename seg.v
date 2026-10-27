
module seg(
    input               clk         ,
    input               rst         ,
    input [7:0]         adc_data    ,
	 input [7:0] 			show_data	,
	 input [2:0]			show_time	,
	 input [1:0] 			state			,
    output reg [7:0]    sel         ,
    output reg [7:0]    seg         
    );
    //1000hz 50_000
    reg [15:0] cnt;
    wire [3:0] hun,ten,one;
    reg [2:0] byte;
    reg [7:0] data_buff;
    assign hun = (show_data>=100)? 1 : 0;
    assign ten = (show_data - hun*100)/10;
    assign one = show_data - hun*100 - ten*10;
    
    always@(posedge clk,negedge rst)begin 
        if(!rst) cnt<=0;
        else if(cnt == 16'd50_000 - 1) 
            cnt<=0;
        else cnt<=cnt+1;
    end
    //byte
    always@(posedge clk,negedge rst)begin 
        if(!rst) byte<=0;
        else if(cnt == 16'd50_000 - 1)
            byte<=byte+1;
        else byte<=byte;
    end
    always@(posedge clk,negedge rst)begin 
        if(!rst) data_buff<=0;
        else begin 
            case(byte)
                0:data_buff<=(state == 0) ? 8'ha : 8'hf;
                1:data_buff<=1;
                2:data_buff<=hun;
                3:data_buff<=ten;
                
                4:data_buff<=one;
                5:data_buff<=8'hff;
                6:data_buff<=0;
                7:data_buff<=show_time;
                
            endcase
        end
    end
    
    always@(posedge clk,negedge rst)begin 
        if(!rst) seg<=8'hff;
        else begin 
            case(data_buff)
            0:begin seg<=8'hc0; end
            1:begin seg<=8'hf9; end
            2:begin seg<=8'ha4; end
            3:begin seg<=8'hb0; end
            
            4:begin seg<=8'h99; end
            5:begin seg<=8'h92; end
            6:begin seg<=8'h82; end
            7:begin seg<=8'hf8; end
            
            8:begin seg<=8'h80; end
            9:begin seg<=8'h90; end
            8'ha:begin seg<=8'h88; end
            8'hb:begin seg<=8'h83; end
            
            8'hc:begin seg<=8'hc6; end
            8'hd:begin seg<=8'ha1; end
            8'he:begin seg<=8'h86; end
            8'hf:begin seg<=8'h8e; end
            default: seg<=8'hff;
            endcase
        end
    end
    always@(posedge clk,negedge rst)begin 
        if(!rst) sel<=8'h0;
        else sel<=~(8'h01<<byte);
    end
endmodule
