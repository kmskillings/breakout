library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_common.all;

entity ent is
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

  ) ;
end ent;

architecture rtl of spi_master is

end architecture ; -- rtl