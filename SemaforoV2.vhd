LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY SemaforoV2 IS --Designacion de Variables de entradas y Salidas
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
    TYPE type_fstate IS (S0, S1, S2); --Maquina de 3 estados S0 Apagado/Verde, S1 Amarillo, S2 rojo
    SIGNAL fstate : type_fstate; --Señal de estado Presente
    SIGNAL reg_fstate : type_fstate; --Estado registrado (futuro)
    
    -- Divisor de Frecuencia original para FPGA
    CONSTANT max_count : INTEGER := 25000000; -- Al usar flancos altos se usa la mitad de valores = 1seg a 50 MHz
    SIGNAL counter_div : INTEGER RANGE 0 TO max_count; 
    SIGNAL one_hz_clock : STD_LOGIC := '0'; --Al llegar al limite de 25M el Bit de Señal de 1 Hz Intercambia de Valor 1-0
    
   SIGNAL sec_counter : INTEGER RANGE 0 TO 30; -- Counter en segundos para cada estado

    CONSTANT sec5 : INTEGER := 5; -- 5 seg
    CONSTANT sec30 : INTEGER := 30; -- 30 seg
--SIMULAPROPS (Valores de Reloj Solo para simularlo con el University Program)
--	 CONSTANT max_count : INTEGER := 2; -- 
--   SIGNAL counter_div : INTEGER RANGE 0 TO max_count;
--    SIGNAL one_hz_clock : STD_LOGIC := '0';
    
--    SIGNAL sec_counter : INTEGER RANGE 0 TO 6; -- Contador para segundos en cada estado

--    CONSTANT sec5 : INTEGER := 2; -- 5 seg
--    CONSTANT sec30 : INTEGER := 6; -- 30 seg


BEGIN
    -- Proceso de Divisor de Freq: Divide la señal de 50 MHz a 1 Hz
    PROCESS (clock)
    BEGIN
        IF (clock = '1' AND clock'event) THEN --Cada que hay un evento en flanco alto y el reloj es 1
            IF counter_div < max_count - 1 THEN --El contador incrementa 1 en 1 hasta el limite -1
                counter_div <= counter_div + 1;
            ELSE
                counter_div <= 0; --Al llegar al limite resetea el contador
                one_hz_clock <= NOT one_hz_clock; -- Intercambia el bit de 1 Hz de señal de reloj 
            END IF;
        END IF;
    END PROCESS;

    -- Estados Detonados por la señal de 1Hz y cada vez que hay un cambio en reset y sensor
    PROCESS (one_hz_clock, reset, Sensor)
    BEGIN
        IF reset = '1' THEN  --Si reset=1 Todo es Cero y esta apagado
            fstate <= S0;
            reg_fstate <= S0;
            Led_Verde <= '0';
            Led_Amarillo <= '0';
            Led_Rojo <= '0';
            sec_counter <= 0;
        ELSIF one_hz_clock = '1' AND one_hz_clock'event THEN --De lo contrario cada vez que la señal de 1Hz esta en H y flaco
            CASE fstate IS
                WHEN S0 => --S0 sera cuando el led verde encienda eternamente, (Preferecia Vehicular) 
    Led_Rojo <= '0';
    Led_Amarillo <= '0';
    Led_Verde <= '1';
    IF sec_counter < sec30 THEN --si hay una señal de Sensor cuenta 30 Segundos y Cambia a S1 (Amarillo)
        sec_counter <= sec_counter + 1;
    ELSE
        sec_counter <= 0; --Cambio a Amarillo al terminar conteo
        IF Sensor = '1' THEN
            reg_fstate <= S1;
        END IF;
    END IF;

                WHEN S1 => --S1 sera cuando Led amarillo encienda 
                    Led_Rojo <= '0';
                    Led_Amarillo <= '1';
                    Led_Verde <= '0';

                    IF sec_counter < sec5 THEN --Entonces contara 5 segundos y cambiara a Rojo (S2)
                        sec_counter <= sec_counter + 1;
                    ELSE
                        sec_counter <= 0;
                        reg_fstate <= S2;
                    END IF;

                WHEN S2 => --S2 Sera cuando encienda led Rojo,
                    Led_Rojo <= '1';
                    Led_Amarillo <= '0';
                    Led_Verde <= '0';

                    IF Sensor = '1' THEN -- S2 Permanecera Permanentemente en rojo siempre que haya una señal de Sensor
                        sec_counter <= 0; -- Reset contador mientras Sensor sea =1 (Preferencia Peatonal_siempre rojo)
                    ELSE
                        IF sec_counter < sec30 THEN --Al Liberar la señal de Sensor o ser =0 Contara 30 Segundos y al terminar Volvera a (verde S1)
                            sec_counter <= sec_counter + 1;
                        ELSE
                            sec_counter <= 0;
                            reg_fstate <= S0;
                        END IF;
                    END IF;

                WHEN OTHERS => --Este estado Solo es en caso de Fallo o condicion Excepcional, y reportara el mismo
                    Led_Verde <= 'X';
                    Led_Amarillo <= 'X';
                    Led_Rojo <= 'X';
                    report "Reached undefined state";
            END CASE;

            fstate <= reg_fstate; -- Actualiza el estado presente al futuro
        END IF;
    END PROCESS;
END BEHAVIOR;
