--------------------------------------------------------------------------------
-- FILE: Extender
-- DESC: Extend a short size number to specific size.
--
-- Author:
-- Create: 2015-05-28
-- Update: 2015-05-30
-- Status: TESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Extender is
	generic(
		SRC_SIZE : integer := 1;
		DEST_SIZE: integer := C_SYS_DATA_SIZE;
		METHOD : std_logic := '0'				-- 0 for "Extend with 0s", 1 for "Extend with MSB" 
	);
	port(
		i : in std_logic_vector(SRC_SIZE-1 downto 0);
		o : out std_logic_vector(DEST_SIZE-1 downto 0)
	);
end Extender;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture extender_arch of Extender is
begin
	GE0: if DEST_SIZE <= SRC_SIZE generate
		o <= i(DEST_SIZE-1 downto 0);
	end generate;
	
	GE1: if DEST_SIZE > SRC_SIZE generate
		o(SRC_SIZE-1 downto 0) <= i;
		GE10: if METHOD = '0' generate
			o(DEST_SIZE-1 downto SRC_SIZE) <= (others => '0');
		end generate;
		GE11: if METHOD = '1' generate
			o(DEST_SIZE-1 downto SRC_SIZE) <= (others => i(SRC_SIZE-1));
		end generate;
	end generate;
end extender_arch;
