library ieee ;
use ieee.std_logic_1164.all ;

library work;
use work.util_components.all;
use work.dispatch_components.all;

entity ArchitectureRegFile is
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
	signal En_data, En_tag, En_valid, 
	       r1d_decoded, r2d_decoded, 
			 sel_data, sel_tag,
			 r1_rob_decoded, r2_rob_decoded,
			 valid_t1, valid_t2: std_logic_vector(7 downto 0);
	
	signal v2o1_temp, v2o2_temp: std_logic;
	signal t2o1_temp, t2o2_temp: std_logic_vector(3 downto 0);
	
	signal t1_stored, t2_stored: std_logic_vector(3 downto 0);
begin
	ARF:
	for I in 0 to 7 generate
		ARFDataX: DataRegister port map (Dout=>RegData(I),Enable=>En_data(I),Din=>WriteData(I),clk=>clk, reset=>reset);
		ARFTagX:  DataRegister port map (Dout=>TagData(I),Enable=>En_tag(I),Din=>TagWriteData(I),clk=>clk,reset=>reset);
		ARFvalidX: DataRegister port map (Dout=>Valid(I),Enable=>En_valid(I),Din=>ValidNew(I),clk=>clk,reset=>reset);
	
		TagWriteData(I) <= t1d when sel_tag(I) = '0' else t2d;
		WriteData(I) <= data1_rob when sel_data(I) = '0' else data2_rob;
		ValidNew(I) <= (0 => (valid_t2(I) or valid_t1(I)) and not(En_tag(I)));
		
		-- tag_equal1(I) <= '1' when TagData(I) = t1_rob else '0';
		-- tag_equal2(I) <= '1' when TagData(I) = t2_rob else '0';
		
	end generate ARF;
	
	r1d_decoder: Decoder8 port map (A => R1d, OE => den1, O => r1d_decoded);
	r2d_decoder: Decoder8 port map (A => R2d, OE => den2, O => r2d_decoded);
	
	sel_tag <= r2d_decoded;
	En_tag <= r1d_decoded or r2d_decoded;
	
	r1_rob_decoder: Decoder8 port map (A => r1_rob, OE => wen1, O => r1_rob_decoded);
	r2_rob_decoder: Decoder8 port map (A => r2_rob, OE => wen2, O => r2_rob_decoded);
	
	sel_data <= r2_rob_decoded;
	En_data <= r1_rob_decoded or r2_rob_decoded;
	
	t1_stored <= TagData(0) when r1_rob = "000" else
			  TagData(1) when r1_rob = "001" else
			  TagData(2) when r1_rob = "010" else
			  TagData(3) when r1_rob = "011" else
			  TagData(4) when r1_rob = "100" else
			  TagData(5) when r1_rob = "101" else
			  TagData(6) when r1_rob = "110" else
			  TagData(7) when r1_rob = "111";
			  
	valid_t1 <= r1_rob_decoded when t1_rob = t1_stored else
					(others => '0');
			  
	t2_stored <= TagData(0) when r2_rob = "000" else
			  TagData(1) when r2_rob = "001" else
			  TagData(2) when r2_rob = "010" else
			  TagData(3) when r2_rob = "011" else
			  TagData(4) when r2_rob = "100" else
			  TagData(5) when r2_rob = "101" else
			  TagData(6) when r2_rob = "110" else
			  TagData(7) when r2_rob = "111";
			  
	valid_t2 <= r2_rob_decoded when t2_rob = t2_stored else
					(others => '0');
	
	En_valid <= valid_t1 or valid_t2 or En_tag;
	
	
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
			  
	v2o1_temp <= Valid(0)(0) when R2o1 = "000" else
			  Valid(1)(0) when R2o1 = "001" else
			  Valid(2)(0) when R2o1 = "010" else
			  Valid(3)(0) when R2o1 = "011" else
			  Valid(4)(0) when R2o1 = "100" else
			  Valid(5)(0) when R2o1 = "101" else
			  Valid(6)(0) when R2o1 = "110" else
			  Valid(7)(0) when R2o1 = "111";
			  
	v2o1 <= v2o1_temp and not(draw1);
			  
	v2o2_temp <= Valid(0)(0) when R2o2 = "000" else
			  Valid(1)(0) when R2o2 = "001" else
			  Valid(2)(0) when R2o2 = "010" else
			  Valid(3)(0) when R2o2 = "011" else
			  Valid(4)(0) when R2o2 = "100" else
			  Valid(5)(0) when R2o2 = "101" else
			  Valid(6)(0) when R2o2 = "110" else
			  Valid(7)(0) when R2o2 = "111";
			  
	v2o2 <= v2o2_temp and not(draw2);
			  
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
			  
	t2o1_temp <= TagData(0) when R2o1 = "000" else
			  TagData(1) when R2o1 = "001" else
			  TagData(2) when R2o1 = "010" else
			  TagData(3) when R2o1 = "011" else
			  TagData(4) when R2o1 = "100" else
			  TagData(5) when R2o1 = "101" else
			  TagData(6) when R2o1 = "110" else
			  TagData(7) when R2o1 = "111";
			  
	t2o1 <= t2o1_temp when draw1 = '0' else
	        t1d;
			  
	t2o2_temp <= TagData(0) when R2o2 = "000" else
			  TagData(1) when R2o2 = "001" else
			  TagData(2) when R2o2 = "010" else
			  TagData(3) when R2o2 = "011" else
			  TagData(4) when R2o2 = "100" else
			  TagData(5) when R2o2 = "101" else
			  TagData(6) when R2o2 = "110" else
			  TagData(7) when R2o2 = "111";
			  
	t2o2 <= t2o2_temp when draw2 = '0' else
	        t1d;
			  
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