--------------------------------------------------------------------------------
-- FILE: BoothGenerator
-- DESC: Generator of Booth's Multiplier
--
-- Author:
-- Create: 2015-08-14
-- Update: 2015-08-14
-- Status: TESED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity BoothGenerator is
	generic(
		DATA_SIZE : integer := C_SYS_DATA_SIZE/2;
		STAGE : integer := C_MUL_STAGE
	);
	port(
		a: in std_logic_vector(DATA_SIZE*2-1 downto 0);
		ya, y2a: out std_logic_vector(DATA_SIZE*2-1 downto 0)
	);
end BoothGenerator;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture booth_generator_arch of BoothGenerator is
begin
	-- a
	ya(DATA_SIZE*2-1 downto STAGE*2) <= a(DATA_SIZE*2-STAGE*2-1 downto 0);
	ya(STAGE*2-1 downto 0) <= (others=>'0');

	-- 2a
	y2a(DATA_SIZE*2-1 downto STAGE*2+1) <= a(DATA_SIZE*2-STAGE*2-2 downto 0);
	y2a(STAGE*2 downto 0) <= (others=>'0');
end booth_generator_arch;
