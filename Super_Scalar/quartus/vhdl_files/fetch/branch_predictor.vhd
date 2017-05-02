library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fetch_components.all;

entity BranchPredictor is
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
end BranchPredictor;

architecture StaticNotTaken of BranchPredictor is
begin
	target_pc <= pc_input;
end architecture;