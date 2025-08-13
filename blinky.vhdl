-- Blinky
--
-- Blinks an LED at a rate of 500 mHz and a duty cycle of 50%
-- (On for one second, off for one second).

library ieee;
use ieee.std_logic_1164.all;

entity blinky is
	generic (
	clock_frequency : natural := 50_000_000;
	blink_period : time := 2 sec;
	duty_cycle : real := 0.5
	);
	port (
	clock	:	in	std_logic; -- 50 MHz input clock
	button	:	in	std_logic; -- Reset button
	led	:	out	std_logic
	);
end blinky;

architecture rtl of blinky is

	constant clock_period : time := 1 sec / clock_frequency;
	constant period_cycles : natural := blink_period / clock_period;
	constant on_count : natural 
		:= integer(duty_cycle * real(period_cycles)) - 1;
	constant off_count : natural := period_cycles - 1;
	constant max_count : natural := period_cycles - 1;

	signal reset_synchronizer_0 : std_logic;
	signal reset_synchronizer_1 : std_logic;
	signal arst_n : std_logic;
	signal count : natural range 0 to max_count;

begin

-- Create reset signal from button.
process (clock, button)
begin
	-- Asynchronous assert
	if button = '0' then
		reset_synchronizer_0 <= '0';
		reset_synchronizer_1 <= '0';
	-- Synchronous de-assert, passed through two d flip-flops.
	elsif rising_edge(clock) then
		reset_synchronizer_0 <= '1';
		reset_synchronizer_1 <= reset_synchronizer_0;
	end if;
end process;
arst_n <= 
	'1' when reset_synchronizer_1 = '1' else
	'0' when reset_synchronizer_1 = '0' else
	'0';

-- Increment the counter every tick.
process (clock, arst_n)
begin
	if arst_n = '0' then
		count <= 0;
	elsif rising_edge(clock) then
		if count = max_count then
			count <= 0;
		else
			count <= count + 1;
		end if;
	end if;
end process;
	
-- Turn the LED on and off.
process (clock, arst_n)
begin
	if arst_n = '0' then
		led <= '0';
	elsif rising_edge(clock) then
		if count = on_count then
			led <= '1';
		elsif count = off_count then
			led <= '0';
		end if;
	end if;
end process;

end rtl;
