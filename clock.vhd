LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY clock IS
    GENERIC (clk_freq : INTEGER := 50000000); -- 50 MHz
    PORT (
        in_clk : IN STD_LOGIC;
        out_clk : OUT STD_LOGIC
    );
END clock;

ARCHITECTURE behavior OF clock IS
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL clk_counter : INTEGER := 0;
    SIGNAL clk_enable : STD_LOGIC := '0';
BEGIN
    PROCESS (in_clk)
    BEGIN
        IF rising_edge(in_clk) THEN
            IF clk_counter = clk_freq / 2 - 1 THEN
                clk_enable <= '1';
                clk_counter <= 0;
            ELSE
                clk_enable <= '0';
                clk_counter <= clk_counter + 1;
            END IF;
            IF clk_enable = '1' THEN
                clk <= NOT clk;
            END IF;
            out_clk <= clk;
        END IF;
    END PROCESS;
END behavior;