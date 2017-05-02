library ieee;
use ieee.std_logic_1164.all;

library work;

package fetch_components is
	component FetchStage is
		port (
			 -- From Decode stage
			new_branch_pc: in std_logic_vector(15 downto 0);
			new_branch_en: in std_logic;
		
			 -- From branch execute stage
			computed_pc: in std_logic_vector(15 downto 0);
			computed_en: in std_logic;
			
			 -- goes to FD pipeline register
			current_pc, I1, I2: out std_logic_vector(15 downto 0);
			
			-- misc
			clk, reset: in std_logic
		);	
	end component;
	
	component icache is
		PORT
		(
			address_a		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			q_a		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	end component;
	
	component BranchPredictor is
		port (
			 -- From Decode stage
			new_branch_pc: in std_logic_vector(15 downto 0);
			new_branch_en: in std_logic;
			
			 -- From branch execute stage
			computed_pc: in std_logic_vector(15 downto 0);
			computed_en: in std_logic;
			
			-- PC from register
			pc_input: in std_logic_vector(15 downto 0);
			
			-- output target pc
			target_pc: out std_logic_vector(15 downto 0);
			
			-- misc
			clk, reset: in std_logic
		);
	end component;
end package;