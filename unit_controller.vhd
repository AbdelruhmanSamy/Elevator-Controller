LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY unit_controller IS
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
END unit_controller;

ARCHITECTURE behavior OF unit_controller IS
    TYPE state_type IS (idle_state, moving_up_state, moving_down_state, door_open_state);
    SIGNAL state : state_type := idle_state;
BEGIN
    PROCESS (clk, reset)
        VARIABLE clk_counter : INTEGER := 0;
        VARIABLE curr_floor_tmp : INTEGER RANGE 0 TO number_of_floors - 1;
        VARIABLE mv_up_temp, mv_down_temp, door_open_temp : STD_LOGIC;

    BEGIN
        IF reset = '1' THEN
            door_open <= '0';
            mv_up <= '0';
            mv_down <= '0';
            state <= idle_state;
            curr_floor_tmp := 0;
            clk_counter := 0;
        ELSE
            IF rising_edge(clk) THEN
                clk_counter := clk_counter + 1;
                door_open_temp := '0';
                mv_up_temp := '0';
                mv_down_temp := '0';
                CASE state IS
                    WHEN moving_up_state =>
                        IF clk_counter >= 2 THEN
                            curr_floor_tmp := curr_floor_tmp + 1;
                            clk_counter := 0;
                        END IF;
                    WHEN moving_down_state =>
                        IF clk_counter >= 2 THEN
                            curr_floor_tmp := curr_floor_tmp - 1;
                            clk_counter := 0;
                        END IF;
                    WHEN OTHERS =>
                        curr_floor_tmp := curr_floor_tmp;
                END CASE;
                CASE state IS
                    WHEN idle_state =>
                        clk_counter := 0;
                        IF dest_floor =- 1 THEN
                            state <= idle_state;
                        ELSIF dest_floor > curr_floor_tmp THEN
                            mv_up_temp := '1';
                            state <= moving_up_state;
                        ELSIF dest_floor < curr_floor_tmp THEN
                            mv_down_temp := '1';
                            state <= moving_down_state;
                        ELSE
                            door_open_temp := '1';
                            state <= door_open_state;
                        END IF;
                    WHEN moving_up_state =>
                        IF curr_floor_tmp < dest_floor THEN
                            mv_up_temp := '1';
                            state <= moving_up_state;
                        ELSIF curr_floor_tmp = dest_floor THEN
                            door_open_temp := '1';
                            state <= door_open_state;
                        ELSE
                            state <= idle_state;
                        END IF;
                    WHEN moving_down_state =>
                        IF curr_floor_tmp > dest_floor THEN
                            mv_down_temp := '1';
                            state <= moving_down_state;
                        ELSIF curr_floor_tmp = dest_floor THEN
                            door_open_temp := '1';
                            state <= door_open_state;
                        ELSE
                            state <= idle_state;
                        END IF;
                    WHEN door_open_state =>
                        IF clk_counter >= 2 THEN
                            clk_counter := 0;
                            IF dest_floor =- 1 THEN
                                state <= idle_state;
                            ELSIF dest_floor > curr_floor_tmp THEN
                                mv_up_temp := '1';
                                state <= moving_up_state;
                            ELSIF dest_floor < curr_floor_tmp THEN
                                mv_down_temp := '1';
                                state <= moving_down_state;
                            ELSE
                                door_open_temp := '1';
                                state <= door_open_state;
                            END IF;
                        ELSE
                            door_open_temp := '1';
                            state <= door_open_state;
                        END IF;
                END CASE;
                curr_floor <= curr_floor_tmp;
            ELSIF falling_edge(clk) THEN
                mv_up <= mv_up_temp;
                mv_down <= mv_down_temp;
                door_open <= door_open_temp;
            END IF;
        END IF;
    END PROCESS;
END behavior;