library ieee;
use ieee.std_logic_1164.all;

library work;
use work.all_components.all;

entity instruction_decoder is
	port
	(
		ir_out : in std_logic_vector(15 downto 0);
		op_code : out std_logic_vector(3 downto 0);
		condition_code : out std_logic_vector(1 downto 0);
		ra : out std_logic_vector(2 downto 0);
		rb : out std_logic_vector(2 downto 0);
		rc : out std_logic_vector(2 downto 0);
		nine_bit_high : out std_logic_vector(15 downto 0);
		sign_ext_imm : out std_logic_vector(15 downto 0);
		eight_bit_lm_sm : out std_logic_vector(7 downto 0);
		is_lhi : out std_logic;
		is_jal : out std_logic;
		is_lm_sm : out std_logic
	);
end entity;

architecture decoder of instruction_decoder is
	signal nine_bit_high_s, nine_bit_imm_s, six_bit_imm_s : std_logic_vector(15 downto 0) := (others=>'0');
	signal op_code_s : std_logic_vector(3 downto 0);
	signal is_se_9 : std_logic;
begin
	op_code_s <= ir_out(15 downto 12);
	op_code <= op_code_s;
	condition_code <= ir_out(1 downto 0);
	ra<=ir_out(11 downto 9);
	rb<=ir_out(8 downto 6);
	rc<=ir_out(5 downto 3);
	nine_bit_high_s(15 downto 7) <= ir_out(8 downto 0);
	nine_bit_imm_s(7 downto 0) <= ir_out(7 downto 0);
	nine_bit_imm_s(15 downto 8) <= (others => ir_out(8));
	six_bit_imm_s(4 downto 0) <= ir_out(4 downto 0);
	six_bit_imm_s(15 downto 5) <= (others => ir_out(5));
	nine_bit_high <= nine_bit_high_s;
	sign_ext_imm <= nine_bit_imm_s when (is_se_9 = '1') else six_bit_imm_s;
	eight_bit_lm_sm <= ir_out(7 downto 0);
	
	process (op_code_s)
		variable is_jal_var : std_logic;
		variable is_lhi_var : std_logic;
		variable is_lm_sm_var : std_logic;
		variable is_se_9_var : std_logic;
		begin
			is_jal_var := '0';
			is_lhi_var := '0';
			is_lm_sm_var := '0';
			is_se_9_var := '0';
			if (op_code_s = "1000") then --jal
				is_se_9_var:= '1';
				is_jal_var := '1';
			elsif (op_code_s = "0011") then --lhi
				is_lhi_var := '1';
			elsif (op_code_s = "0110" or op_code_s = "0111") then --lm/sm
				is_lm_sm_var := '1';
			end if;
			is_jal <= is_jal_var;
			is_lhi <= is_lhi_var;
			is_lm_sm <= is_lm_sm_var;
			is_se_9 <= is_se_9_var;
	end process;
end architecture;