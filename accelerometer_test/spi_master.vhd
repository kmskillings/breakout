library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_common.all;

entity spi_master is
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
end spi_master;

architecture rtl of spi_master is

  -- clock constants

  -- The period spi_sclk is high for during a spi cycle.
  constant period_high : natural := clock_divider / 2;

  -- The period spi_sclk is low for during a spi cycle
  -- Note that this will always be either equal to or longer than period_high.
  constant period_low : positive := clock_divider - period_high;

  -- output mirrors
  signal spi_csn_int : std_logic;
  signal spi_sclk_int : std_logic;

  signal start : std_logic;
  signal start_d1 : std_logic;

  signal spi_sclk_n : std_logic;
  signal sclk_rising_edge : std_logic;
  signal sclk_falling_edge : std_logic;

  signal spi_cs : std_logic;

  signal counter_clock : natural range 0 to period_low - 1;

  -- Which bit of the transaction is currently being transferred. Counts down
  -- to 0 at the end of the transaction.
  signal counter_transaction : natural range 0 to transaction_bits - 1;

begin

  -- output mirrors
  spi_csn <= spi_csn_int;
  spi_sclk <= spi_sclk_int;

  start <= go and spi_csn_int;
  process(clock_master, reset_n)
  begin
    if reset_n = '0' then
      start_d1 <= '0';
    elsif rising_edge(clock_master) then
      start_d1 <= start;
    end if;
  end process;

  -- spi_csn goes low when the go control signal goes high while a transaction
  -- isn't in progress (spi_csn is high). spi_csn goes high again after all
  -- bits have been shifted and spi_sclk is high.
  process(clock_master, reset_n)
  begin
    if reset_n = '0' then
      spi_cs <= '0';
    elsif rising_edge(clock_master) then
      if start = '1' then
        spi_cs <= '1';
      elsif counter_transaction = 0 and spi_sclk_int = '1' and spi_cs = '1' then
        spi_cs <= '0';
      end if;
    end if;
  end process;
  spi_csn_int <= not spi_cs;

  -- One clock cycle after the beginning of a cycle, counter_transaction is set to its
  -- maximum value. On each falling edge of spi_sclk, it decrements.
  -- This process has no asynchronous reset because counter_transaction doesn't affect
  -- anything while a transaction isn't in progress.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if start_d1 = '1' then
        counter_transaction <= transaction_bits - 1;
      elsif sclk_falling_edge = '1' then
        counter_transaction <= counter_transaction - 1;
      end if;
    end if;
  end process;

  -- During a spi transaction, the spi sclk counter counts down. Whenever it
  -- reaches zero, the spi sclk toggles. To maintain the correct timing in the
  -- case that the clock divider is odd, the counter is reloaded with one of
  -- two values depending on whether the clock is going high or low. At the
  -- beginning of a transaction, the spi sclk is loaded with the correct value.
  -- Because of this, no asynchronous reset is necessary.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if start = '1' then
        counter_clock <= 0; -- Starts at 0 so that spi_sclk goes low next tick.
      elsif spi_csn_int = '0' then -- Counter only ticks during a transaction
        if counter_clock = 0 then
          if spi_sclk_int = '1' then
            counter_clock <= period_low - 1;
          elsif spi_sclk_int = '0' then
            counter_clock <= period_high - 1;
          end if;
        else
          counter_clock <= counter_clock - 1;
        end if;
      end if;
    end if;
  end process;
  sclk_rising_edge <= 
    '1' when counter_clock = 0 and spi_sclk_int = '0' else
    '0';
  sclk_falling_edge <= 
    '1' when counter_clock = 0 and spi_sclk_int = '1' else
    '0';

  -- Whenever the clock counter reaches zero, the spi_sclk toggles. spi_sclk
  -- is manipulated via its inverse because it idles high.
  process(clock_master, reset_n)
  begin
    if reset_n = '0' then
      spi_sclk_n <= '0';
    elsif rising_edge(clock_master) then
      if spi_csn_int = '0' and counter_clock = 0 then
        spi_sclk_n <= not spi_sclk_n;
      end if;
    end if;
  end process;
  spi_sclk_int <= spi_sclk_n;
  

end architecture; -- rtl