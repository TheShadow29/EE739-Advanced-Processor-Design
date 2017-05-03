library ieee ;
use ieee.std_logic_1164.all ;
library work;

package dispatch_components is
	component ArchitectureRegFile is
		port (
				-- I1 I2 operands
				R1o1, R1o2, R2o1, R2o2,
				-- I1 I2 destination, destination enable and empty tags
				R1d, R2d: in std_logic_vector(2 downto 0);
				den1, den2: in std_logic;
				t1d, t2d: in std_logic_vector(3 downto 0);
				
				draw1, draw2, dwaw: in std_logic;
				
				-- From ROB
				r1_rob, r2_rob: in std_logic_vector(2 downto 0);
				wen1, wen2: in std_logic;
				t1_rob, t2_rob: in std_logic_vector(3 downto 0);
				data1_rob, data2_rob: in std_logic_vector(15 downto 0);
				
				v1o1, v1o2, v2o1, v2o2 : out std_logic;
				t1o1, t1o2, t2o1, t2o2 : out std_logic_vector(3 downto 0);
				d1o1, d1o2, d2o1, d2o2 : out std_logic_vector(15 downto 0);
				
				clk, reset: in std_logic
		);
	end component;
end package;