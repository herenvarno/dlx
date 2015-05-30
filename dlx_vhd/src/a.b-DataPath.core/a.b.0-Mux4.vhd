--------------------------------------------------------------------------------
-- FILE: Mux4
-- DESC: 4 inputs 1 output multiplexer
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
entity Mux4 is
	generic(
		DATA_SIZE: integer := C_SYS_DATA_SIZE
	);
	port(
		sel: in std_logic_vector(1 downto 0);
		din0: in std_logic_vector(DATA_SIZE-1 downto 0);
		din1: in std_logic_vector(DATA_SIZE-1 downto 0);
		din2: in std_logic_vector(DATA_SIZE-1 downto 0);
		din3: in std_logic_vector(DATA_SIZE-1 downto 0);
		dout: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end Mux4;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture mux4_arch of Mux4 is
begin
	dout <= din0 when sel="00" else
			din1 when sel="01" else
			din2 when sel="10" else
			din3 when sel="11";
end mux4_arch;
