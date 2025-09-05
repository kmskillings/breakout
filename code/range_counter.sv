// Range Counter
//
// Range Counter monitors an upwards-counting input. When it reaches a certain
// count, the Range Counter's primary output goes high. The Range Counter also
// has a secondary output, which counts the number of ticks since the output
// went high. Once this count reaches a certain value, determined by a generic,
// the primary output goes low and the count resets.
//
// The "turn-on count" of the Range Counter can be loaded by asserting
// a "load" input. This also causes all the outputs to clear.

module range_counter #(
	parameter counter_width,
	parameter elapsed_width,
	parameter range_duration
) (
	input logic 				clock,
	input logic				reset,
	input logic [counter_width - 1:0] 	load,
	input logic				on_count,
	input logic [counter_width - 1:0]	counter,
	output logic				active,
	output logic [elapsed_width - 1:0]	elapsed
);

	// Load the on_count register.
	logic [counter_width - 1:0] current_on_count;
	always_ff @(posedge clock or negedge reset) begin

		if (reset == 1'b0) begin
			current_on_count <= 0;
		end

		else if (load == 1'b1) begin
			current_on_count <= on_count;
		end

	end

	// Active signal goes high when the on_count is reached and low when
	// the full duration has elapsed.
	always_ff @(posedge clock or negedge reset) begin

		if (reset == 1'b0) begin
			active <= 1'b0;
		end

		else if (load == 1'b1) begin
			active <= 1'b0;
		end

		else if (counter == current_on_count) begin
			active <= 1'b1;
		end

		else if (elapsed == range_duration - 1) begin
			active <= 1'b0;
		end
	end

	// The elapsed counter starts counting when active goes high and
	// resets when it goes low.
	always_ff @(posedge clock or negedge reset) begin

		if (reset == 1'b0) begin
			elapsed <= 0;
		end

		else if (load == 1'b1) begin
			elapsed <= 0;
		end

		else if (active == 1'b1) begin
			if (elapsed == range_duration - 1) begin
				elapsed <= 0;
			end else begin
				elapsed <= elapsed + 1;
			end
		end

		else if (active == 1'b0) begin
			elapsed <= 0;
		end

	end

endmodule
