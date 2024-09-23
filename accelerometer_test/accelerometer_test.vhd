library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity accelerometer_test is
  port (
    adc_clk_10 : in std_logic;
    max10_clk1_50 : in std_logic;
    max10_clk2_50 : in std_logic;
    
    ledr : out std_logic_vector(9 downto 0);

    sw : out std_logic_vector(9 downto 0);

    gsensor_cs_n : out std_logic;
    gsensor_int : in std_logic_vector(1 downto 0);
    gsensor_sclk : out std_logic;
    gsensor_sdi : inout std_logic;
    gsensor_sdo : inout std_logic

  );
end entity accelerometer_test;

architecture rtl of accelerometer_test is

begin

  

end architecture;