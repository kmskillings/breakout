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

  constant c_vga_phase_name_length : natural := 16;

  type t_phase_id is (
    SYNC,
    FRONT,
    ACTIVE,
    BACK
  );

  subtype t_phase_duration is positive;

  type t_vga_phase is record
    id : t_phase_id;
    duration : t_phase_duration;
    name : string(1 to c_vga_phase_name_length);
  end record;

  type t_vga_phase_sequence is array (natural range <>) of t_vga_phase;

  -- Returns the duration of the longest phase in a sequence.
  function get_longest_duration(
    sequence : t_vga_phase_sequence
  ) return t_phase_duration;
  
end package ;

package body vga_common is

  function get_longest_phase(
    sequence : t_vga_phase_sequence
  ) return t_phase_duration is
    
    variable longest_phase : t_vga_phase := sequence(0);
    variable phase : t_vga_phase;

  begin

    for i in sequence'range loop
      phase := sequence(i);
      if phase.duration > longest_phase.duration then
        longest_phase := phase;
      end if;
    end loop;
    
    return longest_phase.duration;

  end get_longest_phase;

end vga_common;
