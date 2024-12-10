--------------------------------------------------------------------------------
-- Breakout
--
-- The top level of the Breakout game.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity breakout is
  port (

  -- Clocks
  adc_clk_10      : in    std_logic                     ;
  max10_clk1_50   : in    std_logic                     ;
  max10_clk2_50   : in    std_logic                     ;

  -- Keys (pushbuttons)
  key             : in    std_logic_vector(1 downto 0)  ;

  -- LED bar
  ledr            : out   std_logic_vector(9 downto 0)  ;

  -- VGA connector
  vga_r           : in    std_logic_vector(3 downto 0)  ;
  vga_g           : in    std_logic_vector(3 downto 0)  ;
  vga_b           : in    std_logic_vector(3 downto 0)  ;
  vga_hs          : in    std_logic                     ;
  vga_vs          : in    std_logic                     ;

  -- Accelerometer
  gsensor_cs_n    : out   std_logic                     ;
  gsensor_int     : in    std_logic_vector(2 downto 1)  ;
  gsensor_sclk    : out   std_logic                     ;
  gsensor_sdi     : inout std_logic                     ;
  gsensor_sdo     : inout std_logic                     ;

  -- Arduino headers
  arduino_io      : inout std_logic_vector(15 downto 0) ;
  arduino_reset_n : inout std_logic                     
  
  ) ;

end breakout;

architecture rtl of breakout is



begin

end rtl ; -- rtl