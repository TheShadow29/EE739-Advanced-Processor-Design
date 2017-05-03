library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity testbench is
end entity;

architecture test of testbench is 
	component fifo is
		generic(
			num_words	: integer := 8;
			word_length	: integer := 8);
		port(
			input	: in std_logic_vector(word_length - 1 downto 0);
			output	: out std_logic_vector(word_length - 1 downto 0);
			empty, full	: out std_logic;
			write, read, clk, reset: in std_logic);
	end component;
	signal input, output: std_logic_vector(7 downto 0);
	signal empty, full, write, read, clk, reset : std_logic;
begin
	inst: fifo
		port map(
			input => input, output => output,
			empty => empty, full => full, write => write,
			read => read, clk => clk, reset => reset);
	
	clock: process
	begin
		clk <= '0';
		wait for 1 ns;
		clk <= '1';
		wait for 1 ns;
	end process;
	
	main: process
	begin
		read <= '0'; 
		input <= (others => '0');
		reset <= '1';
		write <= '0';
		wait until clk = '1';
		wait until clk = '1';
		reset <= '0';

		input <= std_logic_vector(to_unsigned(1, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(2, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(3, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(4, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(5, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(6, 8));
		read <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(7, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		input <= std_logic_vector(to_unsigned(8, 8));
		write <= '1';
		wait until clk = '1';
		write <= '0';
		wait until clk = '1';
		wait;
	end process;
end architecture;