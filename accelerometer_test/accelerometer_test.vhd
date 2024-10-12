library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_common.all;

entity accelerometer_test is
  port (
    adc_clk_10 : in std_logic;
    max10_clk1_50 : in std_logic;
    max10_clk2_50 : in std_logic;
    
    ledr : out std_logic_vector(9 downto 0);

    sw : in std_logic_vector(9 downto 0);
    key : in std_logic_vector(1 downto 0);

    gsensor_cs_n : out std_logic;
    gsensor_int : in std_logic_vector(2 downto 1);
    gsensor_sclk : out std_logic;
    gsensor_sdi : inout std_logic;
    gsensor_sdo : inout std_logic

  );
end entity accelerometer_test;

architecture rtl of accelerometer_test is

  -- Rename certain signals to be more readable
  signal clock_master : std_logic;
  signal reset_n : std_logic;

  constant spi_clock_divisor : positive := 16; -- Get well below 5 MHz
  constant spi_transaction_bits : natural := 24;
  constant spi_command_width : natural := 8;
  constant spi_address_width : natural := 6;
  constant spi_data_width : natural := 16;

  constant address_startup : std_logic_vector(spi_address_width - 1 downto 0) := b"101100";
  constant data_startup : std_logic_vector(spi_data_width - 1 downto 0) := b"0000101000001000";
  constant address_measure : std_logic_vector(spi_address_width - 1 downto 0) := b"110010";

  constant sampling_rate_divisor : positive := 500_000;
  signal counter_sampling : natural range 0 to sampling_rate_divisor - 1;

  signal measure_bit_set : std_logic;

  signal accelerometer_reading : std_logic_vector(spi_data_width - 1 downto 0);
  signal accelerometer_command : std_logic_vector(spi_transaction_bits - 1 downto 0);

  signal go : std_logic;
  signal done : std_logic;

begin

  clock_master <= max10_clk1_50;
  reset_n <= key(0);

  -- Samples the accelerometer every so often
  process (clock_master, reset_n)
  begin
    if reset_n = '0' then
      counter_sampling <= 0;
    elsif rising_edge(clock_master) then
      if counter_sampling = 0 then
        counter_sampling <= sampling_rate_divisor - 1;
      else
        counter_sampling <= counter_sampling - 1;
      end if;
    end if;
  end process;

  process (clock_master, reset_n)
  begin
    if reset_n = '0' then
      go <= '0';
    elsif rising_edge(clock_master) then
      if counter_sampling = 0 then
        go <= '1';
      else
        go <= '0';
      end if;
    end if;
  end process;

  -- Display the reading
  process (clock_master, reset_n)
  begin
    if reset_n = '0' then
      ledr <= (others => '0');
    elsif rising_edge(clock_master) then
      if done = '1' then
        ledr <= accelerometer_reading(9 downto 0);
      elsif key(1) = '0' then
        ledr <= (others => '1');
      end if;
    end if;
  end process;

  -- The measure_bit_set signal goes high after the first transaction, which
  -- enables the accelerometer.
  process (clock_master, reset_n)
  begin
    if reset_n = '0' then
      measure_bit_set <= '0';
    elsif rising_edge(clock_master) then
      if done = '1' then
        measure_bit_set <= '1';
      end if;
    end if;
  end process;

  -- the first transaction is a write
  accelerometer_command(23) <=
    '0' when measure_bit_set = '0' else
    '1';

  accelerometer_command(22) <= '1'; -- Always read or write two bytes at a time

  -- On the first transaction, write to the configuration registers. On all
  -- subsequent transactions, read from the x axis registers.
  accelerometer_command(21 downto 16) <= 
    address_startup when measure_bit_set = '0' else
    address_measure;

  accelerometer_command(15 downto 0) <= data_startup;

  ACCELEROMETER_SPI : spi_master
    generic map (
      clock_divider => spi_clock_divisor,
      transaction_bits => spi_transaction_bits,
      transmit_data_width => spi_transaction_bits,
      receive_data_width => spi_data_width
    )
    port map (
      clock_master => clock_master,
      reset_n => reset_n,
      transmit_data => accelerometer_command,
      receive_data => accelerometer_reading,
      go => go,
      done => done,
      spi_csn => gsensor_cs_n,
      spi_sclk => gsensor_sclk,
      spi_sdi => gsensor_sdo,
      spi_sdo => gsensor_sdi
    )
  ;

end architecture;