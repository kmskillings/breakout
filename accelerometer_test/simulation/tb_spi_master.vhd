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
  constant reset_duration_cycles : real := 3.2;
  constant reset_duration : time := reset_duration_cycles * clock_master_period;
  
  -- Timing for transactions
  constant delay_between_transactions_cycles : real := 5.0;
  constant delay_between_transactions : time := delay_between_transactions_cycles * clock_master_period;

  -------------------- DUT settings --------------------

  constant clock_divider : positive := 6;
  constant transaction_bits : natural := 8;
  constant transmit_data_width : natural := 8;
  constant receive_data_width : natural := 8;

  -------------------- Testbench signals --------------------

  -- Interface signals
  signal clock_master : std_logic;
  signal reset_n : std_logic;
  signal transmit_data : std_logic_vector(transmit_data_width - 1 downto 0);
  signal receive_data : std_logic_vector(receive_data_width - 1 downto 0);
  signal go : std_logic;
  signal done : std_logic;
  signal spi_csn : std_logic;
  signal spi_sclk : std_logic;
  signal spi_sdi : std_logic;
  signal spi_sdo : std_logic;

  -- The "other side" of the SPI
  signal transmitted_data : std_logic_vector(transmit_data_width - 1 downto 0);
  signal response_data : std_logic_vector(receive_data_width - 1 downto 0);
  signal counter_transaction : natural range 0 to transaction_bits;

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
    wait until rising_edge(reset_n) or (done = '1');
    wait until rising_edge(clock_master);
    wait for delay_between_transactions;
    go <= '1';
    wait for clock_master_period;
    go <= '0';
  end process;

  -- Increments response data for every transaction
  process (go)
    variable random_real : real;
    variable seed1 : positive;
    variable seed2 : positive;
  begin
    if rising_edge(go) then
      uniform(seed1, seed2, random_real);
      response_data <= std_logic_vector(to_unsigned(integer(
        random_real * real(2**receive_data_width - 1)), receive_data_width
      ));
    end if;
  end process;

  -- Checks for correct data at the end of each transaction
  process (clock_master)
  begin
    if rising_edge(clock_master) then
      if done = '1' then
        assert std_logic_vector(response_data) = receive_data
          report "Incorrect data received."
          severity error;
      end if;
    end if;
  end process;

  -- Generates stimulus
  process (spi_sclk, spi_csn)
    variable transmitted_data_index : integer;
    variable response_data_index : integer;
  begin
    transmitted_data_index := transmit_data_width - 1 - counter_transaction;
    response_data_index := transaction_bits - 1 - counter_transaction;
    if spi_csn = '1' then
      counter_transaction <= 0;
    elsif falling_edge(spi_sclk) then
      if response_data_index > receive_data_width then
        spi_sdi <= 'X';
      else
        spi_sdi <= response_data(response_data_index);
      end if;
    elsif rising_edge(spi_sclk) then
      if counter_transaction < transaction_bits then
        counter_transaction <= counter_transaction + 1;
      end if;
      transmitted_data(transmitted_data_index) <= spi_sdo;
    end if;
  end process;

  DUT : spi_master
    generic map (
      clock_divider => clock_divider,
      transaction_bits => transaction_bits,
      transmit_data_width => transmit_data_width,
      receive_data_width => receive_data_width
    )
    port map (
      clock_master => clock_master,
      reset_n => reset_n,
      transmit_data => transmit_data,
      receive_data => receive_data,
      go => go,
      done => done,
      spi_csn => spi_csn,
      spi_sclk => spi_sclk,
      spi_sdi => spi_sdi,
      spi_sdo => spi_sdo
    )
  ;

end architecture ; -- tb