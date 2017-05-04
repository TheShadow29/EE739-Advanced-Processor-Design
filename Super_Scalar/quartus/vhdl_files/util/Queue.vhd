library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.decode_components.all;
use work.util_components.all;

entity queue is
	generic
	(
		--For RRF Queue, word_len = 4, 
		word_len : in integer;
		num_words : in integer;
		head_p_bits : in integer
	);
	port 
	(
		head_reg_out : out std_logic_vector  := (others => '0');
		head2_reg_out : out std_logic_vector := (others => '0');
--		head_num_out : in std_logic_vector;
		tail_reg_in : in std_logic_vector  := (others => '0');
		tail2_reg_in : in std_logic_vector := (others => '0');
		tail_en : in std_logic_vector(1 downto 0) := (others => '0');--00, 01 or 10
		head_en : in std_logic_vector(1 downto 0) := (others => '0');--00, 01 or 10
		
		not_empty : out std_logic;
		clk, reset : in std_logic
	);
end entity;

architecture que of queue is 
--	constant  word_len : integer := 4;
--	constant  num_words : integer := 16;
--	constant  head_p_bits : integer := 4;
	type reg_array is array (natural range <>) of std_logic_vector(word_len - 1 downto 0);
	
	signal R,write_data : reg_array(num_words-1 downto 0);
	signal En, sel1, sel2 : std_logic_vector(num_words - 1 downto 0);
	signal head_pointer_out, tail_pointer_out, head_pointer_in, tail_pointer_in : std_logic_vector(head_p_bits - 1 downto 0);
	signal head_p_plus_1, head_p_plus_2, tail_p_plus_1, tail_p_plus_2 : std_logic_vector(head_p_bits -1 downto 0);
	signal head_p_en, tail_p_en : std_logic;
	
	signal ht_eq, last_ac_en: std_logic;
	signal last_action_in, last_action : std_logic_vector(0 downto 0);
	
	constant one_b: std_logic_vector(head_p_bits-1 downto 0) := (0 => '1', others => '0');
	constant two_b: std_logic_vector(head_p_bits-1 downto 0) := (1=> '1', others => '0');
begin
	qu:
	for I in 0 to num_words - 1 generate
		qux : DataRegister port map (Dout => R(I),Enable=>En(I),Din=>write_data(I),clk=>clk, reset=>reset);
		
		write_data(I) <= tail2_reg_in when sel2(I) = '1' else
								tail_reg_in;
	end generate;
	
	head_r : DataRegister port map (Dout => head_pointer_out, Enable => head_p_en, Din => head_pointer_in, clk => clk, reset => reset);
	tail_r : DataRegister port map (Dout => tail_pointer_out, Enable => tail_p_en, Din => tail_pointer_in, clk => clk, reset => reset);

	head_reg_out <= R(to_integer(unsigned(head_pointer_out)));
	head2_reg_out <= R(to_integer(unsigned(head_p_plus_1)));
	
	process(tail_pointer_out, tail_p_plus_1, tail_p_en) is
		variable sel1_var, sel2_var : std_logic_vector(word_len - 1 downto 0) := (others => '0');
	begin
		if( tail_en(0) = '1') then
			sel1_var(to_integer(unsigned(tail_pointer_out))) := '1';
		end if;
		
		if( tail_en(1) = '1') then
			sel2_var(to_integer(unsigned(tail_p_plus_1))) := '1';
	   end if;
		
		sel1 <= sel1_var;
		sel2 <= sel2_var;
	end process;
	
	En <= sel1 or sel2;
	
	
--	write_data(to_integer(unsigned(tail_pointer_out))) <= tail_reg_in;
--	write_data(to_integer(unsigned(tail_pointer_out))+1) <= tail2_reg_in;
--	En(to_integer(unsigned(tail_pointer_out))) <= tail_en(0);
--	En(to_integer(unsigned(tail_pointer_out))+1) <= tail_en(1);
	
	head_p_plus_1 <= head_pointer_out + one_b;
	head_p_plus_2 <= head_pointer_out + two_b;
	
	head_pointer_in <= head_p_plus_2 when head_en(1) = '1' else
								head_p_plus_1;
	head_p_en <= head_en(0) or head_en(1);
	
	tail_p_plus_1 <= tail_pointer_out + one_b;
	tail_p_plus_2 <= tail_pointer_out + two_b;
	
	tail_pointer_in <= tail_p_plus_2 when tail_en(1) = '1' else
								tail_p_plus_1;
	tail_p_en <= tail_en(0) or tail_en(1);
		
	ht_eq <= '1' when head_pointer_out = tail_pointer_out else
	         '0';
	last_ac : DataRegister port map (Din=>last_action_in,Dout=>last_action,enable=>last_ac_en,clk=>clk,reset=>reset);
	
	last_action_in(0) <= tail_p_en;
	last_ac_en <= head_p_en or tail_p_en;
	
	not_empty <= ht_eq and last_action(0);
end architecture;