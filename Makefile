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

./build/blinky.sof ./build/blinky.pof: blinky.vhdl blinky.qsf blinky.sdc
	quartus_map blinky
	quartus_fit blinky
	quartus_asm blinky
	quartus_sta blinky

.PHONY: burn_temp
burn_temp: ./build/blinky.sof
	quartus_pgm -c "USB-Blaster [1-1]" -m "JTAG" -o "p;./build/blinky.sof"

.PHONY: burn_perm
burn_perm: ./build/blinky.sof
	quartus_pgm -c "USB-Blaster [1-1]" -m "JTAG" -o "bpv;./build/blinky.pof"
