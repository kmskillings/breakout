dir_test := ./test
dir_src := ./src
dir_test_compiles := ${dir_test}/compiles

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

.PHONY: all
all: ${test_compiles_modules} ${test_compiles_tbs}

${test_compiles_modules}: ${dir_test_compiles}/%.vhdl.test_compile: ${dir_src}/%.vhdl
	vcom -work work -explicit -vopt $< && touch $@

${test_compiles_tbs}: ${dir_test_compiles}/%.tb.vhdl.test_compile: ${dir_test}/%.tb.vhdl
	vcom -work work -explicit -vopt $< && touch $@