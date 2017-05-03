library ieee;
use ieee.std_logic_1164.all;

library work;
use work.util_components.all;


entity IITB_RISC_SuperScalar is
	port
	(
		clk, reset, start : in std_logic;
		done : out std_logic
	);
end entity;

architecture pipe of IITB_RISC_SuperScalar is
	signal clk_slow : std_logic := '0';
begin
--	process(clk)
--	begin
--		if(clk'event and clk = '0') then 
--			clk_slow <= not(clk_slow);
--		end if;
--	end process;


end architecture;
