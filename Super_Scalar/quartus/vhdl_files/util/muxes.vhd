library ieee ;
	use ieee.std_logic_1164.all ;

library work;
	use work.util_components.all;

entity mux2 is
	port 
	(
		A0,A1 : in std_logic_vector;
		s : in std_logic;
		D : out std_logic_vector
	);
end entity;

architecture big of mux2 is
	signal s1 : std_logic_vector(A0'range);
begin 
	process(s)
	begin
		for I in 0 to A0'length-1
		loop
			s1(I) <= s;
		end loop;
	end process;
	
	D <= (A0 and (not s1)) or (A1 and s1);
end architecture;

library ieee ;
	use ieee.std_logic_1164.all ;

library work;
	use work.all_components.all;

entity mux4 is
	port 
	(
		A0,A1,A2,A3 : in std_logic_vector;
		s : in std_logic_vector(1 downto 0);
		D : out std_logic_vector
	);
end entity;

architecture big of mux4 is
	signal T0,T1 : std_logic_vector(A0'range);
begin 
	mux_a: mux2 port map (A0=>A0,A1=>A1,D=>T0,s=>s(0));
	mux_b: mux2 port map (A0=>A2,A1=>A3,D=>T1,s=>s(0)); 
	mux_c: mux2 port map (A0=>T0,A1=>T1,D=>D,s=>s(1));
end architecture;

library ieee ;
	use ieee.std_logic_1164.all ;

library work;
	use work.all_components.all;

entity mux8 is
	port 
	(
		A0,A1,A2,A3,A4,A5,A6,A7 : in std_logic_vector;
		s : in std_logic_vector(2 downto 0);
		D : out std_logic_vector
	);
end entity;

architecture big of mux8 is
	signal T0,T1 : std_logic_vector(A0'range);
begin
	mux_a: mux4 port map (A0=>A0,A1=>A1,A2=>A2,A3=>A3,D=>T0,s=>s(1 downto 0));
	mux_b: mux4 port map (A0=>A4,A1=>A5,A2=>A6,A3=>A7,D=>T1,s=>s(1 downto 0)); 
	mux_c: mux2 port map (A0=>T0,A1=>T1,D=>D,s=>s(2)); 
end architecture;