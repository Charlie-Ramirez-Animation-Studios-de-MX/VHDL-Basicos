LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SemaforoV2 IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC := '0';
        Sensor : IN STD_LOGIC := '0';
        Led_Verde : OUT STD_LOGIC;
        Led_Amarillo : OUT STD_LOGIC;
        Led_Rojo : OUT STD_LOGIC
    );
END SemaforoV2;

ARCHITECTURE BEHAVIOR OF SemaforoV2 IS
    TYPE type_fstate IS (S0, S1, S2);
    SIGNAL fstate : type_fstate;
    SIGNAL reg_fstate : type_fstate;
    
    -- Frequency divider signals OG CLOCK
--    CONSTANT max_count : INTEGER := 25000000; -- 50 million/2 for 1 second at 50 MHz
--    SIGNAL counter_div : INTEGER RANGE 0 TO max_count;
--    SIGNAL one_hz_clock : STD_LOGIC := '0';
--    
--    SIGNAL sec_counter : INTEGER RANGE 0 TO 30; -- Counter for seconds in each state
--
--    CONSTANT sec5 : INTEGER := 5; -- 5 seconds
--    CONSTANT sec30 : INTEGER := 30; -- 30 seconds
--SIMULAPROPS
	 CONSTANT max_count : INTEGER := 2; -- 50 million/2 for 1 second at 50 MHz
    SIGNAL counter_div : INTEGER RANGE 0 TO max_count;
    SIGNAL one_hz_clock : STD_LOGIC := '0';
    
    SIGNAL sec_counter : INTEGER RANGE 0 TO 6; -- Counter for seconds in each state

    CONSTANT sec5 : INTEGER := 2; -- 5 seconds
    CONSTANT sec30 : INTEGER := 6; -- 30 seconds


BEGIN
    -- Frequency Divider Process: Divide 50 MHz clock to 1 Hz
    PROCESS (clock)
    BEGIN
        IF (clock = '1' AND clock'event) THEN
            IF counter_div < max_count - 1 THEN
                counter_div <= counter_div + 1;
            ELSE
                counter_div <= 0;
                one_hz_clock <= NOT one_hz_clock; -- Toggle 1 Hz clock signal
            END IF;
        END IF;
    END PROCESS;

    -- State update process triggered by 1 Hz clock
    PROCESS (one_hz_clock, reset)
    BEGIN
        IF reset = '1' THEN
            fstate <= S0;
            reg_fstate <= S0;
            Led_Verde <= '0';
            Led_Amarillo <= '0';
            Led_Rojo <= '0';
            sec_counter <= 0;
        ELSIF one_hz_clock = '1' AND one_hz_clock'event THEN
            CASE fstate IS
                WHEN S0 =>
                    Led_Rojo <= '0';
                    Led_Amarillo <= '0';
                    Led_Verde <= '1';

                    IF sec_counter < sec30 THEN
                        sec_counter <= sec_counter + 1;
                    ELSE
                        sec_counter <= 0;
                        IF Sensor = '1' THEN
                            reg_fstate <= S1;
                        END IF;
                    END IF;

                WHEN S1 =>
                    Led_Rojo <= '0';
                    Led_Amarillo <= '1';
                    Led_Verde <= '0';

                    IF sec_counter < sec5 THEN
                        sec_counter <= sec_counter + 1;
                    ELSE
                        sec_counter <= 0;
                        reg_fstate <= S2;
                    END IF;

                WHEN S2 =>
                    Led_Rojo <= '1';
                    Led_Amarillo <= '0';
                    Led_Verde <= '0';

                    IF Sensor = '1' THEN
                        sec_counter <= 0; -- Reset counter while Sensor is active
                    ELSE
                        IF sec_counter < sec30 THEN
                            sec_counter <= sec_counter + 1;
                        ELSE
                            sec_counter <= 0;
                            reg_fstate <= S0;
                        END IF;
                    END IF;

                WHEN OTHERS =>
                    Led_Verde <= 'X';
                    Led_Amarillo <= 'X';
                    Led_Rojo <= 'X';
                    report "Reached undefined state";
            END CASE;

            fstate <= reg_fstate; -- Update state
        END IF;
    END PROCESS;
END BEHAVIOR;
