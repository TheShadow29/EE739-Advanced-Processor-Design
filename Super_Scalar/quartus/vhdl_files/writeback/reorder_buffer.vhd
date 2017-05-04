library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all ;

library work;
use work.util_components.all;
use work.writeback_components.all;

entity ReorderBuffer is
	port (
		-- Finished from exec
		exec1_pos, exec2_pos, exec3_pos: in std_logic_vector(3 downto 0);
		--exec1_data, exec2_data, exec3_data: in std_logic_vector(15 downto 0);
		wen1, wen2, wen3: std_logic;
		
		-- Broadcast to RS
		bc_tag1, bc_tag2, bc_tag3: out std_logic_vector(3 downto 0);
		bc1, bc2, bc3: out std_logic;
		
		-- Assigned from dispatch
		pc1, pc2: in std_logic_vector(15 downto 0);
		rd1, rd2: in std_logic_vector(2 downto 0);
		tag1, tag2: in std_logic_vector(3 downto 0);
		den1, den2,
		assgn1, assgn2: in std_logic;
		
		pos1, pos2: out std_logic_vector(3 downto 0);
		
		-- Tell WB what we are removing
		rm1, rm2: out std_logic;
		
		clk, reset: in std_logic
	);
end entity;

architecture Behave of ReorderBuffer is
	-- 23 -> finished
	-- 22 to 7 -> PC
	-- 6 to 4 -> RD
	-- 3 to 0 -> tag
	type pc_array is array (natural range <>) of std_logic_vector(15 downto 0);
	type rd_array is array (natural range <>) of std_logic_vector(2 downto 0);
	type tag_array is array (natural range <>) of std_logic_vector(3 downto 0);
	type fin_array is array (natural range <>) of std_logic_vector(0 downto 0);
	
	signal PC,PCWrite : pc_array(15 downto 0);
	signal RD,RDWrite : rd_array(2 downto 0);
	signal Tag,TagWrite : tag_array(3 downto 0);
	signal Finish,FinishWrite,Den,DenWrite: fin_array(0 downto 0);
	
	signal pc_en, rd_en, tag_en, fin_en,
			 sel_row1, sel_row2, sel_fin1, sel_fin2, sel_fin3: std_logic_vector(15 downto 0);
	
	signal head_pointer_out, tail_pointer_out, head_pointer_in, tail_pointer_in : std_logic_vector(3 downto 0);
	signal head_p_plus_1, head_p_plus_2, tail_p_plus_1, tail_p_plus_2 : std_logic_vector(3 downto 0);
	signal head_p_en, tail_p_en, top_fin1, top_fin2 : std_logic;
	
	constant one_b: std_logic_vector(3 downto 0) := (0 => '1', others => '0');
	constant two_b: std_logic_vector(3 downto 0) := (1=> '1', others => '0');
begin
	qu:
	for I in 0 to 15 generate
		pcx : DataRegister port map (Dout => PC(I),Enable=>pc_en(I),Din=>PCWrite(I),clk=>clk, reset=>reset);
		rdx : DataRegister port map (Dout => RD(I),Enable=>rd_en(I),Din=>RDWrite(I),clk=>clk, reset=>reset);
		tagx : DataRegister port map (Dout => Tag(I),Enable=>tag_en(I),Din=>TagWrite(I),clk=>clk, reset=>reset);
		denx : DataRegister port map (Dout => Den(I),Enable=>tag_en(I),Din=>DenWrite(I),clk=>clk, reset=>reset);
		finx : DataRegister port map (Dout => Finish(I),Enable=>fin_en(I),Din=>FinishWrite(I),clk=>clk, reset=>reset);
		
		PCWrite(I) <= pc2 when sel_row2(I) = '1' else
						  pc1;
					
		RDWrite(I) <= rd2 when sel_row2(I) = '1' else
						  rd1;
		
		TagWrite(I) <= tag2 when sel_row2(I) = '1' else
							tag1;
					 
		DenWrite(I)(0) <= den2 when sel_row2(I) = '1' else
								den1;
		
					 
		FinishWrite(I) <= "1";
				
	end generate;
	
	head_r : DataRegister port map (Dout => head_pointer_out, Enable => head_p_en, Din => head_pointer_in, clk => clk, reset => reset);
	tail_r : DataRegister port map (Dout => tail_pointer_out, Enable => tail_p_en, Din => tail_pointer_in, clk => clk, reset => reset);

	pos1 <= head_pointer_out;
	pos2 <= head_p_plus_1;
	
	sel_row1_decoder: Decoder16 port map (A => head_pointer_out, OE => assgn1, O => sel_row1);
	sel_row2_decoder: Decoder16 port map (A => head_p_plus_1, OE => assgn2, O => sel_row2);
	
	sel_fin1_decoder: Decoder16 port map (A => exec1_pos, OE => wen1, O => sel_fin1);
	sel_fin2_decoder: Decoder16 port map (A => exec2_pos, OE => wen2, O => sel_fin2);
	sel_fin3_decoder: Decoder16 port map (A => exec3_pos, OE => wen3, O => sel_fin3);
	
	pc_en <= sel_row1 or sel_row2;
	rd_en <= sel_row1 or sel_row2;
	tag_en <= sel_row1 or sel_row2;
	fin_en <= sel_fin1 or sel_fin2 or sel_fin3;
	
	bc_tag1 <= Tag(to_integer(unsigned(exec1_pos)));
	bc_tag2 <= Tag(to_integer(unsigned(exec2_pos)));
	bc_tag3 <= Tag(to_integer(unsigned(exec3_pos)));
	bc1 <= Den(to_integer(unsigned(exec1_pos)))(0) and wen1;
	bc2 <= Den(to_integer(unsigned(exec2_pos)))(0) and wen2;
	bc3 <= Den(to_integer(unsigned(exec3_pos)))(0) and wen3;
	
--	write_data(to_integer(unsigned(tail_pointer_out)) <= tail_reg_in;
--	write_data(to_integer(unsigned(tail_pointer_out))+1) <= tail2_reg_in;
--	En(to_integer(unsigned(tail_pointer_out)) <= tail_en(0);
--	En(to_integer(unsigned(tail_pointer_out))+1) <= tail_en(1);
--	
	head_p_plus_1 <= head_pointer_out + one_b;
	head_p_plus_2 <= head_pointer_out + two_b;
	
	top_fin1 <= Finish(to_integer(unsigned(head_pointer_out)))(0);
	top_fin2 <= Finish(to_integer(unsigned(head_p_plus_1)))(0);
	
	rm1 <= top_fin1;
	rm2 <= top_fin2 and top_fin2;
	
	head_pointer_in <= head_p_plus_2 when top_fin2 = '1' and top_fin1 = '1' else
							 head_p_plus_1;
	head_p_en <= top_fin1 or top_fin2;
	
	tail_p_plus_1 <= tail_pointer_out + one_b;
	tail_p_plus_2 <= tail_pointer_out + two_b;
	
	tail_pointer_in <= tail_p_plus_2 when assgn2 = '1' else
							 tail_p_plus_1;
	tail_p_en <= assgn2 or assgn1;

end architecture;