library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
library work;
use work.util_components.all;

entity StoreQueue is
	port (
		push_addr, push_data : in std_logic_vector(15 downto 0);
		push_en: in std_logic;
		
		load_en: in std_logic;
		
		pop_addr, pop_data : out std_logic_vector(15 downto 0);
		pop_en: out std_logic;
		
		clk, reset: in std_logic
		
	);	
end entity;

architecture Behave of StoreQueue is
	signal push_sig, pop_sig : std_logic_vector(1 downto 0) := (others => '0');
	signal push_line, pop_line : std_logic_vector(31 downto 0);
	
	signal not_empty : std_logic;
begin
	Q: Queue generic map ( word_len => 32, num_words => 8, head_p_bits => 3) 
	         port map (head_en => pop_sig, tail_en => push_sig,
				          head_reg_out => pop_line, tail_reg_in => push_line,
							 not_empty => not_empty,
							 clk=>clk, reset => reset);
							 
   push_sig(0) <= push_en;
	pop_sig(0) <= not(load_en);
	pop_en <= not(load_en);
	
	push_line(31 downto 16) <= push_addr;
	push_line(15 downto 0) <= push_data;
	
	pop_addr <= pop_line(31 downto 16) ;
	pop_data <= pop_line(15 downto 0);
end architecture;