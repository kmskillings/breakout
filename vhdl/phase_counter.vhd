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
  constant phases : t_vga_phase_array

  ) ;

  port (

  clock : in std_logic ;
  reset_n : in std_logic ;

  -- The counter only counts when this is high.
  enable : in std_logic ;

  -- Tracks the counter's progress through the phase.
  count : out natural range 0 to (get_longest_phase(phases)).duration - 1 ;

  -- The phase that is currently being counted through.
  phase : out t_vga_phase;
  
  ) ;

end phase_counter ; 

architecture arch of phase_counter is

begin

end architecture ;