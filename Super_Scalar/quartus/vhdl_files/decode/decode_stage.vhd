library ieee;
use ieee.std_logic_1164.all;

library work;
use work.decode_components.all;
use work.util_components.all;


entity DecodeStage is
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
end entity;

architecture Behave of DecodeStage is
	signal r1d, r1o1, r1o2, 
	       r2d, r2o1, r2o2 : std_logic_vector(2 downto 0);
	
	signal op1, op2 : std_logic_vector(3 downto 0);
	
	signal fo1, fo2, fd1, fd2: std_logic_vector(1 downto 0);	
	
	signal b1,b2 : std_logic;
begin
i1_decoder: InstructionDecoder port map (
					instr => I1,
					rd => r1d,
					ro1 => r1o1,
					ro2 => r1o2,
					
					op_code => op1,
					fo => fo1,
					fd => fd1,
					
					nine_bit_high => LHI_imm1,
					sign_ext_imm => imm1,
					eight_bit_lm_sm => LMSM_imm1,
					is_branch => b1
				);
				
i2_decoder: InstructionDecoder port map (
					instr => I2,
					rd => r2d,
					ro1 => r2o1,
					ro2 => r2o2,
					
					op_code => op2,
					fo => fo2,
					fd => fd2,
					
					nine_bit_high => LHI_imm2,
					sign_ext_imm => imm2,
					eight_bit_lm_sm => LMSM_imm2,
					is_branch => b2
				);
				
new_branch_en <= b1 or b2;
new_branch_pc <= pc_p1 when b2 = '1' else
                 pc when b1 = '1' else
					  (others => '0');
					  
draw1 <= '1' when r1d = r2o1 else
         '0';
			
draw2 <= '1' when r1d = r2o2 else
         '0';
			
dwaw <= '1' when r1d = r2d else
		  '0';

fwaw(1) <= fd1(1) xnor fd2(1);
fwaw(0) <= fd1(0) xnor fd2(0);

fraw(1) <= fd1(1) xnor fo2(1);
fraw(0) <= fd1(0) xnor fo2(0);
end architecture;