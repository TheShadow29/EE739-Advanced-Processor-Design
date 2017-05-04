library ieee;
use ieee.std_logic_1164.all;

library work;
use work.dispatch_components.all;
use work.util_components.all;

entity reservation_station is
	
	port
	(	
		--Allocate ids
		all_id1, all_id2 : in std_logic_vector(3 downto 0);
		--Operand Registers
		r11_in, r12_in, r21_in, r22_in : in std_logic_vector(2 downto 0);
		--Valid Bits
		v11_in, v12_in , v13_in, v14_in : in std_logic;
		--Source Tags of RRF
		t11_in, t12_in, t21_in, t22_in : in std_logic_vector(3 downto 0);
		--Data of Registers
		d11_in, d12_in, d21_in, d22_in : in std_logic_vector(15 downto 0);
		--rob tags
		rob_t1, rob_t2 : in std_logic_vector(3 downto 0);
		--issue id
		issue_id1, issue_id1 : in std_logic_vector(3 downto 0);
		--issue data
		d11_out, d12_out, d21_out, d22_out : out std_logic_vector(15 downto 0);
		--exec tags
		--Need 4 tags
		--exec data
		--4 data inputs
		ready_bits : out std_logic_vector(15 downto 0);
		clk, reset : std_logic
	);
end entity;

architecture rs of reservation_station is
	--Assumption RS is 16 bit entry
	type RegArray is array (natural range <>) of std_logic_vector(15 downto 0);
	type TagArray is array (natural range <>) of std_logic_vector(3 downto 0);
	type ValidArray is array (natural range <>) of std_logic_vector(0 downto 0);
	
	signal data1, data2, write_data1, write_data2: RegArray(15 downto 0);
	signal rf_tag1, rf_tag2, write_tag1, write_tag2: TagArray(15 downto 0);
	signal rob_tag, write_rob_tag : TagArray(15 downto 0);
	signal valid1, valid_new1, valid2, valid_new2: ValidArray(15 downto 0);
	
	signal en_data1, en_data2, en_tag1, en_tag2,en_rob_tag, en_valid1, en_valid2 : std_logic_vector(15 downto 0);
	signal sel_alloc_id, alloc_decoded1, alloc_decoded2 : std_logic_vector(15 downto 0);

	--	constant zeros_16b : std_logic_vector(15 downto 0) := (others => '0');
begin
	for I in 0 to 15 generate
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
				
	end generate;
	--Not sure if I should keep OE=1, everywhere
	al1_decoder : Decoder8 port map (A => all_id1, OE => '1', O => alloc_decoded1);
	al2_decoder : Decoder8 port map (A => all_id2, OE => '1', O => alloc_decoded2);
	
	sel_alloc_id <= alloc_decoded2;
 
	ready_bits <= valid1 and valid2;
	
	d11_out <= data1(to_integer(unsigned(issue_id1));
	d12_out <= data2(to_integer(unsigned(issue_id1));
	
	d21_out <= data1(to_integer(unsigned(issue_id2));
	d22_out <= data2(to_integer(unsigned(issue_id2));
	
	
	
	
	

end architecture;









