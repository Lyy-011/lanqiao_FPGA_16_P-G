
module key(
    input       clk         ,
    input       rst         ,
    input       key         ,
    output reg  key_val     
    );
    //20ms 50_000_000 * 20 * 10^-3 = 1_000_000
    reg [19:0] cnt;
    always@(posedge clk,negedge rst) begin 
        if(!rst) cnt<=0;
        else if(!key) begin 
            if(cnt == 20'd1_000_000 ) cnt<=cnt;
            else cnt<=cnt+1;
        end
        else cnt<=0;
    end
    always@(posedge clk,negedge rst) begin 
        if(!rst) key_val<=0;
        else if(cnt == 20'd1_000_000 - 1) key_val<=1;
        else key_val<=0;
    end
    
endmodule
