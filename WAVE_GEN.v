`timescale 1ns / 1ps

module wave_gen(
    input           clk                     ,
    input           rst                     ,
    
    input           [7:0] adc_data          ,
    input           duty_input              ,
    input           time_input              ,
    input           s_out                   ,
    input           c_out                   ,
    
	 output reg [2:0] led							,
	 output reg [7:0] show_data					,
	 output reg [2:0]  show_time					,
	 output reg [1:0] state							,
    output          wave                    
    );
    //1-数据录入
    //2-波形输出
    parameter   IDLE = 2'b00,
                S_OUT = 2'b01,
                C_OUT = 2'b10,
                DONE = 2'b11;
                
    reg wave_reg;           
    reg [2:0] time_input_reg;
    reg [28:0] cnt_1s;
    reg [2:0] cnt_wave;
    reg [2:0] cnt_time;
    //数据存储器
    reg [7:0] duty_mem[2:0];
    reg [2:0] time_input_mem[2:0];
    reg [2:0] duty_mem_cnt,time_input_mem_cnt;
    
    wire [7:0] duty;
    //1000hz 50_000
    reg [15:0] counter;
    wire [15:0] DUTY_NUM;
    
    assign duty = adc_data * 100 / 255;
    assign DUTY_NUM = duty_mem[cnt_wave] * 500;
    assign wave = wave_reg;
    //cnt_1s
    always@(posedge clk,negedge rst) begin 
        if(!rst) cnt_1s<=0;
        else if((state == S_OUT) || (state == C_OUT)) begin
            if(cnt_1s == 29'd50_000_000 - 1 ) 
                cnt_1s<=0;
            else cnt_1s<=cnt_1s+1;
        end
    end
    //time_input_reg
     always@(posedge clk,negedge rst) begin 
        if(!rst) time_input_reg<=3'd1;
        else if((time_input) & (state == IDLE))
            time_input_reg <=(time_input_reg == 3'd5) ? 3'd1: time_input_reg + 1;
			else if(state == DONE) 
				time_input_reg<=3'd1;
			else time_input_reg <= time_input_reg;
     end
     //1KHz
     always@(posedge clk,negedge rst) begin 
        if(!rst) counter<=0;
        else if((state == S_OUT) || (state == C_OUT))
            counter <= (counter == 16'd50_000) ? 0 : counter+1;
     end
     //wave
     always@(posedge clk,negedge rst) begin 
        if(!rst) wave_reg<=0;
        else if((state == S_OUT) || (state == C_OUT))
            wave_reg <= (counter < DUTY_NUM) ? 1 : 0;
        else wave_reg<=0;
     end
     //state
     always@(posedge clk,negedge rst) begin 
        if(!rst) begin 
            state<=IDLE;
            duty_mem_cnt<=0;
            time_input_mem_cnt<=0;
            cnt_wave<=0;
            cnt_time<=0;
				led<=3'b111;
				show_time<=0;
				show_data<=0;
            end
        else begin 
            case(state)
                IDLE : begin 
								led<=3'b110;
								show_time <= time_input_reg;
								show_data <= duty;
                        if(duty_input) begin 
                            duty_mem[duty_mem_cnt]<=duty;
                            time_input_mem[time_input_mem_cnt]<=time_input_reg;
                            duty_mem_cnt<=duty_mem_cnt+1;
                            time_input_mem_cnt<=time_input_mem_cnt+1; 
                        end
								else if(duty_mem_cnt != 0) begin 
									if(s_out) 
                            state<=S_OUT;
                        else if(c_out)
                            state<=C_OUT;
								end
                    end
                S_OUT : begin 
								led<=3'b101;
								show_time <= time_input_mem[cnt_wave] - cnt_time;
								show_data <= duty_mem[cnt_wave];
								if(s_out) 
									state <= DONE;
                        else if(cnt_time == time_input_mem[cnt_wave]) begin 
                            state <= (cnt_wave == duty_mem_cnt - 1) ? DONE : state;
                            cnt_wave <= cnt_wave + 1;
                            cnt_time <= 0;
                            end
                        else if(cnt_1s == 29'd50_000_000 - 1 )
                            cnt_time <= cnt_time + 1;
                    end
                C_OUT : begin 
								led<=3'b011;
								show_time <= time_input_mem[cnt_wave] - cnt_time;
								show_data <= duty_mem[cnt_wave];
                        if(c_out) 
                            state<=DONE;
                        else if(cnt_time == time_input_mem[cnt_wave]) begin 
//                            state <= (cnt_wave == duty_mem_cnt) ? DONE : state;
                            cnt_wave <=(cnt_wave == duty_mem_cnt - 1) ? 0 : cnt_wave + 1;
                            cnt_time <= 0;
                            end
                        else if(cnt_1s == 29'd50_000_000 - 1 )
                            cnt_time <= cnt_time + 1;
                    end
                DONE : begin 
                        state<=IDLE;
                        duty_mem_cnt<=0;
                        time_input_mem_cnt<=0;
                        cnt_wave<=0;
                        cnt_time<=0;
								led<=3'b111;
								show_time<=0;
								show_data<=0;
                    end
                default : state<=DONE;
            endcase
        end
     end
endmodule
