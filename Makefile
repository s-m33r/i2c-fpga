sim:
	iverilog -o sim src/*
	vvp sim
	gtkwave master_tb.vcd

clean:
	rm sim
	rm *.vcd
