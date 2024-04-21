`timescale 1ns / 1ps

module master_tb;

reg clk;
reg reset;
wire i2c_sda;
wire i2c_scl;

// Instantiate the master module
master dut (
    .clk(clk),
    .reset(reset),
    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl)
);

// Clock generator
always #1 clk = ~clk;

initial begin
    // Initialize signals
    clk = 0;
    reset = 1;

    // Reset the module
    #10 reset = 0;

    // Wait for the module to complete its operations
    #1000 $finish;
end

// Dump signals for GTKWave
initial begin
    $dumpfile("master_tb.vcd");
    $dumpvars(0, master_tb);
end

endmodule
