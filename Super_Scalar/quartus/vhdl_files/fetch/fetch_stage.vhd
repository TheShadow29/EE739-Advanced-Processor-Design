library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.ALL;
use ieee.numeric_std.all;

library work;
use work.fetch_components.all;
use work.util_components.all;


entity FetchStage is
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
end FetchStage;

architecture Behaviour of FetchStage is
	signal target_pc, target_pc_p1, 
	       pc_dout, pc_din: 
			 std_logic_vector(15 downto 0) := (others => '0');
			 
	constant one_16b: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
	constant two_16b: std_logic_vector(15 downto 0) := (1 => '1', others => '0');
begin

target_pc_p1 <= target_pc + one_16b;
pc_din <= target_pc + two_16b;

current_pc <= target_pc;

icache_fetch: icache port map (
						address_a => target_pc,
						address_b => target_pc_p1,
						clock => clk,
						q_a => I1,
						q_b => I2
					);
						
pc_reg: DataRegister port map (
				Din => pc_din,
				Dout => pc_dout,
				enable => '1',
				clk => clk,
				reset => reset
			);
			
bp: BranchPredictor port map (
			new_branch_pc => new_branch_pc,
			new_branch_en => new_branch_en,
			
			computed_pc => computed_pc,
			computed_en => computed_en,
			
			pc_input => pc_dout,
			target_pc => target_pc,
			
			clk => clk,
			reset => reset
		);
end architecture;