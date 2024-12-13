--------------------------------------------------------------------------------
-- Phase Counter
--
-- The Phase Counter is a counter that counts through a particular sequence of
-- phases. Each phase may have a different length. The counter counts up from 0.
-- When the counter reaches the "length" parameter of the phase, the counter
-- resets to 0 and the next phase begins.
--------------------------------------------------------------------------------

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity phase_counter is
  
  generic (
  
  -- The array of phases that this counter should count through.
  constant sequence : t_vga_phase_sequence

  ) ;

  port (

  clock : in std_logic ;
  reset_n : in std_logic ;

  -- The counter only counts when this is high.
  enable : in std_logic ;

  -- Tracks the counter's progress through the phase.
  count : out natural range 0 to get_longest_duration(sequence);

  -- The phase that is currently being counted through.
  phase : out t_vga_phase;

  -- High when the counter will "roll over" to the beginning of a new phase on
  -- the next tick.
  phase_ending : out std_logic;
  
  ) ;

end phase_counter ; 

architecture arch of phase_counter is

  signal phase_index : natural range phases'range;

  signal 

begin

  phase <= sequence(phase_index);

  phase_ending <=
    '1' when count = phase.duration and enable = '1' else
    '0';

   process( clock, reset_n )
  begin
    if reset_n = '0' then
      phase_index <= 0
    elsif rising_edge(clock) then
      if enable = '1' then
        if phase_ending = '1' then
          count <= 0
        else
          count <= count + 1;
        end if;
      end if;
    end if;
  end process;

  GO_TO_NEXT_PHASE : process( clock, reset_n )
  begin
    if reset_n = '0' then
    elsif rising_edge(clock) then
      if phase_ending = '1' then
        
      end if;
    end if;
  end process;

end architecture ;