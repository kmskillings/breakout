library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_common.all;

entity tb_spi_master is
end tb_spi_master ;

architecture tb of tb_spi_master is

  -------------------- General settings --------------------

  -- Master clock
  constant clock_master_frequency : positive := 50_000_000;
  constant clock_master_period : time := 1 sec / clock_master_frequency;
  
  -- A short time to ensure that testbench events always happen after the
  -- corresponding clock edges
  constant short_time_cycles : real := 0.01;
  constant short_time : time := short_time_cycles * clock_master_period;

  -------------------- Timing settings --------------------
  
  -- Reset at the beginning of the simulation to initialize DUT
  constant reset_initial_duration_cycles : real := 3.2;
  constant reset_initial_duration : time := reset_initial_duration_cycles * clock_master_period;
  
  -- Reset in the middle of operation to test weird states
  constant reset_middle_delay_cycles : real := 30.0;
  constant reset_middle_delay : time := reset_middle_delay_cycles * clock_master_period + short_time;
  constant reset_middle_duration_cycles : real := 9.7;
  constant reset_middle_duration : time := reset_middle_duration_cycles * clock_master_period + short_time;

  -- Executes a transaction
  constant go1_delay_cycles : real := 5.0;
  constant go1_delay : time := go1_delay_cycles * clock_master_period + short_time;
  constant go1_duration : time := clock_master_period;

  constant go2_delay_cycles : real := 40.0;
  constant go2_delay : time := go2_delay_cycles * clock_master_period + short_time;
  constant go2_duration : time := clock_master_period;

  -------------------- DUT settings --------------------

  constant clock_divider : positive := 6;
  constant transaction_bits : natural := 8;

  -------------------- Testbench signals --------------------

  -- Interface signals
  signal clock_master : std_logic;
  signal reset_n : std_logic;
  signal go : std_logic;
  signal spi_csn : std_logic;
  signal spi_sclk : std_logic;
  signal spi_sdi : std_logic;
  signal spi_sdo : std_logic;

begin

  -- Generate the master clock signal.
  process
  begin
    clock_master <= '1';
    wait for clock_master_period / 2;
    clock_master <= '0';
    wait for clock_master_period / 2;
  end process;

  -- Generates the reset signal.
  process
  begin
    reset_n <= '0';
    wait for reset_initial_duration;
    reset_n <= '1';
    wait for reset_middle_delay;
    reset_n <= '0';
    wait for reset_middle_duration;
    reset_n <= '1';
    wait;
  end process;

  -- Generates the go signal
  process
  begin
    go <= '0';
    wait for go1_delay;
    go <= '1';
    wait for go1_duration;
    go <= '0';
    wait for go2_delay;
    go <= '1';
    wait for go2_duration;
    go <= '0';
    wait;
  end process;

  DUT : spi_master
    generic map (
      clock_divider => clock_divider,
      transaction_bits => transaction_bits
    )
    port map (
      clock_master => clock_master,
      reset_n => reset_n,
      go => go,
      spi_csn => spi_csn,
      spi_sclk => spi_sclk,
      spi_sdi => spi_sdi,
      spi_sdo => spi_sdo
    )
  ;

end architecture ; -- tb