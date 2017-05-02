library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all_components.all;

entity history_block_single is
   port
		(
			pc_br: in std_logic_vector(15 downto 0);
			br_d, clk, reset, wen, BEQ: in std_logic;
			pc_in : in std_logic_vector(15 downto 0);
			write_data : in std_logic_vector(32 downto 0);			
			occ, mru, br_match, in_match: out std_logic := '0';
			
			h_mismatch : out std_logic := '0';
			br_en : out std_logic := '0';
			pc_out : out std_logic_vector(15 downto 0) := (others => '0')
		);
end entity;

architecture Parallel of history_block_single is
	signal h_match, pc_br_match, pc_in_match, wen_tmp, br_en_tmp: std_logic := '0';
	
	-- Registered signals
	signal hist_entry_in, hist_entry_out :std_logic_vector(32 downto 0) := (others => '0');
	signal hb_in, hb_out, mru_in, mru_out : std_logic_vector(0 downto 0);
begin
	hist_entry_in <= write_data;
	wen_tmp <= wen and BEQ;
	hist_entry: DataRegister port map
		(
			Din => hist_entry_in,
			Dout => hist_entry_out,
			clk => clk,
			reset => reset,
			enable => wen_tmp
		);
		
	hb_entry: DataRegister port map
		(
			Din => hb_in,
			Dout => hb_out,
			clk => clk,
			reset => reset,
			enable => BEQ
		);
		
	mru_entry: DataRegister port map
		(
			Din => mru_in,
			Dout => mru_out,
			clk => clk,
			reset => reset,
			enable => BEQ
		);
		
	h_match <= not(br_d xor hb_out(0));
	pc_br_match <= '1' when pc_br = hist_entry_out(31 downto 16) else '0';
	pc_in_match <= '1' when pc_in = hist_entry_out(31 downto 16) else '0';
	
	h_mismatch <= not(h_match) and pc_br_match;
	br_en_tmp <= hb_out(0) and pc_in_match;
	br_en <= br_en_tmp;
	
	pc_out <= hist_entry_out(15 downto 0) when br_en_tmp = '1' else (others => '0');
	
	occ <= hist_entry_out(32);
	mru <= mru_out(0);
	mru_in(0) <= pc_br_match or pc_in_match;
	hb_in(0) <= br_d;
	
	br_match <= pc_br_match;
	in_match <= pc_in_match;
end Parallel;

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all_components.all;

entity history_block_parallel is
	generic ( size : integer );
	port (
		pc_br, pc_br_next: in std_logic_vector(15 downto 0);
		br_d, clk, reset, BEQ: in std_logic;
		pc_in : in std_logic_vector(15 downto 0);
		
		stall_hist : out std_logic := '0';
		br_en : out std_logic := '0';
		pc_out : out std_logic_vector(15 downto 0) := (others => '0')
	);
end entity;

architecture Parallel of history_block_parallel is
	signal write_data : std_logic_vector(32 downto 0);
	
	--signal pc_out_tmp : std_logic_vector(15 downto 0);
	signal occ_array, mru_array, wen_array,
	       br_en_array, h_mismatch_array, br_match_array, in_match_array: std_logic_vector(size-1 downto 0) := (others => '0');
	type pc_out_array is array (size-1 downto 0) of std_logic_vector(15 downto 0);
	
	signal br_match_any, in_match_any, occ_all, h_mismatch_all : std_logic;
	
	signal pc_out_arr, pc_out_tmp: pc_out_array := (others => (others => '0'));
begin 
   write_data(32) <= '1'; -- Occ 
	write_data(31 downto 16) <= pc_br;
	write_data(15 downto 0) <= pc_br_next;
	
	h_entries:
	for i in size-1 downto 0 generate
		h_entryX : history_block_single port map (
				pc_br => pc_br,
				br_d => br_d,
				clk => clk,
				reset => reset,
				BEQ => BEQ,
				pc_in => pc_in,
				write_data => write_data,
				wen => wen_array(i),
				
				occ => occ_array(i),
				mru => mru_array(i),
				br_match => br_match_array(i),
				in_match => in_match_array(i),
				
				h_mismatch => h_mismatch_array(i),
				br_en => br_en_array(i),
				pc_out => pc_out_arr(i)
			);
	end generate;
	
--	match_any <= '0' when match_array = 0 else '1';
--	occ_all <= '1' when not occ_array = 0 else '0';
--	
--	br_en <= '0' when br_en_array = 0 else '1';
--	stall_hist <= '0' when stall_hist_array = 0 else '1';
--	
   br_match_u_or : unary_OR generic map(N=>size) port map(inp=>br_match_array, outp=>br_match_any);
   in_match_u_or : unary_OR generic map(N=>size) port map(inp=>in_match_array, outp=>in_match_any);
   occ_u_and : unary_AND generic map(N=>size) port map(inp=>occ_array, outp=>occ_all);
   br_en_u_or : unary_OR generic map(N=>size) port map(inp=>br_en_array, outp=>br_en);
   h_mismatch_u_or : unary_OR generic map(N=>size) port map(inp=>h_mismatch_array, outp=>h_mismatch_all);
	
	stall_hist <= br_d when br_match_any = '0' and BEQ = '1' else
	              '1' when h_mismatch_all = '1' and br_match_any = '1' and BEQ = '1' else
					  '0';
	
	pc_out_gen:
	for i in size-1 downto 1 generate
		pc_out_tmp(i-1) <= pc_out_tmp(i) or pc_out_arr(i);
	end generate;
	pc_out <= pc_out_tmp(0) or pc_out_arr(0);
	
	process(BEQ, br_match_any, occ_array, occ_all, mru_array)
		variable wen_array_tmp : std_logic_vector(size-1 downto 0) := (others => '0');
	begin
		wen_array_tmp := (others => '0');
		if(br_match_any = '0' and BEQ = '1') then
			for i in size-1 downto 0 loop
				if(occ_array(i) = '0' or (occ_all = '1' and mru_array(i) = '0')) then
					wen_array_tmp(i) := '1';
					exit;
				end if;
			end loop;
		end if;
		wen_array <= wen_array_tmp;
	end process;
end architecture;
