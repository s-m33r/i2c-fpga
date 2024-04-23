sim:
	iverilog -o sim src/*
	vvp sim

clean:
	rm sim
	rm *.vcd
