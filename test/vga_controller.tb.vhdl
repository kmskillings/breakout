library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

use std.env.finish;

entity vga_controller_tb is
end vga_controller_tb ; 

architecture tb of vga_controller_tb is

    -- Requirement settings
    constant clock_period_min : time := 39.6 ns;
    constant clock_period_max : time := 39.9 ns;
    constant wake_up_time_max : time := 100 ms;
    constant horizontal_sync_duration_min : time := 3.79 us;
    constant horizontal_sync_duration_max : time := 3.83 us;
    constant horizontal_scan_duration_min : time := 31.6 us;
    constant horizontal_scan_duration_max : time := 31.9 us;
    constant horizontal_back_porch_duration_min : time := 1.585 us;
    constant horizontal_front_porch_duration_min : time := 316 ns;

    -- DUT interface signals
    signal clock : std_logic := '0';
    signal reset : std_logic := '0';
    signal v_sync : std_logic;
    signal h_sync : std_logic;
    signal color : std_logic_vector(11 downto 0);

    signal reset_delay_1_dt : std_logic;
    signal clock_delay_1_dt : std_logic;
    signal first_dt_has_passed : std_logic := '0';

    constant initial_reset_hold : time := 1000 ms;

begin

first_dt_has_passed <= '1';

GENERATE_CLOCK : process
begin
    clock <= '0';
    wait for clock_period_min / 2;
    clock <= '1';
    wait for clock_period_min / 2;
end process ; -- GENERATE_CLOCK

TEST_RESET : process
begin
    reset <= '0';
    wait until rising_edge(clock);
    reset <= '1';
    wait for initial_reset_hold;
    report "TEST_SUCCESS" severity note;
    finish;
end process ; -- TEST_RESET

assert first_dt_has_passed = '0' or v_sync = '0' or v_sync = '1'
    report "TEST_FAILURE: Output v_sync is in illegal state."
    severity failure;
assert first_dt_has_passed = '0' or h_sync = '0' or h_sync = '1'
    report "TEST_FAILURE: Output h_sync is in illegal state."
    severity failure;
CHECK_COLOR_STATES : for i in 11 downto 0 generate
    assert first_dt_has_passed = '0' or color(i) = '0' or color(i) = '1'
        report "TEST_FAILURE: Output color(" & integer'image(i) & ") is in illegal state."
        severity failure;
end generate;

clock_delay_1_dt <= clock;
reset_delay_1_dt <= reset;

assert 
        rising_edge(first_dt_has_passed) or
        not(v_sync'event)                or 
        rising_edge(clock_delay_1_dt)    or 
        falling_edge(reset_delay_1_dt)
    report "TEST_FAILURE: Output v_sync changed asynchronously with clock and reset."
    severity failure;
assert 
        rising_edge(first_dt_has_passed) or
        not(h_sync'event)                or 
        rising_edge(clock_delay_1_dt)    or 
        falling_edge(reset_delay_1_dt)
    report "TEST_FAILURE: Output h_sync changed asynchronously with clock and reset."
    severity failure;
CHECK_COLOR_REG : for i in 11 downto 0 generate
    assert 
            rising_edge(first_dt_has_passed) or
            not(color(i)'event)              or 
            rising_edge(clock_delay_1_dt)    or 
            falling_edge(reset_delay_1_dt)
        report "TEST_FAILURE: Output color(" & integer'image(i) & ") changed asynchronously with clock and reset."
        severity failure;
end generate ; -- CHECK_COLOR_REG

assert reset_delay_1_dt /= '0' or or(color) = '0'
    report "TEST_FAILURE: Color output failed to respect reset assertion."
    severity failure;
assert reset_delay_1_dt /= '0' or h_sync = '0'
    report "TEST_FAILURE: h-sync output failed to respect reset assertion."
    severity failure;
assert reset_delay_1_dt /= '0' or v_sync = '0'
    report "TEST_FAILURE: v-sync output failed to respect reset assertion."
    severity failure;

CHECK_WAKE_UP_TIME : process
begin
    wait until rising_edge(reset);
    wait until ( 
        falling_edge(h_sync) or
        falling_edge(reset)
    ) for wake_up_time_max;
    assert falling_edge(h_sync) or falling_edge(reset)
        report "TEST_FAILURE: DUT failed to begin horizontal scan waveform within allotted wake-up time."
        severity failure;
end process ; -- CHECK_WAKE_UP_TIME

CHECK_HORIZONTAL_CYCLE_PERIOD : process
    variable first_cycle_hasnt_started : boolean := true;
    variable last_cycle_beginning : time;
    variable this_cycle_beginning : time;
    variable last_cycle_period : time;
begin
    -- Imagine we've encountered one falling edge
    wait until (
        falling_edge(h_sync) or 
        reset = '0'
    ) for horizontal_scan_duration_max;
    if reset = '0' then
        first_cycle_hasnt_started := true;
    else
        if not first_cycle_hasnt_started then
            assert falling_edge(h_sync)
                report "TEST_FAILURE: Horizontal cycle period exceeded maximum."
                severity failure;
            this_cycle_beginning := now;
            last_cycle_period := this_cycle_beginning - last_cycle_beginning;
            assert last_cycle_period >= horizontal_scan_duration_min
                report "TEST_FAILURE: Horizontal cycle period is below minimum."
                severity failure;
            last_cycle_beginning := now;
        elsif falling_edge(h_sync) then
            last_cycle_beginning := now;
            first_cycle_hasnt_started := false;
        end if;
    end if;
end process ; -- CHECK_HORIZONTAL_CYCLE_PERIOD

CHECK_HORIZONTAL_SYNC_PERIOD : process
begin
    wait until (
        falling_edge(h_sync) and
        reset = '1'
    );
    wait until (
        reset = '0' or
        h_sync = '1'
    ) for horizontal_sync_duration_min;
    assert reset = '0' or h_sync = '0'
        report "TEST_FAILURE: Horizontal sync period duration is below minimum."
        severity failure;
    wait until (
        reset = '0' or
        h_sync = '1'
    ) for (horizontal_sync_duration_max - horizontal_sync_duration_max);
    assert reset = '0' or h_sync = '1'
        report "TEST_FAILURE: Horizontal sync period duration exceeded maximum."
        severity failure;
end process ; -- CHECK_HORIZONTAL_SYNC_PERIOD

CHECK_COLOR_LOW_DURING_H_SYNC : for i in 11 downto 0 generate
    assert h_sync /= '0' or color(i) = '0'
        report "TEST_FAILURE: Output color(" & integer'image(i) & ") was non-0 during horizontal sync period."
        severity failure;
end generate ; -- CHECK_COLOR_LOW_DURING_H_SYNC

CHECK_HORIZONTAL_BACK_PORCH_DURATION : process
    variable first_cycle_hasnt_started : boolean := true;
begin
    wait until (
        reset = '0' or
        h_sync = '1'
    );
    if reset = '0' then
        first_cycle_hasnt_started := true;
    elsif h_sync = '1' then
        if first_cycle_hasnt_started then
            first_cycle_hasnt_started := false;
        else
            wait until (
                reset = '0' or
                color /= (11 downto 0 => '0')
            ) for horizontal_back_porch_duration_min;
            assert reset = '0' or color = (11 downto 0 => '0')
                report "TEST_FAILURE: Activity on color outputs during horizontal front porch."
                severity failure;
        end if;
    end if;
end process ; -- CHECK_HORIZONTAL_BACK_PORCH_DURATION

CHECK_HORIZONTAL_FRONT_PORCH_DURATION : process
begin
    
end process ; -- CHECK_HORIZONTAL_FRONT_PORCH_DURATION

DUT : entity work.vga_controller(rtl)
port map (
    clock => clock,
    reset => reset,
    v_sync => v_sync,
    h_sync => h_sync,
    color => color
);

end architecture;