`timescale 1ns/1ns
module key_model;
reg clk;
reg rst_n;
reg key_in;
reg key_out;
wire key_press;

key_det det(
.clk(clk),
.reset(rst_n),
.key(key_in),
.key_state(),
.key_flag(key_press)
);

reg [15:0] myrand;

task press_key;
	begin
			repeat(50) begin
				myrand = {$random}%65536;
				#myrand key_in = ~key_in;
			end
			key_in = 0;
			#50_000_000; // 按下稳定

			repeat(50) begin
				myrand = {$random}%65536;
				#myrand key_in = ~key_in;
			end
			key_in = 1;
			#50_000_000; // 释放稳定
	end
endtask

initial begin
    clk = 1'b0;
    forever #10 clk = ~clk; // 每10ns翻转一次
end

// 不按时高电平，按下时低电平
initial begin
    rst_n = 0;
    key_in = 1;
	#200 rst_n = 1;
	#3000;
	press_key; #10000;	
	press_key; #10000;	
	press_key; #10000;	
	press_key; #10000;	
	$finish;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, key_model); 
end
endmodule
