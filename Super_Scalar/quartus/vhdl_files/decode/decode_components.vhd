library ieee;
use ieee.std_logic_1164.all;

library work;

package decode_components is
	component InstructionDecoder is
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
	end component;
	
	component DecodeStage is
		port (
			I1, I2: in std_logic_vector(15 downto 0);
			
			pc, pc_p1: in std_logic_vector(15 downto 0);
			
			LHI_imm1, LHI_imm2, imm1, imm2: out std_logic_vector(15 downto 0);
			LMSM_imm1, LMSM_imm2: out std_logic_vector(7 downto 0); 
			
			new_branch_pc: out std_logic_vector(15 downto 0);
			new_branch_en: out std_logic;
			
			draw1, draw2, dwaw: out std_logic;
			fraw, fwaw: out std_logic_vector(1 downto 0)
		);
	end component;
end package;
