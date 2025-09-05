.PHONY: compile_all
compile_all: compile_range_counter compile_range_counter_tb

.PHONY: compile_range_counter
compile_range_counter: ./code/range_counter.sv
	vlog -work work -vopt -sv ./code/range_counter.sv

.PHONY: compile_range_counter_tb
compile_range_counter_tb: ./test/range_counter_tb.sv
	vlog -work work -vopt -sv ./test/range_counter_tb.sv

.PHONY: test_range_counter
test_range_counter: compile_range_counter compile_range_counter_tb
	vsim -c -do "run -all" -vopt work.range_counter_tb -voptargs=+acc
