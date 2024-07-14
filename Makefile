
tb:
	iverilog -o tb *.v
	vvp -n tb -lxt2
	#gtkwave dual_clk_fifo_tb.vcd

clean:
	rm -rf tb *.vcd

.PHONY:tb clean
