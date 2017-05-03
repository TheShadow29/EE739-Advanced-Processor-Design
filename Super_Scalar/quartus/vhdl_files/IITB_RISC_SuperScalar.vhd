library ieee;
use ieee.std_logic_1164.all;

library work;
use work.util_components.all;
use work.fetch_components.all;
use work.decode_components.all;


entity IITB_RISC_SuperScalar is
	port
	(
		clk, reset, start : in std_logic;
		done : out std_logic
	);
end entity;

architecture pipe of IITB_RISC_SuperScalar is
	signal clk_slow : std_logic := '0';
	
	signal new_branch_pc, computed_pc : std_logic_vector(15 downto 0);
	signal new_branch_en, computed_en : std_logic;
	
	-- FD pipeline signals
	signal current_pc_in, current_pc_p1_in, current_pc_out, current_pc_p1_out,
	       I1_in, I2_in, I1_out, I2_out, pc_in, pc_out, pc_p1_in, pc_p1_out: std_logic_vector(15 downto 0);
			 
   -- DDs pipeline signals
	signal LHI_imm1_in, LHI_imm1_out, LHI_imm2_in, LHI_imm2_out,
	       imm1_in, imm2_in, imm1_out, imm2_out: std_logic_vector(15 downto 0);
	signal LMSM_imm1_in, LMSM_imm1_out, LMSM_imm2_in, LMSM_imm2_out : std_logic_vector(7 downto 0);
	signal interdependency_in, interdependency_out: std_logic_vector(6 downto 0);
		
		
	signal fd_pipeline_en, dds_pipeline_en : std_logic := '1';
begin
--	process(clk)
--	begin
--		if(clk'event and clk = '0') then 
--			clk_slow <= not(clk_slow);
--		end if;
--	end process;

fetch: FetchStage port map (
				new_branch_pc => new_branch_pc,
				new_branch_en => new_branch_en,
				
				computed_pc => computed_pc,
				computed_en => computed_en,
				
				current_pc => current_pc_in,
				current_pc_p1 => current_pc_p1_in,
				I1 => I1_in,
				I2 => I2_in,
				
				clk => clk,
				reset => reset
			);
			
I1_FD_pipeline: DataRegister port map(Din => I1_in, Dout => I1_out, enable => fd_pipeline_en, clk => clk, reset => reset);
I2_FD_pipeline: DataRegister port map(Din => I2_in, Dout => I2_out, enable => fd_pipeline_en, clk => clk, reset => reset);
PC_FD_pipeline: DataRegister port map(Din => pc_in, Dout => pc_out, enable => fd_pipeline_en, clk => clk, reset => reset);
PC_P1_FD_pipeline: DataRegister port map(Din => pc_p1_in, Dout => pc_p1_out, enable => fd_pipeline_en, clk => clk, reset => reset);

decode: DecodeStage port map (
				I1 => I1_out,
				I2 => I2_out,
				pc => pc_out,
				pc_p1 => pc_p1_out,
				
				new_branch_pc => new_branch_pc,
				new_branch_en => new_branch_en,
				
				LHI_imm1 => LHI_imm1_in,
				LHI_imm2 => LHI_imm2_in,
				imm1 => imm1_in,
				imm2 => imm2_in,
				LMSM_imm1 => LMSM_imm1_in,
				LMSM_imm2 => LMSM_imm2_in,
				
				draw1 => interdependency_in(0),
				draw2 => interdependency_in(1),
				dwaw => interdependency_in(2),
				fraw => interdependency_in(4 downto 3),
				fwaw => interdependency_in(6 downto 5)
			);
			
LHI_imm1_DDs_pipeline: DataRegister port map(Din => LHI_imm1_in, Dout => LHI_imm1_out, enable => dds_pipeline_en, clk => clk, reset => reset);
LHI_imm2_DDs_pipeline: DataRegister port map(Din => LHI_imm2_in, Dout => LHI_imm2_out, enable => dds_pipeline_en, clk => clk, reset => reset);
imm1_DDs_pipeline: DataRegister port map(Din => imm1_in, Dout => imm1_out, enable => dds_pipeline_en, clk => clk, reset => reset);
imm2_DDs_pipeline: DataRegister port map(Din => imm2_in, Dout => imm2_out, enable => dds_pipeline_en, clk => clk, reset => reset);
LMSM_imm1_DDs_pipeline: DataRegister port map(Din => LMSM_imm1_in, Dout => LMSM_imm1_out, enable => dds_pipeline_en, clk => clk, reset => reset);
LMSM_imm2_DDs_pipeline: DataRegister port map(Din => LMSM_imm2_in, Dout => LMSM_imm2_out, enable => dds_pipeline_en, clk => clk, reset => reset);
interdependency_DDs_pipeline: DataRegister port map(Din => interdependency_in, Dout => interdependency_out, enable => dds_pipeline_en, clk => clk, reset => reset);


end architecture;
