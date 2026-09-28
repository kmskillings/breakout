dir_test := ./test
dir_src := ./src
dir_test_compiles := ${dir_test}/compiles
dir_test_work := ${dir_test}/vsim/work
dir_test_logs := ${dir_test}/logs
dir_test_passes := ${dir_test}/passes

names_modules := \
vga_controller

# The VHDL source files, including path, for each module in the project
srcs_modules := ${names_modules:%=${dir_src}/%.vhdl}

# The touch files for when each module is successfully compiled for testing
test_compiles_modules := ${names_modules:%=${dir_test_compiles}/%.vhdl.test_compile}

# The VHDL source files, including the path, for the testbench for each module.
srcs_tbs := ${names_modules:%=${dir_test}/%.tb.vhdl}

# The touch files for when each tb is successfully compiled for testing
test_compiles_tbs := ${names_modules:%=${dir_test_compiles}/%.tb.vhdl.test_compile}

# The log files for when each tb is executed
test_logs := ${names_modules:%=${dir_test_logs}/%.log}

test_passes := ${names_modules:%=${dir_test_passes}/%.pass}

.PHONY: all
all: ${test_passes}

${test_passes}: ${dir_test_passes}/%.pass: ${dir_test_logs}/%.log
	grep "TEST_FAILURE" $< || touch $@

${test_logs}: ${dir_test_logs}/%.log: ${dir_test_compiles}/%.vhdl.test_compile ${dir_test_compiles}/%.tb.vhdl.test_compile
	vsim -c -lib ${dir_test_work} -do "run -all; exit" $*_tb | tee $@

.PHONY: compile
compile: ${test_compiles_modules} ${test_compiles_tbs}

${test_compiles_modules}: ${dir_test_compiles}/%.vhdl.test_compile: ${dir_src}/%.vhdl
	vcom -work ${dir_test_work} -2008 -explicit -vopt $< && touch $@

${test_compiles_tbs}: ${dir_test_compiles}/%.tb.vhdl.test_compile: ${dir_test}/%.tb.vhdl
	vcom -work ${dir_test_work} -2008 -explicit -vopt $< && touch $@

.PHONY: clean
clean:
	find ${dir_test_compiles} -maxdepth 1 -name "*.test_compile" -delete
	find ${dir_test_work} -name "*" -delete
	find ${dir_test_logs} -maxdepth 1 -name "*.log" -delete