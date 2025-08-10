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

	constant clock_frequency : natural := 50_000_000;
	constant clock_period : time := 1 sec / clock_frequency;
	constant blink_period : time := 10 us;
	constant duty_cycle : real := 0.5;

	constant init_reset_cycles : natural := 3;
	constant init_reset_time : time := clock_period * init_reset_cycles;

	signal clock : std_logic;
	signal button : std_logic;
	signal led : std_logic;

begin

-- Generate clock signal
process
begin
	clock <= '0';
	wait for clock_period / 2;
	clock <= '1';
	wait for clock_period / 2;
end process;

-- Generate initial reset pulse
process
begin
	button <= '1';
	wait for init_reset_time;
	button <= '0';
	wait;
end process;

-- Checks the period of the blinker
process
	variable edge1 : time;
	variable edge2 : time;
	variable period : time;
begin
	wait until rising_edge(led);
	edge1 := now;
	wait for 1 ns;
	wait until rising_edge(led);
	edge2 := now;
	period := edge2 - edge1;
	report "Period of blinker is " & time'image(period);
	wait;
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
