
module top(
    input           clk         ,
    input           rst         ,
    input [3:0]     key         ,
    //input [7:0]     adc_data    ,
    output [2:0]    led         ,
    output [7:0]    sel         ,
    output [7:0]    seg         ,
    output          scl         ,
    inout           sda         ,
	 output 				wave
    );
    
    wire [3:0] key_val;
    wire [7:0] adc_data;
	 wire [2:0] show_time;
	 wire [7:0] show_data;
	 wire [1:0] state;
    key key_0(
    .clk      (clk),
    .rst      (rst),
    .key      (key[0]),
    .key_val  (key_val[0])
    );
    key key_1(
    .clk      (clk),
    .rst      (rst),
    .key      (key[1]),
    .key_val  (key_val[1])
    );
    key key_2(
    .clk      (clk),
    .rst      (rst),
    .key      (key[2]),
    .key_val  (key_val[2])
    );
    key key_3(
    .clk      (clk),
    .rst      (rst),
    .key      (key[3]),
    .key_val  (key_val[3])
    );
    
    seg seg_0(
   .clk      (clk),
   .rst      (rst),
   .adc_data (adc_data),
	.show_data(show_data),
	.show_time(show_time),
	.state		(state),
   .sel      (sel),
   .seg      (seg)
    );
    
    adc adc_1(
    .clk       (clk),
    .rst       (rst),
//  .          ()
    .adc_data  (adc_data) ,
    .scl       (scl) ,
    .sda       (sda) 
    );
	 
    wave_gen wave_gen_4(
    .clk             (clk),
    .rst             (rst),

    .adc_data  		(adc_data),
    .duty_input      (key_val[0]),
    .time_input      (key_val[1]),
    .s_out           (key_val[2]),
    .c_out           (key_val[3]),
	 
	 .led					(led)			,
	 .show_data			(show_data) ,
	 .show_time			(show_time)	,
	 .state				(state)		,
    .wave            (wave)
	 
    );
endmodule
