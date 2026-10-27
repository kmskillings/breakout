library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity vga_controller is
  port (
    clock : in std_logic;
    reset : in std_logic;
    v_sync: out std_logic;
    h_sync: out std_logic;
    color : out std_logic_vector(11 downto 0)
  );
end vga_controller ; 

architecture rtl of vga_controller is

begin

v_sync <= '0';
h_sync <= '0';
color <= (others => '0');

end architecture ;