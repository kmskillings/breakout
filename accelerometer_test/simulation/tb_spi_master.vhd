library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_spi_master is
end tb_spi_master ;

architecture tb of tb_spi_master is

  -------------------- General settings --------------------

  -- Master clock
  constant clock_master_frequency : positive := 5_000_000;
  constant clock_master_period : time := 1 sec / clock_master_frequency;
  
  -- A short time to ensure that testbench events always happen after the
  -- corresponding clock edges
  constant short_time_cycles : real := 0.01;
  constant short_time : time := short_time_cycles * clock_master_frequency;

  -------------------- Timing settings --------------------
  
  -- Reset at the beginning of the simulation to 
  constant reset_duration_cycles : real := 3.2;
  constant reset_duration : time := reset_duration_cycles * clock_master_period;
  
  -- A pause occuring in the middle of the testbench
  constant pause_delay_cycles : real := 11;
  constant pause_duration_cycles : real := 16;
  constant pause_delay : time := pause_delay_cycles * clock_master_period + short_time;
  constant pause_duration : time := pause_duration_cycles * clock_master_period + short_time;

  -------------------- Testbench signals --------------------

  -- Interface signals
  signal clock_master : std_logic;
  signal enable : std_logic;

begin

  

end architecture ; -- tb