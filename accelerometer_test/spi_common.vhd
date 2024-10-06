library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package spi_common is

component spi_master is
  generic (
    clock_divider : positive;
    transaction_bits : natural
  );
  port (

    -- General inputs
    clock_master : in std_logic;
    reset_n : in std_logic;

    -- control interface
    go : in std_logic;  -- spi transaction begins when this goes high

    -- spi interface
    spi_csn : out std_logic;
    spi_sclk : out std_logic;
    spi_sdi : in std_logic;
    spi_sdo : out std_logic

  );
end component ;

end package ;