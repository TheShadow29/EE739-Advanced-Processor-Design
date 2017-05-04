library ieee ;
use ieee.std_logic_1164.all ;
library work;

package util_components is
	component unary_AND IS
		 generic (N: positive := 8); --array size
		 port (
			  inp: in std_logic_vector(N-1 downto 0);
			  outp: out std_logic);
	end component;
	
	component unary_OR IS
		 generic (N: positive := 8); --array size
		 port (
			  inp: in std_logic_vector(N-1 downto 0);
			  outp: out std_logic);
	end component;
	
	component PriorityEncoder is
		port ( x : in std_logic_vector(7 downto 0) ;
				 S : out std_logic_vector(2 downto 0);
				 N : out std_logic;
				 Tn: out std_logic_vector(7 downto 0)
			) ;
	end component ;
	
	component DataRegister is
		--n bit register
		port (Din: in std_logic_vector;
				Dout: out std_logic_vector;
				clk, enable, reset: in std_logic);
	end component;
	
--	component PipelineDataRegister is
--		--n bit register
--		port (Din: in std_logic_vector;
--				Dout: out std_logic_vector;
--				clk, enable, reset: in std_logic);
--	end component;
--	
	component alu is
		port
		(
			X, Y : in std_logic_vector(15 downto 0);
			out_p : out std_logic_vector(15 downto 0) := (others => '0');
			C, Z : out std_logic := '0';
			op_code : in std_logic;
			do_xor : in std_logic
		);
	end component;
	
--	component FullAdder is
--		 -- x, y -> input bits
--		 -- ci   -> carry in
--		 -- s    -> sum
--		 -- co   -> carry out
--		 port(
--			  x, y, ci: in std_logic;
--			  s, co: out std_logic
--		 );
--	end component;
--	
--	component Adder is
--		 -- cin    -> carry in
--		 -- x, y   -> 8 bit inputs
--		 -- z      -> sum output
--		 -- cout   -> carry out
--		 port(
--			  x, y: in std_logic_vector(15 downto 0);
--			  z: out std_logic_vector(15 downto 0) := (others => '0')
--		 );
--	end component;
--	
--	component Incrementer is
--		 port(
--			  x: in std_logic_vector(15 downto 0);
--			  z: out std_logic_vector(15 downto 0) := (others => '0')
--		 );
--	end component;
	
	component Decoder8 is
		port (
			A: in std_logic_vector(2 downto 0);
			OE: in std_logic;
			O: out std_logic_vector(7 downto 0)
		);
	end component;
	
	component Decoder16 is
		port (
			A: in std_logic_vector(3 downto 0);
			OE: in std_logic;
			O: out std_logic_vector(15 downto 0)
		);
	end component;
	
	component Queue is
		generic
		(
			--For RRF Queue, word_len = 4, 
			word_len : in integer;
			num_words : in integer;
			head_p_bits : in integer
		);
		port 
		(
			head_reg_out : out std_logic_vector  := (others => '0');
			head2_reg_out : out std_logic_vector := (others => '0');
	--		head_num_out : in std_logic_vector;
			tail_reg_in : in std_logic_vector  := (others => '0');
			tail2_reg_in : in std_logic_vector := (others => '0');
			tail_en : in std_logic_vector(1 downto 0) := (others => '0');--00, 01 or 10
			head_en : in std_logic_vector(1 downto 0) := (others => '0');--00, 01 or 10
			
			not_empty : out std_logic;
			clk, reset : in std_logic
		);
	end component;
end util_components;
