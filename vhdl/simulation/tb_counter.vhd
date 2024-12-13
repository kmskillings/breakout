library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.math_real.all ;

library work;
  use work.common.all;

entity tb_counter is
end tb_counter ; 

architecture arch of tb_counter is

-------------------- Testbench settings --------------------

  constant clock_frequency : positive := 50_000_000;
  constant clock_period : time := 1 sec / clock_frequency;

  constant initial_reset_cycles : real := 3.2;
  constant initial_reset_duration : time 
    := initial_reset_cycles * clock_period;

  constant max_count : natural := 10;

-------------------- Interface signals --------------------

  signal clock : std_logic;
  signal reset_n : std_logic;

  signal enable : std_logic;

  signal terminal_count : natural range 0 to max_count;
  signal count : natural range 0 to max_count;
  signal wrapping : std_logic;

begin

  CREATE_CLOCK : process
  begin
    clock <= '0';
    wait for clock_period / 2;
    clock <= '1';
    wait for clock_period / 2;
  end process ; -- CREATE_CLOCK

  CREATE_RESET_N : process
  begin
    reset_n <= '0';
    wait for initial_reset_duration;
    reset_n <= '1';
    wait;
  end process ; -- CREATE_RESET_N

  STEP_TERMINAL_COUNT : process
  begin

    for i in 0 to max_count loop
      terminal_count <= i;
      wait until (
        rising_edge(clock) and 
        wrapping = '1' and
        reset_n = '1'
      );
    end loop;
    
  end process ; -- STEP_TERMINAL_COUNT

  DUT : counter
    generic map (
    max_count => max_count
    )
    port map(
    clock           => clock,
    reset_n         => reset_n,
    enable          => '1',
    terminal_count  => terminal_count,
    count           => count,
    wrapping        => wrapping
    );

end architecture ;