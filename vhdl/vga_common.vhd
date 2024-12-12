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

  subtype t_phase_duration is natural;

  type t_vga_phase is record
    id : natural range 0 to 3;
    duration : t_phase_duration;
    name : string(1 to c_vga_phase_name_length);
  end record;

  type t_vga_phase_array is array (natural range <>) of t_vga_phase;

  -- Returns the longest phase in the given array.
  function get_longest_phase(
    phases : t_vga_phase_array
  ) return t_vga_phase;
  
end package ;

package body vga_common is

  function get_longest_phase(
    phases : t_vga_phase_array
  ) return t_vga_phase is
    
    variable longest_phase : t_vga_phase := phases(0);
    variable phase : t_vga_phase;

  begin

    for i in phases'range loop
      phase := phases(i);
      if phase.duration > longest_phase.duration then
        longest_phase := phase;
      end if;
    end loop;
    
    return longest_phase;

  end get_longest_phase;

end vga_common;
