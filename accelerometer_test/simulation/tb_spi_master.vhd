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
  constant clock_master_frequency : positive := 5_000_000;
  constant clock_master_period : time := 1 sec / clock_master_frequency;
  
  -- A short time to ensure that testbench events always happen after the
  -- corresponding clock edges
  constant short_time_cycles : real := 0.01;
  constant short_time : time := short_time_cycles * clock_master_period;

  -------------------- Timing settings --------------------
  
  -- Reset at the beginning of the simulation to initialize DUT
  constant reset_duration_cycles : real := 3.2;
  constant reset_duration : time := reset_duration_cycles * clock_master_period;
  
  -- Executes a transaction
  constant go_delay_cycles : real := 5.0;
  constant go_delay : time := go_delay_cycles * clock_master_period + short_time;
  constant go_duration : time := clock_master_period;

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
    wait for reset_duration;
    reset_n <= '1';
    wait;
  end process;

  -- Generates the go signal
  process
  begin
    go <= '0';
    wait for go_delay;
    go <= '1';
    wait for go_duration;
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