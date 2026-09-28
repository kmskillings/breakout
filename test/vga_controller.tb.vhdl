library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

use std.env.finish;

entity vga_controller_tb is
end vga_controller_tb ; 

architecture tb of vga_controller_tb is

    -- Testbench settings
    constant dt : time := 1 ps;
    constant aliveness_wait_max : time := 1 ms;

    -- Requirement settings
    constant clock_period_min : time := 39.6 ns;
    constant clock_period_max : time := 39.9 ns;
    constant aliveness_time_max : time := 1 ms;

    -- Test parameter signals
    signal clock_period : time := dt;
    signal initial_reset_hold : time := dt;

    signal begin_test : std_logic;
    signal test_running : std_logic;

    signal test_complete : std_logic;

    -- Driver internal signals
    signal clock_running : std_logic;

    -- Monitor output signals

    signal aliveness_ready : std_logic;
    signal aliveness_timed_out : std_logic;
    signal aliveness_time: time;

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
    report "Beginning test battery." severity note;
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
    clock_running <= '1';
    reset <= '0';
    wait for initial_reset_hold;
    reset <= '1';
    wait for 1 us;
    test_running <= '0';
    clock_running <= '0';
    wait;
end process;

GENERATE_CLOCK : process
begin
    wait on clock_running for clock_period / 2;
    if clock_running = '1' then
        clock <= not clock;
    else
        clock <= '0';
    end if;
end process;

MONITOR_ALIVENESS : process
    variable start_time : time;
    variable alive_time : time;
begin
    wait until reset = '1';
    aliveness_ready <= '0';
    aliveness_timed_out <= '0';
    aliveness_time <= 0 ns;
    start_time := now;
    wait on v_sync, h_sync, color for aliveness_wait_max;
    if v_sync'event or h_sync'event or color'event then
        alive_time := now;
        aliveness_time <= start_time - alive_time;
    else
        aliveness_timed_out <= '1';
    end if;
    aliveness_ready <= '1';
end process ; -- MONITOR_ALIVENESS

SCOREBOARD_ALIVENESS  : process
begin
    wait until aliveness_ready = '1';
    if aliveness_timed_out = '1' then
        report "TEST_FAILURE: DUT failed to show signs of life after maximum wait time."
            severity failure;
    elsif aliveness_time >= aliveness_time_max then
        report "TEST_FAILURE: DUT exceeded reset wake-up time."
            severity error;
    else
        report "Finishing test" severity note;
        finish;
        report "Uh oh" severity note;
    end if;
end process ; -- SCOREBOARD_ALIVENESS

DUT : entity work.vga_controller(rtl)
port map (
    clock => clock,
    reset => reset,
    v_sync => v_sync,
    h_sync => h_sync,
    color => color
);

end architecture;