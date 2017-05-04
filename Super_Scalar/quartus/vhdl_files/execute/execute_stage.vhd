library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dispatch_components.all;
use work.util_components.all;

entity execute_stage is
	port
	(
		rs11, rs12, rs21, rs22, rs31, rs32 : in std_logic_vector(15 downto 0);
		rrf_tag1_in, rrf_tag2_in, rrf_tag3_in : in std_logic_vector(3 downto 0);
		rrf_tag1_out, rrf_tag2_out, rrf_tag3_out : out std_logic_vector(3 downto 0);
		rob_tag1_in, rob_tag2_in, rob_tag3_in : in std_logic_vector(3 downto 0);
		rob_tag1_out, rob_tag2_out, rob_tag3_out : out std_logic_vector(3 downto 0);
		d1, d2, d3 : out std_logic_vector(15 downto 0);
		op1 , op2, op3 : in std_logic;
		c1, c2, c3, z1, z2, z3 : out std_logic;
--		enc1, enc2, enc3, enz1, enz2, enz3 : std_logic;
		is_lhi : in std_logic;
		is_beq : in std_logic;
		is_lw : in std_logic;
		mem_w_bit : in std_logic;
		inv_bits_ld_in : in std_logic_vector(2 downto 0);
		inv_bits_ld_out : out std_logic_vector(2 downto 0);
		data_store : in std_logic_vector(15 downto 0);
		pipe_en : in std_logic;
--		is_store : in std_logic;
		clk, reset : in std_logic
		
	);
end entity;

architecture execution of execute_stage is
--	signal pipeline_signals : std_logic_vector(;
	signal mem_addr_in ,mem_addr_in_tmp, mem_addr_out: std_logic_vector(15 downto 0);
	signal mem_w_in, mem_w_out: std_logic_vector(0 downto 0);
	signal con_sig_in, con_sig_out : std_logic_vector(2 downto 0);
	signal z3_tmp,c3_tmp : std_logic;
	constant all_z : std_logic_vector(15 downto 0) := (others => '0');
	signal d3_tmp : std_logic_vector(15 downto 0);
begin
	A1 : alu port map (X => rs11, Y => rs12, out_p => d1, C => c1, Z => z1, 
				op_code => op1, do_xor => '0');
	rob_tag1_out <= rob_tag1_in;
	rrf_tag1_out <= rrf_tag1_in;
	A2 : alu port map (X => rs21, Y => rs22, out_p => d2, C => c2, Z => z2, 
				op_code => op2, do_xor => is_beq);
	rob_tag2_out <= rob_tag2_in;
	rrf_tag2_out <= rrf_tag2_in;
	A3 : alu port map (X => rs31, Y => rs32, out_p => mem_addr_in_tmp, C => c3_tmp, Z => z3_tmp, 
				op_code => op3, do_xor => '0'	);
				
	mem_addr_in <= mem_addr_in_tmp when (is_lhi = '0') else rs32;
	mem_w_in(0) <= '1' when (mem_w_bit = '1') else '0';
	con_sig_in(0) <= is_lw;
	
	con_sig : DataRegister port map (Dout => con_sig_out,Enable=>pipe_en,Din=> con_sig_in,clk=>clk, reset=>reset);
	mem_addr : DataRegister port map (Dout => mem_addr_out,Enable=>pipe_en,Din=> mem_addr_in,clk=>clk, reset=>reset);
	memw : DataRegister port map (Dout => mem_w_out,Enable=>pipe_en,Din=> mem_w_in,clk=>clk, reset=>reset);
	rob_reg : DataRegister port map (Dout => rob_tag3_out, Enable => pipe_en, Din => rob_tag3_in, clk=> clk, reset => reset);
	rrf_reg : DataRegister port map (Dout => rrf_tag3_out, Enable => pipe_en, Din => rrf_tag3_in, clk=> clk, reset => reset);
	inv_bits : DataRegister port map (Dout => inv_bits_ld_out, Enable =>pipe_en, Din => inv_bits_ld_in, clk => clk, reset => reset);
	D_cache_inst : 
		D_cache PORT MAP (
			aclr	 => reset,
			address	 => mem_addr_out(11 downto 0),
			clock	 => clk,
			data	 => data_store,
			wren	 => mem_w_out(0),
			q	 => d3_tmp
		);
	z3 <= '1' when (d3_tmp = all_z) else '0';
	c3 <= '0';
	d3 <= d3_tmp;
	
	
	
end architecture;







