LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_integrated_model IS
END tb_integrated_model;

ARCHITECTURE behavior OF tb_integrated_model IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT integrated_model
        GENERIC (number_of_floors : INTEGER := 10);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            request_btn : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            take_request : IN STD_LOGIC;
            curr_floor : OUT INTEGER RANGE 0 TO number_of_floors - 1;
            door_open : OUT STD_LOGIC;
            mv_up : OUT STD_LOGIC;
            mv_down : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Test Signals
    SIGNAL reset : STD_LOGIC := '1';
    SIGNAL request_btn : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    SIGNAL take_request : STD_LOGIC := '1';
    SIGNAL curr_floor : INTEGER RANGE 0 TO 9;
    SIGNAL door_open : STD_LOGIC;
    SIGNAL mv_up : STD_LOGIC;
    SIGNAL mv_down : STD_LOGIC;
    SIGNAL clk : STD_LOGIC;

    -- Clock Periods
    CONSTANT clk_period : TIME := 10 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : integrated_model
    GENERIC MAP(number_of_floors => 10)
    PORT MAP(
        clk => clk,
        reset => reset,
        request_btn => request_btn,
        take_request => take_request,
        curr_floor => curr_floor,
        door_open => door_open,
        mv_up => mv_up,
        mv_down => mv_down
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period / 2;
        clk <= '0';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Stimulus process
    stimulus_process : PROCESS
    BEGIN
        -- Initial reset
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        -- Test Case 1: Request to move from floor 0 to floor 3
        request_btn <= "0011";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 3 * clk_period;
        ASSERT curr_floor = 3
        REPORT "Test Case 1 Failed: Elevator did not reach floor 3"
            SEVERITY ERROR;

        -- Test Case 2: Request to move up to floor 7
        request_btn <= "0111";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 8 * clk_period;
        ASSERT curr_floor = 7
        REPORT "Test Case 2 Failed: Elevator did not reach floor 7"
            SEVERITY ERROR;

        -- Test Case 3: Request to move down to floor 2
        request_btn <= "0010";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 4 * clk_period;
        ASSERT curr_floor = 2
        REPORT "Test Case 3 Failed: Elevator did not reach floor 2"
            SEVERITY ERROR;

        -- Test Case 4: Request to top floor (floor 9)
        request_btn <= "1001";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 10 * clk_period;
        ASSERT curr_floor = 9
        REPORT "Test Case 4 Failed: Elevator did not reach floor 9"
            SEVERITY ERROR;

        -- Test Case 5: Request back down to ground floor (floor 0)
        request_btn <= "0000";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 10 * clk_period;
        ASSERT curr_floor = 0
        REPORT "Test Case 5 Failed: Elevator did not return to floor 0"
            SEVERITY ERROR;

        -- Test Case 6: Simulate pressing reset during operation
        request_btn <= "0101";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR 2 * clk_period; -- Begin moving
        reset <= '1'; -- Reset midway
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR 3 * clk_period;
        ASSERT curr_floor = 0
        REPORT "Test Case 6 Failed: Elevator did not reset to floor 0"
            SEVERITY ERROR;

        -- Test Case 7: Concurrent request handling
        request_btn <= "0011";
        take_request <= '1';
        WAIT FOR clk_period;
        take_request <= '0';
        WAIT FOR clk_period;
        ASSERT mv_up = '1' OR mv_down = '1'
        REPORT "Test Case 7 Failed: Elevator did not handle concurrent requests properly"
            SEVERITY ERROR;

        -- End of Test
        WAIT FOR 500 * clk_period;
    END PROCESS;

END behavior;