library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity spi_master is
  generic (
    clock_divider : positive
  ) ;
  port (
    
    -- General inputs
    clock_master : in std_logic;
    reset_n : in std_logic;

    enable : in std_logic;  -- SPI only runs while this is high

    -- spi interface
    clock_spi : out std_logic
  ) ;
end spi_master ;

architecture rtl of spi_master is

  -- Counts down while the spi clock is running. The max count is divided by
  -- two because the counter completes two cycles for each cycle of the spi
  -- clock.
  constant counter_max_count : natural := clock_divider / 2;
  constant counter_reset : natural := 0;
  signal counter : natural range 0 to counter_max_count;

  -- Serves as the spi clock. Toggles each time the counter reaches 0.
  constant spi_sclk_reset : std_logic := 0
  signal spi_sclk : std_logic;

begin

divide_clock : process( clock_master, reset_n )
begin

  if reset_n = '0' then
    counter <= counter_reset;
  elsif rising_edge(clock_master) then
    if counter = 0 then
      counter <= counter_max_count;
    else
      counter <= counter - 1;
    end if ;
  end if ;
  
end process ; -- generate_clock_spi

generate_sclk : process( clock_master, reset_n )
begin
  
  if reset_n = '0' then
    spi_sclk <= spi_sclk_reset;
  elsif rising_edge(clock_master) then
    if counter = 0 then
      spi_sclk <= ~spi_sclk;
    end if ;
  end if ;

end process ; -- generate_sclk


end architecture ; -- rtl