library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_reg is
	generic ( data_width : integer);
	port(
		clk, ena, clr: in std_logic;
		Din: in std_logic_vector(data_width-1 downto 0);
		Dout: out std_logic_vector(data_width-1 downto 0));
end entity;

architecture reg of my_reg is
begin

	process(clk, clr)	
	begin
		if(clk'event and clk='1') then
			if ( clr = '1' ) then
				Dout <= (others => '0');
			elsif ( ena = '1' ) then
				Dout <= Din;
			end if;
		end if;
	end process;
	
end architecture;	