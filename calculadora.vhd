--Biblioteca y Paquetes Cyclone III EP3C16F484C6N
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;


--Entidad
entity calculadora is
	Port(
		E1 : in std_logic_vector (1 downto 0);
		E2 : in std_logic_vector (1 downto 0);
		O : in std_logic_vector (2 downto 0);
		R : out std_logic_vector (3 downto 0)
		);
end calculadora;

--Arquitectura
architecture arquitec of calculadora is
	begin
		PROCESS (O, E1, E2) is
		variable temp_result : integer;
			begin
				CASE O IS
					when "000" => R <=std_logic_vector ('0' &'0' &unsigned(E1) + unsigned(E2)); --suma
					when "001" => R <=std_logic_vector ('0' &'0' &unsigned(E1) - unsigned(E2)); --resta
					when "010" => R <=std_logic_vector (unsigned(E1) * unsigned(E2)); --multiplica
					when "100" => 
						if E2 /= "00" then
                    temp_result := to_integer(unsigned(E1)) / to_integer(unsigned(E2));
                    R <= std_logic_vector(to_unsigned(temp_result, 4));
						else
                    R <= (others => '0'); -- División por cero, resultado es "0000"
						end if;--divide
					when others => R <= (others => '0');
				END CASE;
		END PROCESS;
end arquitec;