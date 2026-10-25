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
    constant h_sync_wait_time_max : time := 1 ms;

    -- Requirement settings
    constant clock_period_min : time := 39.6 ns;
    constant clock_period_max : time := 39.9 ns;
    constant wake_up_time_max : time := 1 ms;
    constant horizontal_sync_duration_min : time := 3.79 us;
    constant horizontal_sync_duration_max : time := 3.83 us;
    constant horizontal_scan_duration_min : time := 31.6 us;
    constant horizontal_scan_duration_max : time := 31.9 us;
    constant horizontal_back_porch_duration_min : time := 1.585 us;
    constant horizontal_front_porch_duration_min : time := 316 ns;

    -- Test parameter signals
    signal clock_period : time := dt;
    signal initial_reset_hold : time := dt;

    signal begin_test : std_logic;
    signal test_running : std_logic;

    signal test_complete : std_logic;

    -- Driver internal signals
    signal clock_running : std_logic;

    -- Monitor signals

    signal reset_deassert : time;
    signal aliveness_time : time;
    signal aliveness_ready : std_logic;

    signal horizontal_sync_deassert : time;
    signal horizontal_sync_assert : time;
    signal horizontal_sync_next : time;
    signal horizontal_sync_ready : std_logic;

    signal horizontal_sync_color : std_logic;
    signal horizontal_sync_color_ready : std_logic;

    signal horizontal_color_first : time;
    signal horizontal_color_activity : std_logic;
    signal horizontal_color_first_ready : std_logic;

    signal horizontal_color_last : time := 0 ns;    -- Always ready

    -- Scoreboard signals

    signal scoreboard_aliveness_complete : std_logic;
    signal scoreboard_horizontal_scan_complete : std_logic;

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
    wait until (
        scoreboard_aliveness_complete = '1' and
        scoreboard_horizontal_scan_complete = '1'
    );
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
begin
    aliveness_ready <= '0';
    wait until reset = '1';
    reset_deassert <= now;
    wait on v_sync, h_sync, color for aliveness_wait_max;
    if v_sync'event or h_sync'event or color'event then
        aliveness_time <= now;
        aliveness_ready <= '1';
    else
        report "TEST_FAILURE: DUT failed to show signs of life within maximum wait time."
            severity failure;
    end if;
    wait until reset = '0';
end process ; -- MONITOR_ALIVENESS

MONITOR_HORIZONTAL_SYNC : process
begin
    wait until h_sync = '0';
    horizontal_sync_assert <= now;
    wait until h_sync = '1' for h_sync_wait_time_max;
    if h_sync = '0' then
        report "TEST_FAILURE: DUT failed to deassert h_sync within maximum wait time."
            severity failure;
    else
        horizontal_sync_deassert <= now;
    end if;
    wait until h_sync = '0';
    horizontal_sync_next <= now;
    horizontal_sync_ready <= '1';
    -- wait for dt;
end process ; -- MONITOR_HORIZONTAL_SYNC

MONITOR_HORIZONTAL_SYNC_COLOR : process
begin
    wait until h_sync = '0';
    horizontal_sync_color_ready <= '0';
    wait until (color /= (11 downto 0 => '0') or h_sync = '1');
    if color /= (11 downto 0 => '0') then
        horizontal_sync_color <= '1';
    else
        horizontal_sync_color <= '0';
    end if;
    horizontal_sync_color_ready <= '1';
    wait until h_sync = '1';
end process ; -- MONITOR_HORIZONTAL_SYNC_COLOR

MONITOR_HORIZONTAL_COLOR_FIRST : process
begin
    wait until h_sync = '0';
    wait until h_sync = '1';
    horizontal_color_first_ready <= '0';
    wait until (color /= (11 downto 0 => '0') or h_sync = '0');
    if color /= (11 downto 0 => '0') then
        horizontal_color_activity <= '1';
        horizontal_color_first <= now;
    else
        horizontal_color_activity <= '0';
    end if;
    horizontal_color_first_ready <= '1';
end process ; -- MONITOR_HORIZONTAL_COLOR_FIRST

MONITOR_HORIZONTAL_COLOR_LAST : process
begin
    wait until color /= (11 downto 0 => '0');
    horizontal_color_last <= now;
end process ; -- MONITOR_HORIZONTAL_COLOR_LAST

SCOREBOARD_ALIVENESS  : process
    variable wake_up_time : time;
begin
    scoreboard_aliveness_complete <= '0';
    wait until aliveness_ready = '1';
    wake_up_time := aliveness_time - reset_deassert;
    if wake_up_time >= wake_up_time_max then
        report "TEST_FAILURE: DUT exceeded reset wake-up time."
            severity error;
    end if;
    scoreboard_aliveness_complete <= '1';
    wait until aliveness_ready = '0';
end process ; -- SCOREBOARD_ALIVENESS

SCOREBOARD_HORIZONTAL_SCAN : process
    variable horizontal_sync_duration : time;
    variable horizontal_scan_duration : time;
    variable horizontal_back_porch_duration : time;
    variable horizontal_front_porch_duration : time;
begin
    scoreboard_horizontal_scan_complete <= '0';
    wait until (
        horizontal_sync_ready = '1' and
        horizontal_sync_color_ready = '1' and
        horizontal_color_first_ready = '1'
        -- horizontal_color_last is always ready
    );

    horizontal_sync_duration := horizontal_sync_deassert - horizontal_sync_assert;
    if horizontal_sync_duration < horizontal_sync_duration_min then
        report "TEST_FAILURE: Horizontal sync duration is below tolerance."
            severity error;
    elsif horizontal_sync_duration > horizontal_sync_duration_max then
        report "TEST_FAILURE: Horizontal sync duration is above tolerance."
            severity error;
    end if;

    horizontal_scan_duration := horizontal_sync_next - horizontal_sync_assert;
    if horizontal_scan_duration < horizontal_scan_duration_min then
        report "TEST_FAILURE: Horizontal scan duration is below tolerance."
            severity error;
    elsif horizontal_scan_duration > horizontal_scan_duration_max then
        report "TEST_FAILURE: Horizontal scan duration is above tolerance."
            severity error;
    end if;

    if horizontal_sync_color = '1' then
        report "TEST_FAILURE: Activity on color outputs during horizontal sync period."
            severity error;
    end if;

    if horizontal_color_activity = '1' then
        
        horizontal_back_porch_duration := horizontal_color_first - horizontal_sync_deassert;
        if horizontal_back_porch_duration > horizontal_back_porch_duration_min then
            report "TEST_FAILURE: Horizontal back porch duration is below tolerance."
                severity error;
        end if;

        horizontal_front_porch_duration := horizontal_sync_next - horizontal_color_last;
        if (horizontal_front_porch_duration < horizontal_front_porch_duration_min) then
            report "TEST_FAILURE: Horizontal front porch duration is below tolerance."
                severity error;
        end if;

    end if;

    scoreboard_horizontal_scan_complete <= '1';

    wait until (
        horizontal_sync_ready = '0' and
        horizontal_sync_color_ready = '0' and
        horizontal_color_first_ready = '0'
        -- horizontal_color_last is always ready
    );

end process ; -- SCOREBOARD_HORIZONTAL_SCAN

DUT : entity work.vga_controller(rtl)
port map (
    clock => clock,
    reset => reset,
    v_sync => v_sync,
    h_sync => h_sync,
    color => color
);

end architecture;