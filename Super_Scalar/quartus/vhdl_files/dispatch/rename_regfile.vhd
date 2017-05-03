library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all;

library work;
use work.util_components.all;
use work.dispatch_components.all;

entity RenameRegFile is
	port (
		t1_rob, t2_rob : in std_logic_vector(3 downto 0);
		data1_rob, data2_rob: out std_logic_vector(15 downto 0);
		del1, del2: in std_logic;
		
		t1_exec, t2_exec, t3_exec: in std_logic_vector(3 downto 0);
		data1_exec, data2_exec, data3_exec: in std_logic_vector(15 downto 0);
		wen1, wen2, wen3: in std_logic;
		
		den1, den2: in std_logic;
		t1d, t2d: out std_logic_vector(3 downto 0);
		
		clk, reset: in std_logic
	);
end entity;

architecture Behave of RenameRegFile is
	type RegArray is array (natural range <>) of std_logic_vector(15 downto 0);
	type ValidArray is array (natural range <>) of std_logic_vector(0 downto 0);
	
	signal RegData, WriteData: RegArray(15 downto 0);
	signal Valid, ValidNew: ValidArray(15 downto 0);
	
	signal En_data, En_valid, sel1_data, sel2_data, sel3_data: std_logic_vector(15 downto 0);
begin

	RRF:
	for I in 0 to 15 generate
		RRFDataX: DataRegister port map (Dout=>RegData(I),Enable=>En_data(I),Din=>WriteData(I),clk=>clk, reset=>reset);
		RRFvalidX: DataRegister port map (Dout=>Valid(I),Enable=>En_valid(I),Din=>ValidNew(I),clk=>clk,reset=>reset);

		WriteData(I) <= data3_exec when sel3_exec(I) = '1' else
							 data2_exec when sel2_exec(I) = '1' else
							 data1_exec;
	end generate RRF;

	data1_rob <= RegData(to_integer(unsigned(t1_rob)));
	data2_rob <= RegData(to_integer(unsigned(t2_rob)));
	
	sel1_decode: Decode16 port map(A=>t1_exec, O=>sel1_data, OE=>wen1);
	sel2_decode: Decode16 port map(A=>t2_exec, O=>sel2_data, OE=>wen2);
	sel3_decode: Decode16 port map(A=>t3_exec, O=>sel3_data, OE=>wen3);
	
	En_data <= sel1_data or sel2_data or sel3_data;
	
end architecture;