--------------------------------------------------------------------------------
-- Counter
--
-- A simple counter that counts up to a certain terminal count, then wraps back
-- to zero. The terminal count can be supplied via a signal or constant. If the
-- terminal count is given with a signal, it is registered on the tick that the
-- counter wraps.
--------------------------------------------------------------------------------

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

entity counter is

  generic (

  -- The maximum count the counter will have under any circumstance.
  max_count : natural ;

  ) ;

  port (

  clock   : in std_logic ;
  reset_n : in std_logic ;

  -- The counter counts only when this is high.
  enable : in std_logic ;

  -- The counter will count up to this before wrapping. This is registered at
  -- the end of the previous count-up cycle, so if it changes during the count,
  -- it has no effect on the counter.
  terminal_count : in natural range 0 to max_count ;

  -- The current count.
  count : out natural range 0 to max_count ;

  -- High whenever the counter is about to wrap. The terminal count is
  -- registered when this is high.
  wrapping : out std_logic

  ) ;

end counter ; 

architecture rtl of counter is

begin

end architecture ;