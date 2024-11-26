LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reqeust_resolver IS
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
END reqeust_resolver;

ARCHITECTURE behaviour OF reqeust_resolver IS
    SIGNAL requested_floors : STD_LOGIC_VECTOR(number_of_floors - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
    PROCESS (clk, reset)
        VARIABLE nearest_greater_req : INTEGER;
        VARIABLE nearest_smaller_req : INTEGER;
        VARIABLE diff_low : INTEGER; -- difference between curr_floor and nearest_smaller_req
        VARIABLE diff_high : INTEGER; -- difference between curr_floor and nearest_greater_req
    BEGIN
        IF reset = '1' THEN
            dest_floor <= - 1;
            nearest_greater_req := 0;
            nearest_smaller_req := 0;
            diff_low := 0;
            diff_high := 0;
            requested_floors <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            requested_floors(curr_floor) <= '0';
            IF requested_floors = "0000000000" THEN
                dest_floor <= - 1;
            END IF;
            IF take_request = '1' THEN
                requested_floors(request_btn) <= '1';
            END IF;
            nearest_greater_req := number_of_floors;
            nearest_smaller_req := - 1;

            FOR i IN 0 TO number_of_floors - 1 LOOP

                IF i > curr_floor AND requested_floors(i) = '1' THEN
                    nearest_greater_req := i;
                    EXIT;
                END IF;
            END LOOP;

            diff_high := ABS(curr_floor - nearest_greater_req);

            FOR i IN number_of_floors - 1 DOWNTO 0 LOOP
                IF i < curr_floor AND requested_floors(i) = '1' THEN
                    nearest_smaller_req := i;
                    EXIT;
                END IF;
            END LOOP;

            diff_low := ABS(curr_floor - nearest_smaller_req);

            IF nearest_greater_req < number_of_floors OR nearest_smaller_req >= 0 THEN

                IF mv_up = '1' THEN

                    IF nearest_greater_req < number_of_floors THEN
                        dest_floor <= nearest_greater_req;
                    ELSE
                        dest_floor <= curr_floor;
                    END IF;

                ELSIF mv_down = '1' THEN

                    IF nearest_smaller_req >= 0 THEN
                        dest_floor <= nearest_smaller_req;
                    ELSE
                        dest_floor <= curr_floor;
                    END IF;
                ELSIF door_open = '1' THEN
                    IF nearest_greater_req < number_of_floors AND (nearest_smaller_req < 0 OR diff_high <= diff_low) THEN
                        dest_floor <= nearest_greater_req;
                    ELSIF nearest_smaller_req >= 0 THEN
                        dest_floor <= nearest_smaller_req;
                    ELSE
                        dest_floor <= curr_floor;
                    END IF;

                ELSE
                    IF nearest_greater_req < number_of_floors AND (nearest_smaller_req < 0 OR diff_high <= diff_low) THEN
                        dest_floor <= nearest_greater_req;
                    ELSIF nearest_smaller_req >= 0 THEN
                        dest_floor <= nearest_smaller_req;
                    ELSE
                        dest_floor <= - 1;
                    END IF;

                END IF;

            ELSE
                IF requested_floors = "0000000000" THEN
                    dest_floor <= - 1;
                ELSE
                    dest_floor <= curr_floor;
                END IF;
            END IF;
        END IF;

    END PROCESS;

END ARCHITECTURE;