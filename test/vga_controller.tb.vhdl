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
    constant wake_up_time_max : time := 1 ms;
    constant horizontal_sync_duration_min : time := 3.79 us;
    constant horizontal_sync_duration_max : time := 3.83 us;
    constant horizontal_scan_duration_min : time := 31.6 us;
    constant horizontal_scan_duration_max : time := 31.9 us;
    constant horizontal_back_porch_duration_min : time := 1.585 us;
    constant horizontal_front_porch_duration_min : time := 316 ns;

    -- DUT interface signals
    signal clock : std_logic;
    signal reset : std_logic;
    signal v_sync : std_logic;
    signal h_sync : std_logic;
    signal color : std_logic_vector(11 downto 0);

    signal reset_delay_1_dt : std_logic;

    signal first_dt_has_passed : std_logic := '0';

    constant initial_reset_hold : time := 50 ns;

begin

first_dt_has_passed <= '1';

TEST_RESET : process
begin
    reset <= '0';
    wait for initial_reset_hold;
    reset <= '1';
    wait for initial_reset_hold;
    report "TEST_SUCCESS" severity note;
    wait;
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

reset_delay_1_dt <= reset;
assert reset_delay_1_dt /= '0' or or(color) = '0'
    report "TEST_FAILURE: Color output failed to respect reset assertion."
    severity failure;
assert reset_delay_1_dt /= '0' or h_sync = '0'
    report "TEST_FAILURE: h-sync output failed to respect reset assertion."
    severity failure;
assert reset_delay_1_dt /= '0' or v_sync = '0'
    report "TEST_FAILURE: v-sync output failed to respect reset assertion."
    severity failure;

DUT : entity work.vga_controller(rtl)
port map (
    clock => clock,
    reset => reset,
    v_sync => v_sync,
    h_sync => h_sync,
    color => color
);

end architecture;