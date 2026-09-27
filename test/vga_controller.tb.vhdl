library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity vga_controller_tb is
end vga_controller_tb ; 

architecture tb of vga_controller_tb is

    -- Testbench settings
    constant dt : time := 1 ps;

    -- Requirement settings
    constant clock_period_min : time := 39.6 ns;
    constant clock_period_max : time := 39.9 ns;

    -- Test parameter signals
    signal clock_period : time := dt;

    signal begin_test : std_logic;
    signal test_running : std_logic;

    signal test_complete : std_logic;

    -- DUT interface signals
    signal clock : std_logic;
    signal reset : std_logic;
    signal v_sync : std_logic;
    signal h_sync : std_logic;
    signal color : std_logic_vector(11 downto 0);

begin

-- Run the tests in sequence
TEST_MANAGER : process
begin
    clock_period <= clock_period_min;
    wait for 50 ns;
    begin_test <= '1';
    wait until test_running <= '1';
    begin_test <= '0';
    wait until test_running <= '0';
    wait;
end process;

DRIVER : process
begin
    wait until begin_test = '1';
    test_running <= '1';
    wait for 1 us;
    test_running <= '0';
    wait;
end process;

GENERATE_CLOCK : process
begin
    wait on test_running for clock_period / 2;
    if test_running = '1' then
        clock <= not clock;
    else
        clock <= '0';
    end if;
end process;


DUT : entity work.vga_controller(rtl)
port map (
    clock => clock,
    reset => reset,
    v_sync => v_sync,
    h_sync => h_sync,
    color => color
);

end architecture;