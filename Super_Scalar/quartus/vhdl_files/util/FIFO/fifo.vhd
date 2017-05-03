library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity fifo is
	generic(
		num_words	: integer := 8;
		word_length	: integer := 8);
	port(
		input	: in std_logic_vector(word_length - 1 downto 0);
		output	: out std_logic_vector(word_length - 1 downto 0);
		empty, full	: out std_logic;
		write, read, clk, reset: in std_logic);
end entity;

architecture rtl of fifo is
	constant counter_length: integer := integer(ceil(log2(real(num_words))));
	constant empty_length: integer := integer(ceil(log2(real(num_words + 1))));
	signal wr_counter, wr_counter_in: std_logic_vector(counter_length - 1 downto 0);
	signal rd_counter, rd_counter_in: std_logic_vector(counter_length - 1 downto 0); 
	signal empty_in, empty_out: std_logic_vector(empty_length - 1 downto 0); 	
	
	signal wr_ena, rd_ena, empty_ena: std_logic;
	signal wr_delayed, rd_delayed: std_logic;
	signal reg_ena : std_logic_vector(num_words - 1 downto 0);
	
	type vector is array (0 to num_words - 1) of std_logic_vector(word_length - 1 downto 0);
	signal reg_out: vector;
	
	component my_reg is
		generic ( data_width : integer);
		port(
			clk, ena, clr: in std_logic;
			Din: in std_logic_vector(data_width-1 downto 0);
			Dout: out std_logic_vector(data_width-1 downto 0));
	end component;

begin
	
	process(clk, write, read)
	begin
		if (clk'event and clk = '1') then 
			wr_delayed <= write; 
			rd_delayed <= read;
		end if;
	end process;
	wr_ena <= (not wr_delayed) and write;
	rd_ena <= ((not rd_delayed) and read) or reset or (('1' when (empty_out = std_logic_vector(to_unsigned(num_words, empty_length))) else '0') and wr_ena);
	
	empty_counter: my_reg
		generic map(empty_length)
		port map(
			clk => clk, clr => reset, ena => empty_ena,
			Din => empty_in, Dout => empty_out);
	empty_in <= empty_out when ((empty_out = std_logic_vector(to_unsigned(num_words, empty_length)) and wr_ena = '1')
		or ((empty_out = std_logic_vector(to_unsigned(0, empty_length))) and rd_ena = '1') or ((wr_ena and rd_ena) = '1')) else
		std_logic_vector(unsigned(empty_out) + to_unsigned(1, empty_length)) when (wr_ena = '1') else
		std_logic_vector(unsigned(empty_out) - to_unsigned(1, empty_length));
	empty_ena <= wr_ena or rd_ena;
		
	write_counter: my_reg
		generic map(counter_length)
		port map(
			clk => clk, clr => reset, ena => wr_ena,
			Din => wr_counter_in, Dout => wr_counter);
	wr_counter_in <= std_logic_vector(unsigned(wr_counter) + to_unsigned(1, counter_length));
	
	read_counter: my_reg
		generic map(counter_length)
		port map(
			clk => clk, clr => '0', ena => rd_ena,
			Din => rd_counter_in, Dout => rd_counter);
	rd_counter_in <= std_logic_vector(to_unsigned(num_words - 1, counter_length)) when (reset = '1') 
		else std_logic_vector(unsigned(rd_counter) + to_unsigned(1, counter_length));
		
	memory:
	for i in 0 to num_words - 1 generate
		REGX: my_reg
			generic map(word_length)
			port map(
				clk => clk, clr => reset, ena => reg_ena(i),
				Din => input, Dout => reg_out(i));
	end generate;
	
	process(wr_counter, wr_delayed, write)
	begin
		reg_ena <= (others => '0');
		if( ((not wr_delayed) and write) = '1') then
			reg_ena(to_integer(unsigned(wr_counter))) <= '1';
		end if;
	end process;
	
	output <= reg_out(to_integer(unsigned(rd_counter)));
	empty <= '1' when (empty_out = std_logic_vector(to_unsigned(0, empty_length))) else '0';
	full <= '1' when (empty_out = std_logic_vector(to_unsigned(num_words, empty_length))) else '0';
	
end architecture;

-- library ieee;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_1164.all;

-- entity control_fifo is

-- end entity;

-- architecture control_path of control_fifo is

-- end architecture;

-- library ieee;
-- use ieee.numeric_std.all;
-- use ieee.std_logic_1164.all;

-- entity data_fifo is
	-- generic(
		-- num_words	: integer := 8;
		-- word_length	: integer := 8);
	-- port(
		-- write)
-- end entity;

-- architecture data_path of data_fifo is

-- end architecture;