library ieee;
	use ieee.std_logic_1164.all;
library work;
	use work.util_components.all;

entity FullAdder is
    -- x, y -> input bits
    -- ci   -> carry in
    -- s    -> sum
    -- co   -> carry out
    port(
        x, y, ci: in std_logic;
        s, co: out std_logic
    );
end entity;
architecture Behave of FullAdder is
    signal w, z: std_logic;
begin
    -- w <= x xor y
    w <= ((not x) and y) or (x and (not y));
    -- s <= w xor ci
    s <= ((not w) and ci) or (w and (not ci));
    co <= (x and y) or ((x or y) and ci);
end Behave;

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.std_logic_unsigned.ALL;
   use ieee.numeric_std.all;
library work;
	use work.util_components.all;

entity Adder is
    -- cin    -> carry in
    -- x, y   -> 8 bit inputs
    -- z      -> sum output
    -- cout   -> carry out
    port(
        x, y: in std_logic_vector(15 downto 0);
        z: out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;
architecture Behave of Adder is
begin
	z <= x + y;
end Behave;

library ieee;
	use ieee.std_logic_1164.all;
library work;
	use work.util_components.all;
	use ieee.std_logic_unsigned.ALL;
   use ieee.numeric_std.all;

entity Incrementer is
    port(
        x: in std_logic_vector(15 downto 0);
        z: out std_logic_vector(15 downto 0) := (others => '0')
    );
end entity;
architecture Behave of Incrementer is
    -- z=x+1
	 constant one_16b : std_logic_vector(15 downto 0) := (0 => '1', others => '0');
begin
    z <= x + one_16b;
end Behave;

--library ieee;
--	use ieee.std_logic_1164.all;
--library work;
--	use work.all_components.all;
--	use ieee.std_logic_unsigned.ALL;
--   use ieee.numeric_std.all;
--
--entity Incrementer3 is
--    port(
--        x: in std_logic_vector(2 downto 0);
--        z: out std_logic_vector(2 downto 0) := (others => '0')
--    );
--end entity;
--architecture Behave of Incrementer3 is
--    -- z=x+1
--	 constant one_16b : std_logic_vector(2 downto 0) := (0 => '1', others => '0');
--begin
--    z <= x + one_16b;
--end Behave;