// VGA Controller
//
// The VGA controller is responsible for generating the video signal for
// display, based on the game state provided by the Game Controller. The VGA
// Controller also detects pixel-perfect collisions and reports them to the
// Game Controller.

module vga_controller
	#(
		parameter rows_total = 525,
		parameter rows_vsync = 2,
		parameter rows_back = 33,
		parameter rows_front = 10,
		parameter pixels_total = 800,
		parameter pixels_hsync = 96,
		parameter pixels_back = 48,
		parameter pixels_front = 16
	)
	(
		input logic 		clock,
		input logic 		reset,
		input logic		vga_vsync,
		input logic 		vga_hsync,
		input logic [3:0]	vga_red,
		input logic [3:0]	vga_green,
		input logic [3:0]	vga_blue
	);

	localparam rows_visible = rows_total
				  - rows_vsync
				  - rows_back
				  - rows_front;

	localparam pixels_visible = pixels_total
				    - pixels_hsync
				    - pixels_back
       				    - pixels_front;
	
	


	// The pixel counter increments with every clock cycle.

	localparam pixel_counter_width = $clog2(pixels_total);
	logic [pixel_counter_width-1:0] pixel_counter;

	logic pixel_last;
	assign pixel_last = 
		pixel_counter == pixels_total - 1 ?
		1'b0 :
		1'b1;

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			pixel_counter <= 0;
		end

		else if (pixel_last == 1'b1) begin
			pixel_counter <= 0;
		end

		else begin
			pixel_counter <= pixel_counter + 1;
		end
		
	end

	// The row counter increments each time the pixel counter rolls over.
	
	localparam row_counter_width = $clog2(rows_total);
	logic [row_counter_width-1:0] row_counter;

	logic row_last;
	assign row_last =
		row_counter == rows_total - 1 ?
		1'b0 :
		1'b1;

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			row_counter <= 0;
		end

		// I know this is hard to read, but the idea is that the row
		// counter only increments when the pixel_counter is about to
		// roll over.
		else if (pixel_last == 1'b0) begin
			row_counter <= row_counter;
		end

		else if (row_last == 1'b1) begin
			row_counter <= 0;
		end

		else begin
			row_counter <= row_counter + 1;
		end
	
	end

	// Determines whether the horizontal scan is in the sync phase.
	localparam hsync_begins = pixels_visible + pixels_front - 1;
	localparam hsync_ends = hsync_begins + pixels_hsync;
	logic hsync_active;
	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			hsync_counter <= 0;
			hsync_active <= 1'b0;
		end

		else if (pixel_counter == hsync_begins) begin
			hsync_active <= 1'b1;
		end

		else if (pixel_counter == hsync_ends) begin
			hysnc_active <= 1'b0;
		end

	end

	// Determines whether the vertical scan is in the sync phase.
	
	localparam vsync_begins = rows_visible + rows_front - 1;
	localparam vsync_ends = vsync_begins + vsync_rows;

	logic vsync_active;

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			vsync_active <= 1'b0;
		end

		else if (pixel_last == 1'b0) begin
		end

		else if (row_counter == vsync_begins) begin
			vsync_active <= 1'b1;
		end

		else if (row_counter == vsync_ends) begin
			vsync_active <= 1'b0;
		end

	end

	// Determines whether the horizontal scan is in the visible phase.
	
	localparam horizontal_visible_begins = pixels_total - 1;
	localparam horizontal_visible_ends = pixels_visible - 1;

	logic horizontal_visible;

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			horizontal_visible <= 1'b1;
		end

		else if (pixel_counter == horizontal_visible_begins) begin
			horizontal_visible <= 1'b1;
		end

		else if (pixel_counter == horizontal_visible_ends) begin
			horizontal_visible <= 1'b0;
		end

	end

	// Determines whether the vertical scan is in the visible phase.
	
	localparam vertical_visible_begins = rows_total - 1;
	localparam vertical_visible_ends = rows_visible - 1;

	logic vertical_visible;

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			vertical_visible <= 1'b1;
		end

		else if (pixel_last == 1'b0) begin
		end

		else if (row_counter == vertical_visible_begins) begin
			vertical_visible <= 1'b1;
		end

		else if (row_counter == vertical_visible_ends) begin
			vertical_visible <= 1'b0;
		end

	end

	logic visible;
	assign visible = vertical_visible & horizontal_visible;

	// Outputs the video signal.
	
	always_ff @(posedge clock, negedge reset) begin
		
		if(reset == 1'b0) begin
			vga_vsync <= 1'b1;
		end

		else if (vsync_active == 1'b0) begin
			vga_vsync <= 1'b1;	
		end

		else if (vsync_active == 1'b1) begin
			vga_vsync <= 1'b0;
		end

	end

	always_ff @(posedge clock, negedge reset) begin

		if (reset == 1'b0) begin
			vga_hsync <= 1'b1;
		end

		else if (hsync_active == 1'b0) begin
			vga_vsync <= 1'b1;
		end

		else if (hsync_active == 1'b1) begin
			vga_vsync <= 1'b0;
		end

	end

	always_ff @(posedge clock, negedge reset) begin
		
		if (reset == 1'b0) begin
			vga_red <= 4'b1111;
			vga_green <= 4'b1111;
			vga_blue <= 4'b1111;
		end

		else if (visible == 1'b1) begin
			vga_red <= 4'b1111;
			vga_green <= 4'b1111;
			vga_blue <= 4'b1111;
		end

		else begin
			vga_red <= 4'b0000;
			vga_green <= 4'b0000;
			vga_blue <= 4'b0000;
		end

	end

endmodule

