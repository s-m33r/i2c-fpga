`timescale 1ns / 1ps

module master (
	input wire clk,
	input wire reset,

	output reg i2c_sda,
	output wire i2c_scl
);

localparam STATE_IDLE = 0;
localparam STATE_START = 1;
localparam STATE_ADDR = 2;
localparam STATE_RW = 3;
localparam STATE_WAIT_ACK = 4;
localparam STATE_DATA = 5;
localparam STATE_STOP = 6;
localparam STATE_WAIT_ACK2 = 7;

reg [7:0] state;
reg [6:0] address; // slave device address
reg [7:0] data;    // data to send

reg [7:0] count;

reg i2c_scl_enable = 0;

assign i2c_scl = (i2c_scl_enable == 0) ? 1 : ~clk;

always @(negedge clk) begin
	if (reset == 1) begin
		i2c_scl_enable <= 0;
	end
	else begin

		if ((state == STATE_IDLE) || (state == STATE_START) || (state == STATE_STOP)) begin
			i2c_scl_enable <= 0;
		end
		else begin
			i2c_scl_enable <= 1;
		end

	end
end

always @(posedge clk) begin
	if (reset == 1) begin
		state <= 0;
		i2c_sda <= 1;

		address = 7'h50;
		data = 8'haa;
		
		count = 8'd0;
	end
	else begin
		case (state)

			STATE_IDLE: begin // idle
				i2c_sda <= 1;
				state <= STATE_START;
			end

			STATE_START: begin // start
				i2c_sda <= 0;
				state <= STATE_ADDR;
				count <= 6; // for sending 7 bits of address in next state
			end

			STATE_ADDR: begin // msb of address
				i2c_sda <= address[count];
				if (count == 0) state <= STATE_RW;
				else count <= count - 1;
			end
			
			STATE_RW: begin 
				i2c_sda <= 1; // write
				state <= STATE_WAIT_ACK;
			end

			STATE_WAIT_ACK: begin
				// TODO: complication - how to read sda, currently set as an
				// output line?
				state <= STATE_DATA;

				count <= 7;
			end

			STATE_DATA: begin
				i2c_sda <= data[count];
				if (count == 0) state <= STATE_WAIT_ACK2;
				else count <= count - 1;
			end

			STATE_WAIT_ACK2: begin
				// TODO: same as STATE_WAIT_ACK
				state <= STATE_STOP;
			end

			STATE_STOP: begin
				i2c_sda <= 1; // stop
				state <= STATE_IDLE;
			end

		endcase
	end
end

endmodule


/*
module testbench;
	// inputs
	reg clk;
	reg reset;

	// outputs
	wire i2c_sda;
	wire i2c_scl;

	// instantiate the unit under test (UUT)
	master uut (
		.clk(clk),
		.reset(reset),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl)
	);

	initial begin
		clk = 0;

		forever begin
			clk = #1 ~clk;
		end
	end

	initial begin
		// initialize inputs
		reset = 1;

		// wait 100ns for global reset to finish
		#10

		// add stimulus here
		reset = 0;

		#100;

		$dumpfile("dump.vcd"); $dumpvars;
		$finish;
	end

endmodule;
*/
