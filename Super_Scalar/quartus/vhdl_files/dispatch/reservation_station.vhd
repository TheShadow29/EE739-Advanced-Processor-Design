library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dispatch_components.all;
use work.util_components.all;

entity reservation_station is
	
	port
	(	
		--Allocate ids
		all_id1, all_id2 : in std_logic_vector(2 downto 0);
		--Operand Registers
		r11_in, r12_in, r21_in, r22_in : in std_logic_vector(2 downto 0);
		--write enables to RS
		wen_rs_1,wen_rs_2 : in std_logic;
		--out to alloc queue
		num_entr_used : out std_logic_vector(1 downto 0);
		num_entr_freed : out std_logic_vector(1 downto 0);
		--freed entries
		addr_freed_to_alloc_id1, addr_freed_to_alloc_id2 : out std_logic_vector(4 downto 0);
		--Valid Bits
		v11_in, v12_in , v21_in, v22_in : in std_logic;
		--Source Tags of RRF
		t11_in, t12_in, t21_in, t22_in : in std_logic_vector(3 downto 0);
		--Data of Registers
		d11_in, d12_in, d21_in, d22_in : in std_logic_vector(15 downto 0);
		--rob tags
		rob_t1, rob_t2 : in std_logic_vector(3 downto 0);

		--issue data
		d1_out, d2_out: out std_logic_vector(15 downto 0);
		--issue validity
		v1_out : out std_logic;
		--exec tags
		exec_rrf_t1 : in std_logic_vector(3 downto 0);
		--exec data
		exec_rrf_d1 : in std_logic_vector(15 downto 0);
		--exec enable
		exec_en : in std_logic;
--		ready_bits : out std_logic_vector(4 downto 0);
		is_load_store : in std_logic;
		clk, reset : std_logic
	);
end entity;

architecture rs of reservation_station is
	--Assumption RS is 16 bit entry
	type RegArray is array (natural range <>) of std_logic_vector(15 downto 0);
	type TagArray is array (natural range <>) of std_logic_vector(3 downto 0);
	type ValidArray is array (natural range <>) of std_logic_vector(0 downto 0);
	
	signal data1, data2, write_data1, write_data2: RegArray(4 downto 0);
	signal rf_tag1, rf_tag2, write_tag1, write_tag2: TagArray(4 downto 0);
	signal rob_tag, write_rob_tag : TagArray(4 downto 0);
	signal valid1, valid_new1, valid2, valid_new2: ValidArray(4 downto 0);
	
	signal en_data1, en_data2, en_tag1, en_tag2,en_rob_tag, en_valid1, en_valid2 : std_logic_vector(15 downto 0);
	signal sel_alloc_id, alloc_decoded1, alloc_decoded2 : std_logic_vector(7 downto 0);

	signal exec_rrf_t1_decoded : std_logic_vector(15 downto 0);
	signal issue_id1 : std_logic_vector(2 downto 0);
	signal ready_bits : std_logic_vector(4 downto 0);
	
	signal d1_out_not_ls, d2_out_not_ls, 
			d1_out_ls, d2_out_ls: std_logic_vector(15 downto 0);
	signal v1_out_ls, v1_out_not_ls : std_logic;
	--	constant zeros_16b : std_logic_vector(15 downto 0) := (others => '0');
begin
	ResStat:
	for I in 0 to 4 generate
		rs_data1x : DataRegister port map (Dout => data1(I), Enable => en_data1(I), Din => write_data1(I),clk => clk, reset => reset);
		rs_data2x : DataRegister port map (Dout => data2(I), Enable => en_data2(I), Din => write_data2(I),clk => clk, reset => reset);		
	
		rs_rf_tag1x : DataRegister port map (Dout => rf_tag1(I), Enable => en_tag1(I), Din => write_tag1(I),clk => clk, reset => reset);
		rs_rf_tag2x : DataRegister port map (Dout => rf_tag2(I), Enable => en_tag2(I), Din => write_tag2(I),clk => clk, reset => reset);
		
		rs_rob_tag : DataRegister port map (Dout => rob_tag(I), Enable => en_rob_tag(I), Din => write_rob_tag(I), clk => clk, reset => reset);
				
		rs_val1x : DataRegister port map (Dout => valid1(I), Enable => en_valid1(I), Din => valid_new1(I),clk => clk, reset => reset);
		rs_val2x : DataRegister port map (Dout => valid2(I), Enable => en_valid2(I), Din => valid_new2(I),clk => clk, reset => reset);
	
		--Need to see the following facts : 
			-- writedata <= according to which one it is, 
				--need to see both from exec units as well as alloc, with prefernce to alloc
			-- valid bit <= if both operands are valid
			-- ready bit <= valid(0) and valid(1)
			-- tag data <= needs to be updated only once in the start
		en_data1(I) <= '1' when (rf_tag1(I) = exec_rrf_t1 and exec_en = '1') else
							'1' when (alloc_decoded1(I) = '1' or alloc_decoded2(I) = '1') else 
							'0';
		en_data2(I) <= '1' when (rf_tag2(I) = exec_rrf_t1 and exec_en = '1') else
							'1' when (alloc_decoded2(I) = '1' or alloc_decoded2(I) = '1') else 
							'0';
		write_data1(I) <= exec_rrf_d1 when (rf_tag1(I) = exec_rrf_t1 and exec_en = '1') else
								d11_in when (alloc_decoded1(I) = '1') else
								d21_in;
		write_data2(I) <= exec_rrf_d1 when (rf_tag2(I) = exec_rrf_t1 and exec_en = '1') else
								d12_in when (alloc_decoded1(I) = '1') else
								d22_in;
								
		write_tag1(I) <= t11_in when (alloc_decoded1(I) = '1') else
								t21_in;
		write_tag2(I) <= t12_in when (alloc_decoded1(I) = '1') else
								t22_in;
		write_rob_tag(I) <= rob_t1 when (alloc_decoded1(I) = '1') else
									rob_t2;
									
								
		valid_new1(I)(0) <= '1' when (rf_tag1(I) = exec_rrf_t1 and exec_en = '1') else 
							v11_in when (alloc_decoded1(I) = '1') else
							v21_in when (alloc_decoded2(I) = '1') else
							'0';
		valid_new2(I)(0) <= '1' when (rf_tag2(I) = exec_rrf_t1 and exec_en = '1') else 
							v12_in when (alloc_decoded1(I) = '1') else
							v21_in when (alloc_decoded2(I) = '1') else
							'0';
		en_valid1(I) <= '1' when (rf_tag1(I) = exec_rrf_t1 and exec_en = '1') else
					'1' when (alloc_decoded1(I) = '1' or alloc_decoded2(I) = '1') else 
					'0';
		en_valid2(I) <= '1' when (rf_tag2(I) = exec_rrf_t1 and exec_en = '1') else
					'1' when (alloc_decoded2(I) = '1' or alloc_decoded2(I) = '1') else 
					'0';							
	end generate;
	
	en_tag1 <= alloc_decoded1 or alloc_decoded2;
	en_tag2 <= alloc_decoded1 or alloc_decoded2;
	en_rob_tag <= alloc_decoded1 or alloc_decoded2;

	--Not sure if I should keep OE=1, everywhere
	al1_decoder : Decoder8 port map (A => all_id1, OE => wen_rs_1, O => alloc_decoded1);
	al2_decoder : Decoder8 port map (A => all_id2, OE => wen_rs_2, O => alloc_decoded2);
	exec_rrf_t1_decoder : Decoder8 port map (A => exec_rrf_t1, OE => exec_en, O => exec_rrf_t1_decoded);
	
--	sel_alloc_id <= alloc_decoded1;
	en_data1 <= alloc_decoded1;
	en_data2 <= alloc_decoded2;
	 
	ready_bits <= valid1(4 downto 0)(0) and valid2(4 downto 0)(0);
	
	d1_out_not_ls <= data1(0) when ready_bits(0) = '1' else
				data1(1) when ready_bits(1) = '1' else
				data1(2) when ready_bits(2) = '1' else
				data1(3) when ready_bits(3) = '1' else
				data1(4);
	d2_out_not_ls <= data2(0) when ready_bits(0) = '1' else
				data2(1) when ready_bits(1) = '1' else
				data2(2) when ready_bits(2) = '1' else
				data2(3) when ready_bits(3) = '1' else
				data2(4);
				
	v1_out_not_ls <= ready_bits(0) or ready_bits(1) or ready_bits(2) or ready_bits(3) or ready_bits(4);
	
	d1_out_ls <= data1(0);
	d2_out_ls <= data2(0);
	v1_out_ls <= ready_bits(0);
	
	d1_out <= d1_out_ls when is_load_store = '1' else d1_out_not_ls;
	d2_out <= d2_out_ls when is_load_store = '1' else d2_out_not_ls;
	v1_out <= v1_out_ls when is_load_store = '1' else v1_out_not_ls;
--	v2_out <= 
	
	
	
--	d1_out <= data1(to_integer(unsigned(issue_id1)));
--	d2_out <= data2(to_integer(unsigned(issue_id1)));
	


end architecture;









