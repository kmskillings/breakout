.PHONY: all
all: compile_rtl compile_test

.PHONY: compile_rtl
compile_rtl: blinky.vhdl
	vcom -work work -2008 -explicit -vopt ./blinky.vhdl

.PHONY: compile_test
compile_test: ./test/blinky_tb.vhdl
	vcom -work work -2008 -explicit -vopt ./test/blinky_tb.vhdl

.PHONY: simulate
simulate:
	vsim -c -do "run -all" work.blinky_tb
