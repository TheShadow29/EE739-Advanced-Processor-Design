library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all_components.all;

-- Will output 0 if nop==1
entity ControlWord is
	generic (
		size : integer
	);
	port (
		cin: in std_logic_vector(size - 1 downto 0);
		cout: out std_logic_vector(size - 1 downto 0);
		nop: in std_logic
	);
end entity ControlWord;

architecture Control of ControlWord is
	constant all_zero : std_logic_vector(size - 1 downto 0) := (others => '0');
--	signal cout_tmp : std_logic_vector(cin'length - 1 downto 0);
begin
	cout <= cin when nop = '0' else
			  all_zero;
--	cout <= cout_tmp;
end Control;