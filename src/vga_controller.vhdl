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

process(reset, clock)
begin
    if reset = '0' then
        v_sync <= '0';
    elsif rising_edge(clock) then
        v_sync <= '1';
    end if;
end process ; -- 

h_sync <= '0';
color <= (others => '0');

end architecture ;