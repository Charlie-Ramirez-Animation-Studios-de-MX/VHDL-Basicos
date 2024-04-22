--Biblioteca y Paquetes
library ieee;
use ieee.std_logic_1164.all;

--Entidad
entity multiplexor is
	Port(
		A : in std_logic_vector (3 downto 0);
		B : in std_logic_vector (3 downto 0);
		C : in std_logic_vector (3 downto 0);
		SEL : in std_logic_vector (1 downto 0);
		Z : out std_logic_vector (3 downto 0)
		);
end multiplexor;

--Arquitectura
architecture arquitec of multiplexor is
	begin
		PROCESS (SEL, A, B ,C) is
			begin
				CASE SEL IS
					when "00" => Z <= (others => '0');
					when "01" => Z <= A;
					when "10" => Z <= B;
					when "11" => Z <= C;
					when others => Z <= (others => '0');
				END CASE;
		END PROCESS;
end arquitec;