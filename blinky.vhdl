-- Blinky
--
-- Blinks an LED at a rate of 500 mHz and a duty cycle of 50%
-- (On for one second, off for one second).

entity blinky is
	port (
	clock	:	in	std_logic; -- 50 MHz input clock
	arst_n	:	in	std_logic; -- Asynchronous active-low reset
	led	:	out	std_logic
	);
end blinky;

architecture rtl of blinky is

	constant period_cycles : natural := 100_000_000;
	constant on_count : natural := period_cycles / 2 - 1;
	constant off_count : natural := period_cycles - 1;
	constant max_count : natural := period_cycles - 1;

	signal count : natural range 0 to max_count;

begin

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
end process
	
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
