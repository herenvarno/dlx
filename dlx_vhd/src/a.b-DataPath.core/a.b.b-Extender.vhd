--------------------------------------------------------------------------------
-- FILE: Extender
-- DESC: Extend a short size number to specific size.
--
-- Author:
-- Create: 2015-05-28
-- Update: 2015-06-10
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
		DEST_SIZE: integer := C_SYS_DATA_SIZE
	);
	port(
		s : in std_logic := '0';								-- signed extend?
		i : in std_logic_vector(SRC_SIZE-1 downto 0);
		o : out std_logic_vector(DEST_SIZE-1 downto 0)
	);
end Extender;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture extender_arch of Extender is
	signal ext_bit : std_logic := '0';
begin
	GE0: if DEST_SIZE <= SRC_SIZE generate
		o <= i(DEST_SIZE-1 downto 0);
	end generate;
	
	GE1: if DEST_SIZE > SRC_SIZE generate
		ext_bit <= s and i(SRC_SIZE-1);
		o(SRC_SIZE-1 downto 0) <= i;
		o(DEST_SIZE-1 downto SRC_SIZE) <= (others => ext_bit);
	end generate;
end extender_arch;
