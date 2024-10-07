library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package spi_common is

component spi_master is
  generic (
    clock_divider : positive;
    transaction_bits : natural;
    transmit_data_width : natural;
    receive_data_width : natural
  );
  port (

    -- General inputs
    clock_master : in std_logic;
    reset_n : in std_logic;

    -- control interface
    transmit_data : in std_logic_vector(transmit_data_width - 1 downto 0);
    receive_data : out std_logic_vector(receive_data_width - 1 downto 0);
    go : in std_logic;  -- spi transaction begins when this goes high
    done : out std_logic; -- spi transaction concludes when this goes high

    -- spi interface
    spi_csn : out std_logic;
    spi_sclk : out std_logic;
    spi_sdi : in std_logic;
    spi_sdo : out std_logic

  );
end component ;

end package ;