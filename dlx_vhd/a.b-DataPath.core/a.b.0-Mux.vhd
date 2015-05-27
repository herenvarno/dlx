--------------------------------------------------------------------------------
-- FILE: Mux -- Multiplexer
-- DESC: 2 inputs 1 output multiplexer
--
-- Author:
-- Create: 2015-05-27
-- Update: 2015-05-27
-- Status: UNTESTED
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Consts.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------
entity Mux is
	generic(
		DATA_SIZE: integer := C_SYS_DATA_SIZE
	);
	port(
		sel: in std_logic;
		din0: in std_logic_vector(DATA_SIZE-1 downto 0);
		din1: in std_logic_vector(DATA_SIZE-1 downto 0);
		dout: out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end Mux;

--------------------------------------------------------------------------------
-- ARCHITECTURE
--------------------------------------------------------------------------------
architecture mux_arch of Mux is
begin
	dout <= din0 when sel='0' else din1;
end mux_arch;
