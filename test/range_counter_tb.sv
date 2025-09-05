// Range Counter Testbench
//
// Performs the following tests on the module range_counter:
// - The "active" output goes high the clock tick after the input counter
// reaches the loaded on_count value.
// - The "active" output goes low "range_duration" clock ticks after it goes
// high.
// - The two above tests are still valid after loading a new on_count value.
// - If a new on_count value is loaded during the active range, all outputs go
// to zero.
// - All above tests are still valid after asynchronously resetting the
// device.

`timescale 1ns/1ps

module range_counter_tb #() ();

	localparam int clock_freq = 25_200_000;
	localparam real clock_period = 1.0 / clock_freq * 1_000_000_000;

	logic 		clock;
	logic		reset;
	logic [7:0]	counter;
	logic [3:0]	elapsed;
	logic		active;

	logic [10:0]	tests_complete;
	logic [10:0]	tests_passed;

	// Generate clock signal
	initial begin
		clock <= 1'b0;
		forever #(clock_period / 2) clock <= ~clock;
	end

	range_counter #(
		.counter_width(8),
		.elapsed_width(4),
		.range_duration(6)	
	) dut (
		.clock(clock),
		.reset(reset),
		.counter(counter),
		.active(active),
		.elapsed(elapsed)
	);

endmodule
