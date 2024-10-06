library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.spi_common.all;

entity spi_master is
  generic (
    clock_divider : positive;
    transaction_bits : natural;
    register_out_width : natural;
    register_in_width : natural
  );
  port (

    -- General inputs
    clock_master : in std_logic;
    reset_n : in std_logic;

    -- control interface
    transmit_data : in std_logic_vector(register_out_width - 1 downto 0);
    receive_data : out std_logic_vector(register_in_width - 1 downto 0);
    go : in std_logic;  -- spi transaction begins when this goes high

    -- spi interface
    spi_csn : out std_logic;
    spi_sclk : out std_logic;
    spi_sdi : in std_logic;
    spi_sdo : out std_logic

  );
end spi_master;

architecture rtl of spi_master is

  -- The period spi_sclk is high for during a spi cycle.
  constant period_high : natural := clock_divider / 2;

  -- The period spi_sclk is low for during a spi cycle
  -- Note that this will always be either equal to or longer than period_high.
  constant period_low : positive := clock_divider - period_high;

  -- A combinational signal that signals the beginning of a new transaction.
  -- Used to initialize counters and control registers for the transaction.
  signal start : std_logic;

  -- Because spi_sclk idles high and the Max10 only supports asynchronous
  -- clear, spi_sclk must be controlled via its inverse.
  signal spi_sclk_n : std_logic;

  -- Because spi_csn idles high and the Max10 only supports asynchronous clear,
  -- spi_scn must be controlled via its inverse.
  signal spi_cs : std_logic;

  -- Counts down while the transaction is running. Whenever it reaches 0, the
  -- value of spi_sclk (via spi_sclk_n) toggles.
  signal counter_clock : natural range 0 to period_low - 1;

  -- Counts the number of bits that still remain to be shifted in during the
  -- transaction. The transaction ends immediately after this reaches zero.
  signal counter_transaction : natural range 0 to transaction_bits;

  -- A combinational signal that signals that a new bit is about to be shifted
  -- out, corresponding to the falling edge of spi_sclk.
  signal shift_out : std_logic;

  -- A combinational signal that signals that a new bit is about to be shifted
  -- in, corresponding to the rising edge of the spi_sclk.
  signal shift_in : std_logic;

  -- A shift register that contains the data the SPI is shifting out.
  signal register_out : std_logic_vector(register_out_width - 1 downto 0);

  -- A shhift register that contains the data the SPI is shifting in.
  signal register_in : std_logic_vector(register_in_width - 1 downto 0);

begin

  -- A transaction starts whenever the "go" signal goes ghigh and a transaction
  -- is not currently in progress.
  start <= go and not spi_cs;

  -- spi_cs goes high (making spi_csn go low) whenevever a transaction starts.
  -- spi_cs goes low (making spi_csn go high) immediately after the last bit
  -- has been shifted in.
  process(clock_master, reset_n)
  begin
    if reset_n = '0' then
      spi_cs <= '0';
    elsif rising_edge(clock_master) then
      if start = '1' then
        spi_cs <= '1';
      elsif spi_cs = '1' and counter_transaction = 0 then
        spi_cs <= '0';
      end if;
    end if;
  end process;
  spi_csn <= not spi_cs;

  -- At the beginning of a transaction, no bits have been shifted in yet.
  -- Whenever a bit is shifted in, the transaction counter decrements. Because
  -- the counter is loaded with the correct value at the beginning of every
  -- transaction, no asynchronous reset is necessary.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if start = '1' then
        counter_transaction <= transaction_bits;
      elsif spi_cs = '1' and shift_in = '1' then
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
      elsif spi_cs = '1' then -- Counter only ticks during a transaction
        if counter_clock = 0 then
          if spi_sclk_n = '1' then 
            -- spi_sclk_n is high, which means spi_sclk is low, which means
            -- spi_sclk is about to go high.
            counter_clock <= period_high - 1;
          elsif spi_sclk_n = '0' then
            -- spi_sclk_n is low, which means spi_sclk is high, which means
            -- spi_sclk is about to go low.
            counter_clock <= period_low - 1;
          end if;
        else
          counter_clock <= counter_clock - 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Bits are shifted out on the falling edge of spi_sclk, which corresponds
  -- to the rising edge of spi_sclk_n.
  shift_out <= 
    '1' when counter_clock = 0 and spi_sclk_n = '0' and spi_cs = '1' else
    '0';

  -- Bits are shifted in on the rising edge of spi_sclk, which corresponds
  -- to the falling edge of spi_sclk_n.
  shift_in <=
    '1' when counter_clock = 0 and spi_sclk_n = '1' and spi_cs = '1' else
    '0';

  -- Whenever the clock counter reaches zero, the spi_sclk toggles. spi_sclk
  -- is manipulated via its inverse because it idles high.
  process(clock_master, reset_n)
  begin
    if reset_n = '0' then
      spi_sclk_n <= '0';
    elsif rising_edge(clock_master) then
      if spi_cs = '1' and counter_clock = 0 then
        spi_sclk_n <= not spi_sclk_n;
      end if;
    end if;
  end process;
  spi_sclk <= not spi_sclk_n;
  
  -- The data out register is loaded at the beginning of a transaction. Data is
  -- then shifted out on every falling edge of spi_sclk (while the spi is
  -- running). Data is shifted out to the left. Because the data out register
  -- is loaded at the beginning of every transaction, asynchronous reset is not
  -- necessary.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if start = '1' then
        register_out <= transmit_data;
      elsif shift_out = '1' then
        register_out(register_out_width - 1 downto 1) <= register_out(register_out_width - 2 downto 0);
        register_out(0) <= 'X';
      end if;
    end if;
  end process;

  -- Data is placed on sdo after being shifted off the left side of the output
  -- register. Because this is always set to something before being consumed by
  -- the slave, no asynchronous reset is necessary.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if shift_out = '1' then
        spi_sdo <= register_out(register_out_width - 1);
      end if;
    end if;
  end process;

  -- Data is shifted in on every rising edge of the spi_sclk. Because this
  -- register is populated before being read, no ansynchronous reset is
  -- necessary.
  process(clock_master)
  begin
    if rising_edge(clock_master) then
      if shift_in = '1' then
        register_in(0) <= spi_sdi;
        register_in(register_in_width - 1 downto 1) <= register_in(register_in_width - 2 downto 0);
      end if;
    end if;
  end process;

end architecture; -- rtl