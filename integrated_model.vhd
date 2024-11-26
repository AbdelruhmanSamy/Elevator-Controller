LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY integrated_model IS
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
END integrated_model;

ARCHITECTURE rtl OF integrated_model IS
    COMPONENT clock IS
        GENERIC (clk_freq : INTEGER := 1000); -- 50 MHz
        PORT (
            in_clk : IN STD_LOGIC;
            out_clk : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT unit_controller IS
        GENERIC (number_of_floors : INTEGER := 10);
        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            dest_floor : IN INTEGER RANGE -1 TO number_of_floors - 1;
            curr_floor : OUT INTEGER RANGE 0 TO number_of_floors - 1;
            door_open : OUT STD_LOGIC;
            mv_up : OUT STD_LOGIC;
            mv_down : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT reqeust_resolver IS
        GENERIC (number_of_floors : INTEGER := 10);

        PORT (
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            curr_floor : IN INTEGER RANGE 0 TO number_of_floors - 1;
            mv_up : IN STD_LOGIC;
            mv_down : IN STD_LOGIC;
            door_open : IN STD_LOGIC;
            request_btn : IN INTEGER RANGE 0 TO number_of_floors - 1;
            take_request : IN STD_LOGIC;
            dest_floor : OUT INTEGER RANGE -1 TO number_of_floors - 1
        );
    END COMPONENT;

    SIGNAL dest_floor_sig : INTEGER;

    SIGNAL curr_floor_sig : INTEGER RANGE 0 TO number_of_floors - 1 := 0;
    SIGNAL mv_up_sig : STD_LOGIC := '0';
    SIGNAL mv_down_sig : STD_LOGIC := '0';
    SIGNAL door_open_sig : STD_LOGIC := '0';
    SIGNAL request_btn_int : INTEGER RANGE 0 TO number_of_floors - 1 := 0;
    SIGNAL clk_slow_sig : STD_LOGIC := '0';
BEGIN
    request_btn_int <= to_integer(signed(request_btn));
    u1 : clock PORT MAP(clk, clk_slow_sig);
    u2 : reqeust_resolver PORT MAP(clk_slow_sig, reset, curr_floor_sig, mv_up_sig, mv_down_sig, door_open_sig, request_btn_int, take_request, dest_floor_sig);
    u3 : unit_controller PORT MAP(clk_slow_sig, reset, dest_floor_sig, curr_floor_sig, door_open_sig, mv_up_sig, mv_down_sig);

    door_open <= door_open_sig;
    mv_up <= mv_up_sig;
    mv_down <= mv_down_sig;
    curr_floor <= curr_floor_sig;

END ARCHITECTURE;