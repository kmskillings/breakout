-- Blinky TB
--
-- Self-checking testbench for the Blinky module. Includes the following tests:
--	- Period of the blinker is 2 seconds.
--	- Duty cycle of the blinker is 1 second.
--	- Reset causes the output to immediately go low.
--	- Functions normally after reset.

library ieee;
use ieee.std_logic_1164.std_logic;
use ieee.std_logic_1164.rising_edge;

use std.env.finish;

entity blinky_tb is
end blinky_tb;

architecture tb of blinky_tb is

	-- Test settings
	constant clock_frequency : natural := 50_000_000;
	constant clock_period : time := 1 sec / clock_frequency;
	constant blink_period : time := 10 us;
	constant duty_cycle : real := 0.5;
	constant reset_test_delay : time := 2 us;
	constant reset_test_duration : time := 1 us;

	constant init_reset_cycles : natural := 3;
	constant init_reset_time : time := clock_period * init_reset_cycles;

	-- Interface signals
	signal clock : std_logic;
	signal button : std_logic;
	signal led : std_logic;

	-- Test result signals
	signal period_0_test_complete : std_logic;
	signal period_0_test_passed : std_logic;
	signal reset_test_complete : std_logic;
	signal reset_test_passed : std_logic;
	signal period_1_test_complete : std_logic;
	signal period_1_test_passed : std_logic;

	procedure inital_reset (
		signal reset : out std_logic
	) is
	begin
		reset <= '1';
		wait for init_reset_time;
		reset <= '0';
	end procedure;

	procedure check_period (
		constant period_ref : in time;
		signal output : in std_logic;
		signal complete : out std_logic;
		signal passed : out std_logic
	) is
		variable rising_edge_0 : time;
		variable rising_edge_1 : time;
		variable period : time;
	begin
		wait until rising_edge(output);
		rising_edge_0 := now;
		wait until rising_edge(output);
		rising_edge_1 := now;
		period := rising_edge_1 - rising_edge_0;
		if period = period_ref then
			passed <= '1';
		else
			passed <= '0';
		end if;
		complete <= '1';
	end procedure;

	procedure check_reset (
		signal output : in std_logic;
		signal reset : out std_logic;
		signal complete : out std_logic;
		signal passed : out std_logic
	) is	
	begin
		wait until output = '1';
		wait for reset_test_delay;
		reset <= '1';	
		wait for 1 ns;
		if output = '0' then
			passed <= '1';
		else
			passed <= '0';
		end if;
		wait for reset_test_duration;
		reset <= '0';
		complete <= '1';	
	end procedure;

begin

-- Generate clock signal
process
begin
	clock <= '0';
	wait for clock_period / 2;
	clock <= '1';
	wait for clock_period / 2;
end process;

-- Run the tests
process
	variable edge1 : time;
	variable edge2 : time;
	variable period : time;
begin
	inital_reset(
		button
	);
	check_period(
		blink_period, 
		led, 
		period_0_test_complete, 
		period_0_test_passed
	);
	check_reset(
		led,
		button,
		reset_test_complete,
		reset_test_passed
	);
	check_period(
		blink_period,
		led,
		period_1_test_complete,
		period_1_test_passed
	);
end process;

-- Report test results
process
	variable all_tests_passed : std_logic := '1';
begin
	wait until period_0_test_complete = '1';
	wait until reset_test_complete = '1';
	wait until period_1_test_complete = '1';

	if period_0_test_passed = '1'  then
		report "Period: OK";
	else
		report "Period: bad";
		all_tests_passed := '0';
	end if;
	
	if reset_test_passed = '1'  then
		report "Reset: OK";
	else
		report "Reset: bad";
		all_tests_passed := '0';
	end if;

	if period_1_test_passed = '1'  then
		report "Reset: OK";
	else
		report "Reset: bad";
		all_tests_passed := '0';
	end if;

	if all_tests_passed = '1' then
		report "Design OK";
	else
		report "Design bad";
	end if;
	finish;	
end process;

-- DUT instance
DUT : entity work.blinky(rtl)
generic map (
	clock_frequency => clock_frequency,
	blink_period => blink_period,
	duty_cycle => duty_cycle
)
port map (
	clock => clock,
	button => button,
	led => led
);

end architecture;
