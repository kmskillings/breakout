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

	// Interface signals
	logic 		clock;
	logic		reset;
	logic		load;
	logic		on_count;
	logic [7:0]	counter;
	logic		enable;
	logic		active;
	logic [3:0]	elapsed;

	logic [3:0]	on_count_loaded;

	// Test status signals
	logic [1:0]	tests_complete;

	logic [1:0]	tests_passed;

	// Generate clock signal
	initial begin
		clock <= 1'b0;
		forever #(clock_period / 2) clock <= ~clock;
	end

	// Test program
	initial begin

		// Stimulus initial values
		load <= 0;
		on_count <= 0;
		counter <= 0;
		enable <= 0;

		on_count_loaded <= 0;

		// Hold the DUT in reset for a few clock cycles
		reset <= 1'b0;
		#(3 * clock_period);
		reset <= 1'b1;

	end

	// Check that DUT resets correctly
	initial begin

		@(posedge reset);
		if ((active == 1'b0) && (elapsed == 0)) begin
			tests_passed[0] <= 1'b1;
		end else begin
			 tests_passed[0] = 1'b0;
		end		
		tests_complete[0] <= 1'b1;

	end

	// Test that active output goes high properly
	initial begin

		@(counter == on_count_loaded);
		@(enable == 1'b1);
		@(posedge clock);
		#1;

		if (active == 1) begin
			tests_passed[1] <= 1'b1;
		end else begin
			tests_passed[1] <= 1'b0;
		end
		tests_complete[1] <= 1'b1;

	end

	// Checks results of test
	always @(tests_complete) begin
		if (&(tests_complete)) begin
			if (&(tests_passed)) begin
				$display("All tests passed. Design ok.");
			end else begin
				$display("Some tests failed. Design bad.");
			end
			$finish;
		end
	end

	range_counter #(
		.counter_width(8),
		.elapsed_width(4),
		.range_duration(6)	
	) dut (
		.clock(clock),
		.reset(reset),
		.load(load),
		.on_count(on_count),
		.counter(counter),
		.enable(enable),
		.active(active),
		.elapsed(elapsed)
	);

endmodule
