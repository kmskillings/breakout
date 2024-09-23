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