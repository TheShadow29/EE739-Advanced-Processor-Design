library ieee;
use ieee.std_logic_1164.all;

library work;
use work.decode_components.all;

entity InstructionDecoder is
	port
	(
		instr : in std_logic_vector(15 downto 0);
		op_code : out std_logic_vector(3 downto 0);
		fo : out std_logic_vector(1 downto 0);
		fd : out std_logic_vector(1 downto 0);
		rd : out std_logic_vector(2 downto 0);
		ro1 : out std_logic_vector(2 downto 0);
		ro2 : out std_logic_vector(2 downto 0);
		nine_bit_high : out std_logic_vector(15 downto 0);
		sign_ext_imm : out std_logic_vector(15 downto 0);
		eight_bit_lm_sm : out std_logic_vector(7 downto 0);
		is_branch : out std_logic
	);
end entity;

architecture decoder of InstructionDecoder is
	signal nine_bit_high_s, nine_bit_imm_s, six_bit_imm_s : std_logic_vector(15 downto 0) := (others=>'0');
	signal op_code_s : std_logic_vector(3 downto 0);
	signal is_se_9 : std_logic;
begin
	op_code_s <= instr(15 downto 12);
	op_code <= op_code_s;
	nine_bit_high_s(15 downto 7) <= instr(8 downto 0);
	nine_bit_imm_s(7 downto 0) <= instr(7 downto 0);
	nine_bit_imm_s(15 downto 8) <= (others => instr(8));
	six_bit_imm_s(4 downto 0) <= instr(4 downto 0);
	six_bit_imm_s(15 downto 5) <= (others => instr(5));
	nine_bit_high <= nine_bit_high_s;
	sign_ext_imm <= nine_bit_imm_s when (is_se_9 = '1') else six_bit_imm_s;
	eight_bit_lm_sm <= instr(7 downto 0);
	
	fo <= instr(1 downto 0) when (op_code_s = "0000" or op_code_s = "0010") else
	      "00";
	fd <= "11" when op_code_s(3 downto 1) = "000" else -- add type
	      "01" when (op_code_s = "0010" or -- nand
			           op_code_s = "0011" or -- lhi
						  op_code_s = "0100") else -- lw
			"00";
	
	
	is_branch <= '1' when op_code_s(3) = '1' or
								 (op_code_s = "0110" and instr(7) = '1') or -- lm with r7
								 ((op_code_s = "0000" or op_code_s = "0010") and instr(5 downto 3) = "111") or -- ALU writing to r7
								 (op_code_s = "0001" and instr(8 downto 6) = "111") or -- ADI writing to r7
								 ((op_code_s = "0011" or op_code_s = "0100") and instr(11 downto 9) = "111") -- LHI/LW writing to r7
						else '0';
						
	rd <= instr(5 downto 3) when (op_code_s = "0000" or -- ADD
	                              op_code_s = "0010") else -- NDU
		   instr(8 downto 6) when  op_code_s = "0001" else -- ADI
			instr(11 downto 9) when (op_code_s = "0100" or -- LW
			                         op_code_s = "0011" or -- LHI
											 op_code_s(3 downto 2) = "10") else -- JAL/JLR
	      "000";
			
	ro1 <= instr(8 downto 6) when (op_code_s = "0100" or -- LW
											 op_code_s = "0101" or -- SW
			                         op_code_s = "0011" or -- LHI
											 op_code_s = "1001") else -- JLR
			 instr(11 downto 9); -- if instr has operands, RA is Ro1
			 
	ro2 <= instr(8 downto 6); -- all 2 operand instr will have Ro2 as RB
	
	
--	process (op_code_s, instr)
--		variable is_branch_var : std_logic;
--		variable is_se_9_var : std_logic;
--		
--		variable rd_var, ro1_var, ro2_var : std_logic_vector(2 downto 0);
--		begin
--			is_branch_var := '0';
--			is_se_9_var := '0';
--			rd_var := (others => '0');
--			ro1_var := (others => '0');
--			ro2_var := (others => '0');
--			if (op_code_s = "1000") then --jal
--				is_se_9_var:= '1';	
--			end if;
--			
--			if (op_code_s(3) = '1') then -- beq/jal/jlr
--				is_branch_var := '1';
--				ro1_var = instr(11 downto 9); -- ra
--				ro2_var = instr(8 downto 6); -- rb
--			elsif (op_code_s = "0110") then --lm
--				ro1_var = instr(11 downto 9); -- ra
--				
--				if (instr(7) = '1') then-- loading to r7
--					is_branch_var := '1';
--				end if;
--			elsif (op_code_s(3 downto 2) = "01" and not(op_code_s(3 downto 2) = "00")) then --sm
--				ro1_var = instr(11 downto 9); -- ra
--				ro2_var = instr(8 downto 6); -- rb	
--			elsif ((op_code_s(3 downto 2) = "00" or op_code_s = "0100") and instr(11 downto 9) = "111") then -- ra = r7
--				is_branch_var := '1';
--			end if;
--			is_branch <= is_branch_var;
--			is_se_9 <= is_se_9_var;
--	end process;
end architecture;