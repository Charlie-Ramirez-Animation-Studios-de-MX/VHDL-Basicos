--Biblioteca y Paquetes
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--Entidad
entity comp_comb is
	Port	(a, b, c, d, e: in std_logic;
			f : out std_logic);
end comp_comb;

--Arquitectura
architecture ejercicio1 of comp_comb is 
	signal g,h,i,j,k: std_logic;
	begin
		--f <= (e xor ((a and b) or (c nor d) and (a and b)nand(c nor d)));
		
		g <= a and b;
		h <= c nor d;
		i <= g or h;
		j <= g nand h;
		k <= i and j;
		f <= k xor e;
end ejercicio1;
----------------------------------------------