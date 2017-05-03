library ieee ;
use ieee.std_logic_1164.all ;

library work;
use work.util_components.all;
use work.dispatch_components.all;

entity ArchitectureRegFile is
	port (
			R1o1, R1o2, R2o1, R2o2,
			R1d, R2d: in std_logic_vector(2 downto 0);
			t1d, t2d: in std_logic_vector(3 downto 0);
			
			draw1, draw2, dwaw: in std_logic;
			
			v1o1, v1o2, v2o1, v2o2 : out std_logic;
			t1o1, t1o2, t2o1, t2o2 : out std_logic_vector(3 downto 0);
			d1o1, d1o2, d2o1, d2o2 : out std_logic_vector(15 downto 0);
			
			clk, reset: in std_logic
	);
end entity;

architecture Behaviour of ArchitectureRegFile is
   -- bit 20 : valid bit
	-- bits 19 downto 16: tag
	-- bits 15 downto 0: data
	type RegArray is array (natural range <>) of std_logic_vector(15 downto 0);
	type TagArray is array (natural range <>) of std_logic_vector(3 downto 0);
	type ValidArray is array (natural range <>) of std_logic_vector(0 downto 0);

	signal RegData, WriteData: RegArray(7 downto 0);
	signal TagData, TagWriteData: TagArray(7 downto 0);
	signal Valid, ValidNew: ValidArray(7 downto 0);
	signal En_data, En_tag, En_valid, sel: std_logic_vector(7 downto 0);
begin
	ARF:
	for I in 0 to 7 generate
		ARFDataX: DataRegister port map (Dout=>RegData(I),Enable=>En_data(I),Din=>WriteData(I),clk=>clk, reset=>reset);
		ARFTagX:  DataRegister port map (Dout=>TagData(I),Enable=>En_tag(I),Din=>TagWriteData(I),clk=>clk,reset=>reset);
		ARFvalidX: DataRegister port map (Dout=>Valid(I),Enable=>En_valid(I),Din=>ValidNew(I),clk=>clk,reset=>reset);		
	end generate ARF;
	
	v1o1 <= Valid(0)(0) when R1o1 = "000" else
			  Valid(1)(0) when R1o1 = "001" else
			  Valid(2)(0) when R1o1 = "010" else
			  Valid(3)(0) when R1o1 = "011" else
			  Valid(4)(0) when R1o1 = "100" else
			  Valid(5)(0) when R1o1 = "101" else
			  Valid(6)(0) when R1o1 = "110" else
			  Valid(7)(0) when R1o1 = "111";
			  
	v1o2 <= Valid(0)(0) when R1o2 = "000" else
			  Valid(1)(0) when R1o2 = "001" else
			  Valid(2)(0) when R1o2 = "010" else
			  Valid(3)(0) when R1o2 = "011" else
			  Valid(4)(0) when R1o2 = "100" else
			  Valid(5)(0) when R1o2 = "101" else
			  Valid(6)(0) when R1o2 = "110" else
			  Valid(7)(0) when R1o2 = "111";
			  
	v2o1 <= Valid(0)(0) when R2o1 = "000" else
			  Valid(1)(0) when R2o1 = "001" else
			  Valid(2)(0) when R2o1 = "010" else
			  Valid(3)(0) when R2o1 = "011" else
			  Valid(4)(0) when R2o1 = "100" else
			  Valid(5)(0) when R2o1 = "101" else
			  Valid(6)(0) when R2o1 = "110" else
			  Valid(7)(0) when R2o1 = "111";
			  
	v2o2 <= Valid(0)(0) when R2o2 = "000" else
			  Valid(1)(0) when R2o2 = "001" else
			  Valid(2)(0) when R2o2 = "010" else
			  Valid(3)(0) when R2o2 = "011" else
			  Valid(4)(0) when R2o2 = "100" else
			  Valid(5)(0) when R2o2 = "101" else
			  Valid(6)(0) when R2o2 = "110" else
			  Valid(7)(0) when R2o2 = "111";
			  
	t1o1 <= TagData(0) when R1o1 = "000" else
			  TagData(1) when R1o1 = "001" else
			  TagData(2) when R1o1 = "010" else
			  TagData(3) when R1o1 = "011" else
			  TagData(4) when R1o1 = "100" else
			  TagData(5) when R1o1 = "101" else
			  TagData(6) when R1o1 = "110" else
			  TagData(7) when R1o1 = "111";
			  
	t1o2 <= TagData(0) when R1o2 = "000" else
			  TagData(1) when R1o2 = "001" else
			  TagData(2) when R1o2 = "010" else
			  TagData(3) when R1o2 = "011" else
			  TagData(4) when R1o2 = "100" else
			  TagData(5) when R1o2 = "101" else
			  TagData(6) when R1o2 = "110" else
			  TagData(7) when R1o2 = "111";
			  
	t2o1 <= TagData(0) when R2o1 = "000" else
			  TagData(1) when R2o1 = "001" else
			  TagData(2) when R2o1 = "010" else
			  TagData(3) when R2o1 = "011" else
			  TagData(4) when R2o1 = "100" else
			  TagData(5) when R2o1 = "101" else
			  TagData(6) when R2o1 = "110" else
			  TagData(7) when R2o1 = "111";
			  
	t2o2 <= TagData(0) when R2o2 = "000" else
			  TagData(1) when R2o2 = "001" else
			  TagData(2) when R2o2 = "010" else
			  TagData(3) when R2o2 = "011" else
			  TagData(4) when R2o2 = "100" else
			  TagData(5) when R2o2 = "101" else
			  TagData(6) when R2o2 = "110" else
			  TagData(7) when R2o2 = "111";
			  
	d1o1 <= RegData(0) when R1o1 = "000" else
			  RegData(1) when R1o1 = "001" else
			  RegData(2) when R1o1 = "010" else
			  RegData(3) when R1o1 = "011" else
			  RegData(4) when R1o1 = "100" else
			  RegData(5) when R1o1 = "101" else
			  RegData(6) when R1o1 = "110" else
			  RegData(7) when R1o1 = "111";
			  
	d1o2 <= RegData(0) when R1o2 = "000" else
			  RegData(1) when R1o2 = "001" else
			  RegData(2) when R1o2 = "010" else
			  RegData(3) when R1o2 = "011" else
			  RegData(4) when R1o2 = "100" else
			  RegData(5) when R1o2 = "101" else
			  RegData(6) when R1o2 = "110" else
			  RegData(7) when R1o2 = "111";
			  
	d2o1 <= RegData(0) when R2o1 = "000" else
			  RegData(1) when R2o1 = "001" else
			  RegData(2) when R2o1 = "010" else
			  RegData(3) when R2o1 = "011" else
			  RegData(4) when R2o1 = "100" else
			  RegData(5) when R2o1 = "101" else
			  RegData(6) when R2o1 = "110" else
			  RegData(7) when R2o1 = "111";
			  
	d2o2 <= RegData(0) when R2o2 = "000" else
			  RegData(1) when R2o2 = "001" else
			  RegData(2) when R2o2 = "010" else
			  RegData(3) when R2o2 = "011" else
			  RegData(4) when R2o2 = "100" else
			  RegData(5) when R2o2 = "101" else
			  RegData(6) when R2o2 = "110" else
			  RegData(7) when R2o2 = "111";
			  
	
	
--	PCen <= R7upd or En(7);
--	PC_register: DataRegister port map (Dout=>R(7),Enable=>PCen,Din=>WriteDataPC,clk=>clk, reset=>reset);

end architecture;