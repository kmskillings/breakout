--------------------------------------------------------------------------------
-- VGA Common
--
-- Provides types, components, and other things used between modules involved in
-- VGA processing.
--------------------------------------------------------------------------------

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;

package vga_common is

  type t_phase_id is (
    SYNC,
    FRONT,
    ACTIVE,
    BACK
  );

  subtype t_phase_duration is positive;

  constant c_phase_name_length : natural := 16;
  subtype t_phase_name is string(1 to c_phase_name_length);

  type t_phase is record
    id : t_phase_id;
    duration : t_phase_duration;
    name : t_phase_name;
  end record;

  type t_sequence is array (natural range <>) of t_phase;

  -- Returns the duration of the longest phase in a sequence.
  function get_longest_duration(
    sequence : t_sequence
  ) return t_phase_duration;
  
end package ;

package body vga_common is

  function get_longest_duration(
    sequence : t_sequence
  ) return t_phase_duration is
    
    variable longest_phase : t_phase := sequence(0);
    variable phase : t_phase;

  begin

    for i in sequence'range loop
      phase := sequence(i);
      if phase.duration > longest_phase.duration then
        longest_phase := phase;
      end if;
    end loop;
    
    return longest_phase.duration;

  end get_longest_duration;

end vga_common;
