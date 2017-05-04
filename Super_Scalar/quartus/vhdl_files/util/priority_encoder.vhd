library ieee;
	use ieee.std_logic_1164.all;
library work;
	use work.util_components.all;
	

entity Decoder8 is
	port (
		A: in std_logic_vector(2 downto 0);
		OE: in std_logic;
		O: out std_logic_vector(7 downto 0)
	);
end entity Decoder8;

architecture Behave of Decoder8 is
begin
O(0) <= not(A(0)) and not(A(1)) and not(A(2)) and OE;
O(1) <= A(0) and not(A(1)) and not(A(2)) and OE;
O(2) <= not(A(0)) and A(1) and not(A(2)) and OE;
O(3) <= A(0) and A(1) and not(A(2)) and OE;
O(4) <= not(A(0)) and not(A(1)) and A(2) and OE;
O(5) <= A(0) and not(A(1)) and A(2) and OE;
O(6) <= not(A(0)) and A(1) and A(2) and OE;
O(7) <= A(0) and A(1) and A(2) and OE;
end architecture;

library ieee;
	use ieee.std_logic_1164.all;
library work;
	use work.util_components.all;

entity Decoder16 is
	port (
		A: in std_logic_vector(3 downto 0);
		OE: in std_logic;
		O: out std_logic_vector(15 downto 0)
	);
end entity Decoder16;

architecture behaviour of Decoder16 is
	signal O_tmp: std_logic_vector(7 downto 0);
	signal o_full_tmp1 : std_logic_vector(15 downto 0) := (others => '0');
	signal o_full_tmp2 : std_logic_vector(15 downto 0) := (others => '0');
begin
dec1: Decoder8 port map(OE=>OE, A=>A(2 downto 0), O=>O_tmp);
o_full_tmp1(7 downto 0) <= O_tmp;
o_full_tmp2(15 downto 0) <= O_tmp;
--O <= (7 downto 0 => O_tmp, others => '0') when A(3) = '0' else
--	  (15 downto 8 => O_tmp, others => '0');
O <= o_full_tmp1 when A(3) = '0' else o_full_tmp2;
end architecture;


library ieee ;
use ieee.std_logic_1164.all ;
library work;
use work.util_components.all;

entity PriorityEncoder is
	port ( x : in std_logic_vector(7 downto 0) ;
			 S : out std_logic_vector(2 downto 0);
			 N : out std_logic;
			 Tn: out std_logic_vector(7 downto 0)
		) ;
end PriorityEncoder ;
architecture comb of PriorityEncoder is
signal stmp : std_logic_vector(2 downto 0);
signal fbit : std_logic_vector(7 downto 0);
begin
	N <= ( x(7) or x(6) or x(5) or x(4) or x(3) or x(2) or x(1) or x(0) ) ;
	 pri_enc : process (x) is
    begin
        if (x(0)='1') then
            stmp <= "000";
        elsif (x(1)='1') then
            stmp <= "001";
        elsif (x(2)='1') then
            stmp <= "010";
        elsif (x(3)='1') then
            stmp <= "011";
        elsif (x(4)='1') then
            stmp <= "100";
        elsif (x(5)='1') then
            stmp <= "101";
        elsif (x(6)='1') then
            stmp <= "110";
        elsif (x(7)='1') then
            stmp <= "111";
			else
				stmp <= "000";
        end if;
    end process pri_enc;
	 
	 s <= stmp;
	 decoder1: Decoder8 port map (A=>stmp,O=>fbit,OE=>'1');
	 Tn <= not(fbit) and x;
end comb ;