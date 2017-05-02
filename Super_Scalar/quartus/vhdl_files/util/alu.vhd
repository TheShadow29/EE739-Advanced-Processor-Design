library ieee ;
	use ieee.std_logic_1164.all ;
	use ieee.std_logic_unsigned.ALL;
    use ieee.numeric_std.all;
library work;
	use work.util_components.all;

--alu will implement add and nand functions depending on the opcode

entity alu is
	port
	(
		X, Y : in std_logic_vector(15 downto 0);
		out_p : out std_logic_vector(15 downto 0) := (others => '0');
		C, Z : out std_logic := '0';
		op_code : in std_logic;
		do_xor : in std_logic
	);
end alu;

architecture implementation of alu is 
	signal lsb , msb : std_logic;
	signal x16, y16, tmp0: std_logic_vector(16 downto 0) := (others => '0');
	signal tmp1, tmp2, sigout, xor_out : std_logic_vector(15 downto 0);
	
begin 
	--lsb <= op_code(0);
	--msb <= op_code(1);
	--ad_sub : EightBitAdd port map (A => X, B => Y, sel => lsb, Z => tmp1);
	--lef_rig : shifter port map (A => X, B => Y, left => lsb, Z => tmp2);
	x16(15 downto 0) <= X;
	y16(15 downto 0) <= Y;
	
	--adder1: Adder port map(x=>X,y=>Y,z=>tmp1,cin=>'0',cout=>C);
	tmp0 <= x16 + y16;
	C <= tmp0(16) and not(op_code);
	tmp1 <= tmp0(15 downto 0);
	tmp2 <= not(X and Y);
	
	Z <= not(sigout(0) or
			sigout(1) or
			sigout(2) or
			sigout(3) or
			sigout(4) or
			sigout(5) or
			sigout(6) or
			sigout(7) or
			sigout(8) or
			sigout(9) or
			sigout(10) or
			sigout(11) or
			sigout(12) or
			sigout(13) or
			sigout(14) or
			sigout(15));
	xor_out <= X xor Y;
	
	sigout <= xor_out when do_xor = '1' else
					tmp1  when op_code = '0' else
					tmp2;
	out_p <= sigout;
end architecture;
